
function frule(
    (_, _, ΔA)::Tuple,
    ::typeof(select),
    op::Function,
    A::AbstractGBArray
)
    Ω = select(op, A)
    ∂Ω = mask(unthunk(ΔA), Structural(Ω))
    return Ω, ∂Ω
end


function frule(
    (_, _, ΔA, _)::Tuple,
    ::typeof(select),
    op::Function,
    A::AbstractGBArray,
    thunk::Union{GBScalar, Nothing, builtin_union}
)
    Ω = select(op, A, thunk)
    ∂Ω = mask(unthunk(ΔA), Structural(Ω))
    return Ω, ∂Ω
end

function rrule(
    ::typeof(select),
    op::Function,
    A::AbstractGBArray
)
    out = select(op, A)
    function selectback(ΔΩ)
        ∂A = mask(unthunk(ΔΩ), Structural(out))
        return NoTangent(), NoTangent(), ∂A
    end
    return out, selectback
end

function rrule(
    ::typeof(select),
    op::Function,
    A::AbstractGBArray,
    thunk::Union{GBScalar, Nothing, builtin_union}
)
    out = select(op, A, thunk)
    function selectback(ΔΩ)
        ∂A = mask(unthunk(ΔΩ), Structural(out))
        return NoTangent(), NoTangent(), ∂A, NoTangent()
    end
    return out, selectback
end
