#PLUS REDUCERS:
###############
function frule(
    (_, ΔA, ΔB)::Tuple,
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray
)
    frule((nothing, ΔA, ΔB, nothing), *, A, B, (+, *))
end
function frule(
    (_, ΔA, ΔB, _)::Tuple,
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, *))
)
    Ω = *(A, B, (+, *))
    ∂Ω = *(unthunk(ΔA), B, (+, *)) + *(A, unthunk(ΔB), (+, *))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, *))
)
    function mulpullback(ΔΩ)
        ∂A = *(unthunk(ΔΩ), B', (+, *); mask=A)
        ∂B = *(A', unthunk(ΔΩ), (+, *); mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return *(A, B), mulpullback
end


function rrule(
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray
)
    Ω, mulpullback = rrule(*, A, B, (+, *))
    pullback(ΔΩ) = mulpullback(ΔΩ)[1:3]
return Ω, pullback
end


# PLUS_DIV:
# Missing frule here.
function rrule(
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, /))
)
    function mulpullback(ΔΩ)
        ∂A = *(unthunk(ΔΩ), one(eltype(A)) ./ B', (+, *); mask=A)
        ∂B = (zero(eltype(A)) .- *(A', unthunk(ΔΩ); mask=B)) ./ (B .^ 2.)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return *(A, B, (+, /)), mulpullback
end

# PLUS_PLUS:
function frule(
    (_, ΔA, ΔB, _)::Tuple,
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, +))
)
    Ω = *(A, B, (+, +))
    ∂Ω = *(unthunk(ΔA), unthunk(ΔB), (+, +))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, +))
)
    function mulpullback(ΔΩ)
        ∂A = *(unthunk(ΔΩ), B', (+, first); mask=A)
        ∂B = *(A', unthunk(ΔΩ), (+, second); mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return *(A, B, (+, +)), mulpullback
end

# PLUS_MINUS:
function frule(
    (_, ΔA, ΔB, _)::Tuple,
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, -))
)
    Ω = *(A, B, (+, -))
    ∂Ω = *(unthunk(ΔA), unthunk(ΔB), (+, -))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, -))
)
    function mulpullback(ΔΩ)
        ∂A = *(unthunk(ΔΩ), B', (+, first); mask=A)
        ∂B = *(A', zero(eltype(unthunk(ΔΩ))) .- unthunk(ΔΩ), (+, second); mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return *(A, B, (+, -)), mulpullback
end

# PLUS_FIRST:
function frule(
    (_, ΔA, ΔB, _)::Tuple,
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, first))
)
    Ω = *(A, B, (+, first))
    ∂Ω = *(unthunk(ΔA), unthunk(ΔB), (+, first))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, first))
)
    function mulpullback(ΔΩ)
        ∂A = *(unthunk(ΔΩ), B', (+, first); mask=A)
        ∂B = NoTangent() # perhaps this should be ZeroTangent(), not sure.
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return *(A, B, (+, first)), mulpullback
end

# PLUS_SECOND:
function frule(
    (_, ΔA, ΔB, _)::Tuple,
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, second))
)
    Ω = *(A, B, (+, second))
    ∂Ω = *(unthunk(ΔA), unthunk(ΔB), (+, second))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(*),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof((+, second))
)
    function mulpullback(ΔΩ)
        ∂A = NoTangent()
        ∂B = *(A', unthunk(ΔΩ), (+, second); mask=B)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return *(A, B, (+, second)), mulpullback
end

# TROPICAL REDUCERS:
# These will require one of the following
# 1. Rewrite (some subset of) mxm in Julia, and allow for an optional output of the reduction indices
# 2. SSGrB adding indexBinaryOp as well as a pair UDT, and some other funky business.
# 3. Enzyme

# The latter is most likely to work in the short term.
