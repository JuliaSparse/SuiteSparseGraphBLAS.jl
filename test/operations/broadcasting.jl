@testset "broadcasting" begin
    A = gbrand(Float64, 10, 10, 0.5)
    # test that ephemeral binaryops work correctly
    @test nonzeros(A .≈ A)[1]


    A = GBMatrix([[1,2] [3,4]])
    @test (A .= A .* A)[2, 2] == 16 
    @test (A .+= 3)[1, 1] == 4
    B = GBMatrix(zeros(2, 2))
    @test sum(B .*= A) == 0
    @test (B .+= identity.(A) .* 1) == A

    A = GBMatrix([[1,2] [3,4]])
    B .= sqrt.(A .^ 2)
    @test B == A

    u = rand(1000)
    v = GBVector(u)
    @test sin.(u) ≈ Vector(sin.(v))
    @testset "Dimensional Broadcasting" begin
        A = rand(3,5)
        u = rand(3)
        v = rand(5)

        G = GBMatrix(A)
        uG = GBVector(u)
        vG = GBVector(v)

        @test A .* u ≈ G .* uG ≈ u .* A ≈ uG .* G
        @test_throws DimensionMismatch G .* vG

        @test A .* v' ≈ G .* vG' ≈ v' .* A ≈ vG' .* G
        @test_throws DimensionMismatch uG' .* G
        @test_throws DimensionMismatch G .* uG'

        @test u .* u ≈ uG .* uG
        @test_throws DimensionMismatch uG .* vG
        @test u' .* u' ≈ uG' .* uG'
        @test_throws DimensionMismatch uG' .* vG'

        @test u .* v' ≈ uG .* vG'
        @test v' .* u ≈ vG' .* uG
        @test v .* u' ≈ vG .* uG'
        @test u' .* v ≈ uG' .* vG

        # tests without a _swapop
        @test A .^ u ≈ G .^ uG
        @test u .^ A ≈ uG .^ G
        @test A .^ v' ≈ G .^ vG'
        @test v' .^ A ≈ vG' .^ G
        @test u' .^ u' ≈ uG' .^ uG'

        @test u .^ v' ≈ uG .^ vG'
        @test v' .^ u ≈ vG' .^ uG
        @test v .^ u' ≈ vG .^ uG'
        @test u' .^ v ≈ uG' .^ vG
    end
end

