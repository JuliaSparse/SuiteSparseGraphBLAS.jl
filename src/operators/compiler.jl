module OperatorCompiler
using GPUCompiler, LLVM, StaticTools
using StaticTools: @c_str
import Clang_jll

fixname(f::Function) = fixname(string(nameof(f)))
fixname(s) = String(GPUCompiler.safe_name(s))

function llvmmodule(@nospecialize(f), @nospecialize(tt), name = "jl" * fixname(f))
    job = operatorjob(f, f, tt; name)
    GPUCompiler.JuliaContext() do ctx
        GPUCompiler.codegen(:llvm, job; strip=true, validate=false)
    end
end

function compiler(job)
    return GPUCompiler.JuliaContext() do ctx
        GPUCompiler.codegen(:llvm, job; strip=true, validate=false)
    end
    return mod
end

# Overrides, Runtime and Targets

# Exception Overrides
#####################

libcexit(x::Int32) = Base.llvmcall(("declare void @exit(i32)\n\ndefine void @main(i32 %A) #0 {\n  \n  call void (i32) @exit(i32 %A)\n  ret void\n}\nattributes #0 = { alwaysinline nounwind ssp uwtable }\n", "main"), Nothing, Tuple{Int32}, x)
macro print_and_throw(err)
    quote
        println($err)
        libcexit(Int32(1))
    end
end

Base.Experimental.@MethodTable(operatortable)

Base.Experimental.@overlay operatortable (@noinline Base.Math.throw_complex_domainerror(f::Symbol, x) =
    @print_and_throw c"This operation requires a complex input to return a complex result")
Base.Experimental.@overlay operatortable (@noinline Base.Math.throw_exp_domainerror(f::Symbol, x) =
    @print_and_throw c"Exponentiation yielding a complex result requires a complex argument")
Base.Experimental.@overlay operatortable (@noinline Base.throw_domerr_powbysq(::Any, p) =
    @print_and_throw c"Cannot raise an integer to a negative power")
Base.Experimental.@overlay operatortable (@noinline Base.throw_domerr_powbysq(::Integer, p) =
    @print_and_throw c"Cannot raise an integer to a negative power")
Base.Experimental.@overlay operatortable (@noinline Base.throw_domerr_powbysq(::AbstractMatrix, p) =
    @print_and_throw c"Cannot raise an integer to a negative power")
Base.Experimental.@overlay operatortable (@noinline Base.__throw_gcd_overflow(a, b) =
    @print_and_throw c"gcd overflow")
Base.Experimental.@overlay operatortable (@noinline Base.Checked.throw_overflowerr_binaryop(op, x, y) =
    @print_and_throw c"Binary operation overflowed")
Base.Experimental.@overlay operatortable (@noinline Base.Checked.throw_overflowerr_negation(op, x, y) =
    @print_and_throw c"Negation overflowed")
Base.Experimental.@overlay operatortable @noinline Core.throw_inexacterror(f::Symbol, ::Type{T}, val) where {T} =
    @print_and_throw c"Inexact conversion"
Base.Experimental.@overlay operatortable (@noinline Base.throw_boundserror(A, I) =
    @print_and_throw c"Out-of-bounds array access")
Base.Experimental.@overlay operatortable (@noinline Base.Math.sincos_domain_error(x) =
    @print_and_throw c"sincos(x) is only defined for finite x.")
Base.Experimental.@overlay operatortable (function Base.Checked.checked_abs(x::Base.Checked.SignedInt)
    r = ifelse(x < 0, -x, x)
    r < 0 && @print_and_throw(c"checked arithmetic: cannot compute |x|")
    r
end)
Base.Experimental.@overlay operatortable (@noinline Base.Math.sin_domain_error(x::Float64) = @print_and_throw c"sin domain error")
Base.Experimental.@overlay operatortable (@noinline Base.Math.cos_domain_error(x::Float64) = @print_and_throw c"cos domain error")


# Targets and Runtime
#####################

Base.@kwdef struct BitcodeCompilerTarget <: GPUCompiler.AbstractCompilerTarget
    triple::String = readchomp(`$(Clang_jll.clang) --print-effective-triple`)
    cpu::String=(LLVM.version() < v"8") ? "" : unsafe_string(LLVM.API.LLVMGetHostCPUName())
    features::String=(LLVM.version() < v"8") ? "" : unsafe_string(LLVM.API.LLVMGetHostCPUFeatures())
end
module OperatorRuntime
    # the runtime library
    signal_exception() = return
    malloc(sz) = ccall("extern malloc", llvmcall, Csize_t, (Csize_t,), sz)
    report_oom(sz) = return
    report_exception(ex) = return
    report_exception_name(ex) = return
    report_exception_frame(idx, func, file, line) = return
end
GPUCompiler.llvm_triple(target::BitcodeCompilerTarget) = target.triple
GPUCompiler.runtime_module(::GPUCompiler.CompilerJob{BitcodeCompilerTarget}) = OperatorRuntime
GPUCompiler.can_throw(job::GPUCompiler.CompilerJob{BitcodeCompilerTarget}) = true

GPUCompiler.method_table(::CompilerJob{BitcodeCompilerTarget}) = operatortable
GPUCompiler.runtime_slug(job::CompilerJob{BitcodeCompilerTarget}) = "bitcode_$(job.config.target.cpu)-$(hash(job.config.target.features))"

struct OperatorCompilerParams{F, F2} <: AbstractCompilerParams
    # parameters needed to create the typedops
    fn::F
    c_fn::F2
    intypes::Any
end


function operatorjob(@nospecialize(f), @nospecialize(f2), @nospecialize(tt); target=BitcodeCompilerTarget(), name = nothing)
    T = Base.to_tuple_type(tt)
    source = GPUCompiler.methodinstance(typeof(f2), T)
    config = CompilerConfig(
        target, 
        OperatorCompilerParams(f, f2, tt); 
        name, always_inline=true, kernel=false
    )
    return CompilerJob(source, config)
end

function optimize!(mod::LLVM.Module)

end
end
