"""
    emul!(C::GBArrayOrTranspose, A::GBArrayOrTranspose, B::GBArrayOrTranspose, op = *; kwargs...)::GBArrayOrTranspose

Apply the binary operator `op` elementwise on the set intersection of `A` and `B`. Store or
accumulate the result into C. When `op = *` this is equivalent to `A .* B`,
however any binary operator may be substituted.

The pattern of the result is the set intersection of `A` and `B`. For a set
union equivalent see [`eadd!`](@ref).

# Arguments
- `C::GBArrayOrTranspose`: the output vector or matrix.
- `A, B::GBArrayOrTranspose`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Function, Monoid} = *`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in both `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, Function} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before
    accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function emul!(
    C::GBVecOrMat,
    A::GBArrayOrTranspose,
    B::GBArrayOrTranspose,
    op = *;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    desc, mask = _handlemask!(desc, mask)
    size(C, 1) == size(A, 1) == size(B, 1) &&
    size(C, 2) == size(A, 2) == size(B, 2) || (return _bcastemul!(C, A, B, op; mask, accum, desc))
    desc = _handledescriptor(desc; out=C, in1=A, in2=B)
    intermediatetype = storedeltype(C)
    op = binaryop(op, A, B, intermediatetype)
    accum = _handleaccum(accum, C, intermediatetype)
    if op isa TypedBinaryOperator
        @wraperror LibGraphBLAS.GrB_Matrix_eWiseMult_BinaryOp(C, mask, accum, op, parent(A), parent(B), desc)
        return C
    else
        throw(ArgumentError("$op is not a valid binary operator."))
    end
end

"""
    emul(A::GBArrayOrTranspose, B::GBArrayOrTranspose, op = *; kwargs...)::GBMatrix

Apply the binary operator `op` elementwise on the set intersection of `A` and `B`.
When `op = *` this is equivalent to `A .* B`, however any binary operator may be substituted.

The pattern of the result is the set intersection of `A` and `B`. For a set
union equivalent see [`eadd`](@ref).

