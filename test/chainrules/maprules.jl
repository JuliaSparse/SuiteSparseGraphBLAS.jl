@testset "Select" begin
    @testset "Dense" begin
        #dense first
        X = GBMatrix(rand(-10.0:0.05:10.0, 10, 10))
        test_frule(map, UnaryOps.SIN, X)
        test_rrule(map, UnaryOps.SIN, X)
        test_frule(map, UnaryOps.COS, X)
        test_rrule(map, UnaryOps.COS, X)
        test_frule(map, UnaryOps.COSH, X)
        test_rrule(map, UnaryOps.COSH, X)
        test_frule(map, UnaryOps.SINH, X)
        test_rrule(map, UnaryOps.SINH, X)
        test_frule(map, UnaryOps.TANH, X)
        test_rrule(map, UnaryOps.TANH, X)
        X = GBMatrix(rand(0.0:1.0, 10, 10))
        test_frule(map, UnaryOps.ASIN, X)
        test_rrule(map, UnaryOps.ASIN, X)
        #test_frule(map, UnaryOps.ACOS, X)
        #test_rrule(map, UnaryOps.ACOS, X)
        #test_frule(map, UnaryOps.ATAN, X)
        #test_rrule(map, UnaryOps.ATAN, X)
    end
    @testset "Sparse" begin
        X = GBMatrix(sprand(50, 50, 0.15))
    end
end
