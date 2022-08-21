@testset "reduce" begin
    @testset "Reduction of Vec -> Scalar" begin
        v = GBVector(Int128.(1:10))
        @test reduce(+, v) == 55
        @test reduce(*, v) == 3628800
        @test reduce(+, v, dims=1) == 55
        @test reduce(+, v, dims=2) == v
    end
end
