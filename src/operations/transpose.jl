# TODO: Document additional trick functionality
"""
    gbtranspose!(C::GBMatrix, A::GBMatrix; kwargs...)::Nothing

Eagerly evaluated matrix transpose, storing the output in `C`.

# Arguments
- `C::GBMatrix`: output matrix.
- `A::GBMatrix`: input matrix.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = DEFAULTDESC`
"""
function gbtranspose!(
    C::AbstractGBArray, A::GBArrayOrTranspose;
    mask = nothing, accum = nothing, desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in1=A)
    mask = _handlemask!(desc, mask)
    accum = _handleaccum(accum, eltype(C))
    @wraperror LibGraphBLAS.GrB_transpose(C, mask, accum, parent(A), desc)
    return C
end
"""
    gbtranspose(A::GBMatrix; kwargs...)::GBMatrix

Eagerly evaluated matrix transpose which returns the transposed matrix.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`

# Returns
- `C::GBMatrix`: output matrix.
"""
function gbtranspose(A::GBArrayOrTranspose; mask = nothing, accum = nothing, desc = nothing)
    C = similar(A, size(A,2), size(A, 1))
    gbtranspose!(C, A; mask, accum, desc)
    return C
end

function LinearAlgebra.transpose(A::AbstractGBArray)
    return Transpose(A)
end

function Base.copy!(
    C::GBVecOrMat, A::LinearAlgebra.Transpose{<:Any, <:GBVecOrMat};
    mask = nothing, accum = nothing, desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    return gbtranspose!(C, A.parent; mask, accum, desc)
end

function Base.copy(
    A::LinearAlgebra.Transpose{<:Any, <:GBVecOrMat};
    mask = nothing, accum = nothing, desc = nothing
)
    return gbtranspose(parent(A); mask, accum, desc)
end

#This is ok per the GraphBLAS Slack channel. Should change its effect on Complex input.
LinearAlgebra.adjoint(A::GBVecOrMat) = transpose(A)

#arrrrgh, type piracy.
# TODO: avoid this if possible
LinearAlgebra.transpose(::Nothing) = nothing

Base.unsafe_convert(::Type{Ptr{T}}, A::LinearAlgebra.AdjOrTrans{<:Any, <:AbstractGBArray}) where {T} = 
throw(ArgumentError("Cannot convert $(typeof(A)) directly to a pointer. Please use copy."))

"""
    mask!(C::GBArrayOrTranspose, A::GBArrayOrTranspose, mask::GBVecOrMat)

Apply a mask to matrix `A`, storing the results in C.
"""
function mask!(C::GBVecOrMat, A::GBArrayOrTranspose, mask; desc = nothing, replace_output = true)
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in1 = A)
    desc.transpose_input1 = true # double transpose to cancel out transpose.
    desc.replace_output = replace_output # we must replace 
    mask = _handlemask!(desc, mask)
    gbtranspose!(C, A; mask, desc)
    return C
end

function mask!(A::GBArrayOrTranspose, mask; desc = nothing, replace_output = true)
    mask!(A, A, mask; desc)
end

"""
    mask(A::GBArrayOrTranspose, mask::GBVecOrMat)

Apply a mask to matrix `A`.
"""
function mask(A::GBArrayOrTranspose, mask; desc = nothing, replace_output = true)
    return mask!(similar(A), A, mask; desc)
end