@testset "ewise" begin
    m = GBMatrix([[1,2,3] [4,5,6]])
    n = GBMatrix([1,2,3,2], [1,2,2,1], [1,2,3,4])
    #eadd correctness
    @test eadd(m, n) == GBMatrix([1,1,2,2,3,3], [1,2,1,2,1,2], [2,4,6,7,3,9])
    @test eadd(m, n, >)[1, 1] == 0
    @test eadd(m, n, >) == eadd(m, n, >)
    #emul correctness
    @test emul(m, n, ^)[3, 2] == m[3,2] ^ n[3,2]
    @test eltype(m .== n) == Bool

    # eunion shortcut forms with a scalar fill for one side
    E = GBMatrix([1.0 2; 3 4]); E2 = GBMatrix([1, 2], [1, 2], [10.0, 20.0], 2, 2)
    @test Matrix(eunion(E, 0.0, E2, +)) == Matrix(eunion(E, getfill(E), E2, getfill(E2), +))
    @test Matrix(eunion(E, E2, 0.0, +)) == Matrix(E) + Matrix(E2)
    @test Matrix(eunion!(similar(E), E, 0.0, E2, +)) == Matrix(E) + Matrix(E2)
    @test Matrix(eunion!(similar(E), E, E2, 0.0, +)) == Matrix(E) + Matrix(E2)
end
