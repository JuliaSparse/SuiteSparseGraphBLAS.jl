# Dense vector construction
function frule(
    (_, Δv),
    ::Type{<:GBVector},
    v::Vector{T}
) where {T}
    return GBVector(v), GBVector(unthunk(Δv))
end

function rrule(::Type{<:GBVector}, v::Vector{T}) where {T}
    function vecpullback(ΔΩ)
        return NoTangent(), Vector(unthunk(ΔΩ))
    end
    return GBVector(v), vecpullback
end

# Dense matrix construction
function frule(
    (_, ΔA),
    ::Type{<:GBMatrix},
    A::Matrix{T}
) where {T}
    return GBMatrix(A), GBMatrix(unthunk(ΔA))
end

function rrule(::Type{<:GBMatrix}, A::Matrix{T}) where {T}
    function vecpullback(ΔΩ)
        return NoTangent(), Matrix(unthunk(ΔΩ))
    end
    return GBMatrix(A), vecpullback
end

# Dense matrix from vector (n x 1 matrix)
function frule(
    (_, ΔA),
    ::Type{<:GBMatrix},
    A::Vector{T}
) where {T}
    return GBMatrix(A), GBMatrix(unthunk(ΔA))
end

function rrule(::Type{<:GBMatrix}, A::Vector{T}) where {T}
    sz = size(A)
    function vecpullback(ΔΩ)
        return NoTangent(), reshape(Matrix(unthunk(ΔΩ)), sz)
    end
    return GBMatrix(A), vecpullback
end


# Sparse Vector
function frule(
    (_, _, Δv),
    ::Type{<:GBVector},
    I::AbstractVector{U},
    v::Vector{T}
) where {U<:Integer, T}
    return GBVector(I, v), GBVector(I, unthunk(Δv))
end

function rrule(::Type{<:GBVector}, I::AbstractVector{U}, v::Vector{T}) where {U<:Integer, T}
    function vecpullback(ΔΩ)
        return NoTangent(), NoTangent(), nonzeros(unthunk(ΔΩ))
    end
    return GBVector(I, v), vecpullback
end


# Sparse Matrix
function frule(
    (_,_,_,Δv),
    ::Type{<:GBMatrix},
    I::AbstractVector{U},
    J::AbstractVector{U},
    v::Vector{T}
) where {U<:Integer, T}
    return GBMatrix(I, J, v), GBMatrix(I, J, Δv)
end

function rrule(
    ::Type{<:GBVector},
    I::AbstractVector{U},
    J::AbstractVector{U},
    v::Vector{T}
) where {U<:Integer, T}
    function vecpullback(ΔΩ)
        return NoTangent(), NoTangent(), NoTangent(), nonzeros(unthunk(ΔΩ))
    end
    return GBMatrix(I, J, v), vecpullback
end

function frule(
    (_,ΔS),
    ::Type{GBMatrix},
    S::SparseMatrixCSC{T}
) where {T}
    return GBMatrix(S), GBMatrix(ΔS)
end

function rrule(
    ::Type{GBMatrix},
    S::SparseMatrixCSC{T}
) where {T}
    function vecpullback(ΔΩ)
        back = unthunk(ΔΩ)
        return NoTangent(), SparseMatrixCSC(back)
    end
    return GBMatrix(S), vecpullback
end

function frule(
    (_,ΔS),
    ::Type{GBMatrix},
    S::SparseVector{T}
) where {T}
    return GBMatrix(S), GBMatrix(ΔS)
end

function rrule(
    ::Type{GBMatrix},
    S::SparseVector{T}
) where {T}
    function vecpullback(ΔΩ)
        return NoTangent(), SparseVector(unthunk(ΔΩ))
    end
    return GBMatrix(S), vecpullback
end
