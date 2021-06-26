

function Base.map!(
    op::UnaryUnion, C::GBArray, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    _, mask, accum, desc = _handlectx(op, mask, accum, desc)
    op = getoperator(op, eltype(A))
    accum = getoperator(accum, eltype(C))
    if C isa GBVector && A isa GBVector
        libgb.GrB_Vector_apply(C, mask, accum, op, A, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.GrB_Matrix_apply(C, mask, accum, op, A, desc)
    end
    return C
end
function Base.map!(
    op::UnaryUnion, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, A, A; mask, accum, desc)
end

function Base.map(
    op::UnaryUnion, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, similar(A), A; mask, accum, desc)
end

function Base.map!(
    op::BinaryUnion, C::GBArray, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    _, mask, accum, desc = _handlectx(op, mask, accum, desc)
    op = getoperator(op, optype(eltype(A), typeof(x)))
    accum = getoperator(accum, eltype(C))
    if C isa GBVector && A isa GBVector
        libgb.scalarvecapply1st[optype(typeof(x), eltype(A))](C, mask, accum, op, x, A, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.scalarmatapply1st[optype(typeof(x), eltype(A))](C, mask, accum, op, x, A, desc)
    end
    return C
end

function Base.map!(
    op::BinaryUnion, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, A, x, A; mask, accum, desc)
end

function Base.map(
    op::BinaryUnion, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, similar(A), x, A; mask, accum, desc)
end

function Base.map!(
    op::BinaryUnion, C::GBArray, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    _, mask, accum, desc = _handlectx(op, mask, accum, desc)
    op = getoperator(op, optype(eltype(A), typeof(x)))
    accum = getoperator(accum, eltype(C))
    if C isa GBVector && A isa GBVector
        libgb.scalarvecapply2nd[optype(typeof(x), eltype(A))](C, mask, accum, op, A, x, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.scalarmatapply2nd[optype(typeof(x), eltype(A))](C, mask, accum, op, A, x, desc)
    end
    return C
end

function Base.map!(
    op::BinaryUnion, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, A, A, x; mask, accum, desc)
end

function Base.map(
    op::BinaryUnion, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, similar(A), A, x; mask, accum, desc)
end

function Base.broadcasted(::typeof(+), u::GBArray, x::valid_union;
    mask = nothing, accum = nothing, desc = nothing
)
    map(BinaryOps.PLUS, u, x; mask, accum, desc)
end
function Base.broadcasted(
    ::typeof(+), x::valid_union, u::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    map(BinaryOps.PLUS, x, u; mask, accum, desc)
end

function Base.broadcasted(::typeof(*), u::GBArray, x::valid_union;
    mask = nothing, accum = nothing, desc = nothing
)
    map(BinaryOps.TIMES, u, x; mask, accum, desc)
end
function Base.broadcasted(::typeof(*), x::valid_union, u::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    map(BinaryOps.TIMES, x, u; mask, accum, desc)
end
