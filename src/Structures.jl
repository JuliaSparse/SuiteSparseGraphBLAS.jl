import Base.show
import Base.==
export GrB_Type, GrB_UnaryOp, GrB_BinaryOp, GrB_Vector, GrB_Matrix

mutable struct GrB_Type
    p::Ptr{Cvoid}
end
GrB_Type() = GrB_Type(Ptr{Cvoid}(0)) 
Base.show(io::IO, ::GrB_Type) = print("GrB_Type")
function ==(t1::GrB_Type, t2::GrB_Type)
    t1.p == t2.p
end

mutable struct GrB_UnaryOp
    p::Ptr{Cvoid}
end
GrB_UnaryOp() = GrB_UnaryOp(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_UnaryOp) = print("GrB_UnaryOp")

mutable struct GrB_BinaryOp
    p::Ptr{Cvoid}
end
GrB_BinaryOp() = GrB_BinaryOp(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_BinaryOp) = print("GrB_BinaryOp")

mutable struct GrB_Vector
    p::Ptr{Cvoid}
end
GrB_Vector() = GrB_Vector(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_Vector) = print("GrB_Vector")

mutable struct GrB_Matrix
    p::Ptr{Cvoid}
end
GrB_Matrix() = GrB_Matrix(Ptr{Cvoid}(0))
Base.show(io::IO, ::GrB_Matrix) = print("GrB_Matrix")
