module BinaryOps
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedBinaryOperator, AbstractBinaryOp,
    valid_vec, juliaop, toGBType, GBType
import ..SuiteSparseGraphBLAS: juliaop
using ..libgb
export BinaryOp
function BinaryOp(name)
    if isGxB(name) || isGrB(name) #If it's a built-in drop the prefix
        simplifiedname = name[5:end]
    else
        simplifiedname = name
    end
    containername = Symbol(simplifiedname, "_T")
    exportedname = Symbol(simplifiedname)
    structquote = quote
        struct $containername <: AbstractBinaryOp
            typedops::Dict{Tuple{DataType, DataType}, TypedBinaryOperator}
            name::String
            $containername() = new(Dict{Tuple{DataType, DataType}, TypedBinaryOperator}(), $name)
        end
    end
    @eval($structquote) #eval container *type* into Types submodule
    constquote = quote
        const $exportedname = $containername()
        export $exportedname
    end
    @eval($constquote) #eval actual op into BinaryOps submodule
    return getproperty(BinaryOps, exportedname)
end
struct GenericBinaryOp <: AbstractBinaryOp
    typedops::Dict{Tuple{DataType, DataType}, TypedBinaryOperator}
    name::String
    GenericBinaryOp(name) = new(Dict{Tuple{DataType, DataType}, TypedBinaryOperator}(), name)
end

#This is adapted from the fork by cvdlab.
#Add a new GrB_BinaryOp to an AbstractBinaryOp
function _addbinaryop(
    op::AbstractBinaryOp,
    fn::Function,
    ztype::GBType{T},
    xtype::GBType{U},
    ytype::GBType{V}
) where {T,U,V}
    function binaryopfn(z, x, y)
        unsafe_store!(z, fn(x, y))
        return nothing
    end
    opref = Ref{libgb.GrB_BinaryOp}()
    binaryopfn_C = @cfunction($binaryopfn, Cvoid, (Ptr{T}, Ref{U}, Ref{V}))
    libgb.GB_BinaryOp_new(opref, binaryopfn_C, ztype, xtype, ytype, op.name)
    op.typedops[(U, V)] = TypedBinaryOperator{U, V, T}(opref[])
    return nothing
end

function _addbinaryop(
    op::AbstractBinaryOp,
    fn::Function,
    ztype::Type{T},
    xtype::Type{U},
    ytype::Type{V}
) where {T,U,V}
    function binaryopfn(z, x, y)
        unsafe_store!(z, fn(x, y))
        return nothing
    end
    opref = Ref{libgb.GrB_BinaryOp}()
    binaryopfn_C = @cfunction($binaryopfn, Cvoid, (Ptr{T}, Ref{U}, Ref{V}))
    libgb.GB_BinaryOp_new(opref, binaryopfn_C, toGBType(ztype), toGBType(xtype), toGBType(ytype), op.name)
    op.typedops[(U, V)] = TypedBinaryOperator{xtype, ytype, ztype}(opref[])
    return nothing
end

function BinaryOp(fn::Function; keep=true)
    @warn "Use built-in functions where possible, user defined functions are less performant.
        \nSee the documentation for a list of available built-in functions."
    name = string(fn)
    if keep
        op = BinaryOp(name)
        funcquote = quote
            BinaryOp(::typeof($fn)) = $op
            juliaop(::typeof($op)) = $fn
        end
        @eval($funcquote)
    else
        op = GenericBinaryOp(name)
    end
    return op
end

function BinaryOp(fn::Function, ztype, xtype, ytype; keep=true)
    op = BinaryOp(fn; keep)
    _addbinaryop(op, fn, toGBType(ztype), toGBType(xtype), toGBType(ytype))
    return op
end

#xtype == ytype == ztype
function BinaryOp(fn::Function, type::DataType; keep=true)
    return BinaryOp(fn, type, type, type; keep)
end

#Vectors of _type, add one function for each triple.
function BinaryOp(
    fn::Function,
    ztype::Vector{DataType},
    xtype::Vector{DataType},
    ytype::Vector{DataType};
    keep = true
)
    op = BinaryOp(fn; keep)
    length(ztype) == length(xtype) == length(ytype) ||
        throw(DimensionMismatch("Lengths of ztype, xtype, and ytype must match"))
    for i ∈ 1:length(ztype)
        _addbinaryop(op, fn, toGBType(ztype[i]), toGBType(xtype[i]), toGBType(ytype[i]))
    end
    return op
end

