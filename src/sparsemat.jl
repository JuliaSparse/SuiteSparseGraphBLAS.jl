module SparseArrayCompat
import SparseArrays
using ..SuiteSparseGraphBLAS

"""
SparseMatrixCSC compatible wrapper over GBMatrix.
"""
struct SparseMatrixGB{Tv, Fv} <: SparseArrays.AbstractSparseMatrix{Tv}
    gbmat::GBMatrix{Tv}
    fillvalue::Fv
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


end
