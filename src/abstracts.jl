
abstract type AbstractGBArray{T, O, N} <: AbstractSparseArray{Union{T, NoValue}, UInt64, N} end

const AbstractGBMatrix{T, O} = AbstractGBArray{T, O, 2}
const AbstractGBVector{T, O} = AbstractGBArray{T, O, 1}

# P = pointer vectors, B = bitmap storage, A = value storage
abstract type AbstractGBShallowArray{T, O, P, B, A, N} <: AbstractGBArray{T, O, N} end
