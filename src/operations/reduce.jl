function reduce!(
    op, w::AbstractGBVector, A::GBArrayOrTranspose;
    mask = nothing, accum = nothing, desc = nothing
)
    desc = _handledescriptor(desc; in1=A)
    mask = _handlemask!(desc, mask)
    
    op = typedmonoid(op, eltype(w))
    accum = _handleaccum(accum, eltype(w))
    @wraperror LibGraphBLAS.GrB_Matrix_reduce_Monoid(
        Ptr{LibGraphBLAS.GrB_Vector}(gbpointer(w)), mask, accum, op, gbpointer(parent(A)), desc
        )
    return w
end

function Base.reduce(
    op,
    A::GBArrayOrTranspose;
    dims = :,
    typeout = nothing,
    init = nothing,
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    desc = _handledescriptor(desc; in1=A)
    mask = _handlemask!(desc, mask)
    if typeout === nothing
        typeout = eltype(A)
    end

    if dims == 2 && !(A isa GBVectorOrTranspose)
        w = similar(A, typeout, size(A, 1))
        reduce!(op, w, A; desc, accum, mask)
        return w
    elseif dims == 1 && !(A isa GBVectorOrTranspose)
        desc.transpose_input1 = true
        w = similar(A, typeout, size(A, 2))
        reduce!(op, w, A; desc, accum, mask)
        return w
    elseif dims == (1,2) || dims == Colon() || A isa GBVectorOrTranspose
        if init === nothing
            c = GBScalar{typeout}()
        else
            c = GBScalar{typeout}(init)
        end
        op = typedmonoid(op, typeout)
        if nnz(c) == 1 && accum == C_NULL
            accum = binaryop(op)
        end
        accum = _handleaccum(accum, typeout)
        @wraperror LibGraphBLAS.GrB_Matrix_reduce_Monoid_Scalar(c, accum, op, gbpointer(parent(A)), desc)
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
- `typeout`: Optional output type specification. Defaults to `eltype(A)`.
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