# Arguments
- `A, B::GBArrayOrTranspose`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Function, Monoid} = *`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in both `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`

# Returns
- `GBVecOrMat`: Output `GBVector` or `GBMatrix` whose eltype is determined by the `eltype` of
    `A` and `B` or the binary operation if a type specific operation is provided.
"""
function emul(
    A::GBArrayOrTranspose,
    B::GBArrayOrTranspose,
    op = *;
    mask = nothing,
    desc = nothing
)
    T = inferbinarytype(parent(A), parent(B), op)
    M = gbpromote_strip(A, B)
    C = M{T}(_combinesizes(A, B))
    return emul!(C, A, B, op; mask, desc)
end

# we assume mismatched sizes here.
# function _bcastemul!(
#     C::GBVecOrMat,
#     A::GBArrayOrTranspose,
#     B::GBArrayOrTranspose,
#     op = *;
#     mask = nothing,
#     accum = nothing,
#     desc = nothing
# )
#     # bcast A[1] into B
#     length(A) == 1 && (return apply!(C, op, A[1], B; mask, accum, desc))
#     # bcast B[1] into A
#     length(B) == 1 && (return apply!(C, op, A, B[1]; mask, accum, desc))
# 
#     if size(A, 2) != size(B, 2) && size(A, 1) == size(B, 1)
#         if size(A, 2) == 1
#             vec, mat = A, B
#         elseif size(B, 2) == 1
#             vec, mat = B, A
#             op = _swapop(op)
#         else
#             throw(DimensionMismatch("arrays could not be broadcast to a common size;" * 
#                 "got a dimension with lengths $(size(A, 2)) and $(size(B, 2))"))
#         end
#         return mul!(C, Diagonal(vec), mat, (any, op); mask, accum, desc)
#     end
#     if size(A, 2) == size(B, 2) && size(A, 1) != size(B, 1)
#         if size(A, 1) == 1
#             vec, mat = B, A
#             op = _swapop(op)
#         elseif size(B, 1) == 1
#             vec, mat = A, B
#         else
#             throw(DimensionMismatch("arrays could not be broadcast to a common size;" * 
#                 "got a dimension with lengths $(size(A, 1)) and $(size(right, 1))"))
#         end
#         return mul!(C, mat, Diagonal(parent(vec)), (any, op); mask, accum, desc)
#     end
#     throw(DimensionMismatch())
# end

# outer prod
function _bcastemul!(
    C::AbstractGBArray, A::AbstractGBVector, B::Transpose{<:Any, <:AbstractGBVector}, op;
    mask = nothing, accum = nothing, desc = nothing
)
    return mul!(C, A, B, (any, op); mask, accum, desc)
end
# also outer prod
function _bcastemul!(
    C::AbstractGBArray, A::Transpose{<:Any, <:AbstractGBVector}, B::AbstractGBVector, op;
    mask = nothing, accum = nothing, desc = nothing
)
    op2 = _swapop(op)
    if isnothing(op2) # worst possible fallback
        full = similar(B)
        full[:] = 0
        T1 = *(full, A, (any, second); mask)
        full = similar(A)
        full[:] = 0
        T2 = *(B, full, (any, first); mask)
        return emul!(C, T1, T2, op; mask, accum, desc)
    end
    return mul!(C, B, A, (any, op2); mask, accum, desc)
end
# A::Matrix .* v::Vector
function _bcastemul!(
    C::AbstractGBArray, A::GBMatrixOrTranspose, B::AbstractGBVector, op;
    mask = nothing, accum = nothing, desc = nothing
)
    op2 = _swapop(op)
    if op2 # manually bcast:
        full = similar(B, size(A, 2))
        full[:] = 0
        T = *(B, full', (any, first); mask)
        return emul!(C, A, T, op; mask, accum, desc)
    end
    return mul!(C, Diagonal(B), A, (any, op2); mask, accum, desc)
end
# v .* A
function _bcastemul!(
    C::AbstractGBArray, A::AbstractGBVector,  B::GBMatrixOrTranspose, op;
    mask = nothing, accum = nothing, desc = nothing
)
    return mul!(C, Diagonal(A), B, (any, op); mask, accum, desc)
end

# A::Matrix .* v::Vector'
function _bcastemul!(
    C::AbstractGBArray, A::GBMatrixOrTranspose, B::Transpose{<:Any, <:AbstractGBVector}, op;
    mask = nothing, accum = nothing, desc = nothing
)
    return mul!(C, A, Diagonal(parent(B)), (any, op); mask, accum, desc)
end
# v' .* A
function _bcastemul!(
    C::AbstractGBArray, A::Transpose{<:Any, <:AbstractGBVector},  B::GBMatrixOrTranspose, op;
    mask = nothing, accum = nothing, desc = nothing
)
    op2 = _swapop(op)
    if isnothing(op2)
        full = similar(A, size(B, 1))
        full[:] = 0
        T = *(full, A, (any, second); mask)
        return emul!(C, T, B, op; mask, accum, desc)
    end
    return mul!(C, B, Diagonal(parent(A)), (any, op2); mask, accum, desc)
end

"""
    eadd!(C::GBVecOrMat, A::GBArrayOrTranspose, B::GBArrayOrTranspose, op = +; kwargs...)::GBVecOrMat

Apply the binary operator `op` elementwise on the set union of `A` and `B`. Store or
accumulate the result into C. When `op = +` this is equivalent to `A .+ B`,
however any binary operation may be substituted.

Note that the behavior of `A[i,j] op B[i,j]` may be unintuitive when one operand is an implicit
zero. The explicit operand *passes through* the function. So `A[i,j] op B[i,j]` where `B[i,j]`
is an implicit zero returns `A[i,j]` **not** `A[i,j] op zero(T)`.

For a set intersection equivalent see [`emul!`](@ref).

# Arguments
- `C::GBArrayOrTranspose`: the output vector or matrix.
- `A, B::GBArrayOrTranspose`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Function, Monoid} = +`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, Function} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eadd!(
    C::GBVecOrMat,
    A::GBArrayOrTranspose,
    B::GBArrayOrTranspose,
    op = +;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in1=A, in2 = B)
    desc, mask = _handlemask!(desc, mask)
    size(C, 1) == size(A, 1) == size(B, 1) &&
    size(C, 2) == size(A, 2) == size(B, 2) || (return _bcasteadd!(C, A, B, op; mask, accum, desc))
        
    intermediatetype = storedeltype(C) # accum should support heterogeneity but it's iffy.
    op = binaryop(op, A, B, intermediatetype)
    accum = _handleaccum(accum, C, intermediatetype)
    if op isa TypedBinaryOperator
        @wraperror LibGraphBLAS.GrB_Matrix_eWiseAdd_BinaryOp(C, mask, accum, op, parent(A), parent(B), desc)
        return C
    else
        throw(ArgumentError("$op is not a valid binary op."))
    end
end

