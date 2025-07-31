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

const GBVecOrMat{T, F, O} = Union{AbstractGBVector{T, F, O}, AbstractGBMatrix{T, F, O}}
const GBMatrixOrTranspose{T, F, O} = Union{AbstractGBMatrix{T, F, O}, Transpose{<:Any, <:AbstractGBMatrix{T, F, O}}}
const GBVectorOrTranspose{T, F, O} = Union{AbstractGBVector{T, F, O}, Transpose{<:Any, <:AbstractGBVector{T, F, O}}}
const GBArrayOrTranspose{T, F, O} = Union{AbstractGBArray{T, F, O}, Transpose{<:Any, <:AbstractGBArray{T, F, O}}}
const VecMatOrTrans = Union{DenseVecOrMat, Transpose{<:Any, <:DenseVecOrMat}}
