@testset "Dense" begin
    @testset "arithmetic semiring" begin
        #dense first
        M = GBMatrix(rand(-10.0:0.05:10.0, 10, 10))
        Y = GBMatrix(rand(-10.0:0.05:10.0, 10))
        test_frule(mul, M, Y; check_inferred=false)
        test_frule(mul, M, Y, Semirings.PLUS_TIMES; check_inferred=false)
        test_rrule(mul, M, Y; check_inferred=false)
        test_rrule(mul, M, Y, Semirings.PLUS_TIMES; check_inferred=false)
        X = GBMatrix(rand(-10.0:0.05:10.0, 10))
        test_frule(eadd, X, Y; check_inferred=false)
        test_frule(eadd, X, Y, BinaryOps.PLUS; check_inferred=false)
        test_rrule(eadd, X, Y; check_inferred=false)
        test_rrule(eadd, X, Y, BinaryOps.PLUS; check_inferred=false)
        test_frule(emul, X, Y; check_inferred=false)
        test_frule(emul, X, Y, BinaryOps.TIMES; check_inferred=false)
        test_rrule(emul, X, Y; check_inferred=false)
        test_rrule(emul, X, Y, BinaryOps.TIMES; check_inferred=false)
    end
end

@testset "Sparse" begin
    @testset "arithmetic semiring" begin
        M = GBMatrix(sprand(10, 10, 0.5))
        Y = GBMatrix(sprand(10, 0.5)) #using matrix for now until I work out transpose(v::GBVector)
        test_frule(mul, M, Y; check_inferred=false)
        test_frule(mul, M, Y, Semirings.PLUS_TIMES; check_inferred=false)
        test_rrule(mul, M, Y; check_inferred=false)
        test_rrule(mul, M, Y, Semirings.PLUS_TIMES; check_inferred=false)
        X = GBMatrix(sprand(10, 0.5))
        test_frule(eadd, X, Y; check_inferred=false)
        test_frule(eadd, X, Y, BinaryOps.PLUS; check_inferred=false)
        test_rrule(eadd, X, Y; check_inferred=false)
        test_rrule(eadd, X, Y, BinaryOps.PLUS; check_inferred=false)
        test_frule(emul, X, Y; check_inferred=false)
        test_frule(emul, X, Y, BinaryOps.TIMES; check_inferred=false)
        test_rrule(emul, X, Y; check_inferred=false)
        test_rrule(emul, X, Y, BinaryOps.TIMES; check_inferred=false)
    end
end
