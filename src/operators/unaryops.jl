module UnaryOps
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedUnaryOperator, AbstractUnaryOp, GBType,
    valid_vec, juliaop, toGBType
import ..SuiteSparseGraphBLAS: juliaop
using ..libgb
export UnaryOp
function UnaryOp(name)
    if isGxB(name) || isGrB(name) #If it's a GrB/GxB op we don't want the prefix
        simplifiedname = name[5:end]
    else
        simplifiedname = name
    end
    tname = Symbol(simplifiedname * "_T")
    simplifiedname = Symbol(simplifiedname)
    structquote = quote
        struct $tname <: AbstractUnaryOp
            typedops::Dict{DataType, TypedUnaryOperator}
            name::String
            $tname() = new(Dict{DataType, TypedUnaryOperator}(), $name)
        end
    end
    @eval($structquote)
    constquote = quote
        const $simplifiedname = $tname()
        export $simplifiedname
    end
    @eval($constquote)
    return getproperty(UnaryOps, simplifiedname)
end
struct GenericUnaryOp <: AbstractUnaryOp
    typedops::Dict{DataType, TypedUnaryOperator}
    name::String
    GenericUnaryOp(name) = new(Dict{DataType, TypedUnaryOperator}(), name)
end
function UnaryOp(fn::Function; keep=true)
    @warn "Use built-in functions where possible, user defined functions are less performant.
        \nSee the documentation for a list of available built-in functions."
    name = string(fn)
    if keep
        op = UnaryOp(name)
        funcquote = quote
            UnaryOp(::typeof($fn)) = $op
            juliaop(::typeof($op)) = $fn
        end
        @eval($funcquote)
    else
        op = GenericUnaryOp(name)
    end
    return op
end
function UnaryOp(fn::Function, ztype, xtype; keep=true)
    op = UnaryOp(fn; keep)
    _addunaryop(op, fn, toGBType(ztype), toGBType(xtype))
    return op
end
#Same xtype, ztype.
function UnaryOp(fn::Function, type; keep=true)
    return UnaryOp(fn, type, type; keep)
end
#Vector of xtypes and ztypes, add a GrB_UnaryOp for each.
function UnaryOp(fn::Function, ztype::Vector{DataType}, xtype::Vector{DataType}; keep=true)
    op = UnaryOp(fn; keep)
    length(ztype) == length(xtype) || throw(DimensionMismatch("Lengths of ztype and xtype must match."))
    for i ∈ 1:length(ztype)
        _addunaryop(op, fn, toGBType(ztype[i]), toGBType(xtype[i]))
    end
    return op
end
#Vector but same ztype xtype.
function UnaryOp(fn::Function, type::Vector{DataType}; keep=true)
    return UnaryOp(fn, type, type; keep)
end

#This is adapted from the fork by cvdlab.
#Add a new GrB_UnaryOp to an AbstractUnaryOp.
function _addunaryop(op::AbstractUnaryOp, fn::Function, ztype::GBType{T}, xtype::GBType{U}) where {T, U}
    function unaryopfn(z, x)
        unsafe_store!(z, fn(x))
        return nothing
    end
    opref = Ref{libgb.GrB_UnaryOp}()
    unaryopfn_C = @cfunction($unaryopfn, Cvoid, (Ptr{T}, Ref{U}))
    libgb.GB_UnaryOp_new(opref, unaryopfn_C, ztype, xtype, op.name)
    op.typedops[U] = TypedUnaryOperator{xtype, ztype}(opref[])
    return nothing
end

function _addunaryop(op::AbstractUnaryOp, fn::Function, ztype, xtype)
    return _addunaryop(op, fn, toGBType(ztype), toGBType(xtype))
end
end
const UnaryUnion = Union{AbstractUnaryOp, TypedUnaryOperator}

#TODO: Rewrite
function _createunaryops()
    builtins = [
    "GrB_IDENTITY",
    "GrB_AINV",
    "GxB_LNOT",
    "GrB_MINV",
    "GxB_ONE",
    "GrB_ABS",
    "GrB_BNOT",
    "GxB_SQRT",
    "GxB_LOG",
    "GxB_EXP",
    "GxB_LOG2",
    "GxB_SIN",
    "GxB_COS",
    "GxB_TAN",
    "GxB_ACOS",
    "GxB_ASIN",
    "GxB_ATAN",
    "GxB_SINH",
    "GxB_COSH",
    "GxB_TANH",
    "GxB_ASINH",
    "GxB_ACOSH",
    "GxB_ATANH",
    "GxB_SIGNUM",
    "GxB_CEIL",
    "GxB_FLOOR",
    "GxB_ROUND",
    "GxB_TRUNC",
    "GxB_EXP2",
    "GxB_EXPM1",
    "GxB_LOG10",
    "GxB_LOG1P",
    "GxB_LGAMMA",
    "GxB_TGAMMA",
    "GxB_ERF",
    "GxB_ERFC",
    "GxB_FREXPE",
    "GxB_FREXPX",
    "GxB_CONJ",
    "GxB_CREAL",
    "GxB_CIMAG",
    "GxB_CARG",
    "GxB_ISINF",
    "GxB_ISNAN",
    "GxB_ISFINITE",
    "GxB_POSITIONI",
    "GxB_POSITIONI1",
    "GxB_POSITIONJ",
    "GxB_POSITIONJ1",
]
    for name ∈ builtins
        UnaryOps.UnaryOp(name)
    end
end

