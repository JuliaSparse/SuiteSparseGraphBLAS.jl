#PLUS REDUCERS:
###############
function frule(
    (_, ΔA, ΔB),
    ::typeof(mul),
    A::GBArray,
    B::GBArray
)
    frule((nothing, ΔA, ΔB, nothing), mul, A, B, Semirings.PLUS_TIMES)
end
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_TIMES)
)
    Ω = mul(A, B, Semirings.PLUS_TIMES)
    ∂Ω = mul(unthunk(ΔA), B, Semirings.PLUS_TIMES) + mul(A, unthunk(ΔB), Semirings.PLUS_TIMES)
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_TIMES)
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), B', Semirings.PLUS_TIMES; mask=A)
        ∂B = mul(A', unthunk(ΔΩ), Semirings.PLUS_TIMES; mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B), mulpullback
end


function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray
)
    Ω, mulpullback = rrule(mul, A, B, Semirings.PLUS_TIMES)
    pullback(ΔΩ) = mulpullback(ΔΩ)[1:3]
return Ω, pullback
end


# PLUS_DIV:
# Missing frule here.
function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_DIV)
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), one(eltype(A)) ./ B', Semirings.PLUS_TIMES; mask=A)
        ∂B = (zero(eltype(A)) .- mul(A', unthunk(ΔΩ); mask=B)) ./ (B .^ 2.)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, Semirings.PLUS_DIV), mulpullback
end

# PLUS_PLUS:
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_PLUS)
)
    Ω = mul(A, B, Semirings.PLUS_PLUS)
    ∂Ω = mul(unthunk(ΔA), unthunk(ΔB), Semirings.PLUS_PLUS)
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_PLUS)
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), B', Semirings.PLUS_FIRST; mask=A)
        ∂B = mul(A', unthunk(ΔΩ), Semirings.PLUS_SECOND; mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, Semirings.PLUS_PLUS), mulpullback
end

# PLUS_MINUS:
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_MINUS)
)
    Ω = mul(A, B, Semirings.PLUS_MINUS)
    ∂Ω = mul(unthunk(ΔA), unthunk(ΔB), Semirings.PLUS_MINUS)
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_MINUS)
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), B', Semirings.PLUS_FIRST; mask=A)
        ∂B = mul(A', zero(eltype(unthunk(ΔΩ))) .- unthunk(ΔΩ), Semirings.PLUS_SECOND; mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, Semirings.PLUS_MINUS), mulpullback
end

# PLUS_FIRST:
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_FIRST)
)
    Ω = mul(A, B, Semirings.PLUS_FIRST)
    ∂Ω = mul(unthunk(ΔA), unthunk(ΔB), Semirings.PLUS_FIRST)
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_FIRST)
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), B', Semirings.PLUS_FIRST; mask=A)
        ∂B = NoTangent() # perhaps this should be ZeroTangent(), not sure.
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, Semirings.PLUS_FIRST), mulpullback
end

# PLUS_SECOND:
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_SECOND)
)
    Ω = mul(A, B, Semirings.PLUS_SECOND)
    ∂Ω = mul(unthunk(ΔA), unthunk(ΔB), Semirings.PLUS_SECOND)
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof(Semirings.PLUS_SECOND)
)
    function mulpullback(ΔΩ)
        ∂A = NoTangent()
        ∂B = mul(A', unthunk(ΔΩ), Semirings.PLUS_SECOND; mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, Semirings.PLUS_SECOND), mulpullback
end

# TROPICAL REDUCERS:

# MAX_PLUS:
