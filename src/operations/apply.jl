function apply!(
    C::GBVecOrMat, A::GBVecOrMat, op::UnaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
    )
    op = getoperator(op, eltype(C))
    if C isa GBVector && A isa GBVector
        libgb.GrB_Vector_apply(C, mask, accum, op, A, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.GrB_Matrix_apply(C, mask, accum, op, A, desc)
    end
end
function apply!(
    A::GBVecOrMat, op::UnaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply!(A, A, op; mask, accum, desc)
end
function apply(
    A::GBVecOrMat, op::UnaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    C = similar(A)
    apply!(C, A, op; mask, accum, desc)
    return C
end

function apply!(
    C::GBVecOrMat, x, A::GBVecOrMat, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    op = getoperator(op, eltype(C))
    if C isa GBVector && A isa GBVector
        libgb.scalarvecapply1st[eltype(C)](C, mask, accum, op, x, A, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.scalarmatapply1st[eltype(C)](C, mask, accum, op, x, A, desc)
    end
end

function apply!(
    x, A::GBVecOrMat, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply!(A, x, A, op; mask, accum, desc)
end

function apply(
    x, A::GBVecOrMat, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    C = similar(A)
    apply!(C, x, A, op; mask, accum, desc)
    return C
end

function apply!(
    C::GBVecOrMat, A::GBVecOrMat, x, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    op = getoperator(op, eltype(C))
    if C isa GBVector && A isa GBVector
        libgb.scalarvecapply2nd[eltype(C)](C, mask, accum, op, A, x, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.scalarmatapply2nd[eltype(C)](C, mask, accum, op, A, x, desc)
    end
end

function apply!(
    A::GBVecOrMat, x, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply!(A, A, x, op; mask, accum, desc)
end

function apply(
    A::GBVecOrMat, x, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    C = similar(A)
    apply!(C, A, x, op; mask, accum, desc)
    return C
end

function Base.broadcasted(::typeof(+), u::GBVecOrMat, x::valid_union;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply(u, x, BinaryOps.PLUS; mask, accum, desc)
end
function Base.broadcasted(
    ::typeof(+), x::valid_union, u::GBVecOrMat;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply(x, u, BinaryOps.PLUS; mask, accum, desc)
end

function Base.broadcasted(::typeof(*), u::GBVecOrMat, x::valid_union;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply(u, x, BinaryOps.TIMES; mask, accum, desc)
end
function Base.broadcasted(::typeof(*), x::valid_union, u::GBVecOrMat;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply(x, u, BinaryOps.TIMES; mask, accum, desc)
end
