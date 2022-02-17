#PLUS REDUCERS:
###############
function frule(
    (_, ΔA, ΔB),
    ::typeof(mul),
    A::GBArray,
    B::GBArray
)
    frule((nothing, ΔA, ΔB, nothing), mul, A, B, (+, *))
end
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, *))
)
    Ω = mul(A, B, (+, *))
    ∂Ω = mul(unthunk(ΔA), B, (+, *)) + mul(A, unthunk(ΔB), (+, *))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, *))
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), B', (+, *); mask=A)
        ∂B = mul(A', unthunk(ΔΩ), (+, *); mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B), mulpullback
end


function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray
)
    Ω, mulpullback = rrule(mul, A, B, (+, *))
    pullback(ΔΩ) = mulpullback(ΔΩ)[1:3]
return Ω, pullback
end


# PLUS_DIV:
# Missing frule here.
function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, /))
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), one(eltype(A)) ./ B', (+, *); mask=A)
        ∂B = (zero(eltype(A)) .- mul(A', unthunk(ΔΩ); mask=B)) ./ (B .^ 2.)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, (+, /)), mulpullback
end

# PLUS_PLUS:
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, +))
)
    Ω = mul(A, B, (+, +))
    ∂Ω = mul(unthunk(ΔA), unthunk(ΔB), (+, +))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, +))
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), B', (+, first); mask=A)
        ∂B = mul(A', unthunk(ΔΩ), (+, second); mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, (+, +)), mulpullback
end

# PLUS_MINUS:
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, -))
)
    Ω = mul(A, B, (+, -))
    ∂Ω = mul(unthunk(ΔA), unthunk(ΔB), (+, -))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, -))
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), B', (+, first); mask=A)
        ∂B = mul(A', zero(eltype(unthunk(ΔΩ))) .- unthunk(ΔΩ), (+, second); mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, (+, -)), mulpullback
end

# PLUS_FIRST:
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, first))
)
    Ω = mul(A, B, (+, first))
    ∂Ω = mul(unthunk(ΔA), unthunk(ΔB), (+, first))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, first))
)
    function mulpullback(ΔΩ)
        ∂A = mul(unthunk(ΔΩ), B', (+, first); mask=A)
        ∂B = NoTangent() # perhaps this should be ZeroTangent(), not sure.
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, (+, first)), mulpullback
end

# PLUS_SECOND:
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, second))
)
    Ω = mul(A, B, (+, second))
    ∂Ω = mul(unthunk(ΔA), unthunk(ΔB), (+, second))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(mul),
    A::GBArray,
    B::GBArray,
    ::typeof((+, second))
)
    function mulpullback(ΔΩ)
        ∂A = NoTangent()
        ∂B = mul(A', unthunk(ΔΩ), (+, second); mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return mul(A, B, (+, second)), mulpullback
end

# TROPICAL REDUCERS:

# MAX_PLUS:
