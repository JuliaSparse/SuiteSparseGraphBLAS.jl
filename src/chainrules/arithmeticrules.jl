import ChainRulesCore: frule, rrule
using ChainRulesCore
const RealOrComplex = Union{Real, Complex}
function frule(
    (_, ΔA, ΔB),
    ::typeof(mul),
    A::GBArray,
    B::GBArray
)
    Ω = mul(A, B)
    ∂Ω = mul(ΔA, B) + mul(A, ΔB)
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBVecOrMat{T},
    B::GBVecOrMat{T}
) where {T <: RealOrComplex}
    function mulpullback(ΔΩ)
        ∂A = mul(ΔΩ, B')
        ∂B = mul(A', ΔΩ)
        return (NoTangent(), ∂A, ∂B)
    end
    return mul(A, B), mulpullback
end
