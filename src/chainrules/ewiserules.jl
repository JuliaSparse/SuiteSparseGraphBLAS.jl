#emul TIMES
function frule(
    (_, ΔA, ΔB, _),
    ::typeof(emul),
    A::GBArray,
    B::GBArray,
    ::typeof(BinaryOps.TIMES)
)
    Ω = emul(A, B, BinaryOps.TIMES)
    ∂Ω = emul(unthunk(ΔA), B, BinaryOps.TIMES) + emul(unthunk(ΔB), A, BinaryOps.TIMES)
    return Ω, ∂Ω
end
function frule((_, ΔA, ΔB), ::typeof(emul), A::GBArray, B::GBArray)
    return frule((nothing, ΔA, ΔB, nothing), emul, A, B, BinaryOps.TIMES)
end

function rrule(::typeof(emul), A::GBArray, B::GBArray, ::typeof(BinaryOps.TIMES))
    function timespullback(ΔΩ)
        ∂A = emul(unthunk(ΔΩ), B)
        ∂B = emul(unthunk(ΔΩ), A)
        return NoTangent(), ∂A, ∂B, NoTangent()
    end
    return emul(A, B, BinaryOps.TIMES), timespullback
end

function rrule(::typeof(emul), A::GBArray, B::GBArray)
    Ω, fullpb = rrule(emul, A, B, BinaryOps.TIMES)
    emulpb(ΔΩ) = fullpb(ΔΩ)[1:3]
    return Ω, emulpb
end

############
# eadd rules
############

# PLUS
######

function frule(
    (_, ΔA, ΔB, _),
    ::typeof(eadd),
    A::GBArray,
    B::GBArray,
    ::typeof(BinaryOps.PLUS)
)
    Ω = eadd(A, B, BinaryOps.PLUS)
    ∂Ω = eadd(unthunk(ΔA), unthunk(ΔB), BinaryOps.PLUS)
    return Ω, ∂Ω
end
function frule((_, ΔA, ΔB), ::typeof(eadd), A::GBArray, B::GBArray)
    return frule((nothing, ΔA, ΔB, nothing), eadd, A, B, BinaryOps.PLUS)
end

function rrule(::typeof(eadd), A::GBArray, B::GBArray, ::typeof(BinaryOps.PLUS))
    function pluspullback(ΔΩ)
        return (
            NoTangent(),
            mask(unthunk(ΔΩ), A; structural = true),
            mask(unthunk(ΔΩ), B; structural = true),
            NoTangent()
        )
    end
    return eadd(A, B, BinaryOps.PLUS), pluspullback
end

function rrule(::typeof(eadd), A::GBArray, B::GBArray)
    Ω, fullpb = rrule(eadd, A, B, BinaryOps.PLUS)
    eaddpb(ΔΩ) = fullpb(ΔΩ)[1:3]
    return Ω, eaddpb
end