"""
    eadd(A::GBArrayOrTranspose, B::GBArrayOrTranspose, op = +; kwargs...)::GBVecOrMat

Apply the binary operator `op` elementwise on the set union of `A` and `B`.
When `op = +` this is equivalent to `A .+ B`, however any binary operation may be substituted.

Note that the behavior of `A[i,j] op B[i,j]` may be unintuitive when one operand is an implicit
zero. The explicit operand *passes through* the function. So `A[i,j] op B[i,j]` where `B[i,j]`
is an implicit zero returns `A[i,j]` **not** `A[i,j] op zero(T)`.

For a set intersection equivalent see [`emul`](@ref).

# Arguments
- `A, B::GBArrayOrTranspose`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Function, Monoid} = +`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eadd(
    A::GBArrayOrTranspose,
    B::GBArrayOrTranspose,
    op = +;
    mask = nothing,
    desc = nothing
)
    T = inferbinarytype(parent(A), parent(B), op)
    M = gbpromote_strip(A, B)
    C = M{T}(_combinesizes(A, B))
    return eadd!(C, A, B, op; mask, desc)
end

function _bcasteadd!(
    C::GBMatrix,
    A::GBVectorOrTranspose,
    B::GBMatrixOrTranspose,
    op = *;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    full = similar(A)
    full[:] = 0
    T = *(A, full', (any, first); mask)
    eadd!(C, T, B, op; mask, accum, desc)
end
function _bcasteadd!(
    C::GBMatrix,
    A::GBMatrixOrTranspose,
    B::GBVectorOrTranspose,
    op = *;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    full = similar(B)
    full[:] = 0
    T = *(B, full', (any, first); mask)
    eadd!(C, A, T, op; mask, accum, desc)
end
function _bcasteadd!(
    C::GBMatrix,
    A::GBVectorOrTranspose,
    B::GBVectorOrTranspose,
    op = *;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    full = similar(B)
    full[:] = 0
    T = *(B, full', (any, first); mask)
    eadd!(C, A, T, op; mask, accum, desc)
end

"""
    eunion!(C::GBVecOrMat, A::GBArrayOrTranspose{T}, α::T B::GBArrayOrTranspose, β::T, op = +; kwargs...)::GBVecOrMat

Apply the binary operator `op` elementwise on the set union of `A` and `B`. Store or
accumulate the result into C. When `op = +` this is equivalent to `A .+ B`,
however any binary operation may be substituted.

Unlike `eadd!` where an argument missing in `A` causes the `B` element to "pass-through",
`eunion!` utilizes the `α` and `β` arguments for the missing operand elements.

# Arguments
- `C::GBArrayOrTranspose`: the output vector or matrix.
- `A, B::GBArrayOrTranspose`: A GBVector or GBMatrix, possibly transposed.
- `α, β`: The fill-in value for `A` and `B` respectively.
- `op::Union{Function, Monoid} = +`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, Function} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eunion!(
    C::GBVecOrMat,
    A::GBArrayOrTranspose{T},
    α::T,
    B::GBArrayOrTranspose{U},
    β::U,
    op = +;
    mask = nothing,
    accum = nothing,
    desc = nothing
) where {T, U}
    _canbeoutput(C) || throw(ShallowException())
    desc = _handledescriptor(desc; out=C, in1=A, in2 = B)
    desc, mask = _handlemask!(desc, mask)
    size(C, 1) == size(A, 1) == size(B, 1) &&
    size(C, 2) == size(A, 2) == size(B, 2) || throw(DimensionMismatch())
    # accum should support heterogeneity but it's iffy.
    intermediatetype = storedeltype(C)
    op = binaryop(op, A, B, intermediatetype)
    accum = _handleaccum(accum, C, intermediatetype)
    if op isa TypedBinaryOperator
        @wraperror LibGraphBLAS.GxB_Matrix_eWiseUnion(C, mask, accum, op, parent(A), GBScalar(α), parent(B), GBScalar(β), desc)
        return C
    else
        throw(ArgumentError("$op is not a valid binary op."))
    end
end

