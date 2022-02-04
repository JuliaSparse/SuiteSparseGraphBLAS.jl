mutable struct TypedUnaryOperator{X, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    p::libgb.GrB_UnaryOp
    function TypedUnaryOperator{X, Z}(builtin, loaded, typestr, p) where {X, Z}
        unop = new(builtin, loaded, typestr, p)
        return finalizer(unop) do op
            libgb.GrB_UnaryOp_free(Ref(op.p))
        end
    end
end

struct UnaryOp{F} <: AbstractUnaryOp
    juliaop::F
end

function Base.unsafe_convert(::Type{libgb.GrB_UnaryOp}, op::TypedUnaryOperator) 
    if op.builtin && !op.loaded
        op.p = load_global(typestr, libgb.GrB_BinaryOp)
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end

function typedunopconstexpr(dispatchstruct, builtin, namestr, intype, outtype)
    # Complex ops must always be GxB prefixed
    if (intype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if builtin
        if intype === :Any && outtype ∈ Ntypes # POSITIONAL ops use the output type for suffix
            namestr = namestr * "_$(suffix(outtype))"
        else
            namestr = namestr * "_$(suffix(intype))"
        end
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    insym = Symbol(intype)
    outsym = Symbol(outtype)
    return quote
        const $(esc(namesym)) = TypedUnaryOperator{$(esc(insym)), $(esc(outsym))}($builtin, false, $namestr, libgb.GrB_UnaryOp(C_NULL))
        (::$(esc(dispatchstruct)))(::Type{$(esc(insym))}) = $(esc(namesym))
    end
end

function typedunopexprs(dispatchstruct, builtin, namestr, intypes, outtypes)
    if intypes isa Symbol
        intypes = [intypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedunopconstexpr.(Ref(dispatchstruct), Ref(builtin), Ref(namestr), intypes, outtypes)
    if exprs isa Expr
        return exprs
    else
        return quote 
            $(exprs...)
        end
    end
end

macro unop(expr...)
    if first(expr) === :new
        newfunc = :(function $(esc(expr[2])) end)
        expr = expr[2:end]
    else
        newfunc = :()
    end
    jlfunc = first(expr)
    #dispatchfunc = Symbol(uppercase(string(first(expr))))
    name = string(expr[2])
    if isGxB(name) || isGrB(name)
        builtin = true
    else
        builtin = false
    end
    dispatchstruct = Symbol((builtin ? name[5:end] : name) * "_T")
    dispatchfunc = Symbol(builtin ? name[5:end] : name)
    types = expr[3]
    if types.head !== :call || types.args[1] !== :(=>)
        error("Type constraints should be in the form <Symbol>=><Symbol>")
    end
    intypes = symtotype(types.args[2])
    outtypes = symtotype(types.args[3])
    constquote = typedunopexprs(dispatchstruct, builtin, name, intypes, outtypes)
    dispatchquote = quote
        struct $(esc(dispatchstruct)) <: AbstractUnaryOp end
        const $(esc(dispatchfunc)) = $(esc(dispatchstruct))()
        $newfunc
        Consts.unaryop(::$(esc(:typeof))($(esc(jlfunc)))) = $(esc(dispatchfunc))
        Consts.juliaop(::$(esc(dispatchstruct))) = $(esc(jlfunc))
        $constquote
    end
    return dispatchquote
end

# all types
@unop identity GrB_IDENTITY Bool=>Bool
@unop (-) GrB_AINV T=>T
@unop inv GrB_MINV T=>T
@unop one GxB_ONE T=>T

# real and int
@unop (!) GxB_LNOT Bool=>Bool
@unop abs GrB_ABS R=>R Z=>F
@unop (~) GrB_BNOT I=>I

# positionals
@unop new positioni GxB_POSITIONI1 Any=>N
@unop new positionj GxB_POSITIONJ1 Any=>N

#floats and complexes
@unop sqrt GxB_SQRT FZ=>FZ
@unop log GxB_LOG FZ=>FZ
@unop exp GxB_EXP FZ=>FZ

@unop log10 GxB_LOG10 FZ=>FZ
@unop log2 GxB_LOG2 FZ=>FZ
@unop exp2 GxB_EXP2 FZ=>FZ
@unop expm1 GxB_EXPM1 FZ=>FZ
@unop log1p GxB_LOG1P FZ=>FZ

@unop sin GxB_SIN FZ=>FZ
@unop cos GxB_COS FZ=>FZ
@unop tan GxB_TAN FZ=>FZ
@unop asin GxB_ASIN FZ=>FZ
@unop acos GxB_ACOS FZ=>FZ
@unop atan GxB_ATAN FZ=>FZ
@unop sinh GxB_SINH FZ=>FZ
@unop cosh GxB_COSH FZ=>FZ
@unop tanh GxB_TANH FZ=>FZ
@unop asinh GxB_ASINH FZ=>FZ
@unop acosh GxB_ACOSH FZ=>FZ
@unop atanh GxB_ATANH FZ=>FZ

@unop sign GxB_SIGNUM FZ=>FZ
@unop ceil GxB_CEIL FZ=>FZ
@unop floor GxB_FLOOR FZ=>FZ
@unop round GxB_ROUND FZ=>FZ
@unop trunc GxB_TRUNC FZ=>FZ

@unop SpecialFunctions.lgamma GxB_LGAMMA FZ=>FZ
@unop SpecialFunctions.gamma GxB_TGAMMA FZ=>FZ
@unop erf GxB_ERF FZ=>FZ
@unop erfc GxB_ERFC FZ=>FZ
# julia has frexp which returns (x, exp). This is split in SS:GrB to frexpx = frexp[1]; frexpe = frexp[2];
@unop new frexpx GxB_FREXPX FZ=>FZ 
@unop new frexpe GxB_FREXPE FZ=>FZ
@unop isinf GxB_ISINF FZ=>Bool
@unop isnan GxB_ISNAN FZ=>Bool
@unop isfinite GxB_ISFINITE FZ=>Bool

# Complex functions
@unop conj GxB_CONJ Z=>Z
@unop real GxB_CREAL Z=>F
@unop imag GxB_CIMAG Z=>F
@unop angle GxB_CARG Z=>F