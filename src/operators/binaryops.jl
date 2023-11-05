module BinaryOps
import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, optype,
    Ntypes, Ttypes, suffix, valid_union, GBArrayOrTranspose, binaryop, @wraperror, load_global, TypedBinaryOperator,
    inferbinarytype, gbset!
using ..LibGraphBLAS
export BinaryOp, binaryop

export second, rminus, iseq, isne, isgt, islt, isge, isle, ∨, ∧, lxor, xnor, fmod, 
bxnor, bget, bset, bclr, firsti0, firsti, firstj0, firstj, secondi0, secondi, secondj0, 
secondj, pair


function TypedBinaryOperator(fn::F, ::Type{X}, ::Type{Y}, ::Type{Z}) where {F, X, Y, Z}
    return TypedBinaryOperator{F, X, Y, Z}(false, false, string(fn), LibGraphBLAS.GrB_BinaryOp(), fn)
end

function TypedBinaryOperator(fn::F, ::Type{X}, ::Type{Y}) where {F, X, Y}
    return TypedBinaryOperator(fn, X, Y, inferbinarytype(X, Y, fn))
end

function (op::TypedBinaryOperator{F, X, Y, Z})(::Type{T1}, ::Type{T2}) where {F, X, Y, Z, T1, T2}
    return op
end
(op::TypedBinaryOperator)(T) = op(T, T)

@generated function cbinary(f::F, ::Type{X}, ::Type{Y}, ::Type{Z}) where {F, X, Y, Z}
    if Base.issingletontype(F)
        :(@cfunction($(F.instance), Cvoid, (Ptr{Z}, Ptr{X}, Ptr{Y})))
    else
        throw("Unsupported function $f")
    end
end

function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_BinaryOp}, op::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z}
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, LibGraphBLAS.GrB_UnaryOp)
        else
            fn = op.fn
            function binaryopfn(z, x, y)
                unsafe_store!(z, fn(unsafe_load(x), unsafe_load(y)))
                return nothing
            end
            opref = Ref{LibGraphBLAS.GrB_BinaryOp}()
            binaryopfn_C = cbinary(binaryopfn, X, Y, Z)
            op.keepalive = (binaryopfn, binaryopfn_C)
            @wraperror LibGraphBLAS.GxB_BinaryOp_new(opref, binaryopfn_C, gbtype(Z), gbtype(X), gbtype(Y), C_NULL, C_NULL)
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

const BINARYOPS = IdDict{Tuple{<:Any, DataType, DataType}, TypedBinaryOperator}()
const BUILTINBINARYOPS = IdDict{<:Any, <:Any}() # (f) -> (name, inputtype(s))

function _handlebuiltinbinary(f, name, ::Type{X}, ::Type{Y}) where {X, Y}
    U = inferbinarytype(X, Y, f)
    namestr = string(name) * "_$(suffix(X))"
    namestr = X <: Complex || Y <: Complex ? "GxB" * namestr[4:end] : namestr
    return TypedBinaryOperator{typeof(f), X, Y, U}(
        true, false, namestr, LibGraphBLAS.GrB_BinaryOp(), f
    )
end

function SuiteSparseGraphBLAS.binaryop(
    f, ::Type{X}, ::Type{Y}
) where {X, Y}
    # some binaryops take any types, including UDTs
    x, y, isindexbuiltin = inputisany(f) ? (Any, Any, true) : (X, Y, false)
    
    existingbop = get(BINARYOPS, (f, x, y), nothing)
    existingbop !== nothing && (return existingbop)
    
    # if isindexbuiltin we can go ahead and handle it, since it's fine for all types.
    isindexbuiltin && (return _handlebuiltinbinary(f, x, y))

    # otherwise we first need to determine if it's a built-in.
    possiblebuiltin = get(BUILTINBINARYOPS, f, nothing) # (name, inputtypes) | nothing
    (possiblebuiltin === nothing || !(x <: valid_union) || !(y <: valid_union)) && 
        (return TypedBinaryOperator(f, x, y)) # early exit if not a builtin.

    # We now know that we have a built-in function and built-in types.
    # We need to determine if we have a single domain version, or a multidomain version.
    # We also need to determine if we have a multi domain version that can be cast to the
    # single domain version.
    name, types = possiblebuiltin
    if builtinsingledomain(f) # very few ops are multidomain without casting.
        t = optype(x, y)
        if t ∈ types
            op = get!(BINARYOPS, (f, t, t)) do 
                _handlebuiltinbinary(f, name, t, t)
            end
            if t != x || t != y # also need to insert into the multidomain version.
                BINARYOPS[(f, x, y)] = op
            end
            return op
        end
    elseif x ∈ types[1] && y ∈ types[2]
        return get!(BINARYOPS, (f, x, y)) do 
            _handlebuiltinbinary(f, name, x, y)
        end
    else
        # final fallback if we have a builtin operator but it doesn't exist for these types.
        return BINARYOPS[(f, x, y)] = TypedBinaryOperator(f, x, y)
    end
