# Standard arithmetic mul:
function frule(
    (_, ΔA, ΔB),
    ::typeof(mul),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose
)
    Ω = mul(A, B)
    ∂Ω = mul(ΔA, B) + mul(A, ΔB)
    return Ω, ∂Ω
end

# Tests will not pass for this. For two reasons.
# First is #25, the output inference is not type stable.
# That's it's own issue.

# Second, to_vec currently works by mapping materialized values back and forth, ie. it knows nothing about nothings.
# This means they give different answers. FiniteDifferences is probably "incorrect".
function rrule(
    ::typeof(mul),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose
)
    function mulpullback(ΔΩ)
        ∂A = mul(ΔΩ, B')
        ∂B = mul(A', ΔΩ)
        return NoTangent(), ∂A, ∂B
    end
    return mul(A, B), mulpullback
end
