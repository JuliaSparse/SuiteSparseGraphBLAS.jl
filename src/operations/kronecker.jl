"""
    kron!(A::GBMatrix, B::GBMatrix, op = BinaryOps.TIMES; kwargs...)::GBMatrix

In-place version of [`kron`](@ref).
"""
function LinearAlgebra.kron!(
    C::GBVecOrMat,
    A::GBArrayOrTranspose,
    B::GBArrayOrTranspose,
    op = *;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; in1=A, in2=B)
    mask = _handlemask!(desc, mask)
    op = binaryop(op, A, B)
    accum = _handleaccum(accum, storedeltype(C))
    @wraperror LibGraphBLAS.GxB_kron(C, mask, accum, op, parent(A), parent(B), desc)
    return C
end

"""
   kron(A::GBMatrix, B::GBMatrix, op = BinaryOps.TIMES; kwargs...)::GBMatrix

Kronecker product of two matrices using `op` as the multiplication operator.
Does not support `GBVector`s at this time.

# Arguments
- `A::GBMatrix`: optionally transposed.
- `B::GBMatrix`: optionally transposed.
- `op::MonoidBinaryOrRig = BinaryOps.TIMES`: the binary operation which replaces the arithmetic
    multiplication operation from the usual kron function.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`
"""
function LinearAlgebra.kron(
    A::GBArrayOrTranspose,
    B::GBArrayOrTranspose,
    op = *;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    T = inferbinarytype(parent(A), parent(B), op)
    fill=_promotefill(parent(A), parent(B), op)
    M = gbpromote_strip(A, B)
    C = M{T}(size(A, 1) * size(B, 1), size(A, 2) * size(B, 2); fill)
    kron!(C, A, B, op; mask, accum, desc)
    return C
end

LinearAlgebra.kron!(C::GBVecOrMat, A::VecMatOrTrans, B::GBArrayOrTranspose, op = *; kwargs...) = 
    @_densepack A kron!(C, A, B, op; kwargs...)
LinearAlgebra.kron!(C::GBVecOrMat, A::GBArrayOrTranspose, B::VecMatOrTrans, op = *; kwargs...) = 
    @_densepack B kron!(C, A, B, op; kwargs...)
LinearAlgebra.kron!(C::GBVecOrMat, A::VecMatOrTrans, B::VecMatOrTrans, op = *; kwargs...) = 
    @_densepack A B kron!(C, A, B, op; kwargs...)

LinearAlgebra.kron(A::VecMatOrTrans, B::GBArrayOrTranspose, op = *; kwargs...) = 
    @_densepack A kron(A, B, op; kwargs...)
LinearAlgebra.kron(A::GBArrayOrTranspose, B::VecMatOrTrans, op = *; kwargs...) = 
    @_densepack B kron(A, B, op; kwargs...)
LinearAlgebra.kron(A::VecMatOrTrans, B::VecMatOrTrans, op = *; kwargs...) = 
    @_densepack A B kron(A, B, op; kwargs...)
