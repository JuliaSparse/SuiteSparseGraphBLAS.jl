@testset "Select" begin
    @testset "Dense" begin
        #dense first
        X = GBMatrix(rand(-10.0:0.05:10.0, 10))
        test_frule(select, diag, X)
        test_rrule(select, diag, X)
        test_frule(select, offdiag, X)
        test_rrule(select, offdiag, X)
        test_frule(select, tril, X)
        test_rrule(select, tril, X)
        test_frule(select, triu, X)
        test_rrule(select, triu, X)
        test_frule(select, nonzeros, X)
        test_rrule(select, nonzeros, X)
        test_frule(select, >, X, 0.)
        test_rrule(select, >, X, 0.)
        test_frule(select, <=, X, 0.)
        test_rrule(select, <=, X, 0.)
    end
    @testset "Sparse" begin
        X = GBMatrix(sprand(50, 50, 0.15))
        test_frule(select, diag, X)
        test_rrule(select, diag, X)
        test_frule(select, offdiag, X)
        test_rrule(select, offdiag, X)
        test_frule(select, tril, X)
        test_rrule(select, tril, X)
        test_frule(select, triu, X)
        test_rrule(select, triu, X)
        test_frule(select, nonzeros, X)
        test_rrule(select, nonzeros, X)
        @test_broken test_frule(select, >, X, 0.)
        @test_broken test_rrule(select, >, X, 0.)
        @test_broken test_frule(select, <=, X, 0.)
        @test_broken test_rrule(select, <=, X, 0.)
    end
end
