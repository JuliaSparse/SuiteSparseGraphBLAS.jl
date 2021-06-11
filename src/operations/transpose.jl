function gbtranspose!(
    C::GBMatrix, A::GBMatrix;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.C_NULL
)
    libgb.GrB_transpose(C, mask, accum, A, desc)
end

function gbtranspose(A::GBMatrix;
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.C_NULL
)
    C = similar(A.parent, size(A.parent,2), size(A.parent, 1))
    gbtranspose!(C, A; mask, accum, desc)
    return C
end

function LinearAlgebra.transpose(A::GBMatrix)
    return Transpose(A)
end

function Base.copy!(
    C::GBMatrix, A::LinearAlgebra.Transpose{<:Any, <:GBMatrix};
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.C_NULL
)
    return gbtranspose!(C, A.parent; mask, accum, desc)
end

function Base.copy(
    A::LinearAlgebra.Transpose{<:Any, <:GBMatrix};
    mask = C_NULL, accum = C_NULL, desc::Descriptor = Descriptors.NULL
)
    return gbtranspose(A.parent; mask, accum, desc)
end

function _handletranspose(
    A::GBArray,
    desc::Union{Descriptor, Nothing} = nothing,
    B::Union{GBArray, Nothing} = nothing
)
    if A isa Transpose
        desc = desc + Descriptors.T0
        A = A.parent
    end
    if B isa Transpose
        desc = desc + Descriptors.T1
        B = B.parent
    end
    return A, desc, B
end
