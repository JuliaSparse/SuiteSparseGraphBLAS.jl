function apply!(
    op, C::GBVecOrMat, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in1=A)
    mask = _handlemask!(desc, mask)
    op = unaryop(op, A)
    accum = _handleaccum(accum, storedeltype(C))
    @wraperror LibGraphBLAS.GrB_Matrix_apply(C, mask, accum, op, parent(A), desc)
    return C
end

function apply!(
    op, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    return apply!(op, A, A; mask, accum, desc)
end

"""
    apply(op::Union{Function, TypedUnaryOperator}, A::GBArrayOrTranspose; kwargs...)::GBArrayOrTranspose
    apply(op::Union{Function}, A::GBArrayOrTranspose, x; kwargs...)::GBArrayOrTranspose
    apply(op::Union{Function}, x, A::GBArrayOrTranspose, kwargs...)::GBArrayOrTranspose

Transform a GBArray by applying `op` to each element. Equivalent to `Base.map` except for the additional
`x` argument for mapping with a scalar.

UnaryOps and single argument functions apply elementwise in the usual fashion.
BinaryOps and two argument functions require the additional argument `x` which is 
    substituted as the first or second operand of `op` depending on its position.

# Arguments
- `op::Union{Function, TypedUnaryOperator}`
- `A::GBArrayOrTranspose`
- `x`: Position dependent argument to binary operators.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function apply(
    op, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    t = inferunarytype(A, op)
    return apply!(op, similar(A, t), A; mask, accum, desc)
end

function apply!(
    op, C::GBVecOrMat, x, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in2=A)
    mask = _handlemask!(desc, mask)
    op = binaryop(op, A, typeof(x))
    accum = _handleaccum(accum, storedeltype(C))
    @wraperror LibGraphBLAS.GxB_Matrix_apply_BinaryOp1st(C, mask, accum, op, GBScalar(x), parent(A), desc)
    return C
end

function apply!(
    op, x, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    return apply!(op, A, x, A; mask, accum, desc)
end

function apply(
    op, x, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    t = inferbinarytype(typeof(x), parent(A), op)
    return apply!(op, similar(A, t), x, A; mask, accum, desc)
end

function apply!(
    op, C::GBVecOrMat, A::GBArrayOrTranspose{T}, x;
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in1=A)
    mask = _handlemask!(desc, mask)
    op = binaryop(op, A, typeof(x))
    accum = _handleaccum(accum, storedeltype(C))
    @wraperror LibGraphBLAS.GxB_Matrix_apply_BinaryOp2nd(C, mask, accum, op, parent(A), GBScalar(x), desc)
    return C
end

function apply!(
    op, A::GBArrayOrTranspose{T}, x;
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    return apply!(op, A, A, x; mask, accum, desc)
end

function apply(
    op, A::GBArrayOrTranspose, x;
    mask = nothing, accum = nothing, desc = nothing
)
    t = inferbinarytype(parent(A), typeof(x), op)
    return apply!(op, similar(A, t), A, x; mask, accum, desc)
end

function Base.map(f, A::GBArrayOrTranspose; mask = nothing, accum = nothing, desc = nothing)
    apply(f, A; mask, accum, desc)
end
function Base.map!(f, C::GBVecOrMat, A::GBArrayOrTranspose; mask = nothing, accum = nothing, desc = nothing)
    apply!(f, C, A; mask, accum, desc)
end
function Base.map!(f, A::GBArrayOrTranspose; mask = nothing, accum = nothing, desc = nothing)
    apply!(f, A, A; mask, accum, desc)
end

Base.:*(x, u::GBArrayOrTranspose; mask = nothing, accum = nothing, desc = nothing) =
    apply(*, x, u; mask, accum, desc)
Base.:*(u::GBArrayOrTranspose, x; mask = nothing, accum = nothing, desc = nothing) =
    apply(*, u, x; mask, accum, desc)

Base.:*(x::Number, u::GBArrayOrTranspose; mask = nothing, accum = nothing, desc = nothing) =
    apply(*, x, u; mask, accum, desc)
Base.:*(u::GBArrayOrTranspose, x::Number; mask = nothing, accum = nothing, desc = nothing) =
    apply(*, u, x; mask, accum, desc)

Base.:-(u::GBArrayOrTranspose) = apply(-, u)

Base.real(A::GBArrayOrTranspose) = real.(A)
Base.imag(A::GBArrayOrTranspose) = imag.(A)
