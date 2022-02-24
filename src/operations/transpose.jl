# TODO: Document additional trick functionality
"""
    gbtranspose!(C::GBMatrix, A::GBMatrix; kwargs...)::Nothing

Eagerly evaluated matrix transpose, storing the output in `C`.

# Arguments
- `C::GBMatrix`: output matrix.
- `A::GBMatrix`: input matrix.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = DEFAULTDESC`
"""
function gbtranspose!(
    C::GBVecOrMat, A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A)
    accum = getaccum(accum, eltype(C))
    @wraperror LibGraphBLAS.GrB_transpose(C, mask, accum, parent(A), desc)
    return C
end

"""
    gbtranspose(A::GBMatrix; kwargs...)::GBMatrix

Eagerly evaluated matrix transpose which returns the transposed matrix.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`

# Returns
- `C::GBMatrix`: output matrix.
"""
function gbtranspose(
    A::GBArray;
    mask = nothing, accum = nothing, desc = nothing
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
    mask = nothing, accum = nothing, desc = nothing
)
    return gbtranspose!(C, A.parent; mask, accum, desc)
end



function Base.copy(
    A::LinearAlgebra.Transpose{<:Any, <:GBArray};
    mask = nothing, accum = nothing, desc = nothing
)
    return gbtranspose(parent(A); mask, accum, desc)
end

#This is ok per the GraphBLAS Slack channel. Should change its effect on Complex input.
LinearAlgebra.adjoint(A::GBMatrix) = transpose(A)

LinearAlgebra.adjoint(v::GBVector) = transpose(v)

#arrrrgh, type piracy.
LinearAlgebra.transpose(::Nothing) = nothing
