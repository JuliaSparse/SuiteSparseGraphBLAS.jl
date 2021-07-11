# Standard arithmetic mul:
function frule(
    (_, ΔA, ΔB),
    ::typeof(mul),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose
)
    frule((nothing, ΔA, ΔB, nothing), mul, A, B, Semirings.PLUS_TIMES)
end
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    ::typeof(Semirings.PLUS_TIMES)
)
    Ω = mul(A, B, Semirings.PLUS_TIMES)
    ∂Ω = mul(ΔA, B, Semirings.PLUS_TIMES) + mul(A, ΔB, Semirings.PLUS_TIMES)
    return Ω, ∂Ω
end
# Tests will not pass for this. For two reasons.
# First is #25, the output inference is not type stable.
# That's it's own issue.

# Second, to_vec currently works by mapping materialized values back and forth, ie. it knows nothing about nothings.
# This means they give different answers. FiniteDifferences is probably "incorrect", but I have no proof.

function rrule(
    ::typeof(mul),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    ::typeof(Semirings.PLUS_TIMES)
)
    function mulpullback(ΔΩ)
        ∂A = mul(ΔΩ, B', Semirings.PLUS_TIMES; mask=A)
        ∂B = mul(A', ΔΩ, Semirings.PLUS_TIMES; mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B), mulpullback
end


function rrule(
    ::typeof(mul),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose
)
    Ω, mulpullback = rrule(mul, A, B, Semirings.PLUS_TIMES)
    pullback(ΔΩ) = mulpullback(ΔΩ)[1:3]
return Ω, pullback
end


# PLUS_DIV:
function rrule(
    ::typeof(mul),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    ::typeof(Semirings.PLUS_DIV)
)
    function mulpullback(ΔΩ)
        ∂A = mul(ΔΩ, one(eltype(A)) ./ B', Semirings.PLUS_TIMES; mask=A)
        ∂B = (zero(eltype(A)) .- mul(A', ΔΩ; mask=B)) ./ (B .^ 2.)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, Semirings.PLUS_DIV), mulpullback
end

# PLUS_PLUS:
function rrule(
    ::typeof(mul),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    ::typeof(Semirings.PLUS_PLUS)
)
    function mulpullback(ΔΩ)
        ∂A = mul(ΔΩ, B', Semirings.PLUS_FIRST; mask=A)
        ∂B = mul(A', ΔΩ, Semirings.PLUS_SECOND; mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, Semirings.PLUS_PLUS), mulpullback
end

# PLUS_MINUS:
function rrule(
    ::typeof(mul),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    ::typeof(Semirings.PLUS_MINUS)
)
    function mulpullback(ΔΩ)
        ∂A = mul(ΔΩ, B', Semirings.PLUS_FIRST; mask=A)
        ∂B = mul(A', zero(eltype(ΔΩ)) .- ΔΩ, Semirings.PLUS_SECOND; mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, Semirings.PLUS_MINUS), mulpullback
end
