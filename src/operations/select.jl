# TODO: update to modern op system.

"In place version of `select`."
function select!(
    op,
    C::GBVecOrMat,
    A::GBArrayOrTranspose,
    thunk = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    op = SelectOp(op)
    desc = _handledescriptor(desc; out=C, in1=A)
    mask = _handlemask!(desc, mask)
    thunk === nothing && (thunk = C_NULL)
    accum = _handleaccum(accum, storedeltype(C))
    if thunk isa Number
        thunk = GBScalar(thunk)
    end
    @wraperror LibGraphBLAS.GxB_Matrix_select(C, mask, accum, op, parent(A), thunk, desc)
    return C
end

function select!(op, A::GBArrayOrTranspose, thunk = nothing; mask = nothing, accum = nothing, desc = nothing)
    return select!(op, A, A, thunk; mask, accum, desc)
end

"""
    select(op::Union{Function, SelectUnion}, A::GBArrayOrTranspose; kwargs...)::GBArrayOrTranspose
    select(op::Union{Function, SelectUnion}, A::GBArrayOrTranspose, thunk; kwargs...)::GBArrayOrTranspose

Return a `GBArray` whose elements satisfy the predicate defined by `op`.
Some SelectOps or functions may require an additional argument `thunk`, for use in
    comparison operations such as `C[i,j] = A[i,j] >= thunk ? A[i,j] : nothing`, which is
    performed by `select(>, A, thunk)`.

# Arguments
- `op::Union{Function, SelectUnion}`: A select operator from the SelectOps submodule.
- `A::GBArrayOrTranspose`
- `thunk::Union{GBScalar, nothing, valid_union}`: Optional value used to evaluate `op`.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask which determines the output
    pattern.
- `accum::Union{Nothing} = nothing`: optional binary accumulator
    operation where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`

# Returns
- `GBArray`: The output matrix whose `eltype` is determined by `A` and `op`.
"""
function select(
    op,
    A::GBArrayOrTranspose,
    thunk = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op = SelectOp(op)
    C = similar(A)
    select!(op, C, A, thunk; accum, mask, desc)
    return C
end

LinearAlgebra.tril(A::GBArrayOrTranspose, k::Integer = 0) = select(tril, A, k)
LinearAlgebra.triu(A::GBArrayOrTranspose, k::Integer = 0) = select(triu, A, k)
SparseArrays.dropzeros(A::GBArrayOrTranspose) = select(nonzeros, A)
SparseArrays.dropzeros!(A::GBArrayOrTranspose) = select!(nonzeros, A)