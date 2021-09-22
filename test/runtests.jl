using SuiteSparseGraphBLAS
using SparseArrays
using Test
using Random
using ChainRulesTestUtils
using ChainRulesCore
using FiniteDifferences
using SuiteSparseGraphBLAS
Random.seed!(1)

function include_test(path)
    println("Testing $path:")
    @time include(path)
end

function ChainRulesTestUtils.rand_tangent(
    rng::AbstractRNG,
    x::GBMatrix{T}
) where {T <: Union{AbstractFloat, Complex}}
    n = nnz(x)
    v = rand(rng, -9:0.01:9, n)
    I, J, _ = findnz(x)
    return GBMatrix(I, J, v; nrows = size(x, 1), ncols = size(x, 2))
end

function ChainRulesTestUtils.rand_tangent(
    rng::AbstractRNG,
    x::GBVector{T}
) where {T <: Union{AbstractFloat, Complex}}
    n = nnz(x)
    v = rand(rng, -9:0.01:9, n)
    I, _ = findnz(x)
    return GBVector(I, v; nrows = size(x, 1))
end

ChainRulesTestUtils.rand_tangent(::AbstractRNG, ::SuiteSparseGraphBLAS.AbstractOp) = NoTangent()

println("Testing SuiteSparseGraphBLAS.jl")
@testset "SuiteSparseGraphBLAS" begin

    #include_test("gbarray.jl")
    #include_test("operations.jl")
    #include_test("chainrules/chainrulesutils.jl")
    #include_test("chainrules/mulrules.jl")
    #include_test("chainrules/ewiserules.jl")
    #include_test("chainrules/selectrules.jl")
    #include_test("chainrules/constructorrules.jl")
    include_test("chainrules/maprules.jl")
end
