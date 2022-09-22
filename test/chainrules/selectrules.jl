@testset "Select" begin
    @testset "Dense" begin
        #dense first
        X = GBMatrix(rand(-10.0:0.05:10.0, 10, 10))
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
        X = GBMatrix(sprand(4, 4, 0.5))
        print(X)
        test_frule(select, diag, X)
        test_rrule(select, diag, X)
        println("diag")
        test_frule(select, offdiag, X)
        test_rrule(select, offdiag, X)
        println("offdiag")
        test_frule(select, tril, X)
        test_rrule(select, tril, X)
        test_frule(select, triu, X)
        test_rrule(select, triu, X)
        println("tris")
        test_frule(select, nonzeros, X)
        test_rrule(select, nonzeros, X)
        println("nonzeros")
        test_frule(select, >, X, 0.)
        test_rrule(select, >, X, 0.)
        test_frule(select, <=, X, 0.)
        test_rrule(select, <=, X, 0.)
        println("equalities")
    end
end
