abstract type AbstractGBType end
abstract type AbstractDescriptor end
abstract type AbstractOp end
abstract type AbstractSelectOp <: AbstractOp end
abstract type AbstractMonoid <: AbstractOp end
abstract type AbstractTypedOp{Z} end

abstract type AbstractGBArray{T, F, O, N} <: AbstractSparseArray{Union{T, F}, UInt64, N} end

const AbstractGBMatrix{T, F, O} = AbstractGBArray{T, F, O, 2}
const AbstractGBVector{T, F, O} = AbstractGBArray{T, F, O, 1}

# P = pointer vectors, B = bitmap storage, A = value storage
abstract type AbstractGBShallowArray{T, F, O, P, B, A, N} <: AbstractGBArray{T, F, O, N} end
