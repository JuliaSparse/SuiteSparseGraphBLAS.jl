#=
NodeWiseTriangleCount:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra

#A is the input matrix. Output: triangles originated by each node
function nodewise_tc(A)

    #extracting lower matrix from input matrix
    partial = mul(A, A, Semirings.PLUS_TIMES, mask=A)
    t = reduce(Monoids.PLUS_MONOID[Float64], partial, dims=2)
    return t/2

end