using GraphBLASInterface, SuiteSparseGraphBLAS
using Test

@test GrB_init(GrB_NONBLOCKING) == GrB_SUCCESS

const testdir = dirname(@__FILE__)

tests = [
    "matrix_and_vector_methods",
]

@testset "SuiteSparseGraphBLAS" begin
    for t in tests
        tp = joinpath(testdir, "$(t).jl")
        include(tp)
    end
end
