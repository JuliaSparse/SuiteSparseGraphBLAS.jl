@testset "map" begin
    m = sprand(5, 5, 0.25)
    n = GBMatrix(m)
    nonzero = Int64.(first.(nonzeroinds(n)))
    @test map(log, n)[nonzero...] == map(log, m)[nonzero...]
    o = map!(>, GBMatrix{Bool}(5, 5),  0.1, n)
    # @test o[1,4] == (0.1 > m[1,4])
    @test map(second, n, 1.5)[nonzero...] == 1.5
    @test (n .* 10)[nonzero...] == n[nonzero...] * 10
    # Julia will map over the entire array, rather than just nnz.
    # so just test [1,1]
    @test map((x) -> 1.5, n)[nonzero...] == map((x) -> 1.5, m)[nonzero...]
end
