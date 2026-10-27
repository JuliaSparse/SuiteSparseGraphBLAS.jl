#=
Triangle centrality:
- Reference: https://arxiv.org/abs/2105.00110, https://doi.org/10.1109/HPEC49654.2021.9622789
=#

using SuiteSparseGraphBLAS
using SuiteSparseGraphBLAS: pair, second

#A is the adjacency matrix of an undirected graph with unit weights, Output: triangle centrality of each vertex
function triangle_centrality1(A)
    T = *(A, A', (+, *), mask=A)
    y = reduce(+, T, dims=2)
    k = reduce(+, y)
    return (3 * *(A, y) - 2 * *(T, y, (+, second)) .+ y) ./ k
end

function triangle_centrality(A)
    T = *(A, A', (+, pair), mask=A, desc=Descriptor(structural_mask=true))
    y = reduce(+, T, dims=2)
    k = reduce(+, y)
    return (3.0 * *(A, y) - (2.0 * *(T, y, (+, second))) .+ y) ./ k
end
