import Base:
        show, ==, pointer, convert, isless, Vector

export ZeroBasedIndex, OneBasedIndex, GrB_Type, GrB_UnaryOp, GrB_BinaryOp, 
       GrB_Monoid, GrB_Semiring, GrB_Vector, GrB_Matrix, GrB_Descriptor, GxB_SelectOp

const valid_types = Union{Bool, Int8, UInt8, Int16, UInt16, Int32, 
                          UInt32, Int64, UInt64, Float32, Float64}

struct ZeroBasedIndex <: Abstract_GrB_Index
    x::UInt64
end

struct OneBasedIndex <: Abstract_GrB_Index
    x::UInt64
end

ZeroBasedIndex(a::OneBasedIndex) = ZeroBasedIndex(a.x-1)
OneBasedIndex(a::ZeroBasedIndex) = OneBasedIndex(a.x+1)

isless(a::ZeroBasedIndex, b::ZeroBasedIndex) = a.x < b.x
isless(a::OneBasedIndex, b::OneBasedIndex) = a.x < b.x

const ZeroBasedIndices = Vector{ZeroBasedIndex}
const OneBasedIndices = Vector{OneBasedIndex}

convert(T::Type{<:Union{ZeroBasedIndex, OneBasedIndex}}, x::Union{Int64, UInt64}) = T(x)
Vector{ZeroBasedIndex}(arr::OneBasedIndices) = ZeroBasedIndex.(arr)
Vector{OneBasedIndex}(arr::ZeroBasedIndices) = OneBasedIndex.(arr)

mutable struct GrB_Type{T <: valid_types} <: Abstract_GrB_Type
    p::Ptr{Cvoid}
end
GrB_Type{T}() where T = GrB_Type{T}(C_NULL)
show(io::IO, ::GrB_Type{T}) where T = print("GrB_Type{" * string(T) * "}")

mutable struct GrB_UnaryOp <: Abstract_GrB_UnaryOp
    p::Ptr{Cvoid}
end
GrB_UnaryOp() = GrB_UnaryOp(C_NULL)
show(io::IO, ::GrB_UnaryOp) = print("GrB_UnaryOp")

mutable struct GrB_BinaryOp <: Abstract_GrB_BinaryOp
    p::Ptr{Cvoid}
end
GrB_BinaryOp() = GrB_BinaryOp(C_NULL)
show(io::IO, ::GrB_BinaryOp) = print("GrB_BinaryOp")

mutable struct GrB_Monoid <: Abstract_GrB_Monoid
    p::Ptr{Cvoid}
end
GrB_Monoid() = GrB_Monoid(C_NULL)
show(io::IO, ::GrB_Monoid) = print("GrB_Monoid")

mutable struct GrB_Semiring <: Abstract_GrB_Semiring
    p::Ptr{Cvoid}
end
GrB_Semiring() = GrB_Semiring(C_NULL)
show(io::IO, ::GrB_Semiring) = print("GrB_Semiring")

mutable struct GrB_Vector{T <: valid_types} <: Abstract_GrB_Vector
    p::Ptr{Cvoid}
end
GrB_Vector{T}() where T = GrB_Vector{T}(C_NULL)
show(io::IO, ::GrB_Vector{T}) where T = print("GrB_Vector{" * string(T) * "}")

mutable struct GrB_Matrix{T <: valid_types} <: Abstract_GrB_Matrix
    p::Ptr{Cvoid}
end
GrB_Matrix{T}() where T = GrB_Matrix{T}(C_NULL)
show(io::IO, ::GrB_Matrix{T}) where T = print("GrB_Matrix{" * string(T) * "}")

mutable struct GrB_Descriptor <: Abstract_GrB_Descriptor
    p::Ptr{Cvoid}
end
GrB_Descriptor() = GrB_Descriptor(C_NULL)
show(io::IO, ::GrB_Descriptor) = print("GrB_Descriptor")

mutable struct GxB_SelectOp
    p::Ptr{Cvoid}
end
GxB_SelectOp() = GxB_SelectOp(C_NULL)
show(io::IO, ::GxB_SelectOp) = print("GxB_SelectOp")

struct GrB_NULL_Type <: Abstract_GrB_NULL
    p::Ptr{Cvoid}
end
show(io::IO, ::GrB_NULL_Type) = print("GrB_NULL")

mutable struct GrB_ALL_Type <: Abstract_GrB_ALL
    p::Ptr{Cvoid}
end
pointer(x::GrB_ALL_Type) = x.p
show(io::IO, ::GrB_ALL_Type) = print("GrB_ALL")
