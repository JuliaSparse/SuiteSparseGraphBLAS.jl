

function typedmonoidconstexpr(dispatchstruct, builtin, namestr, xtype, outtype)
    # Complex ops must always be GxB prefixed
    if (xtype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if builtin
        namestr = namestr * "_$(suffix(xtype))"
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    xsym = Symbol(xtype)
    outsym = Symbol(outtype)
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
        struct $(esc(dispatchstruct)) <: AbstractMonoid end
        const $(esc(dispatchfunc)) = $(esc(dispatchstruct))()
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
