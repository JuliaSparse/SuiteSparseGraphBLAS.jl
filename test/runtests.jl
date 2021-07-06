using SuiteSparseGraphBLAS
using SparseArrays
using Test
using Random
using ChainRulesTestUtils
Random.seed!(1)

function include_test(path)
    println("Testing $path:")
    @time include(path)
end

println("Testing SuiteSparseGraphBLAS.jl")
@testset "SuiteSparseGraphBLAS" begin
    include_test("gbarray.jl")
    include_test("operations.jl")
    include_test("testrules.jl")
end
