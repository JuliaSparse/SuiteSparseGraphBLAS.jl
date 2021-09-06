# TODO: Document additional trick functionality
"""
    gbtranspose!(C::GBMatrix, A::GBMatrix; kwargs...)::Nothing

Eagerly evaluated matrix transpose, storing the output in `C`.

# Arguments
- `C::GBMatrix`: output matrix.
- `A::GBMatrix`: input matrix.

# Keywords
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: optional mask.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = DEFAULTDESC`
"""
function gbtranspose!(
    C::GBVecOrMat, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc === nothing && (desc = DEFAULTDESC)
    if A isa Transpose && desc.input1 == TRANSPOSE
        throw(ArgumentError("Cannot have A isa Transpose and desc.input1 = TRANSPOSE."))
    elseif A isa Transpose
        A = A.parent
        desc = desc + T0
    end
    accum = getaccum(accum, eltype(C))
    libgb.GrB_transpose(C, mask, accum, A, desc)
    return C
end

"""
    gbtranspose(A::GBMatrix; kwargs...)::GBMatrix

Eagerly evaluated matrix transpose which returns the transposed matrix.

# Keywords
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: optional mask.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = DEFAULTDESC`

# Returns
- `C::GBMatrix`: output matrix.
"""
function gbtranspose(
    A::GBArray;
    mask = C_NULL, accum = nothing, desc::Descriptor = DEFAULTDESC
)
    C = similar(A, size(A,2), size(A, 1))
    gbtranspose!(C, A; mask, accum, desc)
    return C
end

function LinearAlgebra.transpose(A::GBArray)
    return Transpose(A)
end

function Base.copy!(
    C::GBMatrix, A::LinearAlgebra.Transpose{<:Any, <:GBArray};
    mask = C_NULL, accum = nothing, desc::Descriptor = C_NULL
)
    return gbtranspose!(C, A.parent; mask, accum, desc)
end



function Base.copy(
    A::LinearAlgebra.Transpose{<:Any, <:GBArray};
    mask = C_NULL, accum = nothing, desc::Descriptor = DEFAULTDESC
)
    return gbtranspose(A.parent; mask, accum, desc)
end

function _handletranspose(
    A::Union{GBArray, Nothing} = nothing,
    desc::Union{Descriptor, Nothing, Ptr{Nothing}} = nothing,
    B::Union{GBArray, Nothing} = nothing
)
    if desc == C_NULL
        desc = DEFAULTDESC
    end
    if A isa Transpose
        desc = desc + T0
        A = A.parent
    end
    if B isa Transpose
        desc = desc + T1
        B = B.parent
    end
    return A, desc, B
end

#This is ok per the GraphBLAS Slack channel. Should change its effect on Complex input.
LinearAlgebra.adjoint(A::GBMatrix) = transpose(A)

LinearAlgebra.adjoint(v::GBVector) = transpose(v)

#arrrrgh, type piracy.
LinearAlgebra.transpose(::Nothing) = nothing
