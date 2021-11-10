

function Base.map!(
    op::UnaryUnion, C::GBArray, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A)
    op = getoperator(op, eltype(A))
    accum = getaccum(accum, eltype(C))
    libgb.GrB_Matrix_apply(C, mask, accum, op, parent(A), desc)
    return C
end

Base.map!(op, C::GBArray, A::GBArray; mask = nothing, accum = nothing, desc = nothing) =
    map!(UnaryOp(op), C, A; mask, accum, desc)

function Base.map!(
    op::UnaryUnion, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    return map!(op, A, A; mask, accum, desc)
end

Base.map!(op, A::GBArray; mask = nothing, accum = nothing, desc = nothing) =
    map!(UnaryOp(op), A; mask, accum, desc)

function Base.map(
    op::UnaryUnion, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    t = inferoutputtype(A, op)
    return map!(op, similar(A, t), A; mask, accum, desc)
end

Base.map(op, A::GBArray; mask = nothing, accum = nothing, desc = nothing) =
    map(UnaryOp(op), A; mask, accum, desc)

function Base.map!(
    op::BinaryUnion, C::GBArray, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in2=A)
    op = getoperator(op, optype(eltype(A), typeof(x)))
    accum = getaccum(accum, eltype(C))
    libgb.scalarmatapply1st[optype(typeof(x), eltype(A))](C, mask, accum, op, x, parent(A), desc)
    return C
end

function Base.map!(
    op, C::GBArray, x, A::GBArray;
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
    op, x, A::GBArray;
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

"""
    map(op::Union{Function, AbstractUnaryOp}, A::GBArray; kwargs...)::GBArray
    map(op::Union{Function, AbstractBinaryOp}, A::GBArray, x; kwargs...)::GBArray
    map(op::Union{Function, AbstractBinaryOp}, x, A::GBArray, kwargs...)::GBArray

Transform a GBArray by applying `op` to each element.

UnaryOps and single argument functions apply elementwise in the usual fashion.
BinaryOps and two argument functions require the additional argument `x` which is 
    substituted as the first or second operand of `op` depending on its position.

# Arguments
- `op::Union{Function, AbstractUnaryOp, AbstractBinaryOp}`
- `A::GBArray`
- `x`: Position dependent argument to binary operators.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function Base.map(
    op, x, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    map(BinaryOps.BinaryOp(op), x, A; mask, accum, desc)
end

function Base.map!(
    op::BinaryUnion, C::GBArray, A::GBArray, x;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A)
    op = getoperator(op, optype(eltype(A), typeof(x)))
    accum = getaccum(accum, eltype(C))
    libgb.scalarmatapply2nd[optype(typeof(x), eltype(A))](C, mask, accum, op, parent(A), x, desc)
    return C
end

function Base.map!(
    op, C::GBArray, A::GBArray, x;
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
    op, A::GBArray, x;
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
    op, A::GBArray, x;
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

Base.:-(u::GBArray) = map(UnaryOps.AINV, u)

"""
    mask!(C::GBArray, A::GBArray, mask::GBArray)

Apply a mask to matrix `A`, storing the results in C.

"""
function mask!(C::GBArray, A::GBArray, mask::GBArray; structural = false, complement = false)
    desc = Descriptor()
    structural && (desc.structural_mask=true)
    complement && (desc.complement_mask=true)
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
