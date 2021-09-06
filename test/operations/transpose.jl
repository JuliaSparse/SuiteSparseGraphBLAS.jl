@testset "transpose" begin
    m = GBMatrix(sprand(3, 3, 0.5))
    @test gbtranspose(m') == m
    @test m[1,2] == m'[2,1]
    @test m[1,2] == gbtranspose(m)[2,1]
end
