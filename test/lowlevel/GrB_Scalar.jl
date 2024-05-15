@testset "GrB_Scalars" begin
    s = GrB.GrB_Scalar{Int64}()
    s2 = GrB.dup(s)
    @test GrB.nvals(s) == GrB.nvals(s2)
    s2[] = 3
    @test GrB.nvals(s) != GrB.nvals(s2)
    @test s2[] == 3
    @test GrB.nvals(GrB.clear!(s2)) == GrB.nvals(s)
    
    @test_throws InexactError s[] = 3.5

    @test GrB.GrB_Scalar{Int64}(3.0)[] == GrB.GrB_Scalar(Int64(3))[]
end
