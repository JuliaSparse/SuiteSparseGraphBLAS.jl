abstract type AbstractGBShallowArray{T, A, N, F} <: AbstractGBArray{T, N, F} end

Base.parent(A::AbstractGBShallowArray) = A.array

StorageOrders.storageorder(A::AbstractGBShallowArray) = storageorder(A.array)

mutable struct GBShallowVector{T, A, F} <: AbstractGBShallowArray{T, A, 1, F}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    fill::F
    array::A
end

mutable struct GBShallowMatrix{T, A, F} <: AbstractGBShallowArray{T, A, 2, F}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    fill::F
    array::A
end

function GBShallowVector(v::StridedVector{T}; fill::F = nothing) where {T, F}
    m = Ref{LibGraphBLAS.GrB_Matrix}()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), size(v, 1), size(v, 2))
    gbvec = GBShallowVector{T, typeof(v), F}(m, fill, v)
    pack!(gbvec, v, false)
end

function GBShallowMatrix(M::StridedMatrix{T}; fill::F = nothing) where {T, F}
    m = Ref{LibGraphBLAS.GrB_Matrix}()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), size(M)...)
    gbmat = GBShallowMatrix{T, typeof(M), F}(m, fill, M)
    pack!(gbmat, M, false)
end

function Base.copy(A::GBShallowMatrix{T}) where {T}
    r = _copyGrBMat(A.p)
    return GBMatrix{T}(r; fill = A.fill)
end

# similar functions:
# Note well, these should *never* return a GBShallowArray.
# GBShallowArrays may only be created by pack operations
function Base.similar(
    A::GBShallowMatrix{T, M, F}, 
    ::Type{TNew}, dims::Tuple{Int64, Vararg{Int64, N}} = size(A);
    fill = A.fill
) where {T, M, F, TNew, N}
    return GBMatrix{TNew}(dims...; fill)
end

function Base.similar(
    A::GBShallowMatrix{T, M, F}, 
    dims::Tuple{Int64, Vararg{Int64, N}} = size(A);
    fill = A.fill
) where {T, M, F, N}
    similar(A, T, dims; fill)
end

function Base.similar(
    A::GBShallowVector{T, V, F}, 
    ::Type{TNew}, dims::Tuple{Int64} = size(A);
    fill = A.fill) where {T, V, F, TNew}
    return GBVector{TNew}(dims..., fill)
end

function Base.similar(
    A::GBShallowVector{T, V, F}, 
    dims::Tuple{Int64} = size(A);
    fill = A.fill
) where {T, V, F}
    similar(A, T, dims; fill)
end

struct ShallowException <: Exception end
Base.showerror(io::IO, e::ShallowException) = print(io, "An AbstractGBShallowArray has been passed to a function which may modify it.")

_canbeoutput(A::AbstractGBShallowArray) = false

Base.empty!(::AbstractGBShallowArray) = throw(ShallowException())
Base.copyto!(::AbstractGBShallowArray, A::GBArrayOrTranspose) = throw(ShallowException())
reshape!(::AbstractGBShallowArray, nrows, ncols; kwargs...) = throw(ShallowException())
reshape!(::AbstractGBShallowArray, dims...; kwargs...) = throw(ShallowException())
reshape!(::AbstractGBShallowArray, n; kwargs...) = throw(ShallowException())
Base.deleteat!(::GBShallowMatrix, i, j) = throw(ShallowException())
Base.deleteat!(::GBShallowVector, i) = throw(ShallowException())
Base.resize!(::GBShallowMatrix, nrows, ncols) = throw(ShallowException())
Base.resize!(::GBShallowVector, nrows) = throw(ShallowException())
build!(::GBShallowMatrix{T}, I::AbstractVector, J::AbstractVector, x::T) where T = throw(ShallowException())

