abstract type Abstract_GrB_Type end
abstract type AbstractDescriptor end
abstract type AbstractOp end
abstract type AbstractUnaryOp <: AbstractOp end
abstract type AbstractBinaryOp <: AbstractOp end
abstract type AbstractSelectOp <: AbstractOp end
abstract type AbstractMonoid <: AbstractOp end
abstract type AbstractSemiring <: AbstractOp end

isloaded(o::AbstractOp) = !isempty(o.pointers)

function validtypes(o::AbstractOp)
    isloaded(o) || load(o)
    return keys(o.pointers)
end

function Base.getindex(o::AbstractOp, t::DataType)
    isloaded(o) || load(o)
    getindex(o.pointers, t)
end
