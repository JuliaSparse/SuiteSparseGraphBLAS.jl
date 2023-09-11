@doc (@doc apply) apply!
function apply!(
    op, C::GBVecOrMat, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    if isindexop(op)
        return apply!(op, C, A, defaultthunk(op, T); mask, accum, desc)
    end
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in1=A)
    mask = _handlemask!(desc, mask)
    op = unaryop(op, A)
    accum = _handleaccum(accum, storedeltype(C))
    @wraperror LibGraphBLAS.GrB_Matrix_apply(C, mask, accum, op, parent(A), desc)
    return C
end

function apply!(
    op::DataType, C::GBVecOrMat, A::GBArrayOrTranspose;
    mask = nothing, accum = nothing, desc = nothing
)
    (mask !== nothing || accum !== nothing || desc !== nothing) &&
        throw(ArgumentError("Cannot apply! a DataType with a mask, accum, and desc."))
    return applyjl!(op, C, A)
end

function apply!(
    op, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    return apply!(op, A, A; mask, accum, desc)
end

function apply!(
    op, C::GBVecOrMat, x, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    isindexop(op) && throw(ArgumentError("IndexOp apply must receive the scalar argument `x` last." *
        "Try apply[!](op, [C], A, x)"))
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in2=A)
    mask = _handlemask!(desc, mask)
    op = binaryop(op, A, typeof(x))
    accum = _handleaccum(accum, storedeltype(C))
    @wraperror LibGraphBLAS.GxB_Matrix_apply_BinaryOp1st(C, mask, accum, op, GBScalar(x), parent(A), desc)
    return C
end
function apply!(
    op, x, A::GBArrayOrTranspose;
    mask = nothing, accum = nothing, desc = nothing
)
    return apply!(op, A, x, A; mask, accum, desc)
end

function apply!(
    op, C::GBVecOrMat, A::GBArrayOrTranspose, x;
    mask = nothing, accum = nothing, desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in1=A)
    mask = _handlemask!(desc, mask)
    accum = _handleaccum(accum, storedeltype(C))
    if isindexop(op)
        op = indexunaryop(op, A, typeof(x))
        @wraperror LibGraphBLAS.GrB_Matrix_apply_IndexOp_Scalar(C, mask, accum, op, A, GBScalar(x), desc)
    else
        op = binaryop(op, A, typeof(x))
        @wraperror LibGraphBLAS.GxB_Matrix_apply_BinaryOp2nd(C, mask, accum, op, parent(A), GBScalar(x), desc)
    end
    return C
end
function apply!(
    op, A::GBArrayOrTranspose, x;
    mask = nothing, accum = nothing, desc = nothing
)
    return apply!(op, A, A, x; mask, accum, desc)
end

"""
    apply[!](op::Function, [C::GBArray], A::GBArrayOrTranspose; kwargs...)::AbstractGBArray
    apply[!](op::Function, [C::GBArray], A::GBArrayOrTranspose, x; kwargs...)::AbstractGBArray
    apply[!](op::Function, [C::GBArray], x, A::GBArrayOrTranspose; kwargs...)::AbstractGBArray
    apply[!](op::IndexOp{<:Function}, [C::GBArray], A::GBArrayOrTranspose{T}, thunk = defaultthunk(op, T); kwargs...)::AbstractGBArray

Transform a GBArray by applying `op` to each element. Equivalent to `Base.map` except for the additional
`x` argument for mapping with a scalar.

Unary operators apply elementwise in the usual fashion.
IndexOps, and operators that set `isindexop(::F) = true` operate elementwise with additional arguments for the indices
    and an additional data argument `thunk`.
Binary operators require the additional argument `x` which is 
    substituted as the first or second operand of `op` depending on its position in the `apply` signature.

# Arguments
- `op::Union{Function, IndexOp}
- `A::GBArrayOrTranspose`
- `x`: Position dependent argument to binary operators.
- `thunk`: Extra data for `IndexOp`s.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, Function} = nothing`: binary accumulator operation
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

function apply(
    op, x, A::GBArrayOrTranspose{T};
    mask = nothing, accum = nothing, desc = nothing
) where {T}
    t = inferbinarytype(typeof(x), parent(A), op)
    return apply!(op, similar(A, t), x, A; mask, accum, desc)
end

function apply(
    op, A::GBArrayOrTranspose, x;
    mask = nothing, accum = nothing, desc = nothing
)
    t = inferbinarytype(parent(A), typeof(x), op)
    return apply!(op, similar(A, t), A, x; mask, accum, desc)
end

apply(::Any, ::GBArrayOrTranspose, ::GBArrayOrTranspose; mask = nothing, accum = nothing, desc = nothing) = 
    throw(ArgumentError("Cannot apply over two AbstractGBArrays, try `eadd`, `emul`, `eunion`, or broadcasting."))
apply!(::Any, ::GBVecOrMat, ::GBArrayOrTranspose, ::GBArrayOrTranspose; mask = nothing, accum = nothing, desc = nothing) = 
    throw(ArgumentError("Cannot apply! over two AbstractGBArrays, try `eadd`, `emul`, `eunion`, or broadcasting."))

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
