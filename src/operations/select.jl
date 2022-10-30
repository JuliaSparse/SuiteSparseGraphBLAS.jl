# TODO: update to modern op system.

function defaultselectthunk(op, T)
    if op ∈ (rowindex, colindex, diagindex)
        return one(Int64)
    elseif op ∈ (tril, triu, diag, offdiag)
        return zero(Int64)
    elseif op === ==
        return zero(T)
    else
        throw(ArgumentError("You must pass `thunk` to select for this function."))
    end
end

"In place version of `select`."
function select!(
    op,
    C::GBVecOrMat,
    A::GBArrayOrTranspose{T},
    thunk::TH = defaultselectthunk(op, T);
    mask = nothing,
    accum = nothing,
    desc = nothing
) where {T, TH}
    op ∈ (rowindex, colindex, diagindex, tril, triu, diag, offdiag) && 
        (thunk = convert(Int64, thunk))
    _canbeoutput(C) || throw(ShallowException())
    op = indexunaryop(op, T, TH)
    desc = _handledescriptor(desc; out=C, in1=A)
    mask = _handlemask!(desc, mask)
    accum = _handleaccum(accum, storedeltype(C))
    @wraperror LibGraphBLAS.GrB_Matrix_select_Scalar(C, mask, accum, op, parent(A), GBScalar(thunk), desc)
    return C
end

function select!(
    op, A::GBArrayOrTranspose{T}, thunk = defaultselectthunk(op, T); 
    mask = nothing, accum = nothing, desc = nothing
) where T
    return select!(op, A, A, thunk; mask, accum, desc)
end

"""
    select(op::Function, A::GBArrayOrTranspose; kwargs...)::GBArrayOrTranspose
    select(op::Function, A::GBArrayOrTranspose, thunk; kwargs...)::GBArrayOrTranspose

Return a `GBArray` whose elements satisfy the predicate defined by `op`.
Some SelectOps or functions may require an additional argument `thunk`, for use in
    comparison operations such as `C[i,j] = A[i,j] >= thunk ? A[i,j] : nothing`, which is
    performed by `select(>, A, thunk)`.

# Arguments
- `op::Function`: A select operator from the SelectOps submodule.
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
    A::GBArrayOrTranspose{T},
    thunk::TH = defaultselectthunk(op, T);
    mask = nothing,
    accum = nothing,
    desc = nothing
) where {T, TH}
    op = indexunaryop(op, T, TH)
    C = similar(A) # we keep the same type!! not the ztype of op.
    select!(op, C, A, thunk; accum, mask, desc)
    return C
end

LinearAlgebra.tril(A::GBArrayOrTranspose, k::Integer = 0) = select(tril, A, k)
LinearAlgebra.triu(A::GBArrayOrTranspose, k::Integer = 0) = select(triu, A, k)
SparseArrays.dropzeros(A::GBArrayOrTranspose{T}) where T = select(!=, A, zero(T))
SparseArrays.dropzeros!(A::GBArrayOrTranspose{T}) where T = select!(!=, A, zero(T))