using SuiteSparseGraphBLAS
using SuiteSparseGraphBLAS: pair
function triangle_centrality1(A)
    T = *(A, A', (+, *), mask=A)
    y = reduce(+, T, dims=2)
    k = reduce(+, y)
    return (3 * *(A, y) - 2 * *(T, y) .+ y) ./ k
end

function triangle_centrality(A)
    T = *(A, A', (+, pair), mask=A, Descriptor(structural_mask=true))
    y = reduce(+, T, dims=2)
    k = reduce(+, y)
    return (3.0 * *(A, y) .- (2.0 * *(T, y, (+, second))) .+ y) ./ k
end
