function frule(
    (_, _, _, ΔX),
    ::Type{GBMatrix},
    I::AbstractVector{<:Integer},
    J::AbstractVector{<:Integer},
    X::AbstractVector
)
    return GBMatrix(I, J, X), GBMatrix(I, J, ΔX)
end
function rrule(::Type{GBMatrix}, I::AbstractVector{<:Integer}, J::AbstractVector{<:Integer}, X::AbstractVector)
    gbmatrix_pullback(Δgbmatrix) = NoTangent(), NoTangent(), NoTangent(), nonzeros(Δgbmatrix)
    return GBMatrix(I, J, X), gbmatrix_pullback
end

function rrule(::Type{GBVector}, I::AbstractVector{<:Integer}, X::AbstractVector)
    gbvector_pullback(Δgbvector) = NoTangent(), NoTangent(), nonzeros(Δgbvector)
    return GBVector(I, X), gbvector_pullback
end
