# fall back to nzval, this may need to change eventually, as it's currently not possible to know the storage order.
# Either a new parameter or something else.
function GBShallowVector(v::DenseVector{T}) where {T}
    m = _newGrBRef()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), size(v, 1), size(v, 2))
    gbvec = GBShallowVector{T}(m, Int64[], Int64[], Int64[], Bool[], v)
    unsafepack!(gbvec, v, true)
end

function GBShallowMatrix(M::StridedMatrix{T}) where {T}
    m = _newGrBRef()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), size(M)...)
    gbmat = GBShallowMatrix{T}(m, Int64[], Int64[], Int64[], Bool[], M)
    unsafepack!(gbmat, M, true)
end

function GBShallowVector(idx::DenseVector{I}, nzvals::DenseVector{T}, size; decrementindices = true) where {I<:Integer, T}
    I isa Integer && sizeo(I) == 8 || throw(ArgumentError("$I is not a 64 bit signed or unsigned Integer."))
    m = _newGrBRef()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), size, 1)
    gbvec = GBShallowVector{T}(m, [1, length(idx) + 1], idx, Int64[], Bool[], nzvals)
    unsafepack!(gbvec, gbvec.ptr, gbvec.idx, gbvec.nzval, true; decrementindices)
end

GBShallowVector(v::SparseVector; decrementindices = true) = return GBShallowVector(
    v.nzind, s.nzval, size(v, 1); 
    decrementindices
)

function GBShallowMatrix(ptr::DenseVector{I}, idx::DenseVector{I}, nzvals::DenseVector{T}, nrows, ncols; decrementindices = true) where {I<:Integer, T}
    I isa Integer && sizeo(I) == 8 || throw(ArgumentError("$I is not a 64 bit signed or unsigned Integer."))
    m = _newGrBRef()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), nrows, ncols)
    gbmat = GBShallowMatrix{T}(m, ptr, idx, Int64[], Bool[], nzvals)
    unsafepack!(gbmat, gbmat.ptr, gbmat.idx, gbmat.nzval, true; decrementindices)
end

GBShallowMatrix(S::SparseMatrixCSC{T}; decrementindices = true) where T = GBShallowMatrix(
    S.colptr, S.rowval, s.nzval, size(S, 1), size(S, 2);
    decrementindices
)

function Base.copy(A::GBShallowMatrix{T}) where {T}
    r = _copyGrBMat(A.p)
    return GBMatrix{T}(r)
end
function Base.copy(A::GBShallowVector{T}) where {T}
    r = _copyGrBMat(A.p)
    return GBVector{T}(r)
end

# similar functions:
# Note well, these should *never* return a GBShallowArray.
# GBShallowArrays may only be created by pack operations
function Base.similar(
    A::GBShallowMatrix{T},
    ::Type{TNew}, dims::Tuple{Int64, Vararg{Int64, N}} = size(A)
) where {T, TNew, N}
    if dims isa Dims{1}
        # TODO: When new Vector types are added this will be incorrect.
        x = GBVector{TNew}(dims...)
    else
        x = GBMatrix{TNew}(dims...)
    end
    _hasconstantorder(x) || setstorageorder!(x, storageorder(A))
    return x
end

function Base.similar(
    ::GBShallowMatrix{T}, 
    dims::Tuple{Int64, Vararg{Int64, N}} = size(A)
) where {T, N}
    similar(A, T, dims)
end

function Base.similar(
    A::GBShallowVector{T}, 
    ::Type{TNew}, dims::Tuple{Int64} = size(A)) where {T, TNew}
    return GBVector{TNew}(dims...)
end

function Base.similar(
    A::GBShallowVector{T}, 
    dims::Tuple{Int64} = size(A)
) where {T}
    similar(A, T, dims)
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

LinearAlgebra.Diagonal(v::GBShallowVector) = Diagonal(copy(v))
