# fall back to nzval, this may need to change eventually, as it's currently not possible to know the storage order.
# Either a new parameter or something else.
StorageOrders.storageorder(A::AbstractGBShallowArray) = storageorder(A.nzval)

function GBShallowVector(v::DenseVector{T}; fill::F = nothing) where {T, F}
    m = _newGrBRef()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), size(v, 1), size(v, 2))
    gbvec = GBShallowVector{T}(m, fill, Int64[], Int64[], Int64[], Bool[], v)
    unsafepack!(gbvec, v, true)
end

function GBShallowMatrix(M::StridedMatrix{T}; fill::F = nothing) where {T, F}
    m = _newGrBRef()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), size(M)...)
    gbmat = GBShallowMatrix{T}(m, fill, Int64[], Int64[], Int64[], Bool[], M)
    unsafepack!(gbmat, M, true)
end

function GBShallowVector(idx::DenseVector{I}, nzvals::DenseVector{T}, size; fill::F = nothing, decrementindices = true) where {I<:Integer, T, F}
    I isa Integer && sizeo(I) == 8 || throw(ArgumentError("$I is not a 64 bit signed or unsigned Integer."))
    m = _newGrBRef()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), size, 1)
    gbvec = GBShallowVector{T}(m, fill, [1, length(idx) + 1], idx, Int64[], Bool[], nzvals)
    unsafepack!(gbvec, gbvec.ptr, gbvec.idx, gbvec.nzval, true; decrementindices)
end

GBShallowVector(v::SparseVector; fill = nothing, decrementindices = true) = return GBShallowVector(
    v.nzind, s.nzval, size(v, 1); 
    fill, decrementindices
)

function GBShallowMatrix(ptr::DenseVector{I}, idx::DenseVector{I}, nzvals::DenseVector{T}, nrows, ncols; fill::F = nothing, decrementindices = true) where {I<:Integer, T, F}
    I isa Integer && sizeo(I) == 8 || throw(ArgumentError("$I is not a 64 bit signed or unsigned Integer."))
    m = _newGrBRef()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), nrows, ncols)
    gbmat = GBShallowMatrix{T}(m, fill, ptr, idx, Int64[], Bool[], nzvals)
    unsafepack!(gbmat, gbmat.ptr, gbmat.idx, gbmat.nzval, true; decrementindices)
end

GBShallowMatrix(S::SparseMatrixCSC; fill = nothing, decrementindices = true) = GBShallowMatrix(
    S.colptr, S.rowval, s.nzval, size(S, 1), size(S, 2);
    fill, decrementindices
)

function Base.copy(A::GBShallowMatrix{T}) where {T}
    r = _copyGrBMat(A.p)
    return GBMatrix{T}(r; fill = A.fill)
end


# similar functions:
# Note well, these should *never* return a GBShallowArray.
# GBShallowArrays may only be created by pack operations
function Base.similar(
    A::GBShallowMatrix{T},
    ::Type{TNew}, dims::Tuple{Int64, Vararg{Int64, N}} = size(A);
    fill = A.fill
) where {T, TNew, N}
    return GBMatrix{TNew}(dims...; fill)
end

function Base.similar(
    ::GBShallowMatrix{T}, 
    dims::Tuple{Int64, Vararg{Int64, N}} = size(A);
    fill = A.fill
) where {T, N}
    similar(A, T, dims; fill)
end

function Base.similar(
    A::GBShallowVector{T}, 
    ::Type{TNew}, dims::Tuple{Int64} = size(A);
    fill = A.fill) where {T, TNew}
    return GBVector{TNew}(dims..., fill)
end

function Base.similar(
    A::GBShallowVector{T}, 
    dims::Tuple{Int64} = size(A);
    fill = A.fill
) where {T}
    similar(A, T, dims; fill)
end

struct ShallowException <: Exception end
Base.showerror(io::IO, ::ShallowException) = print(io, "An AbstractGBShallowArray has been passed to a function which may modify it.")

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

