module UnaryOps

import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedUnaryOperator, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, Ntypes, Ttypes, suffix,
    GBArrayOrTranspose
using ..LibGraphBLAS
export unaryop, @unop

export rowindex, colindex, frexpx, frexpe

using SpecialFunctions

const UNARYOPS = IdDict{Tuple{<:Any, DataType}, TypedUnaryOperator}()

function unaryop(f, ::Type{T}) where T
    return get!(UNARYOPS, (f, T)) do
        TypedUnaryOperator(f, T)
    end
end

unaryop(f, ::GBArrayOrTranspose{T}) where T = unaryop(f, T)
unaryop(op::TypedUnaryOperator, ::GBArrayOrTranspose{T}) where T = op
unaryop(op::TypedUnaryOperator, ::Type{X}) where X = op

SuiteSparseGraphBLAS.juliaop(op::TypedUnaryOperator) = op.fn

function typedunopconstexpr(jlfunc, builtin, namestr, intype, outtype)
    # Complex ops must always be GxB prefixed
    if (intype ∈ Ztypes || outtype ∈ Ztypes) && isGrB(namestr)
        namestr = "GxB" * namestr[4:end]
    end
    if intype === :Any && outtype ∈ Ntypes # POSITIONAL ops use the output type for suffix
        namestr = namestr * "_$(suffix(outtype))"
    else
        namestr = namestr * "_$(suffix(intype))"
    end
    if builtin
        namesym = Symbol(namestr[5:end])
    else
        namesym = Symbol(namestr)
    end
    insym = Symbol(intype)
    outsym = Symbol(outtype)
    if builtin
        constquote = :(const $(esc(namesym)) = TypedUnaryOperator{$(esc(:typeof))($(esc(jlfunc))), $(esc(insym)), $(esc(outsym))}(true, false, $namestr, LibGraphBLAS.GrB_UnaryOp(), $(esc(jlfunc))))
    else
        constquote = :(const $(esc(namesym)) = TypedUnaryOperator($(esc(jlfunc)), $(esc(insym)), $(esc(outsym))))
    end
    return quote
        $(constquote)
        $(esc(:(SuiteSparseGraphBLAS.UnaryOps.unaryop)))(::$(esc(:typeof))($(esc(jlfunc))), ::Type{$(esc(insym))}) = $(esc(namesym))
    end
end

function typedunopexprs(jlfunc, builtin, namestr, intypes, outtypes)
    if intypes isa Symbol
        intypes = [intypes]
    end
    if outtypes isa Symbol
        outtypes = [outtypes]
    end
    exprs = typedunopconstexpr.(Ref(jlfunc), Ref(builtin), Ref(namestr), intypes, outtypes)
    if exprs isa Expr
        return exprs
    else
        return quote 
            $(exprs...)
        end
    end
end

macro unop(expr...)
    # If the first token is :new then we want to create a new dummy function. I don't love this feature, but it's necessary for things like 
    # second, secondi, firsti, etc which don't have equivalent functions in Julia.
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
    intypes = symtotype(types.args[2])
    outtypes = symtotype(types.args[3])
    constquote = typedunopexprs(jlfunc, builtin, name, intypes, outtypes)
    dispatchquote = quote
        $newfunc
        $constquote
    end
    return dispatchquote
end

# all types
@unop identity GrB_IDENTITY T=>T
@unop (-) GrB_AINV T=>T
@unop inv GrB_MINV T=>T
@unop one GxB_ONE T=>T

# real and int
@unop (!) GxB_LNOT Bool=>Bool
@unop abs GrB_ABS R=>R Z=>F
@unop (~) GrB_BNOT I=>I

# positionals
# dummy functions mostly for Base._return_type purposes.
# 1 is the most natural value regardless.
"""
    rowindex(xᵢⱼ) -> i

Dummy function for use with [`apply`](@ref). Returns the row index of an element.
"""
rowindex(_) = 1::Int64

"""
    colindex(xᵢⱼ) -> j

Dummy function for use with [`apply`](@ref). Returns the row index of an element.
"""
colindex(_) = 1::Int64
@unop rowindex GxB_POSITIONI1 Any=>N
@unop colindex GxB_POSITIONJ1 Any=>N


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
frexpx(x) = frexp[1]
frexpe(x) = frexp[2]
@unop frexpx GxB_FREXPX FZ=>FZ 
@unop frexpe GxB_FREXPE FZ=>FZ
@unop isinf GxB_ISINF FZ=>Bool
@unop isnan GxB_ISNAN FZ=>Bool
@unop isfinite GxB_ISFINITE FZ=>Bool

# manually create promotion overloads.
# Otherwise we will fallback to Julia functions which can be harmful.
for f ∈ [
    sqrt, log, exp, log10, log2, exp2, expm1, log1p, sin, cos, tan, 
    asin, acos, atan, sinh, cosh, tanh, asinh, acosh, atanh]
    @eval begin
        unaryop(::typeof($f), ::Type{UInt64}) = 
            unaryop($f, Float64)
        unaryop(::typeof($f), ::Type{<:Union{UInt32, UInt16, UInt8}}) =
            unaryop($f, Float32)
    end
end

# I think this list is correct.
# It should be those functions which can be safely promoted to float
# from Ints (including negatives).
# This might be overzealous, and should be just combined with the list above.
# I'd rather error on domain than create a bunch of NaNs.
for f ∈ [
    exp, exp2, expm1, sin, cos, tan, 
    atan, sinh, cosh, tanh, asinh] 
    @eval begin
        unaryop(::typeof($f), ::Type{Int64}) = 
            unaryop($f, Float64)
        unaryop(::typeof($f), ::Type{<:Union{Int32, Int16, Int8}}) =
            unaryop($f, Float32)
    end
end

# Complex functions
@unop conj GxB_CONJ Z=>Z
@unop real GxB_CREAL Z=>F
@unop imag GxB_CIMAG Z=>F
@unop angle GxB_CARG Z=>F
end

ztype(::TypedUnaryOperator{F, I, O}) where {F, I, O} = O
xtype(::TypedUnaryOperator{F, I, O}) where {F, I, O} = I
