mutable struct TypedSemiringOperator{X, Y, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GrB_PLUS_FP64, if not it's just some user defined string.
    p::libgb.GrB_Semiring
    function TypedSemiringOperator{X, Y, Z}(builtin, loaded, typestr, p) where {X, Y, Z}
        binop = new(builtin, loaded, typestr, p)
        return finalizer(binop) do op
            libgb.GrB_Semiring_free(Ref(op.p))
        end
    end
end
function Base.unsafe_convert(::Type{libgb.GrB_Semiring}, op::TypedSemiringOperator) 
   if op.builtin && !op.loaded
       op.p = load_global(typestr, libgb.GrB_Semiring)
   end
   if !op.loaded
       error("This operator could not be loaded, and is invalid.")
   else
       return op.p
   end
end

function typedrigconstexpr(dispatchstruct, builtin, namestr, xtype, ytype, outtype)
    # Complex ops must always be GxB prefixed
    if (xtype ∈ Ztypes || ytype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if builtin
        if xtype === :Any && ytype === :Any && outtype ∈ Ntypes # POSITIONAL ops use the output type for suffix
            namestr = namestr * "_$(suffix(outtype))"
        else
            namestr = namestr * "_$(suffix(xtype))"
        end
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    xsym = Symbol(xtype)
    ysym = Symbol(ytype)
    outsym = Symbol(outtype)
    return quote
        const $(esc(namesym)) = TypedSemiringOperator{$xsym, $ysym, $outsym}($builtin, false, $namestr, libgb.GrB_Semiring(C_NULL))
        $(esc(dispatchstruct))(::Type{$xsym}, ::Type{$ysym}) = $(esc(namesym))
    end
end
function typedrigexprs(dispatchstruct, builtin, namestr, xtypes, ytypes, outtypes)
    if xtypes isa Symbol
        xtypes = [xtypes]
    end
    if ytypes isa Symbol
        ytypes = [ytypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedbinopconstexpr.(Ref(dispatchstruct), Ref(builtin), Ref(namestr), xtypes, ytypes, outtypes)
    if exprs isa Expr
        return exprs
    else
        return quote 
            $(exprs...)
        end
    end
end

macro rig(expr...)
    operands = first(expr)
    if operands.head === :tuple && operands.args[1] isa Symbol && operands.args[2] isa Symbol
        reducer = operands.args[1]
        binop = operands.args[2]
    else
        error("Semiring macro 1st argument must be of the form (<Symbol>,<Symbol>)")
    end

    name = string(expr[2])
    if isGxB(name) || isGrB(name)
        builtin = true
    else
        builtin = false
    end

    dispatchfunc = builtin ? name[5:end] : name
    dispatchfunc = Symbol(occursin("SEMIRING", dispatchfunc) ? dispatchfunc[begin:end-8] : dispatchfunc)
    dispatchstruct = Symbol(string(dispatchfunc) * "_T")
    types = expr[3]
    if types.head !== :call || types.args[1] !== :(=>)
        error("Type constraints should be in the form <Symbol>=><Symbol>")
    end
    intypes = types.args[2]
    if intypes isa Expr && intypes.head === :tuple
        xtypes = symtotype(intypes.args[1])
        ytypes = symtotype(intypes.args[2])
    else
        xtypes = symtotype(intypes)
        ytypes = xtypes
    end
    outtypes = symtotype(types.args[3])
    constquote = typedrigexprs(dispatchfunc, builtin, name, xtypes, ytypes, outtypes)
    dispatchquote = Base.remove_linenums!(quote
        function $(esc(dispatchfunc)) end
        Consts.binaryop(::$(esc(dispatchstruct))) = $(esc(binop))
        Consts.monoid(::$(esc(dispatchstruct))) = $(esc(reducer))
        Consts.semiring(::typeof($(esc(reducer))), ::typeof($(esc(binop))))
        $constquote
    end)
    return dispatchquote
end