function LinearAlgebra.kron!(
    C::GBMatOrTranspose,
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op, mask, accum, desc = _handlectx(op, mask, accum, desc, BinaryOps.TIMES)
    op = getoperator(op, optype(A, B))
    A, desc, B = _handletranspose(A, desc, B)
    accum = getoperator(accum, eltype(C))
    if op isa libgb.GrB_BinaryOp
        libgb.GxB_kron(C, mask, accum, op, A, B, desc)
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Matrix_kronecker_Monoid(C, mask, accum, op, A, B, desc)
    elseif op isa libgb.GrB_Semiring
        libgb.GrB_Matrix_kronecker_Semiring(C, mask, accum, op, A, B, desc)
    else
        throw(ArgumentError("$op is not a valid monoid binary op or semiring."))
    end
end

function LinearAlgebra.kron(
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op = _handlectx(op, ctxop, BinaryOps.TIMES)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(A, B)
    end
    C = GBMatrix{t}(size(A,1) * size(B, 1), size(A, 2) * size(B, 2))
    kron!(C, A, B, op; mask, accum, desc)
    return C
end
