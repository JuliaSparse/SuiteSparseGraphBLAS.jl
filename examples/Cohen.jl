#=
Cohen:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra

##A is the input matrix, Output: Triangle Count
function cohen(A)

    #extracting lower matrix from input matrix
    L = tril(A)


    #extracting upper matrix from input matrix
    U = triu(A')

    B = mul(L, U, Semirings.PLUS_TIMES)
    C = emul(B, A,  BinaryOps.TIMES)
    result = reduce(Monoids.PLUS_MONOID[Float64], C, dims=:)
    result = result /2

    return result

end