#Vector of type, xtype == ytype == ztype
function BinaryOp(fn::Function, type::Vector{DataType}; keep = true)
    return BinaryOp(fn, type, type, type; keep)
end
end
const BinaryUnion = Union{AbstractBinaryOp, TypedBinaryOperator}

function _createbinaryops()
    builtins = [
    "GrB_FIRST",
    "GrB_SECOND",
    "GxB_POW",
    "GrB_PLUS",
    "GrB_MINUS",
    "GrB_TIMES",
    "GrB_DIV",
    "GxB_RMINUS",
    "GxB_RDIV",
    "GxB_PAIR",
    "GxB_ANY",
    "GxB_ISEQ",
    "GxB_ISNE",
    "GxB_ISGT",
    "GxB_ISLT",
    "GxB_ISGE",
    "GxB_ISLE",
    "GrB_MIN",
    "GrB_MAX",
    "GxB_LOR",
    "GxB_LAND",
    "GxB_LXOR",
    "GxB_ATAN2",
    "GxB_HYPOT",
    "GxB_FMOD",
    "GxB_REMAINDER",
    "GxB_LDEXP",
    "GxB_COPYSIGN",
    "GrB_BOR",
    "GrB_BAND",
    "GrB_BXOR",
    "GrB_BXNOR",
    "GxB_BGET",
    "GxB_BSET",
    "GxB_BCLR",
    "GxB_BSHIFT",
    "GrB_EQ",
    "GrB_NE",
    "GrB_GT",
    "GrB_LT",
    "GrB_GE",
    "GrB_LE",
    "GxB_CMPLX",
    "GxB_FIRSTI",
    "GxB_FIRSTI1",
    "GxB_FIRSTJ",
    "GxB_FIRSTJ1",
    "GxB_SECONDI",
    "GxB_SECONDI1",
    "GxB_SECONDJ",
    "GxB_SECONDJ1",
    ]
    for name ∈ builtins
        BinaryOps.BinaryOp(name)
    end
end

