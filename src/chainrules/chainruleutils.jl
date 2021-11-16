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
