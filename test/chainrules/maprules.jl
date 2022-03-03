@testset "Select" begin
    @testset "Dense" begin
        #dense first
        X = GBMatrix(rand(-10.0:0.05:10.0, 10, 10))
        test_frule(apply, sin, X)
        test_rrule(apply, sin, X)
        test_frule(apply, cos, X)
        test_rrule(apply, cos, X)
        test_frule(apply, tan, X)
        test_rrule(apply, tan, X)
        test_frule(apply, cosh, X)
        test_rrule(apply, cosh, X)
        test_frule(apply, sinh, X)
        test_rrule(apply, sinh, X)
        test_frule(apply, tanh, X)
        test_rrule(apply, tanh, X)
        test_frule(apply, inv, X)
        test_rrule(apply, inv, X)
        test_frule(apply, abs, X)
        test_rrule(apply, abs, X)
        test_frule(apply, identity, X)
        test_rrule(apply, identity, X)
        test_frule(apply, exp, X)
        test_rrule(apply, exp, X)
    end
    @testset "Sparse" begin
        X = GBMatrix(sprand(50, 50, 0.15))
    end
end
