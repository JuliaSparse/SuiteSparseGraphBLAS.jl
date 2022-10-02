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
    desc = _handledescriptor(desc; out=C, in1=A, in2=B)
    mask = _handlemask!(desc, mask)
    size(C, 1) == size(A, 1) == size(B, 1) &&
    size(C, 2) == size(A, 2) == size(B, 2) || throw(DimensionMismatch())
    op = binaryop(op, A, B)
    accum = _handleaccum(accum, storedeltype(C))
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
    accum = nothing,
    desc = nothing
)
    t = inferbinarytype(parent(A), parent(B), op)
    
    C = similar(A, t, _combinesizes(A, B); fill=_promotefill(parent(A), parent(B), op))
    return emul!(C, A, B, op; mask, accum, desc)
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
    mask = _handlemask!(desc, mask)
    size(C, 1) == size(A, 1) == size(B, 1) &&
    size(C, 2) == size(A, 2) == size(B, 2) || throw(DimensionMismatch())
    op = binaryop(op, A, B)
    accum = _handleaccum(accum, storedeltype(C))
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
- `accum::Union{Nothing, Function} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eadd(
    A::GBArrayOrTranspose,
    B::GBArrayOrTranspose,
    op = +;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    t = inferbinarytype(parent(A), parent(B), op)
    C = similar(A, t, _combinesizes(A, B); fill=_promotefill(parent(A), parent(B), op))
    return eadd!(C, A, B, op; mask, accum, desc)
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
    mask = _handlemask!(desc, mask)
    size(C, 1) == size(A, 1) == size(B, 1) &&
    size(C, 2) == size(A, 2) == size(B, 2) || throw(DimensionMismatch())
    op = binaryop(op, A, B)
    accum = _handleaccum(accum, storedeltype(C))
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
- `accum::Union{Nothing, Function} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eunion(
    A::GBArrayOrTranspose{T},
    α::T,
    B::GBArrayOrTranspose{U},
    β::U,
    op = +;
    mask = nothing,
    accum = nothing,
    desc = nothing
) where {T, U}
    t = inferbinarytype(parent(A), parent(B), op)
    C = similar(A, t, _combinesizes(A, B); fill=_promotefill(parent(A), parent(B), op))
    return eunion!(C, A, α, B, β, op; mask, accum, desc)
end

function Base.:+(A::GBArrayOrTranspose, B::GBArrayOrTranspose)
    eadd(A, B, +)
end

function Base.:-(A::GBArrayOrTranspose, B::GBArrayOrTranspose)
    eadd(A, B, -)
end

⊕(A, B, op; mask = nothing, accum = nothing, desc = nothing) =
    eadd(A, B, op; mask, accum, desc)
⊗(A, B, op; mask = nothing, accum = nothing, desc = nothing) =
    emul(A, B, op; mask, accum, desc)

⊕(f::Union{Function, TypedBinaryOperator}) = (A, B; mask = nothing, accum = nothing, desc = nothing) ->
    eadd(A, B, f; mask, accum, desc)

⊗(f::Union{Function, TypedBinaryOperator}) = (A, B; mask = nothing, accum = nothing, desc = nothing) ->
    emul(A, B, f; mask, accum, desc)

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