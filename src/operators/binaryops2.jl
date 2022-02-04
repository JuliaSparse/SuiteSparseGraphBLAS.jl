mutable struct TypedBinaryOperator{X, Y, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GrB_PLUS_FP64, if not it's just some user defined string.
    p::libgb.GrB_BinaryOp
    function TypedBinaryOperator{X, Y, Z}(builtin, loaded, typestr, p) where {X, Y, Z}
        binop = new(builtin, loaded, typestr, p)
        return finalizer(binop) do op
            libgb.GrB_BinaryOp_free(Ref(op.p))
        end
    end
end
function Base.unsafe_convert(::Type{libgb.GrB_BinaryOp}, op::TypedBinaryOperator) 
   if op.builtin && !op.loaded
       op.p = load_global(typestr, libgb.GrB_BinaryOp)
   end
   if !op.loaded
       error("This operator could not be loaded, and is invalid.")
   else
       return op.p
   end
end

function typedbinopconstexpr(dispatchstruct, builtin, namestr, xtype, ytype, outtype)
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
        const $(esc(namesym)) = TypedBinaryOperator{$xsym, $ysym, $outsym}($builtin, false, $namestr, libgb.GrB_BinaryOp(C_NULL))
        $(esc(dispatchstruct))(::Type{$xsym}, ::Type{$ysym}) = $(esc(namesym))
    end
end
function typedbinopexprs(dispatchstruct, builtin, namestr, xtypes, ytypes, outtypes)
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

macro binop(expr...)
    if first(expr) === :new
        newfunc = :(function $(esc(expr[2])) end)
        expr = expr[2:end]
    else
        newfunc = :()
    end
    jlfunc = first(expr)
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
    intypes = types.args[2]
    if intypes isa Expr && intypes.head === :tuple
        xtypes = symtotype(intypes.args[1])
        ytypes = symtotype(intypes.args[2])
    else
        xtypes = symtotype(intypes)
        ytypes = xtypes
    end
    outtypes = symtotype(types.args[3])
    constquote = typedbinopexprs(dispatchstruct, builtin, name, xtypes, ytypes, outtypes)
    dispatchquote = Base.remove_linenums!(quote
        struct $(esc(dispatchstruct)) <: AbstractBinaryOp end
        const $(esc(dispatchfunc)) = $(esc(dispatchstruct))()
        $newfunc
        Consts.binaryop(::$(esc(:typeof))($(esc(jlfunc)))) = $(esc(dispatchfunc))
        Consts.juliaop(::$(esc(dispatchstruct))) = $(esc(jlfunc))
        $constquote
    end)
    return dispatchquote
end
# All types
@binop first GrB_FIRST T=>T
@binop new second GrB_SECOND T=>T
@binop any GxB_ANY T=>T # this doesn't match the semantics of Julia's any, but that may be ok...
@binop one GrB_ONEB T=>T # I prefer pair, but to keep up with the spec I'll match...
@binop (+) GrB_PLUS T=>T
@binop (-) GrB_MINUS T=>T
@binop new rminus GxB_RMINUS T=>T
@binop (*) GrB_TIMES T=>T
@binop (/) GrB_DIV T=>T
@binop (\) GxB_RDIV T=>T
@binop (^) GxB_POW T=>T
@binop new iseq GxB_ISEQ T=>T
@binop new isne GxB_ISNE T=>T

# Real types
@binop min GrB_MIN R=>R
@binop max GrB_MAX R=>R
@binop new isgt GxB_ISGT R=>R
@binop new islt GxB_ISLT R=>R
@binop new isge GxB_ISGE R=>R
@binop new isle GxB_ISLE R=>R
@binop new (∨) GxB_LOR R=>R
@binop new (∧) GxB_LAND R=>R
@binop new lxor GxB_LXOR R=>R

# T/R => Bool
@binop (==) GrB_EQ T=>Bool
@binop (!=) GrB_NE T=>Bool
@binop (>) GrB_GT R=>Bool
@binop (<) GrB_LT R=>Bool
@binop (>=) GrB_GE R=>Bool
@binop (<=) GrB_LE R=>Bool

# Bool=>Bool, most of which are covered above.
@binop new xnor GrB_LXNOR Bool=>Bool


@binop atan GxB_ATAN2 F=>F
@binop hypot GxB_HYPOT F=>F
@binop new fmod GxB_FMOD F=>F
@binop rem GxB_REMAINDER F=>F
@binop ldexp GxB_LDEXP F=>F
@binop copysign GxB_COPYSIGN F=>F
@binop complex GxB_CMPLX F=>Z

# bitwise
@binop (|) GrB_BOR I=>I
@binop (&) GrB_BAND I=>I
@binop (⊻) GrB_BXOR I=>I
@binop new bxnor GrB_BXNOR I=>I
BXOR(::Type{Bool}, ::Type{Bool}) = LXOR_BOOL

@binop new bget GxB_BGET I=>I
@binop new bset GxB_BSET I=>I
@binop new bclr GxB_BCLR I=>I
@binop (>>) GxB_BSHIFT (I, Int8)=>I

# Positionals
@binop new firsti0 GxB_FIRSTI Any=>N
@binop new firsti GxB_FIRSTI1 Any=>N

@binop new firstj0 GxB_FIRSTJ Any=>N
@binop new firstj GxB_FIRSTJ1 Any=>N

@binop new secondi0 GxB_SECONDI Any=>N
@binop new secondi GxB_SECONDI1 Any=>N

@binop new secondj0 GxB_SECONDJ Any=>N
@binop new secondj GxB_SECONDJ1 Any=>N