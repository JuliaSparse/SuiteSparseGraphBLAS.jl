#=
BellmanFord:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
- Reference: https://en.wikipedia.org/wiki/Bellman%E2%80%93Ford_algorithm
=#

using SuiteSparseGraphBLAS
using SparseArrays

#A is the input matrix (A[i,j] is the weight of edge i->j, with explicit zeros on the diagonal),
#s is the source node, and n is the number of nodes, Output: Shortest path from source node
function bellmanford(A, s, n)

    #vector init +inf
    d = GBVector{Float64}(n)
        for i = 1:n
            d[i] = Inf
        end

    d[s]=0.0
    for _ ∈ 1:n
           d = *(A', d, (min, +))
    end

    return d

end