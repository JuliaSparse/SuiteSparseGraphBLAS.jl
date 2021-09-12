#=
Sandia:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra

#A is the input matrix, Output: Triangle Count
function sandia(A)

    #extracting lower matrix from input matrix
    L = tril(A)


    C = mul(L, L, Semirings.PLUS_TIMES, mask=L)
    result = reduce(Monoids.PLUS_MONOID, C, dims=:)

    return result

end