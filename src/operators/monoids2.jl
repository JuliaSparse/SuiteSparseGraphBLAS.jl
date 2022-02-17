module Monoids

import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedMonoid, AbstractMonoid, GBType,
    valid_vec, juliaop, toGBType, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, Ntypes, Ttypes, suffix, BinaryOp, _builtinMonoid
using ..libgb
export Monoid, @monoid

struct Monoid{F} <: AbstractMonoid
    binaryop::BinaryOp{F}
end
SuiteSparseGraphBLAS.juliaop(op::Monoid) = juliaop(op.binaryop)

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
        constquote = :(const $(esc(namesym)) = _builtinMonoid(namestr, BinaryOp($(esc(jlfunc)))($(esc(typesym)))))
    else
        constquote = :(const $(esc(namesym)) = TypedMonoid(BinaryOp($(esc(jlfunc)))($(esc(typesym))), $(esc(identity), $(esc(term)))))
    end
    return quote
        $(constquote)
        (::$(esc(:Monoid)){$(esc(:typeof))($(esc(jlfunc)))})(::Type{$typesym}) = $(esc(namesym))
    end
end

function typedmonoidexprs(jlfunc, builtin, namestr, type, identity, term)
    if type isa Symbol
        types = [type]
    end
    exprs = typedbinopconstexpr.(Ref(jlfunc), Ref(builtin), Ref(namestr), )
end
function typedmonoidconstexpr(dispatchstruct, builtin, namestr, type)
    # Complex ops must always be GxB prefixed
    if (intype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    namestr = namestr * "_$(suffix(type))"
    if builtin
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    xsym = Symbol(xtype)
    return quote
        const $(esc(namesym)) = TypedMonoidOperator{$xsym, $outsym}($builtin, false, $namestr, libgb.GrB_Monoid(C_NULL))
        $(esc(dispatchstruct))(::Type{$xsym}) = $(esc(namesym))
    end
end
function typedmonoidexprs(dispatchstruct, builtin, namestr, xtypes, outtypes)
    if xtypes isa Symbol
        xtypes = [xtypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedmonoidconstexpr.(Ref(dispatchstruct), Ref(builtin), Ref(namestr), xtypes, outtypes)
    if exprs isa Expr
        return exprs
    else
        return quote 
            $(exprs...)
        end
    end
end

macro monoid(expr...)
    if first(expr) === :new
        newfunc = :(function $(esc(expr[2])) end)
        expr = expr[2:end]
    else
        newfunc = :()
    end
    binop = first(expr)
    name = string(expr[2])
    if isGxB(name) || isGrB(name)
        builtin = true
    else
        builtin = false
    end
    dispatchstruct = Symbol((builtin ? name[5:end] : name) * "_T")
    dispatchfunc = Symbol(builtin ? name[5:end] : name)
    types = expr[3]
    if !(types isa Symbol)
        error("Monoid type constraints should be in the form <Symbol>")
    end
    intypes = symtotype(types)
    outtypes = intypes
    constquote = typedmonoidexprs(dispatchfunc, builtin, name, intypes, outtypes)
    dispatchquote = Base.remove_linenums!(quote
        $newfunc
        Consts.binaryop(::$(esc(dispatchstruct))) = $(esc(binop))
        Consts.monoid(::$(esc(:typeof))($(esc(binop)))) = $(esc(dispatchfunc))
        $constquote
    end)
    return dispatchquote
end

# We link to the BinaryOp rather than the Julia functions, 
# because users will mostly be exposed to the higher level interface.

@monoid PLUS GrB_PLUS_MONOID T
@monoid TIMES GrB_TIMES_MONOID T

@monoid ANY GxB_ANY_MONOID T
@monoid MIN GrB_MIN_MONOID T
@monoid MAX GrB_MAX_MONOID T

@monoid LOR GrB_LOR_MONOID Bool
@monoid LAND GrB_LAND_MONOID Bool
@monoid LXOR GrB_LXOR_MONOID Bool
@monoid LXNOR GrB_LXNOR_MONOID Bool
@monoid BOR GrB_BOR_MONOID I
@monoid BAND GrB_BAND_MONOID I
@monoid BXOR GrB_BXOR_MONOID I
@monoid BXNOR GrB_BXNOR_MONOID I