function _load(binary::AbstractBinaryOp)
    booleans = [
        "GrB_FIRST",
        "GrB_SECOND",
        "GxB_POW",
        "GrB_PLUS",
        "GrB_MINUS",
        "GrB_TIMES",
        "GrB_DIV",
        "GxB_RMINUS",
        "GxB_RDIV",
        "GxB_PAIR",
        "GxB_ANY",
        "GxB_ISEQ",
        "GxB_ISNE",
        "GxB_ISGT",
        "GxB_ISLT",
        "GxB_ISGE",
        "GxB_ISLE",
        "GrB_MIN",
        "GrB_MAX",
        "GxB_LOR",
        "GxB_LAND",
        "GxB_LXOR",
        "GrB_EQ",
        "GrB_NE",
        "GrB_GT",
        "GrB_LT",
        "GrB_GE",
        "GrB_LE",
    ]
    integers = [
        "GrB_FIRST",
        "GrB_SECOND",
        "GxB_POW",
        "GrB_PLUS",
        "GrB_MINUS",
        "GrB_TIMES",
        "GrB_DIV",
        "GxB_RMINUS",
        "GxB_RDIV",
        "GxB_PAIR",
        "GxB_ANY",
        "GxB_ISEQ",
        "GxB_ISNE",
        "GxB_ISGT",
        "GxB_ISLT",
        "GxB_ISGE",
        "GxB_ISLE",
        "GrB_MIN",
        "GrB_MAX",
        "GxB_LOR",
        "GxB_LAND",
        "GxB_LXOR",
        "GrB_BOR",
        "GrB_BAND",
        "GrB_BXOR",
        "GrB_BXNOR",
        "GxB_BGET",
        "GxB_BSET",
        "GxB_BCLR",
        "GxB_BSHIFT",
        "GrB_EQ",
        "GrB_NE",
        "GrB_GT",
        "GrB_LT",
        "GrB_GE",
        "GrB_LE",
    ]
    unsignedintegers = [
        "GrB_FIRST",
        "GrB_SECOND",
        "GxB_POW",
        "GrB_PLUS",
        "GrB_MINUS",
        "GrB_TIMES",
        "GrB_DIV",
        "GxB_RMINUS",
        "GxB_RDIV",
        "GxB_PAIR",
        "GxB_ANY",
        "GxB_ISEQ",
        "GxB_ISNE",
        "GxB_ISGT",
        "GxB_ISLT",
        "GxB_ISGE",
        "GxB_ISLE",
        "GrB_MIN",
        "GrB_MAX",
        "GxB_LOR",
        "GxB_LAND",
        "GxB_LXOR",
        "GrB_BOR",
        "GrB_BAND",
        "GrB_BXOR",
        "GrB_BXNOR",
        "GxB_BGET",
        "GxB_BSET",
        "GxB_BCLR",
        "GxB_BSHIFT",
        "GrB_EQ",
        "GrB_NE",
        "GrB_GT",
        "GrB_LT",
        "GrB_GE",
        "GrB_LE",
    ]
    floats = [
        "GrB_FIRST",
        "GrB_SECOND",
        "GxB_POW",
        "GrB_PLUS",
        "GrB_MINUS",
        "GrB_TIMES",
        "GrB_DIV",
        "GxB_RMINUS",
        "GxB_RDIV",
        "GxB_PAIR",
        "GxB_ANY",
        "GxB_ISEQ",
        "GxB_ISNE",
        "GxB_ISGT",
        "GxB_ISLT",
        "GxB_ISGE",
        "GxB_ISLE",
        "GrB_MIN",
        "GrB_MAX",
        "GxB_LOR",
        "GxB_LAND",
        "GxB_LXOR",
        "GxB_ATAN2",
        "GxB_HYPOT",
        "GxB_FMOD",
        "GxB_REMAINDER",
        "GxB_LDEXP",
        "GxB_COPYSIGN",
        "GrB_EQ",
        "GrB_NE",
        "GrB_GT",
        "GrB_LT",
        "GrB_GE",
        "GrB_LE",
        "GxB_CMPLX",
    ]

    positionals = [
        "GxB_FIRSTI",
        "GxB_FIRSTI1",
        "GxB_FIRSTJ",
        "GxB_FIRSTJ1",
        "GxB_SECONDI",
        "GxB_SECONDI1",
        "GxB_SECONDJ",
        "GxB_SECONDJ1",
    ]

    complexes = [
        "GxB_FIRST",
        "GxB_SECOND",
        "GxB_POW",
        "GxB_PLUS",
        "GxB_MINUS",
        "GxB_TIMES",
        "GxB_DIV",
        "GxB_RMINUS",
        "GxB_RDIV",
        "GxB_PAIR",
        "GxB_ANY",
        "GxB_ISEQ",
        "GxB_ISNE",
        "GxB_EQ",
        "GxB_NE",
    ]
    name = binary.name
    if name ∈ booleans
        binary[Bool] = TypedBinaryOperator(load_global(name * "_BOOL", libgb.GrB_BinaryOp))
    end

    if name ∈ integers
        binary[Int8] = TypedBinaryOperator(load_global(name * "_INT8", libgb.GrB_BinaryOp))
        binary[Int16] = TypedBinaryOperator(load_global(name * "_INT16", libgb.GrB_BinaryOp))
        binary[Int32] = TypedBinaryOperator(load_global(name * "_INT32", libgb.GrB_BinaryOp))
        binary[Int64] = TypedBinaryOperator(load_global(name * "_INT64", libgb.GrB_BinaryOp))
    end

    if name ∈ unsignedintegers
        binary[UInt8] = TypedBinaryOperator(load_global(name * "_UINT8", libgb.GrB_BinaryOp))
        binary[UInt16] = TypedBinaryOperator(load_global(name * "_UINT16", libgb.GrB_BinaryOp))
        binary[UInt32] = TypedBinaryOperator(load_global(name * "_UINT32", libgb.GrB_BinaryOp))
        binary[UInt64] = TypedBinaryOperator(load_global(name * "_UINT64", libgb.GrB_BinaryOp))
    end

    if name ∈ floats
        binary[Float32] = TypedBinaryOperator(load_global(name * "_FP32", libgb.GrB_BinaryOp))
        binary[Float64] = TypedBinaryOperator(load_global(name * "_FP64", libgb.GrB_BinaryOp))
    end
    if name ∈ positionals
        binary[Any] = TypedBinaryOperator(load_global(name * "_INT64", libgb.GrB_BinaryOp))
    end
    name = "GxB_" * name[5:end]
    if name ∈ complexes
        binary[ComplexF32] = TypedBinaryOperator(load_global(name * "_FC32", libgb.GrB_BinaryOp))
        binary[ComplexF64] = TypedBinaryOperator(load_global(name * "_FC64", libgb.GrB_BinaryOp))
    end
end

ztype(::TypedBinaryOperator{X, Y, Z}) where {X, Y, Z} = Z
xtype(::TypedBinaryOperator{X, Y, Z}) where {X, Y, Z} = X
ytype(::TypedBinaryOperator{X, Y, Z}) where {X, Y, Z} = Y