end

SuiteSparseGraphBLAS.binaryop(f, ::GBArrayOrTranspose{T}, ::GBArrayOrTranspose{U}) where {T, U} = 
    binaryop(f, T, U)
SuiteSparseGraphBLAS.binaryop(f, ::GBArrayOrTranspose{T}, ::Type{U}) where {T, U} = binaryop(f, T, U)
SuiteSparseGraphBLAS.binaryop(f, ::Type{T}, ::GBArrayOrTranspose{U}) where {T, U} = binaryop(f, T, U)

SuiteSparseGraphBLAS.binaryop(f, type) = binaryop(f, type, type)
SuiteSparseGraphBLAS.binaryop(op::TypedBinaryOperator, ::Type{X}, ::Type{Y}) where {X, Y} = op
SuiteSparseGraphBLAS.binaryop(op::TypedBinaryOperator, ::Type{X}) where X = op
SuiteSparseGraphBLAS.juliaop(op::TypedBinaryOperator) = op.fn

# All types
BUILTINBINARYOPS[first] = :GrB_FIRST, Ttypes
second(x, y) = y
BUILTINBINARYOPS[second] = :GrB_SECOND, Ttypes
BUILTINBINARYOPS[any] = :GxB_ANY, Ttypes # this doesn't match the semantics of Julia's any, but that may be 

pair(x::T, y::T) where T = one(T)
pair(x::T, y::U) where {T, U} = promote_type(T, U)(true)
BUILTINBINARYOPS[pair] = :GrB_ONEB, Ttypes # I prefer pair, but to keep up with the spec I'll 
BUILTINBINARYOPS[+] = :GrB_PLUS, Ttypes
BUILTINBINARYOPS[-] = :GrB_MINUS, Ttypes

rminus(x, y) = y - x
BUILTINBINARYOPS[rminus] = :GxB_RMINUS, Ttypes

BUILTINBINARYOPS[*] = :GrB_TIMES, Ttypes
BUILTINBINARYOPS[/] = :GrB_DIV, Ttypes
BUILTINBINARYOPS[\] = :GxB_RDIV, Ttypes
BUILTINBINARYOPS[^] = :GxB_POW, Ttypes

iseq(x::T, y::T) where T = T(x == y)
BUILTINBINARYOPS[iseq] = :GxB_ISEQ, Ttypes

isne(x::T, y::T) where T = T(x != y)
BUILTINBINARYOPS[isne] = :GxB_ISNE, Ttypes

# Real types
BUILTINBINARYOPS[min] = :GrB_MIN, Rtypes
BUILTINBINARYOPS[max] = :GrB_MAX, Rtypes

isgt(x::T, y::T) where T = T(x > y)
BUILTINBINARYOPS[isgt] = :GxB_ISGT, Rtypes
islt(x::T, y::T) where T = T(x < y)
BUILTINBINARYOPS[islt] = :GxB_ISLT, Rtypes
isge(x::T, y::T) where T = T(x >= y)
BUILTINBINARYOPS[isge] = :GxB_ISGE, Rtypes
isle(x::T, y::T) where T = T(x <= y)
BUILTINBINARYOPS[isle] = :GxB_ISLE, Rtypes
function ∨(x::T, y::T) where T
    return (x != zero(T)) || (y != zero(T))
end
BUILTINBINARYOPS[(∨)] = :GxB_LOR, Rtypes
function ∧(x::T, y::T) where T
    return (x != zero(T)) && (y != zero(T))
end
BUILTINBINARYOPS[(∧)] = :GxB_LAND, Rtypes

const LOR_BOOL = TypedBinaryOperator{typeof(|), Bool, Bool, Bool}(
    true, false, "GxB_LOR_BOOL", LibGraphBLAS.GrB_BinaryOp(), (|)
)
const LAND_BOOL = TypedBinaryOperator{typeof(&), Bool, Bool, Bool}(
    true, false, "GxB_LAND_BOOL", LibGraphBLAS.GrB_BinaryOp(), (&)
)
SuiteSparseGraphBLAS.binaryop(::typeof(|), ::Type{Bool}, ::Type{Bool}) = LOR_BOOL
SuiteSparseGraphBLAS.binaryop(::typeof(&), ::Type{Bool}, ::Type{Bool}) = LAND_BOOL

