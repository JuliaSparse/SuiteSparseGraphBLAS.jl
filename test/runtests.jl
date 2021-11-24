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

# Inefficient, but doesn't matter, only doing small matrices
function FiniteDifferences.to_vec(M::SparseMatrixCSC)
    x, back = FiniteDifferences.to_vec(Matrix(M))
    function backtomat(xvec)
        M2 = back(xvec)
        M_out = copy(M)
        nz = findnz(M_out)
        for j ∈ nz[1], i ∈ nz[2]
            M_out[i,j] = M2[i, j]
        end
        return M_out
    end
    return x, backtomat
end
function FiniteDifferences.to_vec(M::SparseVector)
    x, back = FiniteDifferences.to_vec(Vector(M))
    function backtovec(xvec)
        M2 = back(xvec)
        M_out = copy(M)
        nz = findnz(M_out)
        for i ∈ nz[1]
            M_out[i] = M2[i]
        end
        return M_out
    end
    return x, backtovec
end
ChainRulesTestUtils.rand_tangent(::AbstractRNG, ::SuiteSparseGraphBLAS.AbstractOp) = NoTangent()

println("Testing SuiteSparseGraphBLAS.jl")
@testset "SuiteSparseGraphBLAS" begin

    include_test("gbarray.jl")
    include_test("operations.jl")
    include_test("chainrules/chainrulesutils.jl")
    include_test("chainrules/mulrules.jl")
    include_test("chainrules/ewiserules.jl")
    include_test("chainrules/selectrules.jl")
    include_test("chainrules/constructorrules.jl")
    include_test("chainrules/maprules.jl")
    include_test("sparsemat.jl")
end
