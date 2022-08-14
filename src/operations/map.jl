function apply!(
    op, C::GBVecOrMat, A::GBArray{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A)
    op = unaryop(op, eltype(A))
    accum = getaccum(accum, eltype(C))
    @wraperror LibGraphBLAS.GrB_Matrix_apply(gbpointer(C), mask, accum, op, gbpointer(parent(A)), desc)
    return C
end

function apply!(
    op, A::GBArray{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    return apply!(op, A, A; mask, accum, desc)
end

"""
    apply(op::Union{Function, TypedUnaryOperator}, A::GBArray; kwargs...)::GBArray
    apply(op::Union{Function}, A::GBArray, x; kwargs...)::GBArray
    apply(op::Union{Function}, x, A::GBArray, kwargs...)::GBArray

Transform a GBArray by applying `op` to each element. Equivalent to `Base.map` except for the additional
`x` argument for mapping with a scalar.

UnaryOps and single argument functions apply elementwise in the usual fashion.
BinaryOps and two argument functions require the additional argument `x` which is 
    substituted as the first or second operand of `op` depending on its position.

# Arguments
- `op::Union{Function, TypedUnaryOperator}`
- `A::GBArray`
- `x`: Position dependent argument to binary operators.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function apply(
    op, A::GBArray{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    t = inferunarytype(eltype(A), op)
    return apply!(op, similar(A, t), A; mask, accum, desc)
end

function apply!(
    op, C::GBVecOrMat, x, A::GBArray{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in2=A)
    op = binaryop(op, eltype(A), typeof(x))
    accum = getaccum(accum, eltype(C))
    @wraperror LibGraphBLAS.GxB_Matrix_apply_BinaryOp1st(gbpointer(C), mask, accum, op, GBScalar(x), gbpointer(parent(A)), desc)
    return C
end

function apply!(
    op, x, A::GBArray{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    return apply!(op, A, x, A; mask, accum, desc)
end

function apply(
    op, x, A::GBArray{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    t = inferbinarytype(typeof(x), eltype(A), op)
    return apply!(op, similar(A, t), x, A; mask, accum, desc)
end

function apply!(
    op, C::GBVecOrMat, A::GBArray{T}, x;
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A)
    op = binaryop(op, eltype(A), typeof(x))
    accum = getaccum(accum, eltype(C))
    @wraperror LibGraphBLAS.GxB_Matrix_apply_BinaryOp2nd(gbpointer(C), mask, accum, op, gbpointer(parent(A)), GBScalar(x), desc)
    return C
end

function apply!(
    op, A::GBArray{T}, x;
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    return apply!(op, A, A, x; mask, accum, desc)
end

function apply(
    op, A::GBArray{T}, x;
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    t = inferbinarytype(eltype(A), typeof(x), op)
    return apply!(op, similar(A, t), A, x; mask, accum, desc)
end

function Base.map(f, A::GBArray{T}; mask = nothing, accum = nothing, desc = nothing) where {T}
    apply(f, A; mask, accum, desc)
end
function Base.map!(f, C::GBArray, A::GBArray{T}; mask = nothing, accum = nothing, desc = nothing) where {T}
    apply!(f, C, A; mask, accum, desc)
end
function Base.map!(f, A::GBArray{T}; mask = nothing, accum = nothing, desc = nothing) where {T}
    apply!(f, C, A; mask, accum, desc)
end

Base.:*(x::V, u::GBArray{T}; mask = nothing, accum = nothing, desc = nothing) where {T, V<:Union{<:valid_union, T}} =
    apply(*, x, u; mask, accum, desc)
Base.:*(u::GBArray{T}, x::V; mask = nothing, accum = nothing, desc = nothing) where {T, V<:Union{<:valid_union, T}} =
    apply(*, u, x; mask, accum, desc)

Base.:-(u::GBArray) = apply(-, u)

"""
    mask!(C::GBArray, A::GBArray, mask::GBArray)

Apply a mask to matrix `A`, storing the results in C.
"""
function mask!(C::GBArray, A::GBArray, mask::GBArray; structural = false, complement = false)
    desc = Descriptor()
    structural && (desc.structural_mask=true)
    complement && (desc.complement_mask=true)
    mask = mask isa Transpose || mask isa Adjoint ? copy(mask) : mask
    apply!(identity, C, A; mask, desc)
    return C
end

function mask!(A::GBArray, mask::GBArray; structural = false, complement = false)
    mask!(A, A, mask; structural, complement)
end

"""
    mask(A::GBArray, mask::GBArray)

Apply a mask to matrix `A`.
"""
function mask(A::GBArray, mask::GBArray; structural = false, complement = false)
    return mask!(similar(A), A, mask; structural, complement)
end
