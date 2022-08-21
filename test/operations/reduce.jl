@testset "reduce" begin
    @testset "Reduction of Vec -> Scalar" begin
        v = GBVector(1:10)
        @test reduce(+, v) == 55
        @test reduce(*, v) == 3628800
    end
end
