function select!(
    op::SelectUnion,
    C::GBVecOrMat,
    A::GBArray,
    thunk::Union{GBScalar, Nothing, Number} = nothing;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    thunk === nothing && (thunk = C_NULL)
    A, desc, _ = _handletranspose(A, desc)
    if thunk isa Number
        thunk = GBScalar(thunk)
    end
    if A isa GBVector && C isa GBVector
        libgb.GxB_Vector_select(C, mask, accum, op, A, thunk, desc)
    elseif A isa GBMatrix && C isa GBMatrix
        libgb.GxB_Matrix_select(C, mask, accum, op, A, thunk, desc)
    end
end

function select(
    op::SelectUnion,
    A::GBArray,
    thunk::Union{GBScalar, Nothing, valid_union} = nothing;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    C = similar(A)
    select!(op, C, A, thunk; accum, mask, desc)
    return C
end
