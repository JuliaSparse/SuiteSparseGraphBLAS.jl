@testset "Constructors" begin
    @testset "Vector" begin
        @testset "Dense Vector" begin
            test_frule(GBVector, rand(-10.0:0.05:10.0, 10))
            test_rrule(GBVector, rand(-10.0:0.05:10.0, 10))
        end
        @testset "Sparse Vector" begin
            test_frule(GBVector, [1,3,5] ⊢ NoTangent(), rand(-10.0:0.05:10.0, 3))
            test_rrule(GBVector, [1,4,5] ⊢ NoTangent(), rand(-10.0:0.05:10.0, 3))
        end
    end
    @testset "Matrix" begin
        @testset "Dense Matrix and Vector" begin
            M = rand(-10.0:0.05:10.0, 10, 20)
            v = rand(-10.0:0.05:10.0, 10)
            test_frule(GBMatrix, M)
            test_rrule(GBMatrix, M)
            test_frule(GBMatrix, v)
            test_rrule(GBMatrix, v)
        end
        @testset "Sparse Matrix and Vector" begin
            test_frule(GBMatrix, [1, 3, 5] ⊢ NoTangent(), [1, 3, 4] ⊢ NoTangent(), rand(-10.0:0.05:10.0, 3))
            test_frule(GBMatrix, [1, 3, 5] ⊢ NoTangent(),  rand(-10.0:0.05:10.0, 3))
        end
    end
end
