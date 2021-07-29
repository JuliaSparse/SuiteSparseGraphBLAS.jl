using SuiteSparseGraphBLAS
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
