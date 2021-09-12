#=
CDLP:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra
using DataStructures

#minMode function: given a collection [1, 5, 5, 3, 3, 7] will return 3 because the highest repetition is 2
#and the lowest most repeated number is 3
function minMode(c)

    minVal = -1
    i = 0

    for row in eachrow(c)
    i = i+1
    row = collect(row)
    temp = filter(x -> x!=0, row)
    count = counter(temp)
    sortedCollection = sort(collect(count), by=x->x[2], rev=true)
    minVal = sortedCollection[1][1]
    repetitions = sortedCollection[1][2]
    for (key, value) in sortedCollection
        if(value == repetitions)
            if(key < minVal)
                minVal = key
            end
        end
    end

    end

    return minVal
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
            F = mul(A, lab, Semirings.PLUS_TIMES)
            for i = 1:n
            r = F[i,:]
            r = sort(r, dims=2)
            lab[i, i] = minMode(r)
        end

    end

    return lab

end