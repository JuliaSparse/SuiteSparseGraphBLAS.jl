import FiniteDifferences: to_vec, rand_tangent
import LinearAlgebra: norm
#Required for ChainRulesTestUtils
function to_vec(M::GBMatrix)
    I, J, X = findnz(M)
    function backtomat(xvec)
        return GBMatrix(I, J, xvec)
    end
    return X, backtomat
end

function to_vec(v::GBVector)
    i, x = findnz(v)
    function backtovec(xvec)
        return GBVector(i, xvec)
    end
    return x, backtovec
end

function rand_tangent(
    rng::AbstractRNG,
    x::GBMatrix{T}
) where {T <: Union{AbstractFloat, Complex}}
    n = nnz(x)
    v = rand(rng, -9:0.01:9, n)
    I, J, _ = findnz(x)
    return GBMatrix(I, J, v)
end

function rand_tangent(
    rng::AbstractRNG,
    x::GBVector{T}
) where {T <: Union{AbstractFloat, Complex}}
    n = nnz(x)
    v = rand(rng, -9:0.01:9, n)
    I, _ = findnz(x)
    return GBVector(I, v)
end


# LinearAlgebra.norm freaks over the nothings.
norm(A::GBArray, p::Real=2) = norm(nonzeros(A), p)
