@testset "reduce" begin
    # m = GBMatrix([[1,2,3] [4,5,6] [7,8,9]])
    # @test reduce(max, m, dims=2) == reduce(max, m) #this only works for dense
    # @test reduce(max, m, dims=(1,2)) == 9
    # @test_throws ArgumentError reduce(*, m) ?? I don't recognize this test. And it doesn't pass in older versions?
end
