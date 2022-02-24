import LinearAlgebra
import ChainRulesCore: frule, rrule
using ChainRulesCore
const RealOrComplex = Union{Real, Complex}

# LinearAlgebra.norm doesn't like the nothings.
LinearAlgebra.norm(A::GBArray, p::Real=2) = norm(nonzeros(A), p)
