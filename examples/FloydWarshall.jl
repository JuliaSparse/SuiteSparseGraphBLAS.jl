#=
FloydWarshall:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
- Reference: https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm
=#

using SuiteSparseGraphBLAS
using SparseArrays

#A is the input matrix for Floyd-Warshall multiple sources multiple destinations
#(A[i,j] is the weight of edge i->j, with explicit zeros on the diagonal), Output: shortest paths
function floydwarshall(A, n)

    #distance matrix = input matrix
    D = A

    for i = 1:n
            partial = *(D[:, i:i], D[i:i, :], (min, +))
            D = eadd(D, partial, min)
    end
    return D

end