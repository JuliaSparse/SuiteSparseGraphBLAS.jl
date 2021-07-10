@testset "Elementwise" begin
    @testset "Dense" begin
        @testset "Arithmetic Semiring" begin
            #dense first
            Y = GBMatrix(rand(-10.0:0.05:10.0, 10))
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
        @testset "Arithmetic Semiring" begin
            Y = GBMatrix(sprand(10, 0.5)) #using matrix for now until I work out transpose(v::GBVector)
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
end
