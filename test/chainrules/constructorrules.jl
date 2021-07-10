@testset "Construction Rules" begin
    I = [1,1,2,2,3,4,4,5,6,7,7,7]
    J = [2,4,5,7,6,1,3,6,3,3,4,5]
    X = rand(12)

    test_frule(GBMatrix, I, J, X)
    test_rrule(GBMatrix, I, J, X)
    test_rrule(GBVector, I, X)

end
