module UnaryOps
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedUnaryOperator, AbstractUnaryOp, GBType,
    valid_vec, juliaop, toGBType
import ..SuiteSparseGraphBLAS: juliaop
using ..libgb
export UnaryOp, @unop, unaryop

unaryop(op::TypedUnaryOperator) = op

struct UnaryOp{F} <: AbstractUnaryOp
    juliaop::F
end
SuiteSparseGraphBLAS.juliaop(op::UnaryOp) = op.juliaop


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
        constquote = :(const $(esc(namesym)) = TypedUnaryOperator{$(esc(insym)), $(esc(outsym))}($builtin, false, $namestr, libgb.GrB_UnaryOp(C_NULL)))
    else
        constquote = :(const $(esc(namesym)) = TypedUnaryOperator($(esc(jlfunc)), $(esc(insym)), $(esc(outsym))))
    end
    return quote
        $(constquote)
        (::UnaryOp{$(esc(:typeof))($(esc(jlfunc)))})(::Type{$(esc(insym))}) = $(esc(namesym))
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
    if isGxB(name) || isGrB(name)
        builtin = true
    else
        builtin = false
    end
    dispatchfunc = Symbol(builtin ? name[5:end] : name)
    if types.head !== :call || types.args[1] !== :(=>)
        error("Type constraints should be in the form <Symbol>=><Symbol>")
    end
    intypes = symtotype(types.args[2])
    outtypes = symtotype(types.args[3])
    constquote = typedunopexprs(jlfunc, builtin, name, intypes, outtypes)
    dispatchquote = quote
        global UnaryOp
        $newfunc
        const $(esc(dispatchfunc)) = UnaryOp($(esc(jlfunc)))
        global unaryop
        unaryop(::$(esc(:typeof))($(esc(jlfunc)))) = $(esc(dispatchfunc))
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

# function UnaryOp(name)
#     if isGxB(name) || isGrB(name) #If it's a GrB/GxB op we don't want the prefix
#         simplifiedname = name[5:end]
#         builtin = true
#     else
#         simplifiedname = name
#         builtin = false
#     end
#     tname = Symbol(simplifiedname * "_T")
#     simplifiedname = Symbol(simplifiedname)
#     structquote = quote
#         struct $tname <: AbstractUnaryOp
#             typedops::Dict{DataType, TypedUnaryOperator}
#             name::String
#             $tname() = new(Dict{DataType, TypedUnaryOperator}(), $name)
#         end
#     end
#     @eval($structquote)
#     constquote = quote
#         const $simplifiedname = $tname()
#         export $simplifiedname
#     end
#     @eval($constquote)
#     return getproperty(UnaryOps, simplifiedname)
# end
# struct GenericUnaryOp <: AbstractUnaryOp
#     typedops::Dict{DataType, TypedUnaryOperator}
#     name::String
#     GenericUnaryOp(name) = new(Dict{DataType, TypedUnaryOperator}(), name)
# end
# function UnaryOp(fn::Function; keep=true)
#     @warn "Use built-in functions where possible, user defined functions are less performant.
#         \nSee the documentation for a list of available built-in functions."
#     name = string(fn)
#     if keep
#         op = UnaryOp(name)
#         funcquote = quote
            UnaryOp(::typeof($fn)) = $op
            SuiteSparseGraphBLAS.juliaop(::typeof($op)) = $fn
#         end
#         @eval($funcquote)
#     else
#         op = GenericUnaryOp(name)
#     end
#     return op
# end
# function UnaryOp(fn::Function, ztype, xtype; keep=true)
#     op = UnaryOp(fn; keep)
#     _addunaryop(op, fn, toGBType(ztype), toGBType(xtype))
#     return op
# end
# #Same xtype, ztype.
# function UnaryOp(fn::Function, type; keep=true)
#     return UnaryOp(fn, type, type; keep)
# end
# #Vector of xtypes and ztypes, add a GrB_UnaryOp for each.
# function UnaryOp(fn::Function, ztype::Vector{DataType}, xtype::Vector{DataType}; keep=true)
#     op = UnaryOp(fn; keep)
#     length(ztype) == length(xtype) || throw(DimensionMismatch("Lengths of ztype and xtype must match."))
#     for i ∈ 1:length(ztype)
#         _addunaryop(op, fn, toGBType(ztype[i]), toGBType(xtype[i]))
#     end
#     return op
# end
# #Vector but same ztype xtype.
# function UnaryOp(fn::Function, type::Vector{DataType}; keep=true)
#     return UnaryOp(fn, type, type; keep)
# end
# 
# #This is adapted from the fork by cvdlab.
# #Add a new GrB_UnaryOp to an AbstractUnaryOp.
# function _addunaryop(op::AbstractUnaryOp, fn::Function, ztype::GBType{T}, xtype::GBType{U}) where {T, U}
#     function unaryopfn(z, x)
#         unsafe_store!(z, fn(x))
#         return nothing
#     end
#     opref = Ref{libgb.GrB_UnaryOp}()
#     unaryopfn_C = @cfunction($unaryopfn, Cvoid, (Ptr{T}, Ref{U}))
#     libgb.GB_UnaryOp_new(opref, unaryopfn_C, ztype, xtype, op.name)
#     op.typedops[U] = TypedUnaryOperator{U, T}(opref[])
#     return nothing
# end

