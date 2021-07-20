using SuiteSparseGraphBLAS
using MatrixMarket
using SparseArrays
function pagerank(
    A,
    d = reduce(Monoids.PLUS_MONOID, A; dims=2),
    α = 0.85,
    maxiters = 100,
    ϵ = 1.0e-4
)
    n = size(A, 1)
    r = GBVector{Float32}(n)
    t = GBVector{Float32}(n)
    d[:, accum=BinaryOps.DIV] = α
    r[:] = 1.0 / n
    teleport = (1 - α) / n
    rdiff = 1.0
    i = 0
    for outer i ∈ 1:maxiters
        temp = t; t = r; r = temp
        w = t ./ d
        r[:] = teleport
        mul!(r, A', w, Semirings.PLUS_SECOND, accum=BinaryOps.PLUS)
        t .-= r
        map!(UnaryOps.ABS, t)
        rdiff = reduce(Monoids.PLUS_MONOID, t)
        if rdiff <= ϵ
            break
        end
    end
    return r, i
end


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
