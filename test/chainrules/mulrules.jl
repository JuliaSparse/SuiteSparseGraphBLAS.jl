@testset "mul" begin
    @testset "Dense" begin
        M = GBMatrix(rand(-10.0:0.05:10.0, 10, 10))
        Y = GBMatrix(rand(-10.0:0.05:10.0, 10))
        N = GBMatrix(rand(-10.0:0.05:10.0, 10, 11))
        @testset "+.*" begin
            test_frule(*, M, Y)
            test_frule(*, M, Y, (+, *))
            test_rrule(*, M, Y)
            test_rrule(*, M, Y, (+, *))

            test_frule(*, M, N)
            test_frule(*, M, N, (+, *))
            test_rrule(*, M, N)
            test_rrule(*, M, N, (+, *))
        end

        @testset "+.÷" begin
            test_rrule(*, M, Y, (+, /))
            test_rrule(*, M, N, (+, /))
        end

        @testset "+.+" begin
            test_frule(*, M, Y, (+, +))
            test_frule(*, M, N, (+, +))
            test_rrule(*, M, Y, (+, +))
            test_rrule(*, M, N, (+, +))
        end

        @testset "+.-" begin
            test_frule(*, M, Y, (+, -))
            test_frule(*, M, N, (+, -))
            test_rrule(*, M, Y, (+, -))
            test_rrule(*, M, N, (+, -))
        end

        @testset "+.first" begin
            test_frule(*, M, Y, (+, first))
            test_frule(*, M, N, (+, first))
            test_rrule(*, M, Y ⊢ NoTangent(), (+, first))
            test_rrule(*, M, N ⊢ NoTangent(), (+, first))
        end
        @testset "+.second" begin
            test_frule(*, M, Y, (+, second))
            test_frule(*, M, N, (+, second))
            test_rrule(*, M ⊢ NoTangent(), Y, (+, second))
            test_rrule(*, M ⊢ NoTangent(), N, (+, second))
        end
    end

    @testset "Sparse" begin
        M = GBMatrix(sprand(20, 10, 0.25))
        Y = GBMatrix(sprand(10, 0.1))
        N = GBMatrix(sprand(10, 30, 0.05))
        @testset "+.*" begin
            test_frule(*, M, Y)
            test_frule(*, M, Y, (+, *))
            test_rrule(*, M, Y)
            test_rrule(*, M, Y, (+, *))

            test_frule(*, M, N)
            test_frule(*, M, N, (+, *))
            test_rrule(*, M, N)
            test_rrule(*, M, N, (+, *))
        end

        @testset "+.÷" begin
            test_rrule(*, M, Y, (+, /))
            test_rrule(*, M, N, (+, /))
        end

        @testset "+.+" begin
            test_frule(*, M, Y, (+, +))
            test_frule(*, M, N, (+, +))
            test_rrule(*, M, Y, (+, +))
            test_rrule(*, M, N, (+, +))
        end
        @testset "+.-" begin
            test_frule(*, M, Y, (+, -))
            test_frule(*, M, N, (+, -))
            test_rrule(*, M, Y, (+, -))
            test_rrule(*, M, N, (+, -))
        end
        @testset "+.first" begin
            test_frule(*, M, Y, (+, first))
            test_frule(*, M, N, (+, first))
            test_rrule(*, M, Y ⊢ NoTangent(), (+, first))
            test_rrule(*, M, N ⊢ NoTangent(), (+, first))
        end
        @testset "+.second" begin
            test_frule(*, M, Y, (+, second))
            test_frule(*, M, N, (+, second))
            test_rrule(*, M ⊢ NoTangent(), Y, (+, second))
            test_rrule(*, M ⊢ NoTangent(), N, (+, second))
        end
    end
end
