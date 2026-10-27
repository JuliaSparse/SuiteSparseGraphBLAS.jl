#=
BFSParentsMultiSource:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
- Reference: https://en.wikipedia.org/wiki/Breadth-first_search
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra
using SuiteSparseGraphBLAS: Structural, Complement

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

    index = GBMatrix{Int64}(s, n; fill=nothing)
            for i = 1:n
                for j = 1:s
                    index[j, i] = i
                end
            end

    #frontier matrix -> F=S source nodes insrted in frontier
    F = mask(index, Structural(S))

    #parent matrix -> P[S]=S because the source is already visited
    P = F

    #result matrix -> R[S]=0 because the parents of the source are considered node 0
    R = GBMatrix{Int64}(s, n; fill=nothing)
    LR = GBMatrix{Int64}(s, n; fill=nothing)
    for i = 1:n
        for j = 1:s
            if(S[j, i] !== nothing && S[j, i] != 0)
                R[j, i] = 0
            end
        end
    end
    for _ ∈ 1:n-1
            F = *(F, A, (min, first), mask=Complement(P))
            P = copy(F)
            F = mask(index, Structural(F))
            R = insert(P, R, s, n)
            if(R == LR)
                break
            end
            LR = copy(R)

    end

    return R

end

