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
    op = getoperator(op, eltype(C))
    A, desc, B = _handletranspose(A, desc, B)
    libgb.GrB_mxm(C, mask, accum, op, A, B, desc)
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
    op = getoperator(op, eltype(w))
    u, desc, A = _handletranspose(u, desc, A)
    libgb.GrB_vxm(w, mask, accum, op, u, A, desc)
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
    op = getoperator(op, eltype(w))
    A, desc, u = _handletranspose(A, desc, u)
    libgb.GrB_mxv(w, mask, accum, op, A, u, desc)
end


"""
    mul(A::GBArray, B::GBArray; op::Semiring = PLUS_TIMES, mask, accum, desc)

Multiply two GBArrays `A` and `B`, at least one of which is a `GBMatrix`. `A` and `B` may
be transposed either by passing in a transposed `GBMatrix` or using the descriptor.
"""
function mul(
    A::GBArray,
    B::GBArray;
    op::SemiringUnion = Semirings.PLUS_TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    op = getoperator(op, optype(eltype(A), eltype(B)))
    t = tojuliatype(ztype(op))
    if A isa GBVector && B isa GBMatOrTranspose
        C = GBVector{t}(size(B, 2))
    elseif A isa GBMatOrTranspose && B isa GBVector
        C = GBVector{t}(size(A, 1))
    elseif A isa GBMatOrTranspose && B isa GBMatOrTranspose
        C = GBMatrix{t}(size(A, 1), size(B, 2))
    end
    A, desc, B = _handletranspose(A, desc, B)
    mul!(C, A, B; op, mask, accum, desc)
    return C
end
