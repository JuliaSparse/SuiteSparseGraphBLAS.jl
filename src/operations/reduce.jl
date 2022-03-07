function reduce!(
    op, w::AbstractGBVector, A::GBMatOrTranspose;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A)
    op = Monoid(op)(eltype(w))
    accum = getaccum(accum, eltype(w))
    @wraperror LibGraphBLAS.GrB_Matrix_reduce_Monoid(
        Ptr{LibGraphBLAS.GrB_Vector}(gbpointer(w)), mask, accum, op, gbpointer(parent(A)), desc
        )
    return w
end

function Base.reduce(
    op,
    A::GBArray;
    dims = :,
    typeout = nothing,
    init = nothing,
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    if typeout === nothing
        typeout = eltype(A)
    end

    if dims == 2 && !(A isa GBVecOrTranspose)
        w = similar(A, typeout, size(A, 1))
        reduce!(op, w, A; desc, accum, mask)
        return w
    elseif dims == 1 && !(A isa GBVecOrTranspose)
        desc.transpose_input1 = true
        w = similar(A, typeout, size(A, 2))
        reduce!(op, w, A; desc, accum, mask)
        return w
    elseif dims == (1,2) || dims == Colon() || A isa GBVecOrTranspose
        if init === nothing
            c = GBScalar{typeout}()
            typec = typeout
        else
            GBScalar{typeout}(init)
            typec = typeof(init)
        end
        op = Monoid(op)(typec)
        desc = _handledescriptor(desc; in1=A)
        accum = getaccum(accum, typec)
        @wraperror LibGraphBLAS.GrB_Matrix_reduce_Monoid_Scalar(c, accum, op, gbpointer(parent(A)), desc)
        return c[]
    end
end

"""
    reduce(op::Monoid, A::GBMatrix, dims=:; kwargs...)
    reduce(op::Monoid, v::GBVector; kwargs...)

Reduce `A` along dimensions of A with monoid `op`.

# Arguments
- `op::MonoidUnion`: the monoid reducer. This may not be a BinaryOp.
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `dims = :`: Optional dimensions for GBMatrix, may be `1`, `2`, or `:`.

# Keywords
- `typeout`: Optional output type specification. Defaults to `eltype(A)`.
- `init`: Optional initial value.
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`
"""
reduce

Base.maximum(A::GBArray) = reduce(max, A)
Base.maximum(f::Function, A::GBArray) = reduce(max, map(f, A))

Base.minimum(A::GBArray) = reduce(min, A)
Base.minimum(f::Function, A::GBArray) = reduce(min, map(f, A))

Base.sum(A::GBArray; dims=:) = reduce(+, A; dims)
