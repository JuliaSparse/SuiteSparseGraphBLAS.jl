function test_to_vec(x::T; check_inferred=true) where {T}
    check_inferred && @inferred FiniteDifferences.to_vec(x)
    x_vec, back = FiniteDifferences.to_vec(x)
    @test x_vec isa Vector
    @test all(s -> s isa Real, x_vec)
    check_inferred && @inferred back(x_vec)
    @test x == back(x_vec)
    return nothing
end

@testset "chainrulesutils" begin
    y = GBMatrix(sprand(10, 10, 0.5))
    test_to_vec(y)
    v = GBVector(sprand(10, 0.5))
    test_to_vec(v)
end
