compilation_enabled::Bool = true

module OperatorCompiler
using GPUCompiler, LLVM, StaticTools
using StaticTools: @c_str
import Clang_jll, LLVM_jll, CompilerSupportLibraries_jll, LLD_jll
using Scratch
import ..GrB
import ..GrB: set!, Global

gbscratch::String = ""
irscratch::String = ""
clangtriple = LLVM.triple()

function cached_compile(cache, job, linker)
    return GPUCompiler.cached_compilation(
        cache, job.source, job.config,
        compiler, linker
    )
end

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

# helper function for operator specific linker functions.
function writeir(compiled)
    ir, meta = compiled
    LLVM.triple!(ir, clangtriple)
    path = joinpath(irscratch, "$(hash(ir)).o")
    write(path, ir)
    return path, LLVM.name(meta[:entry])
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
Base.Experimental.@overlay operatortable @noinline Base.throw(::InexactError) =
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
    triple::String = LLVM.triple()
    cpu::String=(LLVM.version() < v"8") ? "" : unsafe_string(LLVM.API.LLVMGetHostCPUName())
    features::String=(LLVM.version() < v"8") ? "" : unsafe_string(LLVM.API.LLVMGetHostCPUFeatures())
end
module OperatorRuntime
    using ..OperatorCompiler: libcexit, @print_and_throw
    # the runtime library
    signal_exception() = return
    malloc(sz) = ccall("extern malloc", llvmcall, Csize_t, (Csize_t,), sz)
    report_oom(sz) = @print_and_throw c"Out of memory"
    report_exception(ex) = @print_and_throw c"Exception thrown"
    report_exception_name(ex) = return
    report_exception_frame(idx, func, file, line) = return
end
GPUCompiler.llvm_triple(target::BitcodeCompilerTarget) = target.triple
GPUCompiler.runtime_module(::GPUCompiler.CompilerJob{BitcodeCompilerTarget}) = OperatorRuntime
GPUCompiler.can_throw(job::GPUCompiler.CompilerJob{BitcodeCompilerTarget}) = false

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

function initcompiler()
    global gbscratch = @get_scratch!("gbscratch")
    delete_scratch!("irscratch")
    global irscratch = @get_scratch!("irscratch")
    set!(Global(), :jit_cache, gbscratch)

    @static if Sys.iswindows() # Windows compilation requires CMake, TODO
        return disablecompilation()
    end

    llvmdir = joinpath(LLVM_jll.artifact_dir, "lib")
    @static if Sys.isapple()
        # Clang does funky things with the macOS
        originalstderr = stderr
        (rd, wr) = redirect_stderr()
        run(`$(Clang_jll.clang()) -xc - -\#\#\#`)
        close(wr)
        redirect_stderr(originalstderr)
        m = match(r"[a-z0-9_]+-apple-macosx[0-9]+\.[0-9]+\.[0-9]+", read(rd, String))
        if m !== nothing
            global clangtriple = m.match
        end
        sysroot = joinpath(readchomp(`xcode-select -p`), "SDKs/MacOSX.sdk")
        if isdir(sysroot)
            compilerflags = "-isysroot $(sysroot)"
            linkerflags = "-dynamiclib"
        else
            return disablecompilation()
        end
    end
    set!(Global(), :jit_compilername, "DYLD_FALLBACK_LIBRARY_PATH=$(llvmdir):$(Clang_jll.LIBPATH[]) $(Clang_jll.get_clang_path())")
    set!(Global(), :jit_compilerflags, "-O3 -DNDEBUG -fopenmp=libomp -fPIC -flto  -Wno-incompatible-pointer-types-discards-qualifiers $compilerflags")
    set!(Global(), :jit_linkerflags, "--ld-path=\"$(createlldsymlinks())\" -lm -ldl -L$(joinpath(CompilerSupportLibraries_jll.find_artifact_dir(), "lib")) $linkerflags")
end

function createlldsymlinks()
    @static if Sys.isapple() || Sys.islinux()
        path = joinpath(irscratch, "ld64.lld")
        run(`ln -s $(LLD_jll.lld_path) $path`)
    else
        path = nothing
    end
    return path
end

function disablecompilation()
    @warn "JIT Kernel Compilation is disabled for SuiteSparse:GraphBLAS"
    set!(Global(), :jit_c_control, 0)
    GrB.compilation_enabled = false
    return nothing
end
function enablecompilation()
    @warn "JIT Kernel Compilation is enabled for SuiteSparse:GraphBLAS"
    set!(Global(), :jit_c_control, 4)
    GrB.compilation_enabled = true
    return nothing
end

end
