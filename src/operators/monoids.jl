module Monoids

import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: BinaryOps, isGxB, isGrB, TypedMonoid, AbstractMonoid, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, 
    Ntypes, nBtypes, Ttypes, suffix, BinaryOps.binaryop, _builtinMonoid, BinaryOps.∨, 
    BinaryOps.∧, BinaryOps.lxor, BinaryOps.xnor, BinaryOps.bxnor, valid_union
using ..LibGraphBLAS
export Monoid, typedmonoid, defaultmonoid


"""
    Monoid{F, I, T}

A Monoid is a binary function `fn` along with an identity and an optional terminal value.

The `identity` and `terminal` should be functions of a type, or `nothing` for the `terminal`.
For instance `Monoid(*, one, zero)` would be the `Monoid` for scalar multiplication.

Monoids are translated into `TypedMonoids` before calling into GraphBLAS itself.
"""
struct Monoid{F, I, T} <: AbstractMonoid
    fn::F
    identity::I
    terminal::T
end

const MONOIDS = IdDict{Tuple{Monoid, DataType}, TypedMonoid}()
# only one datatype since monoids have 1 domain.
const BUILTINMONOIDS = IdDict{Monoid, Any}() # monoid -> name, datatype 

SuiteSparseGraphBLAS.juliaop(op::Monoid) = op.fn

function Monoid(fn, identity)
    return Monoid(fn, identity, nothing)
end

function typedmonoid(m::Monoid, ::Type{T}) where {T}
    return get!(MONOIDS, (m, T)) do
        builtin_result = get(BUILTINMONOIDS, m, nothing)
        if builtin_result !== nothing
            builtin_name, types = builtin_result
            if T == types || T ∈ types
                builtin_name = string(builtin_name)
                if builtin_name[1:3] == "GxB" || T <: Complex
                    builtin_name = "GxB" * builtin_name[4:end] * "_$(suffix(T))_MONOID"
                else
                    builtin_name = builtin_name * "_MONOID_$(suffix(T))"
                end
                return _builtinMonoid(
                    builtin_name, 
                    binaryop(m.fn, T),
                    m.identity, 
                    m.terminal
                )
            end
        end
        return TypedMonoid(binaryop(m.fn, T), m.identity, m.terminal)
    end
end

typedmonoid(op::TypedMonoid, x...) = op

# We default to no available monoid.
defaultmonoid(f::F, ::Type{T}) where {F, T} = throw(
    ArgumentError("Function $f does not have a default monoid.
    You must either extend defaultmonoid(::$F, ::Type{T}) = 
    Monoid($f, <identity> [, <terminal>]) or pass the struct
    Monoid($f, <identity>, [, <terminal>]) to the operation.")
    )
defaultmonoid(monoid::M, ::Type{T}) where {M<:Union{Monoid, TypedMonoid}, T} = monoid
# Use defaultmonoid when available. User should verify that this results in the correct monoid.
typedmonoid(f::F, ::Type{T}) where {F, T} = typedmonoid(defaultmonoid(f, T), T)

# We link to the BinaryOp rather than the Julia functions, 
# because users will mostly be exposed to the higher level interface.

const PLUSMONOID = Monoid(+, zero)
defaultmonoid(::typeof(+), ::Type{<:Number}) = PLUSMONOID
BUILTINMONOIDS[PLUSMONOID] = ("GrB_PLUS", nBtypes)

const TIMESMONOID = Monoid(*, one, zero)
defaultmonoid(::typeof(*), ::Type{<:Integer}) = TIMESMONOID
BUILTINMONOIDS[TIMESMONOID] = ("GrB_TIMES", Itypes)

const FLOATTIMESMONOID = Monoid(*, one) # float * monoid doesn't have a terminal.
defaultmonoid(::typeof(*), ::Type{<:Union{Complex, AbstractFloat}}) = FLOATTIMESMONOID
BUILTINMONOIDS[FLOATTIMESMONOID] = ("GrB_TIMES", FZtypes)

# This is technically incorrect. The identity and terminal are *ANY* value in the domain.
# TODO: Users MAY NOT extend the any monoid, and this should be banned somehow.
const ANYMONOID = Monoid(any, one, one)
defaultmonoid(::typeof(any), ::Type{<:valid_union}) = ANYMONOID
BUILTINMONOIDS[ANYMONOID] = ("GxB_ANY", Ttypes)

const MINMONOID = Monoid(min, typemax, typemin)
defaultmonoid(::typeof(min), ::Type{<:Real}) = MINMONOID
BUILTINMONOIDS[MINMONOID] = ("GrB_MIN", Rtypes)

const MAXMONOID = Monoid(max, typemin, typemax)
defaultmonoid(::typeof(max), ::Type{<:Real}) = MAXMONOID
BUILTINMONOIDS[MAXMONOID] = ("GrB_MAX", Rtypes)

const ORMONOID = Monoid(∨, false, true)
defaultmonoid(::typeof(∨), ::Type{Bool}) = ORMONOID
defaultmonoid(::typeof(+), ::Type{Bool}) = ORMONOID
BUILTINMONOIDS[ORMONOID] = ("GrB_LOR", Bool)

const ANDMONOID = Monoid(∧, true, false)
defaultmonoid(::typeof(∧), ::Type{Bool}) = ANDMONOID
defaultmonoid(::typeof(*), ::Type{Bool}) = ANDMONOID
BUILTINMONOIDS[ANDMONOID] = ("GrB_LAND", Bool)

const XORMONOID = Monoid(lxor, false)
defaultmonoid(::typeof(lxor), ::Type{Bool}) = XORMONOID
BUILTINMONOIDS[XORMONOID] = ("GrB_LXOR", Bool)

const EQMONOID = Monoid(==, true)
defaultmonoid(::typeof(==), ::Type{Bool}) = EQMONOID
BUILTINMONOIDS[EQMONOID] = ("GrB_LXNOR", Bool)

const BORMONOID = Monoid(|, zero, typemax)
defaultmonoid(::typeof(|), ::Type{<:Unsigned}) = BORMONOID
BUILTINMONOIDS[BORMONOID] = ("GrB_BOR", Itypes)

const BANDMONOID = Monoid(&, typemax, zero)
defaultmonoid(::typeof(&), ::Type{<:Unsigned}) = BANDMONOID
BUILTINMONOIDS[BANDMONOID] = ("GrB_BAND", Itypes)

const BXORMONOID = Monoid(⊻, zero)
defaultmonoid(::typeof(⊻), ::Type{<:Unsigned}) = BXORMONOID
BUILTINMONOIDS[BXORMONOID] = ("GrB_BXOR", Itypes)

const BXNORMONOID = Monoid(bxnor, typemax)
defaultmonoid(::typeof(bxnor), ::Type{<:Unsigned}) = BXNORMONOID
BUILTINMONOIDS[BXNORMONOID] = ("GrB_BXNOR", Itypes)

end

ztype(::TypedMonoid{F, X, T}) where {F, X, T} = X
xtype(::TypedMonoid{F, X, T}) where {F, X, T} = X
ytype(::TypedMonoid{F, X, T}) where {F, X, T} = X
