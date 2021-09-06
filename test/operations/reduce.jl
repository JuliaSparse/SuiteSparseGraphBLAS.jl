@testset "reduce" begin
    m = GBMatrix([[1,2,3] [4,5,6] [7,8,9]])
    reduce(max, m, dims=2) == reduce(Monoids.MAX_MONOID, m) #this only works for dense
    reduce(Monoids.MAX_MONOID, m, dims=(1,2)) == 9
    @test_throws ArgumentError reduce(BinaryOps.TIMES, m)
end
