

function apply!(
    C::GBArray, A::GBArray, op::UnaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
    )
    op = getoperator(op, eltype(A))
    if C isa GBVector && A isa GBVector
        libgb.GrB_Vector_apply(C, mask, accum, op, A, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.GrB_Matrix_apply(C, mask, accum, op, A, desc)
    end
    return C
end
function apply!(
    A::GBArray, op::UnaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    return apply!(A, A, op; mask, accum, desc)
end

function apply(
    A::GBArray, op::UnaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    return apply!(similar(A), A, op; mask, accum, desc)
end

function apply!(
    C::GBArray, x, A::GBArray, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    op = getoperator(op, optype(eltype(A), typeof(x)))
    if C isa GBVector && A isa GBVector
        libgb.scalarvecapply1st[optype(typeof(x), eltype(A))](C, mask, accum, op, x, A, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.scalarmatapply1st[optype(typeof(x), eltype(A))](C, mask, accum, op, x, A, desc)
    end
    return C
end

function apply!(
    x, A::GBArray, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    return apply!(A, x, A, op; mask, accum, desc)
end

function apply(
    x, A::GBArray, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    return apply!(similar(A), x, A, op; mask, accum, desc)
end

function apply!(
    C::GBArray, A::GBArray, x, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    op = getoperator(op, optype(eltype(A), typeof(x)))
    if C isa GBVector && A isa GBVector
        libgb.scalarvecapply2nd[optype(typeof(x), eltype(A))](C, mask, accum, op, A, x, desc)
    elseif C isa GBMatrix && A isa GBMatrix
        libgb.scalarmatapply2nd[optype(typeof(x), eltype(A))](C, mask, accum, op, A, x, desc)
    end
    return C
end

function apply!(
    A::GBArray, x, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    return apply!(A, A, x, op; mask, accum, desc)
end

function apply(
    A::GBArray, x, op::BinaryUnion;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    return apply!(similar(A), A, x, op; mask, accum, desc)
end

function Base.broadcasted(::typeof(+), u::GBArray, x::valid_union;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply(u, x, BinaryOps.PLUS; mask, accum, desc)
end
function Base.broadcasted(
    ::typeof(+), x::valid_union, u::GBArray;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply(x, u, BinaryOps.PLUS; mask, accum, desc)
end

function Base.broadcasted(::typeof(*), u::GBArray, x::valid_union;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply(u, x, BinaryOps.TIMES; mask, accum, desc)
end
function Base.broadcasted(::typeof(*), x::valid_union, u::GBArray;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    apply(x, u, BinaryOps.TIMES; mask, accum, desc)
end

"""
    apply!(C::GBArray, A::GBArray, op::UnaryOp; kwargs...)::GBArray
    apply!(A::GBArray, op::UnaryOp; kwargs...)::GBArray
    apply!(C::GBArray, A::GBArray, x, op::BinaryOp; kwargs...)::GBArray
    apply!(C::GBArray, x, A::GBArray, op::BinaryOp; kwargs...)::GBArray
    apply!(x, A::GBArray, op::BinaryOp; kwargs...)::GBArray
    apply!(A::GBArray, x, op::BinaryOp; kwargs...)::GBArray

    apply(...; kwargs...)::GBArray

Apply a unary or binary operation to `A`. The mutating methods above each have a
non-mutating form without the `!`.

# Keywords
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: optional mask which determines the output
    pattern.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: optional binary accumulator
    operation where `C[i,j] = accum(C[i,j], A[i,j])`.
- `desc::Descriptor = Descriptors.NULL`

# Examples

With matrix `X` with `eltype(X) = Float64`:

- Apply the `sin` function to each element: `apply(X, UnaryOps.SIN)`.
- Add `0.5` to each element: `apply(X, 0.5, BinaryOps.PLUS)`.
- Test whether each element is greater than 10: `apply(X, 10, BinaryOps.GT)`.
- Test whether each element is equal to 1: `apply(1, X, BinaryOps.EQ)`.
- Typecast: `apply(similar(Int64, X), X, UnaryOps.IDENTITY)`
"""
apply, apply!
