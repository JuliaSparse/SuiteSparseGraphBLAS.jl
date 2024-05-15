function reduce!(
    op, w::AbstractGBVector, A::GBArrayOrTranspose;
    dims = nothing,
    mask = nothing, accum = nothing, desc = nothing
)
    (dims ∉ (1, 2)) && throw(
        ArgumentError("dims=[1 | 2] must be specified as a keyword argument.")
    )
    _canbeoutput(w) || throw(ShallowException())
    dims == 1 && (A = transpose(A))
    desc = _handledescriptor(desc; out=w, in1=A)
    desc, mask = _handlemask!(desc, mask)
    op = typedmonoid(op, storedeltype(A))
    accum = _handleaccum(accum, w, A)
    @wraperror LibGraphBLAS.GrB_Matrix_reduce_Monoid(
            w, mask, accum, op, parent(A), desc
        )
    return w
end

function Base.reduce(
    op,
    A::GBArrayOrTranspose;
    dims = :,
    init = nothing,
    mask = nothing,
    desc = nothing
)
    # we need the descriptor in this function.
    isnothing(desc) && (desc = Descriptor())
    desc = _handledescriptor(desc; in1=A)
    desc, mask = _handlemask!(desc, mask)
    typeout = storedeltype(A)

    if dims == 2
        w = similar(A, typeout, size(A, 1))
        reduce!(op, w, A; dims, desc, mask)
        return w
    elseif dims == 1
        w = similar(A, typeout, size(A, 2))
        reduce!(op, w, A; dims, desc, mask)
        return w
    elseif dims == (1,2) || dims == Colon() || A isa GBVectorOrTranspose
        mask != C_NULL && throw(
            ArgumentError("Reduction to a scalar does not support masking."))
        if isnothing(init)
            c = GBScalar{typeout}()
        else
            c = GBScalar{typeout}(init)
        end
        op = typedmonoid(op, typeout)
        @wraperror LibGraphBLAS.GrB_Matrix_reduce_Monoid_Scalar(c, C_NULL, op, parent(A), desc)
        isnothing(c[]) && return getfill(A)
        return c[]
    end
end

"""
    reduce(op::Union{Function, AbstractMonoid}, A::GBMatrix, dims=:; kwargs...)
    reduce(op::Union{Function, AbstractMonoid}, v::GBVector; kwargs...)

Reduce `A` along dimensions of A with monoid `op`.

# Arguments
- `op`: the reducer. This must map to an AbstractMonoid, not a binary op.
- `A::GBArrayOrTranspose`: `GBVector` or optionally transposed `GBMatrix`.
- `dims = :`: Optional dimensions for GBMatrix, may be `1`, `2`, or `:`.

# Keywords
- `init`: Optional initial value.
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`
"""
reduce

Base.maximum(A::GBArrayOrTranspose) = reduce(max, A)
Base.maximum(f::Function, A::GBArrayOrTranspose) = reduce(max, map(f, A))

Base.minimum(A::GBArrayOrTranspose) = reduce(min, A)
Base.minimum(f::Function, A::GBArrayOrTranspose) = reduce(min, map(f, A))

Base.sum(A::GBArrayOrTranspose; dims=:) = reduce(+, A; dims)

function countstored!(
    C::GBVector, A::GBArrayOrTranspose; 
    dims=1, mask = nothing, accum = nothing, desc = nothing
)
    v=GBVector(size(A, dims), true)
    A = dims == 1 ? A' : dims == 2 ? A : throw(ArgumentError("dims ∉ {1, 2}"))
    return mul!(C, A, v, (+, pair); mask, accum, desc)
end
function countstored(
    A::GBArrayOrTranspose; 
    dims=1, mask = nothing, desc = nothing
)
    v=GBVector(size(A, dims), true)
    countstored!(
        similar(A, Int64, size(A, dims == 1 ? 2 : 1)), A; 
        dims, mask, desc
    )
end

function countstoredcol(A::GBArrayOrTranspose, i::Integer)
    mask = GBVector{Bool}(size(A, 2))
    mask[i] = true
    countstored(A; mask)[i]
end

function countstoredrow(A::GBArrayOrTranspose, i::Integer)
    mask = GBVector{Bool}(size(A, 2))
    mask[i] = true
    countstored(A'; mask)[i]
end
