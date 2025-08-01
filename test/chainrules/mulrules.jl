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
        Y = GBMatrix(sprand(10, 0.5))
        # there's some sort of hangup when we hit completely zero matrices.
        # But I can't replicate outside of Test.jl...
        # TODO: *really* fix this.
        if nnz(Y) == 0
            Y[rand(1:10), 1] = rand(storedeltype(Y))
        end
        N = GBMatrix(sprand(10, 30, 0.05))
        if nnz(N) == 0
            N[rand(1:10), rand(1:30)] = rand(storedeltype(N))
        end
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
