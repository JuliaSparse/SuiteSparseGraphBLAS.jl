@testset "broadcasting" begin
    A = gbrand(Float64, 10, 10, 0.5)
    # test that new binaryops works correctly!
    @test nonzeros(A .≈ A)[1]
end