function _load(unaryop::AbstractUnaryOp)
    booleans = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS"]
    integers = [
        "GrB_IDENTITY",
        "GrB_AINV",
        "GrB_MINV",
        "GxB_LNOT",
        "GxB_ONE",
        "GrB_ABS",
        "GrB_BNOT",
    ]
    unsignedintegers = [
        "GrB_IDENTITY",
        "GrB_AINV",
        "GrB_MINV",
        "GxB_LNOT",
        "GxB_ONE",
        "GrB_ABS",
        "GrB_BNOT",
    ]
    floats = [
        "GrB_IDENTITY",
        "GrB_AINV",
        "GrB_MINV",
        "GxB_LNOT",
        "GxB_ONE",
        "GrB_ABS",
        "GxB_SQRT",
        "GxB_LOG",
        "GxB_EXP",
        "GxB_LOG2",
        "GxB_SIN",
        "GxB_COS",
        "GxB_TAN",
        "GxB_ACOS",
        "GxB_ASIN",
        "GxB_ATAN",
        "GxB_SINH",
        "GxB_COSH",
        "GxB_TANH",
        "GxB_ASINH",
        "GxB_ACOSH",
        "GxB_ATANH",
        "GxB_SIGNUM",
        "GxB_CEIL",
        "GxB_FLOOR",
        "GxB_ROUND",
        "GxB_TRUNC",
        "GxB_EXP2",
        "GxB_EXPM1",
        "GxB_LOG10",
        "GxB_LOG1P",
        "GxB_LGAMMA",
        "GxB_TGAMMA",
        "GxB_ERF",
        "GxB_ERFC",
        "GxB_FREXPE",
        "GxB_FREXPX",
        "GxB_ISINF",
        "GxB_ISNAN",
        "GxB_ISFINITE",
    ]
    positionals = ["GxB_POSITIONI", "GxB_POSITIONI1", "GxB_POSITIONJ", "GxB_POSITIONJ1"]
    complexes = [
        "GxB_IDENTITY",
        "GxB_AINV",
        "GxB_MINV",
        "GxB_ONE",
        "GxB_SQRT",
        "GxB_LOG",
        "GxB_EXP",
        "GxB_LOG2",
        "GxB_SIN",
        "GxB_COS",
        "GxB_TAN",
        "GxB_ACOS",
        "GxB_ASIN",
        "GxB_ATAN",
        "GxB_SINH",
        "GxB_COSH",
        "GxB_TANH",
        "GxB_ASINH",
        "GxB_ACOSH",
        "GxB_ATANH",
        "GxB_SIGNUM",
        "GxB_CEIL",
        "GxB_FLOOR",
        "GxB_ROUND",
        "GxB_TRUNC",
        "GxB_EXP2",
        "GxB_EXPM1",
        "GxB_LOG10",
        "GxB_LOG1P",
        "GxB_CONJ",
        "GxB_CREAL",
        "GxB_CIMAG",
        "GxB_CARG",
        "GxB_ABS",
        "GxB_ISINF",
        "GxB_ISNAN",
        "GxB_ISFINITE",
    ]
    name = unaryop.name
    if name ∈ booleans
        constname = name * "_BOOL"
        unaryop.typedops[Bool] = TypedUnaryOperator(load_global(constname, libgb.GrB_UnaryOp))
    end

    if name ∈ integers
        unaryop.typedops[Int8] = TypedUnaryOperator(load_global(name * "_INT8", libgb.GrB_UnaryOp))
        unaryop.typedops[Int16] = TypedUnaryOperator(load_global(name * "_INT16", libgb.GrB_UnaryOp))
        unaryop.typedops[Int32] = TypedUnaryOperator(load_global(name * "_INT32", libgb.GrB_UnaryOp))
        unaryop.typedops[Int64] = TypedUnaryOperator(load_global(name * "_INT64", libgb.GrB_UnaryOp))
    end

    if name ∈ unsignedintegers
        unaryop.typedops[UInt8] = TypedUnaryOperator(load_global(name * "_UINT8", libgb.GrB_UnaryOp))
        unaryop.typedops[UInt16] = TypedUnaryOperator(load_global(name * "_UINT16", libgb.GrB_UnaryOp))
        unaryop.typedops[UInt32] = TypedUnaryOperator(load_global(name * "_UINT32", libgb.GrB_UnaryOp))
        unaryop.typedops[UInt64] = TypedUnaryOperator(load_global(name * "_UINT64", libgb.GrB_UnaryOp))
    end

    if name ∈ floats
        unaryop.typedops[Float32] = TypedUnaryOperator(load_global(name * "_FP32", libgb.GrB_UnaryOp))
        unaryop.typedops[Float64] = TypedUnaryOperator(load_global(name * "_FP64", libgb.GrB_UnaryOp))
    end
    if name ∈ positionals
        unaryop.typedops[Any] = TypedUnaryOperator(load_global(name * "_INT64", libgb.GrB_UnaryOp))
    end
    name = "GxB_" * name[5:end]
    if name ∈ complexes
        unaryop.typedops[ComplexF32] = TypedUnaryOperator(load_global(name * "_FC32", libgb.GrB_UnaryOp))
        unaryop.typedops[ComplexF64] = TypedUnaryOperator(load_global(name * "_FC64", libgb.GrB_UnaryOp))
    end
end

ztype(::TypedUnaryOperator{I, O}) where {I, O} = O
xtype(::TypedUnaryOperator{I, O}) where {I, O} = I
