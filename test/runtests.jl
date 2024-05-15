using SuiteSparseGraphBLAS
using SuiteSparseGraphBLAS: ispair, second, Structural, Complement, storedeltype, NoValue
using SparseArrays
using Test
using Random
using ChainRulesTestUtils
using ChainRulesCore
using FiniteDifferences
using CIndices
Random.seed!(1)

function include_test(path)
    println("Testing $path:")
    @time include(path)
end

# function ChainRulesTestUtils.rand_tangent(
#     rng::AbstractRNG,
#     x::GBMatrix{T}
# ) where {T <: Union{AbstractFloat, Complex}}
#     n = nnz(x)
#     v = rand(rng, -9:0.01:9, n)
#     I, J, _ = findnz(x)
#     return GBMatrix(I, J, v, size(x, 1), size(x, 2))
# end
# 
# function ChainRulesTestUtils.rand_tangent(
#     rng::AbstractRNG,
#     x::GBVector{T}
# ) where {T <: Union{AbstractFloat, Complex}}
#     n = nnz(x)
#     v = rand(rng, -9:0.01:9, n)
#     I, _ = findnz(x)
#     return GBVector(I, v, size(x, 1))
# end

# ChainRulesTestUtils.rand_tangent(::AbstractRNG, ::SuiteSparseGraphBLAS.AbstractOp) = NoTangent()
# ChainRulesTestUtils.test_approx(::NoValue, ::NoValue, msg=""; kwargs...) = @test true
# ChainRulesTestUtils.test_approx(::NoValue, x, msg=""; kwargs...) = ChainRulesTestUtils.test_approx(zero(x), x, msg; kwargs...)
# ChainRulesTestUtils.test_approx(x, ::NoValue, msg=""; kwargs...) = ChainRulesTestUtils.test_approx(x, zero(x), msg; kwargs...)

println("Testing SuiteSparseGraphBLAS.jl")
println("$(SuiteSparseGraphBLAS.get_lib())")
@testset "SuiteSparseGraphBLAS" begin
@testset "Low Level Interface" begin
    using SuiteSparseGraphBLAS: LowLevel
    include_test("libutils.jl")
end
    
    # include_test("operatorutils.jl")
    # include_test("ops.jl")
    # include_test("abstractgbarray.jl")
    # include_test("gbarray.jl")
    # include_test("types.jl")
    # include_test("issues.jl")
    # include_test("operations/ewise.jl")
    # include_test("operations/extract.jl")
    # include_test("operations/kron.jl")
    # include_test("operations/map.jl")
    # include_test("operations/mul.jl")
    # include_test("operations/reduce.jl")
    # include_test("operations/select.jl")
    # include_test("operations/transpose.jl")
    # include_test("operations/broadcasting.jl")
    # include_test("operations/concat.jl")
    # include_test("operations/operationutils.jl")
    # include_test("chainrules/chainrulesutils.jl")
    # include_test("chainrules/mulrules.jl")
    # include_test("chainrules/ewiserules.jl")
    # include_test("chainrules/selectrules.jl")
    # include_test("chainrules/constructorrules.jl")
    # include_test("chainrules/maprules.jl")
    # include_test("solvers/klu.jl")
    # include_test("solvers/umfpack.jl")
    # include_test("solvers/cholmod.jl")
end
