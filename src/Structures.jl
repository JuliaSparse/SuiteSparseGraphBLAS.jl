import Base.show

mutable struct GrB_Type
    p::Ptr{Cvoid}
end
Base.show(io::IO, ::GrB_Type) = print("GrB_Type")

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
