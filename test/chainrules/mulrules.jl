@testset "mul" begin
    @testset "Dense" begin
        M = GBMatrix(rand(-10.0:0.05:10.0, 10, 10))
        Y = GBMatrix(rand(-10.0:0.05:10.0, 10))
        N = GBMatrix(rand(-10.0:0.05:10.0, 10, 11))
        @testset "+.*" begin
            test_frule(mul, M, Y)
            test_frule(mul, M, Y, (+, *))
            test_rrule(mul, M, Y)
            test_rrule(mul, M, Y, (+, *))

            test_frule(mul, M, N)
            test_frule(mul, M, N, (+, *))
            test_rrule(mul, M, N)
            test_rrule(mul, M, N, (+, *))
        end

        @testset "+.÷" begin
            test_rrule(mul, M, Y, (+, /))
            test_rrule(mul, M, N, (+, /))
        end

        @testset "+.+" begin
            test_frule(mul, M, Y, (+, +))
            test_frule(mul, M, N, (+, +))
            test_rrule(mul, M, Y, (+, +))
            test_rrule(mul, M, N, (+, +))
        end

        @testset "+.-" begin
            test_frule(mul, M, Y, (+, -))
            test_frule(mul, M, N, (+, -))
            test_rrule(mul, M, Y, (+, -))
            test_rrule(mul, M, N, (+, -))
        end

        @testset "+.first" begin
            test_frule(mul, M, Y, (+, first))
            test_frule(mul, M, N, (+, first))
            test_rrule(mul, M, Y ⊢ NoTangent(), (+, first))
            test_rrule(mul, M, N ⊢ NoTangent(), (+, first))
        end
        @testset "+.second" begin
            test_frule(mul, M, Y, (+, second))
            test_frule(mul, M, N, (+, second))
            test_rrule(mul, M ⊢ NoTangent(), Y, (+, second))
            test_rrule(mul, M ⊢ NoTangent(), N, (+, second))
        end
    end

    @testset "Sparse" begin
        M = GBMatrix(sprand(100, 10, 0.25))
        Y = GBMatrix(sprand(10, 0.1))
        N = GBMatrix(sprand(10, 75, 0.05))
        @testset "+.*" begin
            test_frule(mul, M, Y)
            test_frule(mul, M, Y, (+, *))
            test_rrule(mul, M, Y)
            test_rrule(mul, M, Y, (+, *))

            test_frule(mul, M, N)
            test_frule(mul, M, N, (+, *))
            test_rrule(mul, M, N)
            test_rrule(mul, M, N, (+, *))
        end

        @testset "+.÷" begin
            test_rrule(mul, M, Y, (+, /))
            test_rrule(mul, M, N, (+, /))
        end

        @testset "+.+" begin
            test_frule(mul, M, Y, (+, +))
            test_frule(mul, M, N, (+, +))
            test_rrule(mul, M, Y, (+, +))
            test_rrule(mul, M, N, (+, +))
        end
        @testset "+.-" begin
            test_frule(mul, M, Y, (+, -))
            test_frule(mul, M, N, (+, -))
            test_rrule(mul, M, Y, (+, -))
            test_rrule(mul, M, N, (+, -))
        end
        @testset "+.first" begin
            test_frule(mul, M, Y, (+, first))
            test_frule(mul, M, N, (+, first))
            test_rrule(mul, M, Y ⊢ NoTangent(), (+, first))
            test_rrule(mul, M, N ⊢ NoTangent(), (+, first))
        end
        @testset "+.second" begin
            test_frule(mul, M, Y, (+, second))
            test_frule(mul, M, N, (+, second))
            test_rrule(mul, M ⊢ NoTangent(), Y, (+, second))
            test_rrule(mul, M ⊢ NoTangent(), N, (+, second))
        end
    end
end
