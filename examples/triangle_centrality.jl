using SuiteSparseGraphBLAS
function triangle_centrality1(A)
    T = mul(A, A', (+, *), mask=A)
    y = reduce(+, T, dims=2)
    k = reduce(+, y)
    return (3 * mul(A, y) - 2 * mul(T, y) .+ y) ./ k
end

function triangle_centrality2(A)
    T = mul(A, A', (+, pair), mask=A, Descriptor(structural_mask=true))
    y = reduce(+, T, dims=2)
    k = reduce(+, y)
    return map(*, eadd(eadd(3.0 * mul(A, y), 2.0 * mul(T, y, (+, second)), -), y), 1/k)
end
