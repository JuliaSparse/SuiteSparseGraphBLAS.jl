"In place version of `select`."
function select!(
    op::SelectUnion,
    C::GBVecOrMat,
    A::GBArray,
    thunk::Union{GBScalar, Nothing, Number} = nothing;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    thunk === nothing && (thunk = C_NULL)
    A, desc, _ = _handletranspose(A, desc)
    accum = getoperator(accum, eltype(C))
    if thunk isa Number
        thunk = GBScalar(thunk)
    end
    if A isa GBVector && C isa GBVector
        libgb.GxB_Vector_select(C, mask, accum, op, A, thunk, desc)
    elseif A isa GBMatrix && C isa GBMatrix
        libgb.GxB_Matrix_select(C, mask, accum, op, A, thunk, desc)
    end
    return C
end

"""
    select(op::SelectUnion, A::GBArray; kwargs...)::GBArray
    select(op::SelectUnion, A::GBArray, thunk; kwargs...)::GBArray

Return a `GBArray` whose elements satisfy the predicate defined by `op`.
Some SelectOps may require an additional argument `thunk`, for use in comparison operations
such as `C[i,j] = A[i,j] >= thunk ? A[i,j] : nothing`, which maps to
`select(SelectOps.GT_THUNK, A, thunk)`.

# Arguments
- `op::SelectUnion`: A select operator from the SelectOps submodule.
- `A::GBArray`: GBVector or optionally transposed GBMatrix.
- `thunk::Union{GBScalar, nothing, valid_union}`: Optional value used to evaluate `op`.

# Keywords
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: optional mask which determines the output
    pattern.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: optional binary accumulator
    operation where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = Descriptors.NULL`

# Returns
- `GBArray`: The output matrix whose `eltype` is determined by `A`.
"""
function select(
    op::SelectUnion,
    A::GBArray,
    thunk::Union{GBScalar, Nothing, valid_union} = nothing;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    C = similar(A)
    select!(op, C, A, thunk; accum, mask, desc)
    return C
end
