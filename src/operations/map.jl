

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
    t = inferoutputtype(A, op)
    return map!(op, similar(A, t), A; mask, accum, desc)
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
    t = inferoutputtype(A, op)
    return map!(op, similar(A, t), x, A; mask, accum, desc)
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
    t = inferoutputtype(A, op)
    return map!(op, similar(A, t), A, x; mask, accum, desc)
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

"""
    map(op::UnaryOp, A::GBArray; kwargs...)::GBArray
    map(op::BinaryOp, A::GBArray, x; kwargs...)::GBArray
    map(op::BinaryOp, x, A::GBArray, kwargs...)::GBArray

Transform a GBArray by applying `op` to each element.

UnaryOps apply elementwise in the usual fashion.
BinaryOps require the additional argument `x` which is substituted as the first or second
argument of `op` depending on its position.

# Arguments
- `op::MonoidBinaryOrRig = BinaryOps.PLUS`: the binary operation which is applied such that
    `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and/or `B`.
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `x`: Position dependent argument to binary operators.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`
"""
function Base.map(
    op::AbstractOp, A::GBArray, x = nothing;
    mask = nothing, accum = nothing, desc = nothing
)
end
