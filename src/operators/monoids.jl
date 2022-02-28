module Monoids

import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedMonoid, AbstractMonoid, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, Ntypes, Ttypes, suffix, BinaryOps.BinaryOp, _builtinMonoid, BinaryOps.∨, BinaryOps.∧, BinaryOps.lxor, BinaryOps.xnor, BinaryOps.bxnor
using ..LibGraphBLAS
export Monoid, @monoid

struct Monoid{F} <: AbstractMonoid
    binaryop::BinaryOp{F}
end
SuiteSparseGraphBLAS.juliaop(op::Monoid) = juliaop(op.binaryop)
Monoid(f::Function) = Monoid(BinaryOp(f))
Monoid(op::TypedMonoid) = op

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
    if builtin
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    typesym = Symbol(type)
    if builtin
        constquote = :(const $(esc(namesym)) = _builtinMonoid($namestr, BinaryOp($(esc(jlfunc)))($(esc(typesym)), $(esc(typesym))), $(esc(identity)), $(esc(term))))
    else
        constquote = :(const $(esc(namesym)) = TypedMonoid(BinaryOp($(esc(jlfunc)))($(esc(typesym)), $(esc(typesym))), $(esc(identity)), $(esc(term))))
    end
    return quote
        $(constquote)
        (::$(esc(:Monoid)){$(esc(:typeof))($(esc(jlfunc)))})(::Type{$typesym}) = $(esc(namesym))
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

@monoid (+) GrB_PLUS nB id=>zero
@monoid (*) GrB_TIMES I id=>one term=>zero
@monoid (*) GrB_TIMES FZ id=>one 

@monoid any GxB_ANY T id=>one term=>one # This is technically incorrect. The identity and terminal are *ANY* value in the domain.
@monoid min GrB_MIN R id=>typemax term=>typemin
@monoid max GrB_MAX R id=>typemin term=>typemax

@monoid (∨) GrB_LOR Bool id=>false term=>true
@monoid (∧) GrB_LAND Bool id=>true term=>false
@monoid (lxor) GrB_LXOR Bool id=>false
@monoid (==) GrB_LXNOR Bool id=>true
@monoid (|) GrB_BOR I id=>zero term=>typemax
@monoid (&) GrB_BAND I id=>typemax term=>zero
@monoid (⊻) GrB_BXOR I id=>zero
@monoid bxnor GrB_BXNOR I id=>typemax

end

const MonoidUnion = Union{AbstractMonoid, TypedMonoid}
ztype(::TypedMonoid{F, X, T}) where {F, X, T} = X
xtype(::TypedMonoid{F, X, T}) where {F, X, T} = X
ytype(::TypedMonoid{F, X, T}) where {F, X, T} = X