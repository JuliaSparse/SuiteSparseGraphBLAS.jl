@testset "extract" begin
    m = GBVector([1,2,3,4,5,6])
    #extract correctness
    @test all(m[1:3] .== [1,2,3])
end
