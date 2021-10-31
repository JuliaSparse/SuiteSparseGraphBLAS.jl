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
    U = select(TRIU, A)
    L = select(TRIL, A)
    return reduce(+, mul(L, U, (+, pair); mask=A)) ÷ 2
end