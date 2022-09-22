#emul TIMES
function frule(
    (_, ΔA, ΔB, _)::Tuple,
    ::typeof(emul),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof(*)
)
    Ω = emul(A, B, *)
    ∂Ω = emul(unthunk(ΔA), B, *) + emul(unthunk(ΔB), A, *)
    return Ω, ∂Ω
end
function frule((_, ΔA, ΔB)::Tuple, ::typeof(emul), A::AbstractGBArray, B::AbstractGBArray)
    return frule((nothing, ΔA, ΔB, nothing), emul, A, B, *)
end

function rrule(::typeof(emul), A::AbstractGBArray, B::AbstractGBArray, ::typeof(*))
    function timespullback(ΔΩ)
        ∂A = emul(unthunk(ΔΩ), B)
        ∂B = emul(unthunk(ΔΩ), A)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return emul(A, B, *), timespullback
end

function rrule(::typeof(emul), A::AbstractGBArray, B::AbstractGBArray)
    Ω, fullpb = rrule(emul, A, B, *)
    emulpb(ΔΩ) = fullpb(ΔΩ)[1:3]
    return Ω, emulpb
end

############
# eadd rules
############

# PLUS
######

function frule(
    (_, ΔA, ΔB, _)::Tuple,
    ::typeof(eadd),
    A::AbstractGBArray,
    B::AbstractGBArray,
    ::typeof(+)
)
    Ω = eadd(A, B, +)
    ∂Ω = eadd(unthunk(ΔA), unthunk(ΔB), +)
    return Ω, ∂Ω
end
function frule((_, ΔA, ΔB)::Tuple, ::typeof(eadd), A::AbstractGBArray, B::AbstractGBArray)
    return frule((nothing, ΔA, ΔB, nothing), eadd, A, B, +)
end

function rrule(::typeof(eadd), A::AbstractGBArray, B::AbstractGBArray, ::typeof(+))
    function pluspullback(ΔΩ)
        return (
            NoTangent(),
            mask(unthunk(ΔΩ), Structural(A)),
            mask(unthunk(ΔΩ), Structural(B)),
            NoTangent()
        )
    end
    return eadd(A, B, +), pluspullback
end

function rrule(::typeof(eadd), A::AbstractGBArray, B::AbstractGBArray)
    Ω, fullpb = rrule(eadd, A, B, +)
    eaddpb(ΔΩ) = fullpb(ΔΩ)[1:3]
    return Ω, eaddpb
end
