function triangle_centrality1(A)
    T = mul(A, A', Semirings.PLUS_TIMES[Float64], mask=A)
    y = reduce(Monoids.PLUS_MONOID[Float64], T, dims=2)
    k = reduce(Monoids.PLUS_MONOID[Float64], y)
    return (3 * mul(A, y) - 2 * mul(T, y) .+ y) ./ k
end

function triangle_centrality2(A)
    T = mul(A, A', Semirings.PLUS_PAIR, mask=A, desc=Descriptors.S)
    y = reduce(Monoids.PLUS_MONOID[Float64], T, dims=2)
    k = reduce(Monoids.PLUS_MONOID[Float64], y)
    return map(BinaryOps.TIMES, eadd(eadd(3.0 * mul(A, y), 2.0 * mul(T, y, Semirings.PLUS_SECOND), BinaryOps.MINUS), y), 1/k)
end
