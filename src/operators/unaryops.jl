module UnaryOps

import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, nBtypes, Ntypes, Ttypes, suffix,
    GBArrayOrTranspose, AbstractTypedOp, @wraperror, load_global, OperatorCompiler, gbset!, irscratch
using ..LibGraphBLAS
using GPUCompiler
import LLVM
export unaryop, @unop

export rowindex, colindex, frexpx, frexpe

using SpecialFunctions

mutable struct TypedUnaryOperator{F, F2, X, Z} <: AbstractTypedOp{Z}
    const builtin::Bool
    loaded::Bool
    const typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    p::LibGraphBLAS.GrB_UnaryOp
    fn::F
    c_fn::F2
    docompilation::Bool
    codeinstance::Any
    function TypedUnaryOperator{F, X, Z}(builtin, loaded, typestr, p, fn, c_fn = nothing; docompilation = false, ir = nothing) where {F, X, Z}
        unop = new{F, typeof(c_fn), X, Z}(builtin, loaded, typestr, p, fn, c_fn, docompilation, ir)
        return finalizer(unop) do op
            @wraperror LibGraphBLAS.GrB_UnaryOp_free(Ref(op.p))
        end
    end
end

function (op::TypedUnaryOperator{F, X, Z})(::Type{T}) where {F, X, Z, T}
    return op
end

function TypedUnaryOperator(fn::F, ::Type{X}, ::Type{Z}) where {F, X, Z}
    return TypedUnaryOperator{F, X, Z}(false, false, string(fn), LibGraphBLAS.GrB_UnaryOp(), fn)
end

function TypedUnaryOperator(fn::F, ::Type{X}) where {F, X}
    return TypedUnaryOperator(fn, X, Broadcast.combine_eltypes(fn, (X,)))
end

@generated function cunary(f::F, ::Type{X}, ::Type{Z}) where {F, X, Z}
    if Base.issingletontype(F)
        :(@cfunction($(F.instance), Cvoid, (Ptr{Z}, Ptr{X})))
    else
       throw("Unsupported function $f. Closure functions are not supported.")
    end
end

function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_UnaryOp}, op::TypedUnaryOperator{F, F2, X, Z}) where {F, F2, X, Z}
    # We can lazily load the built-ins since they are already constants. 
    # Could potentially do this with UDFs, but probably not worth the effort.
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, LibGraphBLAS.GrB_UnaryOp)
        else
            opref = Ref{LibGraphBLAS.GrB_UnaryOp}()
            unaryopfn_C = cunary(op.c_fn, X, Z)
            # the "" below is a placeholder for C code in the future for JIT'ing. (And maybe compiled code as a ptr :pray:?)
            name = op.docompilation ? op.typestr : C_NULL
            defn = op.docompilation ? "GB_ISOBJ $(op.codeinstance)" : C_NULL
            LibGraphBLAS.GxB_UnaryOp_new(opref, unaryopfn_C, gbtype(Z), gbtype(X), name, defn)
            op.p = opref[]
        end
        op.loaded = true
        !op.builtin && gbset!(op, :name, string(op.fn))
    end
    if !op.loaded
        error("This operator $(op.fn) could not be loaded, and is invalid.")
    else
        return op.p
    end
end

const UNARYOPS = Dict()
const COMPILEDUNARYOPS = Dict()
const BUILTINUNARYOPS = Dict{<:Any, <:Any}() # (f) -> name, inputtypes

function linker(job, compiled)
    ir, meta = compiled
    (; fn, c_fn, intypes) = job.config.params
    write(joinpath(irscratch, "$(hash(ir)).o"), ir)
    return TypedUnaryOperator{typeof(fn), eltype(intypes[2]), eltype(intypes[1])}(
        false, false, LLVM.name(meta[:entry]), LibGraphBLAS.GrB_UnaryOp(), fn, c_fn; docompilation = true, ir = joinpath(irscratch, "$(hash(ir)).o")
    )
end

