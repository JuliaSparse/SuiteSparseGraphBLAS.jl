module SparseMatrixCSC
import SparseArrays
using ..SuiteSparseGraphBLAS

"""
SparseMatrixCSC compatible wrapper over GBMatrix.
"""
struct SparseMatrixGB{Tv} <: SparseArrays.AbstractSparseMatrix{Tv}
    gbmat::GBMatrix{Tv}
end

function SparseMatrixGB(m::Integer, n::Integer, colptr::Vector, rowval::Vector, nzval::Vector)
    return SparseMatrixGB{eltype(nzval)}(GBMatrix(m, n, colptr, rowval, nzval))
end

end