# function _addunaryop(op::AbstractUnaryOp, fn::Function, ztype, xtype)
#     return _addunaryop(op, fn, toGBType(ztype), toGBType(xtype))
# end
end
const UnaryUnion = Union{AbstractUnaryOp, TypedUnaryOperator}

#TODO: Rewrite
# function _createunaryops()
#     builtins = [
#     "GrB_IDENTITY",
#     "GrB_AINV",
#     "GxB_LNOT",
#     "GrB_MINV",
#     "GxB_ONE",
#     "GrB_ABS",
#     "GrB_BNOT",
#     "GxB_SQRT",
#     "GxB_LOG",
#     "GxB_EXP",
#     "GxB_LOG2",
#     "GxB_SIN",
#     "GxB_COS",
#     "GxB_TAN",
#     "GxB_ACOS",
#     "GxB_ASIN",
#     "GxB_ATAN",
#     "GxB_SINH",
#     "GxB_COSH",
#     "GxB_TANH",
#     "GxB_ASINH",
#     "GxB_ACOSH",
#     "GxB_ATANH",
#     "GxB_SIGNUM",
#     "GxB_CEIL",
#     "GxB_FLOOR",
#     "GxB_ROUND",
#     "GxB_TRUNC",
#     "GxB_EXP2",
#     "GxB_EXPM1",
#     "GxB_LOG10",
#     "GxB_LOG1P",
#     "GxB_LGAMMA",
#     "GxB_TGAMMA",
#     "GxB_ERF",
#     "GxB_ERFC",
#     "GxB_FREXPE",
#     "GxB_FREXPX",
#     "GxB_CONJ",
#     "GxB_CREAL",
#     "GxB_CIMAG",
#     "GxB_CARG",
#     "GxB_ISINF",
#     "GxB_ISNAN",
#     "GxB_ISFINITE",
#     "GxB_POSITIONI",
#     "GxB_POSITIONI1",
#     "GxB_POSITIONJ",
#     "GxB_POSITIONJ1",
# ]
#     for name ∈ builtins
#         UnaryOps.UnaryOp(name)
#     end
# end
# 
# function _load(unaryop::AbstractUnaryOp)
#     booleans = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS"]
#     integers = [
#         "GrB_IDENTITY",
#         "GrB_AINV",
#         "GrB_MINV",
#         "GxB_LNOT",
#         "GxB_ONE",
#         "GrB_ABS",
#         "GrB_BNOT",
#     ]
#     unsignedintegers = [
#         "GrB_IDENTITY",
#         "GrB_AINV",
#         "GrB_MINV",
#         "GxB_LNOT",
#         "GxB_ONE",
#         "GrB_ABS",
#         "GrB_BNOT",
#     ]
#     floats = [
#         "GrB_IDENTITY",
#         "GrB_AINV",
#         "GrB_MINV",
#         "GxB_LNOT",
#         "GxB_ONE",
#         "GrB_ABS",
#         "GxB_SQRT",
#         "GxB_LOG",
#         "GxB_EXP",
#         "GxB_LOG2",
#         "GxB_SIN",
#         "GxB_COS",
#         "GxB_TAN",
#         "GxB_ACOS",
#         "GxB_ASIN",
#         "GxB_ATAN",
#         "GxB_SINH",
#         "GxB_COSH",
#         "GxB_TANH",
#         "GxB_ASINH",
#         "GxB_ACOSH",
#         "GxB_ATANH",
#         "GxB_SIGNUM",
#         "GxB_CEIL",
#         "GxB_FLOOR",
#         "GxB_ROUND",
#         "GxB_TRUNC",
#         "GxB_EXP2",
#         "GxB_EXPM1",
#         "GxB_LOG10",
#         "GxB_LOG1P",
#         "GxB_LGAMMA",
#         "GxB_TGAMMA",
#         "GxB_ERF",
#         "GxB_ERFC",
#         "GxB_FREXPE",
#         "GxB_FREXPX",
#         "GxB_ISINF",
#         "GxB_ISNAN",
#         "GxB_ISFINITE",
#     ]
#     positionals = ["GxB_POSITIONI", "GxB_POSITIONI1", "GxB_POSITIONJ", "GxB_POSITIONJ1"]
#     complexes = [
#         "GxB_IDENTITY",
#         "GxB_AINV",
#         "GxB_MINV",
#         "GxB_ONE",
#         "GxB_SQRT",
#         "GxB_LOG",
#         "GxB_EXP",
#         "GxB_LOG2",
#         "GxB_SIN",
#         "GxB_COS",
#         "GxB_TAN",
#         "GxB_ACOS",
#         "GxB_ASIN",
#         "GxB_ATAN",
#         "GxB_SINH",
#         "GxB_COSH",
#         "GxB_TANH",
#         "GxB_ASINH",
#         "GxB_ACOSH",
#         "GxB_ATANH",
#         "GxB_SIGNUM",
#         "GxB_CEIL",
#         "GxB_FLOOR",
#         "GxB_ROUND",
#         "GxB_TRUNC",
#         "GxB_EXP2",
#         "GxB_EXPM1",
#         "GxB_LOG10",
#         "GxB_LOG1P",
#         "GxB_CONJ",
#         "GxB_CREAL",
#         "GxB_CIMAG",
#         "GxB_CARG",
#         "GxB_ABS",
#         "GxB_ISINF",
#         "GxB_ISNAN",
#         "GxB_ISFINITE",
#     ]
#     name = unaryop.name
#     if name ∈ booleans
#         constname = name * "_BOOL"
#         unaryop.typedops[Bool] = TypedUnaryOperator(load_global(constname, libgb.GrB_UnaryOp))
#     end
# 
#     if name ∈ integers
#         unaryop.typedops[Int8] = TypedUnaryOperator(load_global(name * "_INT8", libgb.GrB_UnaryOp))
#         unaryop.typedops[Int16] = TypedUnaryOperator(load_global(name * "_INT16", libgb.GrB_UnaryOp))
#         unaryop.typedops[Int32] = TypedUnaryOperator(load_global(name * "_INT32", libgb.GrB_UnaryOp))
#         unaryop.typedops[Int64] = TypedUnaryOperator(load_global(name * "_INT64", libgb.GrB_UnaryOp))
#     end
# 
#     if name ∈ unsignedintegers
#         unaryop.typedops[UInt8] = TypedUnaryOperator(load_global(name * "_UINT8", libgb.GrB_UnaryOp))
#         unaryop.typedops[UInt16] = TypedUnaryOperator(load_global(name * "_UINT16", libgb.GrB_UnaryOp))
#         unaryop.typedops[UInt32] = TypedUnaryOperator(load_global(name * "_UINT32", libgb.GrB_UnaryOp))
#         unaryop.typedops[UInt64] = TypedUnaryOperator(load_global(name * "_UINT64", libgb.GrB_UnaryOp))
#     end
# 
#     if name ∈ floats
#         unaryop.typedops[Float32] = TypedUnaryOperator(load_global(name * "_FP32", libgb.GrB_UnaryOp))
#         unaryop.typedops[Float64] = TypedUnaryOperator(load_global(name * "_FP64", libgb.GrB_UnaryOp))
#     end
#     if name ∈ positionals
#         unaryop.typedops[Any] = TypedUnaryOperator(load_global(name * "_INT64", libgb.GrB_UnaryOp))
#     end
#     name = "GxB_" * name[5:end]
#     if name ∈ complexes
#         unaryop.typedops[ComplexF32] = TypedUnaryOperator(load_global(name * "_FC32", libgb.GrB_UnaryOp))
#         unaryop.typedops[ComplexF64] = TypedUnaryOperator(load_global(name * "_FC64", libgb.GrB_UnaryOp))
#     end
# end

ztype(::TypedUnaryOperator{I, O}) where {I, O} = O
xtype(::TypedUnaryOperator{I, O}) where {I, O} = I
