@testset "mul" begin
    @testset "Dense" begin
        M = GBMatrix(rand(-10.0:0.05:10.0, 10, 10))
        Y = GBMatrix(rand(-10.0:0.05:10.0, 10))
        N = GBMatrix(rand(-10.0:0.05:10.0, 10, 11))
        @testset "+.*" begin
            test_frule(mul, M, Y)
            test_frule(mul, M, Y, Semirings.PLUS_TIMES)
            test_rrule(mul, M, Y)
            test_rrule(mul, M, Y, Semirings.PLUS_TIMES)

            test_frule(mul, M, N)
            test_frule(mul, M, N, Semirings.PLUS_TIMES)
            test_rrule(mul, M, N)
            test_rrule(mul, M, N, Semirings.PLUS_TIMES)
        end

        @testset "+.÷" begin
            test_rrule(mul, M, Y, Semirings.PLUS_DIV)
            test_rrule(mul, M, N, Semirings.PLUS_DIV)
        end

        @testset "+.+" begin
            test_frule(mul, M, Y, Semirings.PLUS_PLUS)
            test_frule(mul, M, N, Semirings.PLUS_PLUS)
            test_rrule(mul, M, Y, Semirings.PLUS_PLUS)
            test_rrule(mul, M, N, Semirings.PLUS_PLUS)
        end

        @testset "+.-" begin
            test_frule(mul, M, Y, Semirings.PLUS_MINUS)
            test_frule(mul, M, N, Semirings.PLUS_MINUS)
            test_rrule(mul, M, Y, Semirings.PLUS_MINUS)
            test_rrule(mul, M, N, Semirings.PLUS_MINUS)
        end
    end

    @testset "Sparse" begin
        M = GBMatrix(sprand(100, 10, 0.25))
        Y = GBMatrix(sprand(10, 0.1))
        N = GBMatrix(sprand(10, 75, 0.05))
        @testset "+.*" begin
            test_frule(mul, M, Y)
            test_frule(mul, M, Y, Semirings.PLUS_TIMES)
            test_rrule(mul, M, Y)
            test_rrule(mul, M, Y, Semirings.PLUS_TIMES)

            test_frule(mul, M, N)
            test_frule(mul, M, N, Semirings.PLUS_TIMES)
            test_rrule(mul, M, N)
            test_rrule(mul, M, N, Semirings.PLUS_TIMES)
        end

        @testset "+.÷" begin
            test_rrule(mul, M, Y, Semirings.PLUS_DIV)
            test_rrule(mul, M, N, Semirings.PLUS_DIV)
        end

        @testset "+.+" begin
            test_frule(mul, M, Y, Semirings.PLUS_PLUS)
            test_frule(mul, M, N, Semirings.PLUS_PLUS)
            test_rrule(mul, M, Y, Semirings.PLUS_PLUS)
            test_rrule(mul, M, N, Semirings.PLUS_PLUS)
        end
        @testset "+.-" begin
            test_frule(mul, M, Y, Semirings.PLUS_MINUS)
            test_frule(mul, M, N, Semirings.PLUS_MINUS)
            test_rrule(mul, M, Y, Semirings.PLUS_MINUS)
            test_rrule(mul, M, N, Semirings.PLUS_MINUS)
        end
    end
end
