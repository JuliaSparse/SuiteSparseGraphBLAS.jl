function LinearAlgebra.kron!(
    C::GBMatOrTranspose,
    A::GBMatOrTranspose,
    B::GBMatOrTranspose;
    op::MonoidBinaryOrRig = BinaryOps.TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    op = getoperator(op, optype(A, B))
    A, desc, B = _handletranspose(A, desc, B)
    accum = getoperator(accum, eltype(C))
    if op isa Union{AbstractBinaryOp, libgb.GrB_BinaryOp}
        libgb.GxB_kron(C, mask, accum, op, A, B, desc)
    elseif op isa Union{AbstractMonoid, libgb.GrB_Monoid}
        libgb.GrB_Matrix_kronecker_Monoid(C, mask, accum, op, A, B, desc)
    elseif op isa Union{AbstractSemiring, libgb.GrB_Semiring}
        libgb.GrB_Matrix_kronecker_Semiring(C, mask, accum, op, A, B, desc)
    end
end

function LinearAlgebra.kron(
    A::GBMatOrTranspose,
    B::GBMatOrTranspose;
    op::MonoidBinaryOrRig = BinaryOps.TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    t = optype(A, B)
    C = GBMatrix{t}(size(A,1) * size(B, 1), size(A, 2) * size(B, 2))
    kron!(C, A, B; op, mask, accum, desc)
    return C
end
