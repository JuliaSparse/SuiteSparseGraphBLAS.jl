"In place version of `select`."
function select!(
    op::SelectUnion,
    C::GBVecOrMat,
    A::GBArray,
    thunk = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A)
    thunk === nothing && (thunk = C_NULL)
    accum = getaccum(accum, eltype(C))
    if thunk isa Number
        thunk = GBScalar(thunk)
    end
    libgb.GxB_Matrix_select(C, mask, accum, op, parent(A), thunk, desc)
    return C
end

function select!(
    op,
    C::GBVecOrMat,
    A::GBArray,
    thunk = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    return select!(SelectOp(op), C, A, thunk; mask, accum, desc)
end

function select!(op, A::GBArray, thunk = nothing; mask = nothing, accum = nothing, desc = nothing)
    return select!(op, A, A, thunk; mask, accum, desc)
end

"""
    select(op::Union{Function, SelectUnion}, A::GBArray; kwargs...)::GBArray
    select(op::Union{Function, SelectUnion}, A::GBArray, thunk; kwargs...)::GBArray

Return a `GBArray` whose elements satisfy the predicate defined by `op`.
Some SelectOps or functions may require an additional argument `thunk`, for use in
    comparison operations such as `C[i,j] = A[i,j] >= thunk ? A[i,j] : nothing`, which is
    performed by `select(>, A, thunk)`.

# Arguments
- `op::Union{Function, SelectUnion}`: A select operator from the SelectOps submodule.
- `A::GBArray`
- `thunk::Union{GBScalar, nothing, valid_union}`: Optional value used to evaluate `op`.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask which determines the output
    pattern.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: optional binary accumulator
    operation where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`

# Returns
- `GBArray`: The output matrix whose `eltype` is determined by `A` and `op`.
"""
function select(
    op::SelectUnion,
    A::GBArray,
    thunk::Union{GBScalar, Nothing, valid_union} = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    C = similar(A)
    select!(op, C, A, thunk; accum, mask, desc)
    return C
end
function select(
    op::Function, A::GBArray, thunk;
    mask = nothing, accum = nothing, desc = nothing
)
    select(SelectOp(op), A, thunk; mask, accum, desc)
end

function select(
    op::Function,
    A::GBArray,
    thunk::Union{GBScalar, Nothing, Number} = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    return select(SelectOp(op), A, thunk; mask, accum, desc)
end

LinearAlgebra.tril(A::GBArray, k::Integer = 0) = select(tril, A, k)
LinearAlgebra.triu(A::GBArray, k::Integer = 0) = select(triu, A, k)
SparseArrays.dropzeros(A::GBArray) = select(nonzeros, A)
SparseArrays.dropzeros!(A::GBArray) = select!(nonzeros, A)