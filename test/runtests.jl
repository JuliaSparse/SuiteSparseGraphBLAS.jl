using SuiteSparseGraphBLAS
using SparseArrays
using Test
using Random
using ChainRulesTestUtils
using ChainRulesCore
using FiniteDifferences
Random.seed!(1)

function include_test(path)
    println("Testing $path:")
    @time include(path)
end

println("Testing SuiteSparseGraphBLAS.jl")
@testset "SuiteSparseGraphBLAS" begin

    include_test("gbarray.jl")
    include_test("operations.jl")
    include_test("chainrules/chainrulesutils.jl")
    include_test("chainrules/mulrules.jl")
    include_test("chainrules/ewiserules.jl")
    include_test("chainrules/selectrules.jl")
    include_test("chainrules/constructorrules.jl")
end
