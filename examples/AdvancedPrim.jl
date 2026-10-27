#=
AdvancedPrim:
- Julia version: 
- Author: samuel
- Date: 2021-09-10
- Reference: https://en.wikipedia.org/wiki/Prim%27s_algorithm
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra

function stoppingCondition(m, n)

infinito = true

for i = 1:n
        if(m[i] == 0.0)
            return false
    end
end
    return infinito
end

#A is the input matrix (dense, Inf where there is no edge and zeros on the diagonal), n is the number of nodes,
#m is a vector of n zeros (Inf marks nodes already in the tree). Output: minimum spanning tree cost and edge weights in the order they were added
function a_prim(A, n, m)

    d = GBVector{Float64}(n)

    weight = 0.0

    d = A[1,:]
    mst = Float64[] #minimum spanning tree

    while(stoppingCondition(m, n) == false)

        u = argmin(m+d)
        m[u] = Inf
        push!(mst, d[u])
        weight = weight + d[u]
        d = emul(d, A[u,:], min)
    end

    return weight, mst

end