function unarycachecompile(f, ptrfunction, ::Type{T}) where T
    O = Base.Broadcast.combine_eltypes(f, (T,))
    job = OperatorCompiler.operatorjob(f, ptrfunction, (Ptr{O}, Ptr{T},))
    return GPUCompiler.cached_compilation(
        COMPILEDUNARYOPS, job.source, job.config,
        OperatorCompiler.compiler, linker
    )
end

function _unarybuiltin(f, t, builtin_name)
    U = Broadcast.combine_eltypes(f, (t,))
    namestr = Any ∈ builtin_name[2] ? string(builtin_name[1]) * 
        "_$(suffix(U))" : string(builtin_name[1]) * "_$(suffix(t))"
    namestr = t <: Complex ? "GxB" * namestr[4:end] : namestr
    return TypedUnaryOperator{typeof(f), t, U}(
        true, false, namestr, LibGraphBLAS.GrB_UnaryOp(), f
    )
end

function unaryop(f, ::Type{T}) where T
    t = (f === rowindex || f === colindex) ? Any : T
    maybeop = get!(UNARYOPS, (f, t)) do
        builtin_name = get(BUILTINUNARYOPS, f, nothing)
        if builtin_name !== nothing && (t ∈ builtin_name[2] || Any ∈ builtin_name[2])
            return _unarybuiltin(f, t, builtin_name)
        else
            return nothing
        end
    end
    if maybeop isa TypedUnaryOperator
        return maybeop
    elseif maybeop === nothing
        function unaryopfn(z, x)
            Base.unsafe_store!(z, f(Base.unsafe_load(x)))
            return nothing
        end
        UNARYOPS[(f, t)] = unaryopfn
        return unarycachecompile(f, unaryopfn, T)
    else
        return unarycachecompile(f, maybeop, T)
    end
end

unaryop(f, ::GBArrayOrTranspose{T}) where T = unaryop(f, T)
unaryop(op::TypedUnaryOperator, ::GBArrayOrTranspose{T}) where T = op
unaryop(op::TypedUnaryOperator, ::Type{X}) where X = op

SuiteSparseGraphBLAS.juliaop(op::TypedUnaryOperator) = op.fn

# all types
BUILTINUNARYOPS[identity] = :GrB_IDENTITY, Ttypes
BUILTINUNARYOPS[(-)] = :GrB_AINV, Ttypes
BUILTINUNARYOPS[inv] = :GrB_MINV, Ttypes
BUILTINUNARYOPS[one] = :GxB_ONE, Ttypes

# real and int
BUILTINUNARYOPS[(!)] = :GxB_LNOT, Bool
BUILTINUNARYOPS[abs] = :GrB_ABS, nBtypes
BUILTINUNARYOPS[(~)] = :GrB_BNOT, Itypes

# positionals
# dummy functions mostly for Base._return_type purposes.
# 1 is the most natural value regardless.
"""
    rowindex(xᵢⱼ) -> i

Dummy function for use with [`apply`](@ref). Returns the row index of an element.
"""
rowindex(_) = 1::Int64

"""
    colindex(xᵢⱼ) -> j

Dummy function for use with [`apply`](@ref). Returns the row index of an element.
"""
colindex(_) = 1::Int64
BUILTINUNARYOPS[rowindex] = :GxB_POSITIONI1, (Any,)
BUILTINUNARYOPS[colindex] = :GxB_POSITIONJ1, (Any,)


#floats and complexes
BUILTINUNARYOPS[sqrt] = :GxB_SQRT, FZtypes
BUILTINUNARYOPS[log] = :GxB_LOG, FZtypes
BUILTINUNARYOPS[exp] = :GxB_EXP, FZtypes

BUILTINUNARYOPS[log10] = :GxB_LOG10, FZtypes
BUILTINUNARYOPS[log2] = :GxB_LOG2, FZtypes
BUILTINUNARYOPS[exp2] = :GxB_EXP2, FZtypes
BUILTINUNARYOPS[expm1] = :GxB_EXPM1, FZtypes
BUILTINUNARYOPS[log1p] = :GxB_LOG1P, FZtypes

