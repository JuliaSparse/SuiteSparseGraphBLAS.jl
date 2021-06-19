@testset "operations.jl" begin
    @testset "ewise" begin
        @testset "eadd" begin
            m = GBMatrix([[1,2,3] [4,5,6]])
            n = GBMatrix([1,2,3,2], [1,2,2,1], [1,2,3,4])
            @test eadd(m, n) == GBMatrix([1,1,2,2,3,3], [1,2,1,2,1,2], [2,4,6,7,3,9])
            @test eadd(m, n; op = BinaryOps.GT)[1, 1] == 0
            @test emul(m, n; op = BinaryOps.POW)[3, 2] == 216
            @test emul(m, n; op = Semirings.MAX_PLUS) == emul(m, n; op = BinaryOps.PLUS)
        end
    end
end
