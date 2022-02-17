@testset "Select" begin
    @testset "Dense" begin
        #dense first
        X = GBMatrix(rand(-10.0:0.05:10.0, 10, 10))
        test_frule(map, sin, X)
        test_rrule(map, sin, X)
        test_frule(map, cos, X)
        test_rrule(map, cos, X)
        test_frule(map, tan, X)
        test_rrule(map, tan, X)
        test_frule(map, cosh, X)
        test_rrule(map, cosh, X)
        test_frule(map, sinh, X)
        test_rrule(map, sinh, X)
        test_frule(map, tanh, X)
        test_rrule(map, tanh, X)
        test_frule(map, inv, X)
        test_rrule(map, inv, X)
        test_frule(map, abs, X)
        test_rrule(map, abs, X)
        test_frule(map, identity, X)
        test_rrule(map, identity, X)
        test_frule(map, exp, X)
        test_rrule(map, exp, X)
    end
    @testset "Sparse" begin
        X = GBMatrix(sprand(50, 50, 0.15))
    end
end
