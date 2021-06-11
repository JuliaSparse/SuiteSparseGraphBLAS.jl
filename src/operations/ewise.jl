function emul!(
    w::GBVector,
    u::GBVector,
    v::GBVector;
    op::MonoidBinaryOrRig = BinaryOps.TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(w) == size(u) == size(v) || throw(DimensionMismatch())
    op = getoperator(op, eltype(w))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseMult_Semiring(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseMult_Monoid(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseMult_BinaryOp(w, mask, accum, op, u, v, desc)
        return w
    end
end

function emul(
    u::GBVector,
    v::GBVector;
    op::MonoidBinaryOrRig = BinaryOps.TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(eltype(u), eltype(v))
    end
    w = GBVector{t}(size(u))
    return emul!(w, u, v; op, mask , accum, desc)
end

function emul!(
    C::GBMatrix,
    A::GBMatOrTranspose,
    B::GBMatOrTranspose;
    op::MonoidBinaryOrRig = BinaryOps.TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    A, desc, B = _handletranspose(A, desc, B)
    op = getoperator(op, eltype(C))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Matrix_eWiseMult_Semiring(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Matrix_eWiseMult_Monoid(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Matrix_eWiseMult_BinaryOp(C, mask, accum, op, A, B, desc)
        return C
    end
end

function emul(
    A::GBMatOrTranspose,
    B::GBMatOrTranspose;
    op::MonoidBinaryOrRig = BinaryOps.TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(eltype(A), eltype(B))
    end
    C = GBMatrix{t}(size(A))
    return emul!(C, A, B; op, mask, accum, desc)
end

function eadd!(
    w::GBVector,
    u::GBVector,
    v::GBVector;
    op::MonoidBinaryOrRig = BinaryOps.PLUS,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(w) == size(u) == size(v) || throw(DimensionMismatch())
    op = getoperator(op, eltype(w))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseAdd_Semiring(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseAdd_Monoid(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseAdd_BinaryOp(w, mask, accum, op, u, v, desc)
        return w
    end
end

function eadd(
    u::GBVector,
    v::GBVector;
    op::MonoidBinaryOrRig = BinaryOps.PLUS,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(eltype(u), eltype(v))
    end
    w = GBVector{t}(size(u))
    return eadd!(w, u, v; op, mask, accum, desc)
end

function eadd!(
    C::GBMatrix,
    A::GBMatOrTranspose,
    B::GBMatOrTranspose;
    op::MonoidBinaryOrRig = BinaryOps.PLUS,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    A, desc, B = _handletranspose(A, desc, B)
    op = getoperator(op, eltype(C))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Matrix_eWiseAdd_Semiring(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Matrix_eWiseAdd_Monoid(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Matrix_eWiseAdd_BinaryOp(C, mask, accum, op, A, B, desc)
        return C
    else
        error("Unreachable")
    end
end

function eadd(
    A::GBMatOrTranspose,
    B::GBMatOrTranspose;
    op::MonoidBinaryOrRig = BinaryOps.PLUS,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(eltype(A), eltype(B))
    end
    C = GBMatrix{t}(size(A))
    return eadd!(C, A, B; op, mask, accum, desc)
end

# Note well: `.*` and `.+` have clear counterparts in the language of GraphBLAS:
# edgewiseAdd and edgewiseMul. These do not necessarily have the same semantics though.
# edgewiseAdd and edgewiseMul might better be described as edgewiseUnion and
# edgewiseIntersection respectively, and then `op` is applied at materialized indices.
#
# So the plan is thus: `.*` and `.+` will have the Union and Intersection semantics *with*
# the default ops of `*` and `+` respectively. *However*, they have `op` kwargs, which
# may be used with a macro later on down the line to override the default ops.
function Base.broadcasted(
    ::typeof(+),
    u::GBVector,
    v::GBVector;
    op::MonoidBinaryOrRig = BinaryOps.PLUS,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    return eadd(u, v; op, mask, accum, desc)
end
function Base.broadcasted(
    ::typeof(*),
    u::GBVector,
    v::GBVector;
    op::MonoidBinaryOrRig = BinaryOps.TIMES,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    return emul(u, v; op, mask, accum, desc)
end

function Base.broadcasted(
    ::typeof(+),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose;
    op::MonoidBinaryOrRig = BinaryOps.PLUS,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    return eadd(A, B; op, mask, accum, desc)
end
function Base.broadcasted(
    ::typeof(*),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose;
    op::MonoidBinaryOrRig = BinaryOps.PLUS,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    return emul(A, B; op, mask, accum, desc)
end
