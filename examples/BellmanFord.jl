#=
BellmanFord:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
=#

using SuiteSparseGraphBLAS
using SparseArrays

#A is the input matrix, s is the source node, and n is the number of nodes, Output: Shortest path from source node
function bellmanford(A, s, n)

    #vector init +inf
    d = GBVector{Float64}(n)
        for i = 1:n
            d[i] = Inf
        end

    d[s]=0.0
    for _ ∈ 1:n
           d = mul(d, A, (min, +), mask=d, desc=Descriptors.S)
    end

    return d

end