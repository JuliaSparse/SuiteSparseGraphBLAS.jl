function reduce!(
    op::MonoidUnion, w::GBVector, A::GBMatOrTranspose;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    A, desc, _ = _handletranspose(A, desc, nothing)
    op = getoperator(op, eltype(w))
    accum = getoperator(accum, eltype(w))
    libgb.GrB_Matrix_reduce_Monoid(w, mask, accum, op, A, desc)
end

function Base.reduce(
    op::MonoidUnion,
    A::GBMatOrTranspose;
    dims = 2,
    typeout = nothing,
    init = nothing,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
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
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
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
    op::BinaryUnion,
    A::GBArray;
    dims = 2,
    typeout = nothing,
    init = nothing,
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    throw(ArgumentError("reduce requires a Monoid op."))
end
