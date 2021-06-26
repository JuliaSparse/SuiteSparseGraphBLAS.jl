function reduce!(
    op::MonoidUnion, w::GBVector, A::GBMatOrTranspose;
    mask = nothing, accum = nothing, desc = nothing
)
    _, mask, accum, desc = _handlectx(op, mask, accum, desc)
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
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    _, mask, accum, desc = _handlectx(op, mask, accum, desc)
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
    _, _, accum, desc = _handlectx(op, nothing, accum, desc, BinaryOps.TIMES)
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
