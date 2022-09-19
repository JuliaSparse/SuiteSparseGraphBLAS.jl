abstract type AbstractGBType end
abstract type AbstractDescriptor end
abstract type AbstractOp end
abstract type AbstractSelectOp <: AbstractOp end
abstract type AbstractMonoid <: AbstractOp end
abstract type AbstractTypedOp{Z} end

abstract type AbstractGBArray{T, N, F} <: AbstractSparseArray{T, UInt64, N} end

const AbstractGBMatrix{T, F} = AbstractGBArray{T, 2, F}
const AbstractGBVector{T, F} = AbstractGBArray{T, 1, F}