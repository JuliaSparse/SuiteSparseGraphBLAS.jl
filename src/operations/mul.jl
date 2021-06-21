function LinearAlgebra.mul!(
    C::GBMatrix,
    A::GBMatOrTranspose,
    B::GBMatOrTranspose;
    op::SemiringUnion = Semirings.PLUS_TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(A, 2) == size(B, 1) || throw(DimensionMismatch("size(A, 2) != size(B, 1)"))
    size(A, 1) == size(C, 1) || throw(DimensionMismatch("size(A, 1) != size(C, 1)"))
    size(B, 2) == size(C, 2) || throw(DimensionMismatch("size(B, 2) != size(C, 2)"))
    op = getoperator(op, optype(A, B))
    accum = getoperator(accum, eltype(C))
    A, desc, B = _handletranspose(A, desc, B)
    libgb.GrB_mxm(C, mask, accum, op, A, B, desc)
    return C
end

function LinearAlgebra.mul!(
    w::GBVector,
    u::GBVector,
    A::GBMatOrTranspose;
    op::SemiringUnion = Semirings.PLUS_TIMES,
    mask = C_NULl,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(u, 1) == size(A, 1) || throw(DimensionMismatch("size(A, 1) != size(u)"))
    size(w, 1) == size(A, 2) || throw(DimensionMismatch("size(A, 2) != size(w)"))
    op = getoperator(op, optype(u, A))
    accum = getoperator(accum, eltype(w))
    u, desc, A = _handletranspose(u, desc, A)
    libgb.GrB_vxm(w, mask, accum, op, u, A, desc)
    return w
end

function LinearAlgebra.mul!(
    w::GBVector,
    A::GBMatOrTranspose,
    u::GBVector;
    op::SemiringUnion = Semirings.PLUS_TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(u, 1) == size(A, 2) || throw(DimensionMismatch("size(A, 2) != size(u)"))
    size(w, 1) == size(A, 1) || throw(DimensionMismatch("size(A, 1) != size(w"))
    op = getoperator(op, optype(A, u))
    accum = getoperator(accum, eltype(w))
    A, desc, u = _handletranspose(A, desc, u)
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
- `B::GBArray`: GBVector or optionally transposed GBVector.

# Keywords
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: optional mask which determines the output
    pattern.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: optional binary accumulator
    operation where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = Descriptors.NULL`

# Returns
- `GBArray`: The output matrix whose `eltype` is determined by `A` and `B` or the semiring
    if a type specific semiring is provided.
"""
function mul(
    A::GBArray,
    B::GBArray;
    op::SemiringUnion = Semirings.PLUS_TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    op = getoperator(op, optype(A, B))
    t = tojuliatype(ztype(op))
    if A isa GBVector && B isa GBMatOrTranspose
        C = GBVector{t}(size(B, 2))
    elseif A isa GBMatOrTranspose && B isa GBVector
        C = GBVector{t}(size(A, 1))
    elseif A isa GBMatOrTranspose && B isa GBMatOrTranspose
        C = GBMatrix{t}(size(A, 1), size(B, 2))
    else
        throw(ArgumentError("Cannot multiply A::GBVector, B::GBVector. Try emul"))
    end
    mul!(C, A, B; op, mask, accum, desc)
    return C
end

function Base.:*(
    A::GBArray,
    B::GBArray;
    op::SemiringUnion = Semirings.PLUS_TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    mul(A, B; op, mask, accum, desc)
end
