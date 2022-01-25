@testset "map" begin
    m = sprand(5, 5, 0.25)
    n = GBMatrix(m)
    @test map(UnaryOps.LOG, n)[1,1] == map(log, m)[1,1]
    o = map!(>, GBMatrix{Bool}(5, 5),  0.1, n)
    # @test o[1,4] == (0.1 > m[1,4])
    @test map(second, n, 1.5)[1,1] == 1.5
    @test (n .* 10)[1,1] == n[1,1] * 10
    # Julia will map over the entire array, rather than just nnz.
    # so just test [1,1]
    @test map((x) -> 1.5, n)[1,1] == map((x) -> 1.5, m)[1,1]
end
