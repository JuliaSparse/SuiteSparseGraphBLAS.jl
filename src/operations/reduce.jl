function reduce!(
    op::MonoidUnion, w::GBVector, A::GBMatOrTranspose;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum, desc = _handlenothings(mask, accum, desc)
    A, desc, _ = _handletranspose(A, desc, nothing)
    op = getoperator(op, eltype(w))
    accum = getoperator(accum, eltype(w))
    libgb.GrB_Matrix_reduce_Monoid(w, mask, accum, op, A, desc)
    return w
end

function Base.reduce(
    op::MonoidUnion,
    A::GBMatOrTranspose;
    dims = :,
    typeout = nothing,
    init = nothing,
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum, desc = _handlenothings(mask, accum, desc)
    if typeout === nothing
        typeout = eltype(A)
    end
    if dims == 2
        w = GBVector{typeout}(size(A, 1))
        reduce!(op, w, A; desc, accum, mask)
        return w
    elseif dims == 1
        desc = desc + Descriptors.T0
        w = GBVector{typeout}(size(A, 2))
        reduce!(op, w, A; desc, accum, mask)
        return w
    elseif dims == (1,2) || dims == Colon()
        if init === nothing
            c = Ref{typeout}()
            typec = typeout
        else
            c = Ref(init)
            typec = typeof(init)
        end
        op = getoperator(op, typec)
        A, desc, _ = _handletranspose(A, desc, nothing)
        accum = getoperator(accum, typec)
        libgb.scalarmatreduce[typeout](c, accum, op, A, desc)
        return c[]
    end
end

function Base.reduce(
    op::MonoidUnion,
    v::GBVector;
    typeout = nothing,
    init = nothing,
    accum = nothing,
    desc = nothing
)
    accum, desc = _handlenothings(accum, desc)
    if typeout === nothing
        typeout = eltype(v)
    end
    if init === nothing
        c = Ref{typeout}()
        typec = typeout
    else
        c = Ref(init)
        typec = typeof(init)
    end
    op = getoperator(op, typec)
    accum = getoperator(accum, typec)
    libgb.scalarvecreduce[typeout](c, accum, op, v, desc)
    return c[]
end

function Base.reduce(
    ::BinaryUnion,
    ::GBArray;
    dims = 2,
    typeout = nothing,
    init = nothing,
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    throw(ArgumentError("reduce requires a Monoid op."))
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
