@testset "ewise" begin
    m = GBMatrix([[1,2,3] [4,5,6]])
    n = GBMatrix([1,2,3,2], [1,2,2,1], [1,2,3,4])
    #eadd correctness
    @test eadd(m, n) == GBMatrix([1,1,2,2,3,3], [1,2,1,2,1,2], [2,4,6,7,3,9])
    @test eadd(m, n, BinaryOps.GT)[1, 1] == 0
    @test eadd(m, n, >) == eadd(m, n, BinaryOps.GT)
    #check that the (+) op is being picked up from the semiring.
    @test eadd(m, n, Semirings.PLUS_MAX) == eadd(m, n, BinaryOps.PLUS)
    #emul correctness
    @test emul(m, n, BinaryOps.POW)[3, 2] == m[3,2] ^ n[3,2]
    @test emul(m, n, ^) == emul(m, n, BinaryOps.POW)
    #check that the (*) op is being picked up from the semiring
    @test emul(m, n, Semirings.MAX_PLUS) == emul(m, n, BinaryOps.PLUS)
    @test eltype(m .== n) == Bool
end
