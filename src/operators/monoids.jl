module Monoids

import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: BinaryOps, isGxB, isGrB, TypedMonoid, AbstractMonoid, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, 
    Ntypes, Ttypes, suffix, BinaryOps.binaryop, _builtinMonoid, BinaryOps.∨, 
    BinaryOps.∧, BinaryOps.lxor, BinaryOps.xnor, BinaryOps.bxnor, valid_union
using ..LibGraphBLAS
export Monoid, typedmonoid, defaultmonoid

struct Monoid{F, I, T} <: AbstractMonoid
    fn::F
    identity::I
    terminal::T
end

const MONOIDS = IdDict{Tuple{<:Monoid, DataType}, TypedMonoid}()

SuiteSparseGraphBLAS.juliaop(op::Monoid) = op.fn

function Monoid(fn, identity)
    return Monoid(fn, identity, nothing)
end

function typedmonoid(m::Monoid{F, I, Term}, ::Type{T}) where {F<:Base.Callable, I, Term, T}
    return (get!(MONOIDS, (m, T)) do
        TypedMonoid(binaryop(m.fn, T), m.identity, m.terminal)
    end)
end

typedmonoid(op::TypedMonoid, x...) = op

# We default to no available monoid.
defaultmonoid(f::F, ::Type{T}) where {F<:Base.Callable, T} = throw(
    ArgumentError("Function $f does not have a default monoid.
    You must either extend defaultmonoid(::$F, ::Type{T}) = 
    Monoid($f, <identity> [, <terminal>]) or pass the struct
    Monoid($f, <identity>, [, <terminal>]) to the operation.")
    )

# Use defaultmonoid when available. User should verify that this results in the correct monoid.
typedmonoid(f::F, ::Type{T}) where {F<:Base.Callable, T} = typedmonoid(defaultmonoid(f, T), T)

BinaryOps.binaryop(op::TypedMonoid) = op.binaryop

# Can't really do ephemeral monoid fallbacks... Need the identity and possibly terminal.

function typedmonoidconstexpr(jlfunc, builtin, namestr, type, identity, term)
    if type ∈ Ztypes && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if isGxB(namestr)
        namestr = namestr * "_$(suffix(type))" * "_MONOID"
    elseif isGrB(namestr)
        namestr = namestr * "_MONOID" * "_$(suffix(type))"
    else
        namestr = namestr * "_$(suffix(type))"
    end
    typesym = Symbol(type)
    return quote
        $(esc(:MONOIDS))[
            ($(esc(:Monoid))($(esc(jlfunc)), $(esc(identity)), $(esc(term))), $(esc(typesym)))
        ] = 
            _builtinMonoid(
                $namestr, 
                binaryop($(esc(jlfunc)), 
                $(esc(typesym)), 
                $(esc(typesym))), 
                $(esc(identity)), 
                $(esc(term))
            )
    end
end

function typedmonoidexprs(jlfunc, builtin, namestr, types, identity, term)
    if types isa Symbol
        types = [types]
    end
    exprs = typedmonoidconstexpr.(Ref(jlfunc), Ref(builtin), Ref(namestr), types, Ref(identity), Ref(term))
    if exprs isa Expr
        return exprs
    else
        return quote
            $(exprs...)
        end
    end
end

macro monoid(expr...)
    # no need to create a new function, we must have already done this for binops.
    jlfunc = first(expr)
    if expr[3] isa Symbol # we have a name symbol
        name = string(expr[2])
        types = expr[3]
        if length(expr) >= 4
            @assert expr[4].head === :call && expr[4].args[1] === :(=>) && expr[4].args[2] === :(id) "Invalid macro formatting."
            id = expr[4].args[3]
        else
            id = :one
        end

        if length(expr) == 5
            @assert expr[5].head === :call && expr[5].args[1] === :(=>) && expr[5].args[2] === :(term)
            term = expr[5].args[3]
        else
            term = :nothing
        end
        
    else # we use the function name
        name = uppercase(string(jlfunc))
        types = expr[2]
        if length(expr) >= 3
            @assert expr[3].head === :call && expr[3].args[1] === :(=>) && expr[3].args[2] === :(id) "Invalid macro formatting."
            id = expr[3].args[3]
        else
            id = :one
        end

        if length(expr) == 4
            @assert expr[4].head === :call && expr[4].args[1] === :(=>) && expr[4].args[2] === :(term)
            term = expr[4].args[3]
        else
            term = :nothing
        end
    end
    
    builtin = isGxB(name) || isGrB(name)
    types = symtotype(types)
    constquote = typedmonoidexprs(jlfunc, builtin, name, types, id, term)
    return Base.remove_linenums!(constquote)
end

# We link to the BinaryOp rather than the Julia functions, 
# because users will mostly be exposed to the higher level interface.

const PLUSMONOID = Monoid(+, zero)
defaultmonoid(::typeof(+), ::Type{<:Number}) = PLUSMONOID
@monoid (+) GrB_PLUS nB id=>zero
# (::Monoid{typeof(+)})(::Type{Bool}) = LOR_MONOID_BOOL

const TIMESMONOID = Monoid(*, one, zero)
defaultmonoid(::typeof(*), ::Type{<:Integer}) = TIMESMONOID
@monoid (*) GrB_TIMES I id=>one term=>zero
# (::Monoid{typeof(*)})(::Type{Bool}) = LAND_MONOID_BOOL
const FLOATTIMESMONOID = Monoid(*, one) # float * monoid doesn't have a terminal.
defaultmonoid(::typeof(*), ::Type{<:Union{Complex, AbstractFloat}}) = FLOATTIMESMONOID
@monoid (*) GrB_TIMES FZ id=>one 

# This is technically incorrect. The identity and terminal are *ANY* value in the domain.
# TODO: Users MAY NOT extend the any monoid, and this should be banned somehow.
const ANYMONOID = Monoid(any, one, one)
defaultmonoid(::typeof(any), ::Type{<:valid_union}) = ANYMONOID
@monoid any GxB_ANY T id=>one term=>one

const MINMONOID = Monoid(min, typemax, typemin)
defaultmonoid(::typeof(min), ::Type{<:Real}) = MINMONOID
@monoid min GrB_MIN R id=>typemax term=>typemin

const MAXMONOID = Monoid(max, typemin, typemax)
defaultmonoid(::typeof(max), ::Type{<:Real}) = MAXMONOID
@monoid max GrB_MAX R id=>typemin term=>typemax

const ORMONOID = Monoid(∨, false, true)
defaultmonoid(::typeof(∨), ::Type{Bool}) = ORMONOID
@monoid (∨) GrB_LOR Bool id=>false term=>true
const ANDMONOID = Monoid(∧, true, false)
defaultmonoid(::typeof(∧), ::Type{Bool}) = ANDMONOID
@monoid (∧) GrB_LAND Bool id=>true term=>false

const XORMONOID = Monoid(lxor, false)
defaultmonoid(::typeof(lxor), ::Type{Bool}) = XORMONOID
@monoid (lxor) GrB_LXOR Bool id=>false

const EQMONOID = Monoid(==, true)
defaultmonoid(::typeof(==), ::Type{Bool}) = EQMONOID
@monoid (==) GrB_LXNOR Bool id=>true

const BORMONOID = Monoid(|, zero, typemax)
defaultmonoid(::typeof(|), ::Type{<:Unsigned}) = BORMONOID
@monoid (|) GrB_BOR I id=>zero term=>typemax
const BANDMONOID = Monoid(&, typemax, zero)
defaultmonoid(::typeof(&), ::Type{<:Unsigned}) = BANDMONOID
@monoid (&) GrB_BAND I id=>typemax term=>zero
const BXORMONOID = Monoid(⊻, zero)
defaultmonoid(::typeof(⊻), ::Type{<:Unsigned}) = BXORMONOID
@monoid (⊻) GrB_BXOR I id=>zero
const BXNORMONOID = Monoid(bxnor, typemax)
defaultmonoid(::typeof(bxnor), ::Type{<:Unsigned}) = BXORMONOID
@monoid bxnor GrB_BXNOR I id=>typemax

end

ztype(::TypedMonoid{F, X, T}) where {F, X, T} = X
xtype(::TypedMonoid{F, X, T}) where {F, X, T} = X
ytype(::TypedMonoid{F, X, T}) where {F, X, T} = X