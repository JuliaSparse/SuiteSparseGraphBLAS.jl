using FiniteDifferences
import LinearAlgebra
import ChainRulesCore: frule, rrule
using ChainRulesCore
const RealOrComplex = Union{Real, Complex}

#Required for ChainRulesTestUtils
function FiniteDifferences.to_vec(M::GBMatrix)
    x, back = FiniteDifferences.to_vec(Matrix(M))
    function backtomat(xvec)
        M2 = GBMatrix(back(xvec))
        return mask(M2, M; structural=true)
    end
    return x, backtomat
end

function FiniteDifferences.to_vec(v::GBVector)
    x, back = FiniteDifferences.to_vec(Vector(v))
    function backtovec(xvec)
        v2 = GBVector(back(xvec))
        return mask(v2, v; structural=true)
    end
    return x, backtovec
end

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

function find_k(A, B::GBArray, op, minmax; mask = nothing, accum = nothing, desc = nothing)
    K = []
    for col ∈ axes(B, 2)
        intermediate = broadcast_emul(A, B[:, col], op; mask, accum, desc)
        push!(K, argminmax(intermediate, minmax, 2))
    end
    return hcat(K...)
end
