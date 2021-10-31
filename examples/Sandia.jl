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

    L = tril(A)
    C = *(+, *; mask=L)(L, L)
    return reduce(+, C, dims=:)

end