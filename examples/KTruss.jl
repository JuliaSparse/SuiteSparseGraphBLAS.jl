#=
KTruss:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
- Reference: https://doi.org/10.1109/HPEC.2018.8547538
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra
using SuiteSparseGraphBLAS: ∧

#A is the original matrix, k is the requested truss, Output: K-Truss graph (values are edge supports)
function ktruss(A, k)

    C = A
    while true
       nz = nnz(C)
       C = *(C, C, (+, ∧), mask=C)
       C = select(>=, C, k-2)
       nnz(C) == nz && return C
    end

end