BUILTINUNARYOPS[sin] = :GxB_SIN, FZtypes
BUILTINUNARYOPS[cos] = :GxB_COS, FZtypes
BUILTINUNARYOPS[tan] = :GxB_TAN, FZtypes
BUILTINUNARYOPS[asin] = :GxB_ASIN, FZtypes
BUILTINUNARYOPS[acos] = :GxB_ACOS, FZtypes
BUILTINUNARYOPS[atan] = :GxB_ATAN, FZtypes
BUILTINUNARYOPS[sinh] = :GxB_SINH, FZtypes
BUILTINUNARYOPS[cosh] = :GxB_COSH, FZtypes
BUILTINUNARYOPS[tanh] = :GxB_TANH, FZtypes
BUILTINUNARYOPS[asinh] = :GxB_ASINH, FZtypes
BUILTINUNARYOPS[acosh] = :GxB_ACOSH, FZtypes
BUILTINUNARYOPS[atanh] = :GxB_ATANH, FZtypes

BUILTINUNARYOPS[sign] = :GxB_SIGNUM, FZtypes
BUILTINUNARYOPS[ceil] = :GxB_CEIL, FZtypes
BUILTINUNARYOPS[floor] = :GxB_FLOOR, FZtypes
BUILTINUNARYOPS[round] = :GxB_ROUND, FZtypes
BUILTINUNARYOPS[trunc] = :GxB_TRUNC, FZtypes

BUILTINUNARYOPS[SpecialFunctions.lgamma] = :GxB_LGAMMA, FZtypes
BUILTINUNARYOPS[SpecialFunctions,gamma] = :GxB_TGAMMA, FZtypes
BUILTINUNARYOPS[erf] = :GxB_ERF, FZtypes
BUILTINUNARYOPS[erfc] = :GxB_ERFC, FZtypes
# julia has frexp which eturns (x, exp). This is split in SS:GrB to frexpx = frexp[1]; frexpe = frexp[2];
frexpx(x) = frexp[1]
frexpe(x) = frexp[2]
BUILTINUNARYOPS[frexpx] = :GxB_FREXPX, FZtypes
BUILTINUNARYOPS[frexpe] = :GxB_FREXPE, FZtypes
BUILTINUNARYOPS[isinf] = :GxB_ISINF, FZtypes
BUILTINUNARYOPS[isnan] = :GxB_ISNAN, FZtypes
BUILTINUNARYOPS[isfinite] = :GxB_ISFINITE, FZtypes

# manually create promotion overloads.
# Otherwise we will fallback to Julia functions which can be harmful.
for f ∈ [
    sqrt, log, exp, log10, log2, exp2, expm1, log1p, sin, cos, tan, 
    asin, acos, atan, sinh, cosh, tanh, asinh, acosh, atanh]
    @eval begin
        unaryop(::typeof($f), ::Type{UInt64}) = 
            unaryop($f, Float64)
        unaryop(::typeof($f), ::Type{<:Union{UInt32, UInt16, UInt8}}) =
            unaryop($f, Float32)
    end
end

# I think this list is correct.
# It should be those functions which can be safely promoted to float
# from Ints (including negatives).
# This might be overzealous, and should be just combined with the list above.
# I'd rather error on domain than create a bunch of NaNs.
for f ∈ [
    exp, exp2, expm1, sin, cos, tan, 
    atan, sinh, cosh, tanh, asinh] 
    @eval begin
        unaryop(::typeof($f), ::Type{Int64}) = 
            unaryop($f, Float64)
        unaryop(::typeof($f), ::Type{<:Union{Int32, Int16, Int8}}) =
            unaryop($f, Float32)
    end
end

# Complex functions
BUILTINUNARYOPS[conj] = :GxB_CONJ, Ztypes
BUILTINUNARYOPS[real] = :GxB_CREAL, Ztypes
BUILTINUNARYOPS[imag] = :GxB_CIMAG, Ztypes
BUILTINUNARYOPS[angle] = :GxB_CARG, Ztypes
end

ztype(::UnaryOps.TypedUnaryOperator{F, I, O}) where {F, I, O} = O
xtype(::UnaryOps.TypedUnaryOperator{F, I, O}) where {F, I, O} = I
