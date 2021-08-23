
function frule(
    (_, _, ΔA),
    ::typeof(select),
    op::Union{Function, SelectUnion},
    A::GBArray
)
    Ω = select(op, A)
    ∂Ω = select(op, ΔA)
    return Ω, ∂Ω
end


function frule(
    (_, _, ΔA, _),
    ::typeof(select),
    op::Union{Function, SelectUnion},
    A::GBArray,
    thunk::Union{GBScalar, Nothing, valid_union}
)
    Ω = select(op, A, thunk)
    ∂Ω = select(op, ΔA, thunk)
    return Ω, ∂Ω
end

function rrule(
    ::typeof(select),
    op::Union{Function, SelectUnion},
    A::GBArray
)
    out = select(op, A)
    function selectback(ΔΩ)
        ∂A = mask(ΔΩ, out, structural = true)
        return NoTangent(), NoTangent(), ∂A
    end
    return out, selectback
end

function rrule(
    ::typeof(select),
    op::Union{Function, SelectUnion},
    A::GBArray,
    thunk::Union{GBScalar, Nothing, valid_union}
)
    out = select(op, A, thunk)
    function selectback(ΔΩ)
        ∂A = mask(ΔΩ, out, structural = true)
        return NoTangent(), NoTangent(), ∂A, NoTangent()
    end
    return out, selectback
end
