abstract type AbstractGBType end
abstract type AbstractDescriptor end
abstract type AbstractOp end
abstract type AbstractUnaryOp <: AbstractOp end
abstract type AbstractBinaryOp <: AbstractOp end
abstract type AbstractSelectOp <: AbstractOp end
abstract type AbstractMonoid <: AbstractOp end
abstract type AbstractSemiring <: AbstractOp end
abstract type AbstractTypedOp{Z} end
