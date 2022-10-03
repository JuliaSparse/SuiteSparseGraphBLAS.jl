@testset "select" begin
    m = GBMatrix([[1,2,3] [4,5,6] [7,8,9]])
    s = select(tril, m)
    @test s[1,2] === getfill(s) && s[3,1] == 3
    s = select(<, m, 6)
    @test s[2,2] == 5 && s[3,3] === getfill(s)
end
