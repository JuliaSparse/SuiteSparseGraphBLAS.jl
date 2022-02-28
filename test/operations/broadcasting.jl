@testset "broadcasting" begin
    A = gbrand(Float64, 10, 10, 0.5)
    # test that new binaryops works correctly!
    @test nonzeros(A .≈ A)[1]

    A = GBMatrix([[1,2] [3,4]])
    @test (A .= A .* A)[2, 2] == 16
    @test (A .+= 3)[1, 1] == 4
    B = GBMatrix(zeros(2, 2))
    @test sum(B .*= A) == 0
    @test (B .+= identity.(A) .* 1) == A

    u = rand(1000)
    v = GBVector(u)
    @test sin.(u) ≈ Vector(sin.(v))
end

