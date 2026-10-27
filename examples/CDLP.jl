#=
CDLP:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
- Reference: https://doi.org/10.1103/PhysRevE.76.036106 (CDLP as defined in LDBC Graphalytics, https://arxiv.org/abs/2011.15028)
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra

#minMode function: given a collection [1, 5, 5, 3, 3, 7] will return 3 because the highest repetition is 2
#and the lowest most repeated number is 3
function minMode(c)

    temp = filter(x -> x!=0, c)
    count = Dict{eltype(temp), Int}()
    for x in temp
        count[x] = get(count, x, 0) + 1
    end
    repetitions = maximum(values(count))
    return minimum(key for (key, value) in count if value == repetitions)
end

#can be useful to tweak the algorithm
function diag_conversion(lab, n)
for i = 1:n
        for j = 1:n
            if(i==j)
                lab[i,j]=i
            else
                lab[i,j]=0
            end
        end
    end
    return lab
end

#A is the input matrix, n is the number of nodes, t the number of iterations Output: label propagation matrix
function cdlp(A, n, t)

    lab = GBMatrix{Int64}(n,n)

    for i = 1:n
        for j = 1:n
            if(i==j)
                lab[i,j]=i
            else
                lab[i,j]=0
            end
        end
    end

    for k = 1:t
            F = A * lab
            for i = 1:n
            r = nonzeros(F[i,:])
            lab[i, i] = minMode(r)
        end
    end
    return lab

end