"""
    eunion(C::GBVecOrMat, A::GBArrayOrTranspose{T}, α::T B::GBArrayOrTranspose, β::T, op = +; kwargs...)::GBVecOrMat

Apply the binary operator `op` elementwise on the set union of `A` and `B`.
When `op = +` this is equivalent to `A .+ B`, however any binary operation may be substituted.

Unlike `eadd!` where an argument missing in `A` causes the `B` element to "pass-through",
`eunion!` utilizes the `α` and `β` arguments for the missing operand elements.

# Arguments
- `A, B::GBArrayOrTranspose`: A GBVector or GBMatrix, possibly transposed.
- `α, β`: The fill-in value for `A` and `B` respectively.
- `op::Union{Function, Monoid} = +`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eunion(
    A::GBArrayOrTranspose{T},
    α::T,
    B::GBArrayOrTranspose{U},
    β::U,
    op = +;
    mask = nothing,
    desc = nothing
) where {T, U}
    t = inferbinarytype(parent(A), parent(B), op)
    M = gbpromote_strip(A, B)
    C = M{t}(_combinesizes(A, B))
    return eunion!(C, A, α, B, β, op; mask, desc)
end

eunion(
    A::GBArrayOrTranspose, α, B::GBArrayOrTranspose, β, op = +;
    kwargs...
) = eunion(A, convert(storedeltype(A), α), B, convert(storedeltype(B), β), op; kwargs...)

eunion!(
    C::GBVecOrMat, A::GBArrayOrTranspose, α, B::GBArrayOrTranspose, β, op = +;
    kwargs...
) = eunion!(C, A, convert(storedeltype(A), α), B, convert(storedeltype(B), β), op; kwargs...)

function Base.:+(A::GBArrayOrTranspose, B::GBArrayOrTranspose)
    eadd(A, B, +)
end

function Base.:-(A::GBArrayOrTranspose, B::GBArrayOrTranspose)
    eadd(A, B, -)
end

⊕(A, B, op; kwargs...) = eadd(A, B, op; kwargs...)
⊗(A, B, op; kwargs...) = emul(A, B, op; kwargs...)

⊕(f::Union{Function, TypedBinaryOperator}) = 
    (A, B; kwargs...) -> eadd(A, B, f; kwargs...)

⊗(f::Union{Function, TypedBinaryOperator}) = 
    (A, B; kwargs...) -> emul(A, B, f; kwargs...)

# pack friendly overloads. Potentially this could be done more succinctly by using Unions above.
# but it's ~ 10loc per function so it's nbd.
emul!(C::GBVecOrMat, A::VecMatOrTrans, B::GBArrayOrTranspose, op = *; kwargs...) = 
    @_densepack A emul!(C, A, B, op; kwargs...)
emul!(C::GBVecOrMat, A::GBArrayOrTranspose, B::VecMatOrTrans, op = *; kwargs...) = 
    @_densepack B emul!(C, A, B, op; kwargs...)
emul!(C::GBVecOrMat, A::VecMatOrTrans, B::VecMatOrTrans, op = *; kwargs...) = 
    @_densepack A B emul!(C, A, B, op; kwargs...)
emul(A::VecMatOrTrans, B::GBArrayOrTranspose, op = *; kwargs...) = 
    @_densepack A emul(A, B, op; kwargs...)
emul(A::GBArrayOrTranspose, B::VecMatOrTrans, op = *; kwargs...) = 
    @_densepack B emul(A, B, op; kwargs...)
emul(A::VecMatOrTrans, B::VecMatOrTrans, op = *; kwargs...) = 
    @_densepack A B emul(A, B, op; kwargs...)

eadd!(C::GBVecOrMat, A::VecMatOrTrans, B::GBArrayOrTranspose, op = +; kwargs...) = 
    @_densepack A eadd!(C, A, B, op; kwargs...)
eadd!(C::GBVecOrMat, A::GBArrayOrTranspose, B::VecMatOrTrans, op = +; kwargs...) = 
    @_densepack B eadd!(C, A, B, op; kwargs...)
eadd!(C::GBVecOrMat, A::VecMatOrTrans, B::VecMatOrTrans, op = +; kwargs...) = 
    @_densepack A B eadd!(C, A, B, op; kwargs...)
eadd(A::VecMatOrTrans, B::GBArrayOrTranspose, op = +; kwargs...) = 
    @_densepack A eadd(A, B, op; kwargs...)
eadd(A::GBArrayOrTranspose, B::VecMatOrTrans, op = +; kwargs...) = 
    @_densepack B eadd(A, B, op; kwargs...)
eadd(A::VecMatOrTrans, B::VecMatOrTrans, op = +; kwargs...) = 
    @_densepack A B eadd(A, B, op; kwargs...)

eunion!(C::GBVecOrMat, A::VecMatOrTrans, α, B::GBArrayOrTranspose, β, op = +; kwargs...) = 
    @_densepack A eunion!(C, A, α, B, β, op; kwargs...)
eunion!(C::GBVecOrMat, A::GBArrayOrTranspose, α, B::VecMatOrTrans, β, op = +; kwargs...) = 
    @_densepack B eunion!(C, A, α, B, β, op; kwargs...)
eunion!(C::GBVecOrMat, A::VecMatOrTrans, α, B::VecMatOrTrans, β, op = +; kwargs...) = 
    @_densepack A B eunion!(C, A, α, B, β, op; kwargs...)
eunion(A::VecMatOrTrans, α, B::GBArrayOrTranspose, β, op = +; kwargs...) = 
    @_densepack A eunion(A, α, B, β, op; kwargs...)
eunion(A::GBArrayOrTranspose, α, B::VecMatOrTrans, β, op = +; kwargs...) = 
    @_densepack B eunion(A, α, B, β, op; kwargs...)
eunion(A::VecMatOrTrans, α, B::VecMatOrTrans, β, op = +; kwargs...) = 
    @_densepack A B eunion(A, B, op; kwargs...)
