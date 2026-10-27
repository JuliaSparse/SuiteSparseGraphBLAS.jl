#=
Sandia:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
- Reference: https://doi.org/10.1109/HPEC.2017.8091043
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