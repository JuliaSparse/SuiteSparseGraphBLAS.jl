function LinearAlgebra.mul!(
    C::GBMatrix,
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op = Semirings.PLUS_TIMES;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc === nothing && (desc = DEFAULTDESC)
    size(A, 2) == size(B, 1) || throw(DimensionMismatch("size(A, 2) != size(B, 1)"))
    size(A, 1) == size(C, 1) || throw(DimensionMismatch("size(A, 1) != size(C, 1)"))
    size(B, 2) == size(C, 2) || throw(DimensionMismatch("size(B, 2) != size(C, 2)"))
    op = getoperator(op, optype(A, B))
    accum = getaccum(accum, eltype(C))
    A, desc, B = _handletranspose(A, desc, B)
    op isa TypedSemiring || throw(ArgumentError("$op is not a valid TypedSemiring"))
    libgb.GrB_mxm(C, mask, accum, op, A, B, desc)
    return C
end

function LinearAlgebra.mul!(
    w::GBVector,
    u::GBVector,
    A::GBMatOrTranspose,
    op = Semirings.PLUS_TIMES;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc === nothing && (desc = DEFAULTDESC)
    size(u, 1) == size(A, 1) || throw(DimensionMismatch("size(A, 1) != size(u)"))
    size(w, 1) == size(A, 2) || throw(DimensionMismatch("size(A, 2) != size(w)"))
    op = getoperator(op, optype(u, A))
    accum = getaccum(accum, eltype(w))
    u, desc, A = _handletranspose(u, desc, A)
    op isa TypedSemiring || throw(ArgumentError("$op is not a valid TypedSemiring"))
    libgb.GrB_vxm(w, mask, accum, op, u, A, desc)
    return w
end

function LinearAlgebra.mul!(
    w::GBVector,
    A::GBMatOrTranspose,
    u::GBVector,
    op = Semirings.PLUS_TIMES;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc === nothing && (desc = DEFAULTDESC)
    size(u, 1) == size(A, 2) || throw(DimensionMismatch("size(A, 2) != size(u)"))
    size(w, 1) == size(A, 1) || throw(DimensionMismatch("size(A, 1) != size(w"))
    op = getoperator(op, optype(A, u))
    accum = getaccum(accum, eltype(w))
    A, desc, u = _handletranspose(A, desc, u)
    op isa TypedSemiring || throw(ArgumentError("$op is not a valid TypedSemiring"))
    libgb.GrB_mxv(w, mask, accum, op, A, u, desc)
    return w
end

"""
    mul(A::GBArray, B::GBArray; kwargs...)::GBArray

Multiply two `GBArray`s `A` and `B` using a semiring provided in the `op` keyword argument.
If either `A` or `B` is a `GBMatrix` it may be transposed either using the descriptor or
by using `transpose(A)` or `A'`.

The default semiring is the `+.*` semiring.

# Arguments
- `A::GBArray`: GBVector or optionally transposed GBMatrix.
- `B::GBArray`: GBVector or optionally transposed GBMatrix.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask which determines the output
    pattern.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: optional binary accumulator
    operation where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`

# Returns
- `GBArray`: The output matrix whose `eltype` is determined by `A` and `B` or the semiring
    if a type specific semiring is provided.
"""
function mul(
    A::GBArray,
    B::GBArray,
    op = Semirings.PLUS_TIMES;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    t = inferoutputtype(A, B, op)
    if A isa GBVector && B isa GBMatOrTranspose
        C = GBVector{t}(size(B, 2))
    elseif A isa GBMatOrTranspose && B isa GBVector
        C = GBVector{t}(size(A, 1))
    elseif A isa GBMatOrTranspose && B isa GBMatOrTranspose
        C = GBMatrix{t}(size(A, 1), size(B, 2))
    end
    mul!(C, A, B, op; mask, accum, desc)
    return C
end

function Base.:*(
    A::GBArray,
    B::GBArray;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mul(A, B, Semirings.PLUS_TIMES; mask, accum, desc)
end


function Base.:*((⊕)::Function, (⊗)::Function)
    return function(A::GBArray, B::GBArray; mask=nothing, accum=nothing, desc=nothing)
        mul(A, B, (⊕, ⊗); mask, accum, desc)
    end
end

function Base.:*(rig::AbstractSemiring)
    return function(A::GBArray, B::GBArray; mask=nothing, accum=nothing, desc=nothing)
        mul(A, B, rig; mask, accum, desc)
    end
end
