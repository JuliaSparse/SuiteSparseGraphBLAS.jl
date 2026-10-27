#=
BFSParents:
- Julia version: 1.6.2
- Author: samuel
- Date: 2021-09-10
- Reference: https://en.wikipedia.org/wiki/Breadth-first_search
=#

using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra
using SuiteSparseGraphBLAS: Structural, Complement, second

#function to insert inside the result array
function insert(p, result)
    for i=1:length(p)
        if(p[i]!=nothing && result[i]==nothing)
            result[i] = p[i]
        end
    end

    return result

end

#function to update visited nodes
function updateVisited(f, visited)
    for i=1:length(f)
        if(f[i]!=nothing)
            visited[i] = true
        end
    end

    return visited

end

#A is the input matrix, s is the source node, and n is the number of nodes, Output: parent matrix
function bfs_parents(A, s, n)

    index = GBVector{Int64}(n; fill=nothing)
        for i = 1:n
            index[i] = i
        end

    #wavefront vector -> w[s]=source node insrted in wavefront
    f = GBVector{Int64}(n; fill=nothing)
    f[s] = s

    #parent vector -> p[s]=1 because the source is already visited
    p = GBVector{Int64}(n; fill=nothing)

    #result vector -> result[s]=0 because the parent of the source is considered node 0
    result = GBVector{Int64}(n; fill=nothing)
    result[s] = 0

    #visited vector -> v[s]=1 because the source is already visited
    visited = GBVector{Bool}(n; fill=nothing)
    visited[s] = true

    for i = 1:n-1
            f = *(A', f, (min, second), mask=Complement(Structural(p)))
            p = copy(f)
            f = mask(index, Structural(f))
            result = insert(p, result)
            visited = updateVisited(f, visited)
            if(nnz(visited) == n)
                break
            end

    end

    return result

end