#=
AdvancedPrim:
- Julia version: 
- Author: samuel
- Date: 2021-09-10
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

#A is the input matrix, n is the number of nodes, m is the source matrix. Output: minimum spanning tree and minimum spanning tree cost
function a_prim(A, n, m)

    d = GBVector{Float64}(n)

    weight = 0.0

    d = A[1,:]
    mst = GBVector{Float64}(n) #minimum spanning tree

    while(stoppingCondition(m, n) == false)

        u = argmin(m'+d)
        m[u[2]] = Inf
        push!(mst, d[u[2]])
        weight = weight + d[u[2]]
        print("WEIGHT: ")
        print(weight)
        d = emul(d, A[u[1],:],  BinaryOps.MIN)
        print("  ITERATION FINISHED")
        print("\n\n\n")
    end

    return weight, mst

end