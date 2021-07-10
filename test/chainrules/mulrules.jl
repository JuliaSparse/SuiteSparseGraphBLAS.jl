@testset "mul" begin
    @testset "Dense" begin
        @testset "Arithmetic Semiring" begin
            M = GBMatrix(rand(-10.0:0.05:10.0, 10, 10))
            Y = GBMatrix(rand(-10.0:0.05:10.0, 10))
            test_frule(mul, M, Y; check_inferred=false)
            test_frule(mul, M, Y, Semirings.PLUS_TIMES; check_inferred=false)
            test_rrule(mul, M, Y; check_inferred=false)
            test_rrule(mul, M, Y, Semirings.PLUS_TIMES; check_inferred=false)
        end
    end

    @testset "Sparse" begin
        M = GBMatrix(sprand(100, 10, 0.25))
        Y = GBMatrix(sprand(10, 0.1)) #using matrix for now until I work out transpose(v::GBVector)
        test_frule(mul, M, Y; check_inferred=false)
        test_frule(mul, M, Y, Semirings.PLUS_TIMES; check_inferred=false)
        test_rrule(mul, M, Y; check_inferred=false)
        test_rrule(mul, M, Y, Semirings.PLUS_TIMES; check_inferred=false)
    end
end
