using SuiteSparseGraphBLAS
function pagerank(
    A::SuiteSparseGraphBLAS.GBArray,
    d = reduce(+, A; dims=2),
    α = 0.85,
    maxiters = 100,
    ϵ = 1.0e-6
)
    n = size(A, 1)
    r = GBVector{Float64}(n)
    t = GBVector{Float64}(n)
    d[:, accum=/] = α
    r[:] = 1.0 / n
    teleport = (1 - α) / n
    rdiff = 1.0
    i = 0
    for outer i ∈ 1:maxiters
        temp = t; t = r; r = temp
        w = t ./ d
        r[:] = teleport
        mul!(r, A', w, (+, second), accum=+)
        t .-= r
        map!(abs, t)
        rdiff = reduce(+, t)
        if rdiff <= ϵ
            break
        end
    end
    return r, i
end
