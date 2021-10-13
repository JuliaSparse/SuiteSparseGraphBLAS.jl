module SparseArrayCompat
import SparseArrays
using ..SuiteSparseGraphBLAS: GBMatrix
"""
SparseMatrixCSC compatible wrapper over GBMatrix.
"""
struct SparseMatrixGB{Tv} <: SparseArrays.AbstractSparseMatrix{Tv, Int64}
    gbmat::GBMatrix{Tv}
    fillvalue::Tv
end

function SparseMatrixGB(
    m::Integer, n::Integer, colptr::Vector, rowval::Vector, nzval::Vector{T}, fill=zero(T)
) where {T}
    gbmat = GBMatrix{eltype(nzval)}(
        SuiteSparseGraphBLAS._importcscmat(m, n, colptr, rowval, nzval)
    )
    SparseMatrixGB{eltype(nzval)}(gbmat, fill)
end
SparseMatrixGB{T}(m::Integer, n::Integer, fill=zero(T)) where {T} =
    SparseMatrixGB{T}(GBMatrix{T}(m, n), fill)
SparseMatrixGB{T}(dims::Dims{2}, fill=zero(T)) where {T} =
    SparseMatrixGB(GBMatrix{T}(dims...), fill)
SparseMatrixGB{T}(size::Tuple{Base.OneTo, Base.OneTo}, fill=zero(T)) where {T} =
    SparseMatrixGB(GBMatrix{T}(size[1].stop, size[2].stop), fill)
SparseMatrixGB(
    I::AbstractVector, J::AbstractVector, X::AbstractVector{T}, fill=zero(T);
    m = maximum(I), n = maximum(J)
) where {T} =
    SparseMatrixGB(GBMatrix(I, J, X, nrows=m, ncols=n), fill)
SparseMatrixGB(
    I::AbstractVector, J::AbstractVector, x::T, fill=zero(T);
    m = maximum(I), n = maximum(J)
) where {T} = 
    SparseMatrixGB(GBMatrix(I, J, x; nrows=m, ncols=n), fill)
SparseMatrixGB(A::GBMatrix{T}) where {T} = SparseMatrixGB{T}(A, zero(T))

Base.copy(A::SparseMatrixGB{Tv}) where {Tv} = SparseMatrixGB(copy(A.gbmat), copy(A.fillvalue))
Base.size(A::SparseMatrixGB) = size(A.gbmat)
SparseArrays.nnz(A::SparseMatrixGB) = nnz(A.gbmat)
Base.eltype(::Type{SparseMatrixGB{Tv}}) where{Tv} = Tv

function Base.similar(A::SparseMatrixGB{Tv}, ::Type{TNew}, dims::Union{Dims{1}, Dims{2}}) where {Tv, TNew}
    return SparseMatrixGB{TNew}(similar(A.gbmat, TNew, dims), A.fillvalue)
end

Base.setindex!(A::SparseMatrixGB, x, i, j) = setindex!(A.gbmat, x, i, j)

function Base.getindex(A::SparseMatrixGB, i, j)
    x = A.gbmat[i,j]
    x === nothing ? (return A.fillvalue) : (return x)
end

SparseArrays.findnz(A::SparseMatrixGB) = SparseArrays.findnz(A.gbmat)
SparseArrays.nonzeros(A::SparseMatrixGB) = SparseArrays.nonzeros(A.gbmat)
SparseArrays.nonzeroinds(A::SparseMatrixGB) = SparseArrays.nonzeroinds(A.gbmat)

Base.show(io::IO, ::MIME"text/plain", A::SparseMatrixGB) = show(io, MIME"text/plain"(), A.gbmat)

end