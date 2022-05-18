module BinaryOps
import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedBinaryOperator, AbstractBinaryOp, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, optype,
    Ntypes, Ttypes, suffix, valid_union
using ..LibGraphBLAS
export BinaryOp, @binop

export second, rminus, iseq, isne, isgt, islt, isge, isle, ∨, ∧, lxor, xnor, fmod, 
bxnor, bget, bset, bclr, firsti0, firsti, firstj0, firstj, secondi0, secondi, secondj0, 
secondj, pair

struct BinaryOp{F} <: AbstractBinaryOp
    juliaop::F
end
SuiteSparseGraphBLAS.juliaop(op::BinaryOp) = op.juliaop
(op::BinaryOp)(T) = op(T, T)

BinaryOp(op::TypedBinaryOperator) = op

function (op::BinaryOp)(::Type{T}, ::Type{U}; cont = true) where {T, U} #fallback
    if !cont
        resulttype = resulttype = Base._return_type(op.juliaop, Tuple{T, U})
        TypedBinaryOperator(op.juliaop, T, U, resulttype)
    end
    promoted = optype(T, U)
    return try
        op(promoted, promoted; cont=false)
    catch
        resulttype = Base._return_type(op.juliaop, Tuple{T, U})
        if resulttype <: Tuple
            throw(ArgumentError("Inferred a tuple return type for function $(string(op.juliaop)) on type $T."))
        end
        TypedBinaryOperator(op.juliaop, T, U, resulttype)
    end
end

function typedbinopconstexpr(jlfunc, builtin, namestr, xtype, ytype, outtype)
    # Complex ops must always be GxB prefixed
    if (xtype ∈ Ztypes || ytype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if xtype === :Any && ytype === :Any && outtype ∈ Ntypes # POSITIONAL ops use the output type for suffix
        namestr = namestr * "_$(suffix(outtype))"
    elseif xtype === ytype
        namestr = namestr * "_$(suffix(xtype))"
    else
        namestr = namestr * "_$(suffix(xtype))_$(suffix(ytype))"
    end
    if builtin
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    xsym = Symbol(xtype)
    ysym = Symbol(ytype)
    outsym = Symbol(outtype)
    if builtin
        constquote = :(const $(esc(namesym)) = TypedBinaryOperator{$(esc(:typeof))($(esc(jlfunc))), $(esc(xsym)), $(esc(ysym)), $(esc(outsym))}(true, false, $namestr, LibGraphBLAS.GrB_BinaryOp(), $(esc(jlfunc))))
    else
        constquote = :(const $(esc(namesym)) = TypedBinaryOperator($(esc(jlfunc)), $(esc(xsym)), $(esc(ysym)), $(esc(outsym))))
    end
    dispatchquote = if xtype === :Any && ytype === :Any
        :((::$(esc(:BinaryOp)){$(esc(:typeof))($(esc(jlfunc)))})(::Type, ::Type) = $(esc(namesym)))
    else
        :((::$(esc(:BinaryOp)){$(esc(:typeof))($(esc(jlfunc)))})(::Type{$xsym}, ::Type{$ysym}) = $(esc(namesym)))
    end
    return quote
        $(constquote)
        $(dispatchquote)
    end
end
function typedbinopexprs(jlfunc, builtin, namestr, xtypes, ytypes, outtypes)
    if xtypes isa Symbol
        xtypes = [xtypes]
    end
    if ytypes isa Symbol
        ytypes = [ytypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedbinopconstexpr.(Ref(jlfunc), Ref(builtin), Ref(namestr), xtypes, ytypes, outtypes)
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
    if expr[2] isa Symbol
        name = string(expr[2])
        types = expr[3]
    else # if we aren't given a name then we'll assume it's just uppercased of the function.
        name = uppercase(string(jlfunc))
        types = expr[2]
    end
    builtin = isGxB(name) || isGrB(name)
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
    constquote = typedbinopexprs(jlfunc, builtin, name, xtypes, ytypes, outtypes)
    dispatchquote = Base.remove_linenums!(quote
        $newfunc
        $constquote
    end)
    return dispatchquote
end
# All types
@binop first GrB_FIRST T=>T
@binop new second GrB_SECOND T=>T
@binop any GxB_ANY T=>T # this doesn't match the semantics of Julia's any, but that may be ok...
@binop new pair GrB_ONEB T=>T # I prefer pair, but to keep up with the spec I'll match...
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
(::BinaryOp{typeof(|)})(::Type{Bool}, ::Type{Bool}) = LOR_BOOL
(::BinaryOp{typeof(&)})(::Type{Bool}, ::Type{Bool}) = LAND_BOOL

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
(::BinaryOp{typeof(⊻)})(::Type{Bool}, ::Type{Bool}) = LXOR_BOOL

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
end


const BinaryUnion = Union{AbstractBinaryOp, TypedBinaryOperator}

ztype(::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Z
xtype(::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = X
ytype(::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Y
