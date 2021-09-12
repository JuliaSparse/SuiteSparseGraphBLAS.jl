#=
BasicPrim:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
=#

using SuiteSparseGraphBLAS
using SparseArrays

function stoppingCondition(m, n)

infinito = true

for i = 1:n
        if(m[i] == 0.0)
            return false
    end
end
    return infinito
end

#A is the input matrix, n is the number of nodes, m is the source matrix Output: minimum spanning tree cost
function b_prim(A, n, m)

    d = GBVector{Float64}(n)

    weight = 0.0

    d = A[1,:]
    print("INITIAL WEIGHT: ")
    print(weight)
    print("\n\n")
    while(stoppingCondition(m, n) == false)

        u = argmin(m'+d)
        m[u[2]] = Inf
        weight = weight + d[u[2]]
        d = emul(d, A[u[1],:],  BinaryOps.MIN)
    end

    return weight

end