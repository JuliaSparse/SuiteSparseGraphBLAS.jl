import Base.show
import Base.==
export GrB_Type, GrB_UnaryOp, GrB_BinaryOp, GrB_Monoid, GrB_Semiring,
       GrB_Vector, GrB_Matrix, GrB_Descriptor

abstract type GrB_Struct end

mutable struct GrB_Type{T} <: GrB_Struct
    p::Ptr{Cvoid}
end
GrB_Type{T}() where T = GrB_Type{T}(Ptr{Cvoid}(0)) 
Base.show(io::IO, ::GrB_Type{T}) where T = print("GrB_Type{" * string(T) * "}")

mutable struct GrB_UnaryOp <: GrB_Struct
    p::Ptr{Cvoid}
end
GrB_UnaryOp() = GrB_UnaryOp(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_UnaryOp) = print("GrB_UnaryOp")

mutable struct GrB_BinaryOp <: GrB_Struct
    p::Ptr{Cvoid}
end
GrB_BinaryOp() = GrB_BinaryOp(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_BinaryOp) = print("GrB_BinaryOp")

mutable struct GrB_Monoid <: GrB_Struct
    p::Ptr{Cvoid}
end
GrB_Monoid() = GrB_Monoid(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_Monoid) = print("GrB_Monoid")

mutable struct GrB_Semiring <: GrB_Struct
    p::Ptr{Cvoid}
end
GrB_Semiring() = GrB_Semiring(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_Semiring) = print("GrB_Semiring")

mutable struct GrB_Vector{T} <: GrB_Struct
    p::Ptr{Cvoid}
end
GrB_Vector{T}() where T = GrB_Vector{T}(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_Vector{T}) where T = print("GrB_Vector{" * string(T) * "}")

mutable struct GrB_Matrix{T} <: GrB_Struct
    p::Ptr{Cvoid}
end
GrB_Matrix{T}() where T = GrB_Matrix{T}(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_Matrix{T}) where T = print("GrB_Matrix{" * string(T) * "}")

mutable struct GrB_Descriptor <: GrB_Struct
    p::Ptr{Cvoid}
end
GrB_Descriptor() = GrB_Descriptor(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_Descriptor) = print("GrB_Descriptor")

struct GrB_NULL_Type
    p::Ptr{Cvoid} 
end
Base.show(io::IO, ::GrB_NULL_Type) = print("NULL")
