const valid_union = Union{
    Bool,
    Int8,
    UInt8,
    Int16,
    UInt16,
    Int32,
    UInt32,
    Int64,
    UInt64,
    Float32,
    Float64,
    ComplexF32,
    ComplexF64,
    }
const valid_vec = [
    Bool,
    Int8,
    UInt8,
    Int16,
    UInt16,
    Int32,
    UInt32,
    Int64,
    UInt64,
    Float32,
    Float64,
    ComplexF32,
    ComplexF64,
]

const gxb_union = Union{ComplexF32, ComplexF64}
const gxb_vec = [ComplexF32, ComplexF64]

struct GBType{T} <: AbstractGBType
    p::libgb.GrB_Type
end

Base.unsafe_convert(::Type{libgb.GrB_Type}, s::AbstractGBType) = s.p

GBType{T}(name::AbstractString) where {T<:valid_union} = GBType{T}(load_global(name))

function Base.show(io::IO, ::MIME"text/plain", t::GBType{T}) where T
    print(io, "GBType(" * string(T) * "): ")
    gxbprint(io, t)
end

struct GBAllType <: AbstractGBType
    p::Ptr{libgb.GrB_Index}
end
Base.show(io::IO, ::MIME"text/plain", t::GBAllType) = print(io, "GraphBLAS type: GrB_ALL")
Base.unsafe_convert(::Type{Ptr{libgb.GrB_Index}}, s::GBAllType) = s.p
Base.length(::GBAllType) = 0 #Allow indexing with ALL

function _load_globaltypes()
    global BOOL = GBType{Bool}("GrB_BOOL")
    ptrtogbtype[BOOL.p] = BOOL
    global INT8 = GBType{Int8}("GrB_INT8")
    ptrtogbtype[INT8.p] = INT8
    global UINT8 = GBType{UInt8}("GrB_UINT8")
    ptrtogbtype[UINT8.p] = UINT8
    global INT16 = GBType{Int16}("GrB_INT16")
    ptrtogbtype[INT16.p] = INT16
    global UINT16 = GBType{UInt16}("GrB_UINT16")
    ptrtogbtype[UINT16.p] = UINT16
    global INT32 = GBType{Int32}("GrB_INT32")
    ptrtogbtype[INT32.p] = INT32
    global UINT32 = GBType{UInt32}("GrB_UINT32")
    ptrtogbtype[UINT32.p] = UINT32
    global INT64 = GBType{Int64}("GrB_INT64")
    ptrtogbtype[INT64.p] = INT64
    global UINT64 = GBType{UInt64}("GrB_UINT64")
    ptrtogbtype[UINT64.p] = UINT64
    global FP32 = GBType{Float32}("GrB_FP32")
    ptrtogbtype[FP32.p] = FP32
    global FP64 = GBType{Float64}("GrB_FP64")
    ptrtogbtype[FP64.p] = FP64
    global FC32 = GBType{ComplexF32}("GxB_FC32")
    ptrtogbtype[FC32.p] = FC32
    global FC64 = GBType{ComplexF32}("GxB_FC64")
    ptrtogbtype[FC64.p] = FC64
    global NULL = GBType{Nothing}(C_NULL)
    ptrtogbtype[NULL.p] = NULL
    global ALL = GBAllType(load_global("GrB_ALL", libgb.GrB_Index))
    ptrtogbtype[ALL.p] = ALL
end

"""
    tojuliatype(x::GBType)

Determine the Julia equivalent of a GBType.

See also: [`toGBType`](@ref)
"""
tojuliatype(::GBType{T}) where {T} = T

"""
    toGBType(x)

Determine the GBType equivalent of a Julia primitive type.

See also: [`juliatype`](@ref)
"""
function toGBType(x)
    if x == Bool
        return BOOL
    elseif x == Int8
        return INT8
    elseif x == UInt8
        return UINT8
    elseif x == Int16
        return INT16
    elseif x == UInt16
        return UINT16
    elseif x == Int32
        return INT32
    elseif x == UInt32
        return UINT32
    elseif x == Int64
        return INT64
    elseif x == UInt64
        return UINT64
    elseif x == Float32
        return FP32
    elseif x == Float64
        return FP64
    elseif x == ComplexF32
        return FC32
    elseif x == ComplexF64
        return FC64
    else
        throw(ArgumentError("Not a valid GrB data type"))
    end
end
