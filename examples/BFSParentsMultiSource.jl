#=
BFSParentsMultiSource:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra

function insert(P, R, s, n)
    for i = 1:s
        for j = 1:n
            if(P[i, j] !== nothing && R[i, j] === nothing) #*
                R[i, j] = P[i, j]
            end
        end
    end

    return R

end

#A is the input matrix, S are the sources, n is the number of nodes, s is the number of sources, Output: Parents matrix
function ms_bfsp(A, S, n, s)

    index = GBMatrix{Int64}(s, n)
            for i = 1:n
                for j = 1:s
                    index[j, i] = i
                end
            end

    #frontier matrix -> F=S source nodes insrted in frontier
    F = GBMatrix{Int64}(n, n)
    F = S

    #parent matrix -> P[S]=S because the source is already visited
    P = GBMatrix{Int64}(n, n)
    P = S

    #result matrix -> R[S]=0 because the parents of the source are considered node 0
    R = GBMatrix{Int64}(s, n)
    LR = GBMatrix{Int64}(s, n)
    R = copy(S)
    for i = 1:n
        for j = 1:s
            if(R[j, i]!=nothing)
                R[j, i] = 0
            end
        end
    end
    for _ ∈ 1:n-1
            F = mul(F, A, (min, first), mask=P, desc=Descriptors.RC)
            P = F[:, :, mask=F, desc=Descriptors.S]
            F = index[:, :, mask=F, desc=Descriptors.S]
            R = insert(P, R, s, n)
            if(R == LR)
                break
            end
            LR = copy(R)

    end

    return R

end