lxor(x::T, y::T) where T = xor((x != zero(T)), (y != zero(T)))
BUILTINBINARYOPS[lxor] = :GxB_LXOR, Rtypes

# T/R => Bool
BUILTINBINARYOPS[(==)] = :GrB_EQ, Ttypes
BUILTINBINARYOPS[(!=)] = :GrB_NE, Ttypes
BUILTINBINARYOPS[(>)] = :GrB_GT, Rtypes
BUILTINBINARYOPS[(<)] = :GrB_LT, Rtypes
BUILTINBINARYOPS[(>=)] = :GrB_GE, Rtypes
BUILTINBINARYOPS[(<=)] = :GrB_LE, Rtypes

# Bool=>Bool, most of which are covered above.
xnor(x::T, y::T) where T = !(lxor(x, y))
BUILTINBINARYOPS[xnor] = :GrB_LXNOR, (Bool,)


BUILTINBINARYOPS[atan] = :GxB_ATAN2, Ftypes
BUILTINBINARYOPS[hypot] = :GxB_HYPOT, Ftypes
BUILTINBINARYOPS[mod] = :GxB_FMOD, Ftypes
BUILTINBINARYOPS[rem] = :GxB_REMAINDER, Ftypes
BUILTINBINARYOPS[ldexp] = :GxB_LDEXP, Ftypes
BUILTINBINARYOPS[copysign] = :GxB_COPYSIGN, Ftypes
BUILTINBINARYOPS[complex] = :GxB_CMPLX, Ftypes

# bitwise
BUILTINBINARYOPS[(|)] = :GrB_BOR, Itypes
BUILTINBINARYOPS[(&)] = :GrB_BAND, Itypes
BUILTINBINARYOPS[⊻] = :GrB_BXOR, Itypes
bxnor(x::T, y::T) where T = ~⊻(x, y)
BUILTINBINARYOPS[bxnor] = :GrB_BXNOR, Itypes
const LXOR_BOOL = TypedBinaryOperator{typeof(⊻), Bool, Bool, Bool}(
    true, false, "GxB_LXOR_BOOL", LibGraphBLAS.GrB_BinaryOp(), (⊻)
)
SuiteSparseGraphBLAS.binaryop(::typeof(⊻), ::Type{Bool}, ::Type{Bool}) = LXOR_BOOL

# leaving these without any equivalent Julia functions
# probably should only operate on Ints anyway.
function bget(x::T, y)::T where T end
function bset(x::T, y)::T where T end
function bclr(x::T, y)::T where T end
BUILTINBINARYOPS[bget] = :bget, :GxB_BGET, Itypes
BUILTINBINARYOPS[bset] = :bset, :GxB_BSET, Itypes
BUILTINBINARYOPS[bclr] = :bclr, :GxB_BCLR, Itypes

BUILTINBINARYOPS[(>>)] = :GxB_BSHIFT, (Itypes, (Int8,))


# Positionals with dummy functions for output type inference purposes
firsti0(x, y) = 0::Int64
BUILTINBINARYOPS[firsti0] = :GxB_FIRSTI, (Any,)
firsti(x, y) = 1::Int64
BUILTINBINARYOPS[firsti] =  :GxB_FIRSTI1, (Any,)

firstj0(x, y) = 0::Int64
BUILTINBINARYOPS[firstj0] = :GxB_FIRSTJ, (Any,)
firstj(x, y) = 1::Int64
BUILTINBINARYOPS[firstj] = :GxB_FIRSTJ1, (Any,)

secondi0(x, y) = 0::Int64
BUILTINBINARYOPS[secondi0] = :GxB_SECONDI, (Any,)
secondi(x, y) = 1::Int64
BUILTINBINARYOPS[secondi] = :GxB_SECONDI1, (Any,)

secondj0(x, y) = 0::Int64
BUILTINBINARYOPS[secondj0] = :GxB_SECONDJ, (Any,)
secondj(x, y) = 1::Int64
BUILTINBINARYOPS[secondj] = :GxB_SECONDJ1, (Any,)

inputisany(x) = false
inputisany(::typeof(firsti0)) = true
inputisany(::typeof(firsti)) = true
inputisany(::typeof(firstj0)) = true
inputisany(::typeof(firstj)) = true
inputisany(::typeof(secondi0)) = true
inputisany(::typeof(secondi)) = true
inputisany(::typeof(secondj0)) = true
inputisany(::typeof(secondj)) = true

builtinsingledomain(x) = true
builtinsingledomain(::typeof(>>)) = false
end

ztype(::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Z
xtype(::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = X
ytype(::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Y
# asdf
