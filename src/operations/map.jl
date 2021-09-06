

function Base.map!(
    op::UnaryUnion, C::GBArray, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc === nothing && (desc = DEFAULTDESC)
    op = getoperator(op, eltype(A))
    accum = getaccum(accum, eltype(C))
    A, desc = _handletranspose(A, desc)
    libgb.GrB_Matrix_apply(C, mask, accum, op, A, desc)
    return C
end

Base.map!(op::Function, C::GBArray, A::GBArray; mask = nothing, accum = nothing, desc = nothing) =
    map!(UnaryOp(op), C, A; mask, accum, desc)

function Base.map!(
    op::UnaryUnion, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, A, A; mask, accum, desc)
end

Base.map!(op::Function, A::GBArray; mask = nothing, accum = nothing, desc = nothing) =
    map!(UnaryOp(op), A; mask, accum, desc)

function Base.map(
    op::UnaryUnion, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    t = inferoutputtype(A, op)
    return map!(op, similar(A, t), A; mask, accum, desc)
end
Base.map(op::Function, A::GBArray; mask = nothing, accum = nothing, desc = nothing) =
    map(UnaryOp(op), A; mask, accum, desc)

function Base.map!(
    op::BinaryUnion, C::GBArray, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc === nothing && (desc = DEFAULTDESC)
    op = getoperator(op, optype(eltype(A), typeof(x)))
    accum = getaccum(accum, eltype(C))
    _, desc, A = _handletranspose(nothing, desc, A)
    libgb.scalarmatapply1st[optype(typeof(x), eltype(A))](C, mask, accum, op, x, A, desc)
    return C
end

function Base.map!(
    op::Function, C::GBArray, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    map!(BinaryOps.BinaryOp(op), C, x, A; mask, accum, desc)
end

function Base.map!(
    op::BinaryUnion, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, A, x, A; mask, accum, desc)
end

function Base.map!(
    op::Function, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    map!(BinaryOps.BinaryOp(op), x, A; mask, accum, desc)
end

function Base.map(
    op::BinaryUnion, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    t = inferoutputtype(A, op)
    return map!(op, similar(A, t), x, A; mask, accum, desc)
end

function Base.map(
    op::Function, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    map(BinaryOps.BinaryOp(op), x, A; mask, accum, desc)
end

function Base.map!(
    op::BinaryUnion, C::GBArray, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc === nothing && (desc = DEFAULTDESC)
    op = getoperator(op, optype(eltype(A), typeof(x)))
    accum = getaccum(accum, eltype(C))
    A, desc, _ = _handletranspose(A, desc)
    libgb.scalarmatapply2nd[optype(typeof(x), eltype(A))](C, mask, accum, op, A, x, desc)
    return C
end

function Base.map!(
    op::Function, C::GBArray, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    map!(BinaryOps.BinaryOp(op), C, A, x; mask, accum, desc)
end

function Base.map!(
    op::BinaryUnion, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, A, A, x; mask, accum, desc)
end

function Base.map!(
    op::Function, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    map!(BinaryOps.BinaryOp(op), A, A, x; mask, accum, desc)
end

function Base.map(
    op::BinaryUnion, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    t = inferoutputtype(A, op)
    return map!(op, similar(A, t), A, x; mask, accum, desc)
end

function Base.map(
    op::Function, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    map(BinaryOps.BinaryOp(op), A, x; mask, accum, desc)
end

Base.:+(x::valid_union, u::GBArray; mask = nothing, accum = nothing, desc = nothing) =
    map(BinaryOps.PLUS, x, u; mask, accum, desc)
Base.:+(u::GBArray, x::valid_union; mask = nothing, accum = nothing, desc = nothing) =
    map(BinaryOps.PLUS, u, x; mask, accum, desc)

Base.:*(x::valid_union, u::GBArray; mask = nothing, accum = nothing, desc = nothing) =
    map(BinaryOps.TIMES, x, u; mask, accum, desc)
Base.:*(u::GBArray, x::valid_union; mask = nothing, accum = nothing, desc = nothing) =
    map(BinaryOps.TIMES, u, x; mask, accum, desc)

Base.:-(x::valid_union, u::GBArray; mask = nothing, accum = nothing, desc = nothing) =
    map(BinaryOps.MINUS, x, u; mask, accum, desc)
Base.:-(u::GBArray, x::valid_union; mask = nothing, accum = nothing, desc = nothing) =
    map(BinaryOps.MINUS, u, x; mask, accum, desc)

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

"""
    mask!(C::GBArray, A::GBArray, mask::GBArray)

Apply a mask to matrix `A`, storing the results in C.

"""
function mask!(C::GBArray, A::GBArray, mask::GBArray; structural = false, complement = false)
    desc = DEFAULTDESC
    structural && (desc = desc + S)
    complement && (desc = desc + C)
    map!(identity, C, A; mask, desc)
    return C
end

"""
    mask(A::GBArray, mask::GBArray)

Apply a mask to matrix `A`.
"""
function mask(A::GBArray, mask::GBArray; structural = false, complement = false)
    return mask!(similar(A), A, mask; structural, complement)
end
