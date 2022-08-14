module BinaryOps
import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedBinaryOperator, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, optype,
    Ntypes, Ttypes, suffix, valid_union
using ..LibGraphBLAS
export BinaryOp, @binop

export second, rminus, iseq, isne, isgt, islt, isge, isle, ∨, ∧, lxor, xnor, fmod, 
bxnor, bget, bset, bclr, firsti0, firsti, firstj0, firstj, secondi0, secondi, secondj0, 
secondj, pair

const BINARYOPS = IdDict{Tuple{<:Base.Callable, DataType, DataType}, TypedBinaryOperator}()

function binaryop(
    f::F, ::Type{X}, ::Type{Y}
) where {F<:Base.Callable, X, Y}
    return get!(BINARYOPS, (f, X, Y)) do
        TypedBinaryOperator(f, X, Y)
    end
end

binaryop(f, type) = binaryop(f, type, type)
binaryop(op::TypedBinaryOperator, x...) = op

SuiteSparseGraphBLAS.juliaop(op::TypedBinaryOperator) = op.fn

# TODO, clean up this function, it allocates typedop and is otherwise perhaps a little slow.

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
        :($(esc(:(SuiteSparseGraphBLAS.BinaryOps.binaryop)))(::$(esc(:typeof))($(esc(jlfunc))), ::Type, ::Type) = $(esc(namesym)))
    else
        :($(esc(:(SuiteSparseGraphBLAS.BinaryOps.binaryop)))(::$(esc(:typeof))($(esc(jlfunc))), ::Type{$xsym}, ::Type{$ysym}) = $(esc(namesym)))
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

pair(x::T, y::T) where T = one(T)
@binop pair GrB_ONEB T=>T # I prefer pair, but to keep up with the spec I'll match...
@binop (+) GrB_PLUS T=>T
@binop (-) GrB_MINUS T=>T

rminus(x, y) = y - x
@binop rminus GxB_RMINUS T=>T

@binop (*) GrB_TIMES T=>T
@binop (/) GrB_DIV T=>T
@binop (\) GxB_RDIV T=>T
@binop (^) GxB_POW T=>T

iseq(x::T, y::T) where T = T(x == y)
@binop new iseq GxB_ISEQ T=>T

isne(x::T, y::T) where T = T(x != y)
@binop new isne GxB_ISNE T=>T

# Real types
@binop min GrB_MIN R=>R
@binop max GrB_MAX R=>R

isgt(x::T, y::T) where T = T(x > y)
@binop isgt GxB_ISGT R=>R
islt(x::T, y::T) where T = T(x < y)
@binop islt GxB_ISLT R=>R
isge(x::T, y::T) where T = T(x >= y)
@binop isge GxB_ISGE R=>R
isle(x::T, y::T) where T = T(x <= y)
@binop isle GxB_ISLE R=>R
∨(x::T, y::T) where T = (x != zero(T)) || (y != zero(T))
@binop (∨) GxB_LOR R=>R
∧(x::T, y::T) where T = (x != zero(T)) && (y != zero(T))
@binop (∧) GxB_LAND R=>R
binaryop(::typeof(|), ::Type{Bool}, ::Type{Bool}) = LOR_BOOL
binaryop(::typeof(&), ::Type{Bool}, ::Type{Bool}) = LAND_BOOL

lxor(x::T, y::T) where T = xor((x != zero(T)), (y != zero(T)))
@binop lxor GxB_LXOR R=>R

# T/R => Bool
@binop (==) GrB_EQ T=>Bool
@binop (!=) GrB_NE T=>Bool
@binop (>) GrB_GT R=>Bool
@binop (<) GrB_LT R=>Bool
@binop (>=) GrB_GE R=>Bool
@binop (<=) GrB_LE R=>Bool

# Bool=>Bool, most of which are covered above.
xnor(x::T, y::T) where T = !(lxor(x, y))
@binop xnor GrB_LXNOR Bool=>Bool


@binop atan GxB_ATAN2 F=>F
@binop hypot GxB_HYPOT F=>F
@binop mod GxB_FMOD F=>F
@binop rem GxB_REMAINDER F=>F
@binop ldexp GxB_LDEXP F=>F
@binop copysign GxB_COPYSIGN F=>F
@binop complex GxB_CMPLX F=>Z

# bitwise
@binop (|) GrB_BOR I=>I
@binop (&) GrB_BAND I=>I
@binop (⊻) GrB_BXOR I=>I
bxnor(x::T, y::T) where T = ~⊻(x, y)
@binop bxnor GrB_BXNOR I=>I
binaryop(::typeof(⊻), ::Type{Bool}, ::Type{Bool}) = LXOR_BOOL

# leaving these without any equivalent Julia functions
# probably should only operate on Ints anyway.
@binop new bget GxB_BGET I=>I
@binop new bset GxB_BSET I=>I
@binop new bclr GxB_BCLR I=>I
@binop (>>) GxB_BSHIFT (I, Int8)=>I

# Positionals with dummy functions for output type inference purposes
firsti0(x, y) = 0::Int64
@binop new firsti0 GxB_FIRSTI Any=>N
firsti1(x, y) = 1::Int64
@binop new firsti GxB_FIRSTI1 Any=>N

firstj0(x, y) = 0::Int64
@binop new firstj0 GxB_FIRSTJ Any=>N
firstj1(x, y) = 1::Int64
@binop new firstj GxB_FIRSTJ1 Any=>N

secondi0(x, y) = 0::Int64
@binop new secondi0 GxB_SECONDI Any=>N
secondi1(x, y) = 1::Int64
@binop new secondi GxB_SECONDI1 Any=>N

secondj0(x, y) = 0::Int64
@binop new secondj0 GxB_SECONDJ Any=>N
secondj1(x, y) = 1::Int64
@binop new secondj GxB_SECONDJ1 Any=>N
end

ztype(::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Z
xtype(::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = X
ytype(::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Y
