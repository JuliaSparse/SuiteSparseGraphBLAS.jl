#=
Cohen:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
- Reference: https://doi.org/10.1109/MCSE.2009.120, https://doi.org/10.1109/IPDPSW.2015.75
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra
using SuiteSparseGraphBLAS: pair

##A is the input matrix, Output: Triangle Count
function cohen(A)
    U = triu(A)
    L = tril(A)
    return reduce(+, *(L, U, (+, pair); mask=A)) ÷ 2
end