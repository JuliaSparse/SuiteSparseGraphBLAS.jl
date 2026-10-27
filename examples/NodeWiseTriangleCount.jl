#=
NodeWiseTriangleCount:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
- Reference: https://doi.org/10.1109/HPEC.2018.8547538
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra

#A is the input matrix. Output: triangles originated by each node
function nodewise_tc(A)

    partial = mul(A, A, (+, *), mask=A)
    t = reduce(+, partial, dims=2)
    return t/2

end