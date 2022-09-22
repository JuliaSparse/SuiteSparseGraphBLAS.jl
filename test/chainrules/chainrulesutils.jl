#Required for ChainRulesTestUtils
function FiniteDifferences.to_vec(M::SuiteSparseGraphBLAS.AbstractGBMatrix)
    x, back = FiniteDifferences.to_vec(Matrix(M))
    function backtomat(xvec)
        M2 = GBMatrix(back(xvec))
        return mask!(M2, Structural(M))
    end
    return x, backtomat
end

function FiniteDifferences.to_vec(v::SuiteSparseGraphBLAS.AbstractGBVector)
    x, back = FiniteDifferences.to_vec(Vector(v))
    function backtovec(xvec)
        v2 = GBVector(back(xvec))
        return mask!(v2, Structural(v))
    end
    return x, backtovec
end

FiniteDifferences.to_vec(P::SuiteSparseGraphBLAS.Structural) = FiniteDifferences.to_vec(parent(P))

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
