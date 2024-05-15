"In place version of `select`."
function select!(
    op,
    C::GBVecOrMat,
    A::GBArrayOrTranspose{T},
    thunk::TH = defaultthunk(op, T);
    mask = nothing,
    accum = nothing,
    desc = nothing
) where {T, TH}
    if op ∈ (
            rowindex, colindex, diagindex,
            rowindex32, colindex32, diagindex32,
            tril, triu, diag, offdiag,
            colle, colgt, rowle, rowgt
        )
        scalar = GBScalar{Int64}(thunk)
    elseif op ∈ (==, !=, <, >, <=, >=) && TH <: builtin_union
        scalar = GBScalar{TH}(thunk)
    else
        scalar = GBScalar(thunk)
    end
    intermediatetype = storedeltype(C)
    _canbeoutput(C) || throw(ShallowException())
    op = indexunaryop(op, T, scalar, intermediatetype)
    desc = _handledescriptor(desc; out=C, in1=A)
    desc, mask = _handlemask!(desc, mask)
    accum = _handleaccum(accum, C, intermediatetype)
    
    @wraperror LibGraphBLAS.GrB_Matrix_select_Scalar(C, mask, accum, op, parent(A), scalar, desc)
    return C
end

function select!(
    op, A::GBArrayOrTranspose{T}, thunk = defaultthunk(op, T); 
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
- `thunk::Union{GBScalar, nothing, builtin_union}`: Optional value used to evaluate `op`.

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
    thunk::TH = defaultthunk(op, T);
    mask = nothing,
    desc = nothing
) where {T, TH}
    C = similar(A) # we keep the same type!! not the ztype of op.
    select!(op, C, A, thunk; mask, desc)
    return C
end

LinearAlgebra.tril(A::GBArrayOrTranspose, k::Integer = 0) = select(tril, A, k)
LinearAlgebra.triu(A::GBArrayOrTranspose, k::Integer = 0) = select(triu, A, k)
SparseArrays.dropzeros(A::GBArrayOrTranspose{T}) where T = select(!=, A, zero(T))
SparseArrays.dropzeros!(A::GBArrayOrTranspose{T}) where T = select!(!=, A, zero(T))
