import FiniteDifferences
import LinearAlgebra
import ChainRulesCore: frule, rrule
using ChainRulesCore
const RealOrComplex = Union{Real, Complex}

#Required for ChainRulesTestUtils
function FiniteDifferences.to_vec(M::GBMatrix)
    I, J, X = findnz(M)
    function backtomat(xvec)
        return GBMatrix(I, J, xvec; nrows = size(M, 1), ncols = size(M, 2))
    end
    return X, backtomat
end

function FiniteDifferences.to_vec(v::GBVector)
    i, x = findnz(v)
    function backtovec(xvec)
        return GBVector(i, xvec; nrows=size(v, 1))
    end
    return x, backtovec
end

function FiniteDifferences.rand_tangent(
    rng::AbstractRNG,
    x::GBMatrix{T}
) where {T <: Union{AbstractFloat, Complex}}
    n = nnz(x)
    v = rand(rng, -9:0.01:9, n)
    I, J, _ = findnz(x)
    return GBMatrix(I, J, v; nrows = size(x, 1), ncols = size(x, 2))
end

function FiniteDifferences.rand_tangent(
    rng::AbstractRNG,
    x::GBVector{T}
) where {T <: Union{AbstractFloat, Complex}}
    n = nnz(x)
    v = rand(rng, -9:0.01:9, n)
    I, _ = findnz(x)
    return GBVector(I, v; nrows = size(x, 1))
end

FiniteDifferences.rand_tangent(::AbstractRNG, ::AbstractOp) = NoTangent()
# LinearAlgebra.norm doesn't like the nothings.
LinearAlgebra.norm(A::GBArray, p::Real=2) = norm(nonzeros(A), p)

# Broadcast b into the rows of A. WARNING: THIS DOES NOT MATCH JULIA.
function broadcast_emul!(C, A, b, op; mask = nothing, accum = nothing, desc = nothing)
    B = diagm(b)
    mul!(C, A, B, (any, op); mask, accum, desc)
    return C
end

function broadcast_emul(A, b, op; mask = nothing, accum = nothing, desc = nothing)
    B = diagm(b)
    mul(A, B, (any, op); mask, accum, desc)
end
