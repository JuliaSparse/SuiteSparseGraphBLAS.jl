"""
    emul!(C::GBArray, A::GBArray, B::GBArray, op = *; kwargs...)::GBArray

Apply the binary operator `op` elementwise on the set intersection of `A` and `B`. Store or
accumulate the result into C. When `op = *` this is equivalent to `A .* B`,
however any binary operator may be substituted.

The pattern of the result is the set intersection of `A` and `B`. For a set
union equivalent see [`eadd!`](@ref).

# Arguments
- `C::GBArray`: the output vector or matrix.
- `A, B::GBArray`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Function, AbstractBinaryOp, Monoid} = *`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in both `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, Function, AbstractBinaryOp} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before
    accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function emul!(
    C::GBVecOrMat,
    A::GBArray,
    B::GBArray,
    op::MonoidBinaryOrRig = BinaryOps.TIMES;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A, in2=B)
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    op = getoperator(op, optype(A, B))
    accum = getaccum(accum, eltype(C))
    if op isa TypedSemiring
        libgb.GrB_Matrix_eWiseMult_Semiring(C, mask, accum, op, parent(A), parent(B), desc)
        return C
    elseif op isa TypedMonoid
        libgb.GrB_Matrix_eWiseMult_Monoid(C, mask, accum, op, parent(A), parent(B), desc)
        return C
    elseif op isa TypedBinaryOperator
        libgb.GrB_Matrix_eWiseMult_BinaryOp(C, mask, accum, op, parent(A), parent(B), desc)
        return C
    else
        throw(ArgumentError("$op is not a valid monoid binary op or semiring."))
    end
    return C
end

"""
    emul(A::GBArray, B::GBArray, op = *; kwargs...)::GBMatrix

Apply the binary operator `op` elementwise on the set intersection of `A` and `B`.
When `op = *` this is equivalent to `A .* B`, however any binary operator may be substituted.

The pattern of the result is the set intersection of `A` and `B`. For a set
union equivalent see [`eadd`](@ref).

# Arguments
- `A, B::GBArray`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Function, AbstractBinaryOp, Monoid} = *`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in both `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`

# Returns
- `GBVecOrMat`: Output `GBVector` or `GBMatrix` whose eltype is determined by the `eltype` of
    `A` and `B` or the binary operation if a type specific operation is provided.
"""
function emul(
    A::GBArray,
    B::GBArray,
    op::MonoidBinaryOrRig = *;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    t = inferoutputtype(A, B, op)
    if A isa GBVector && B isa GBVector
        C = GBVector{t}(size(A))
    else
        C = GBMatrix{t}(size(A))
    end
    return emul!(C, A, B, op; mask, accum, desc)
end

"""
    eadd!(C::GBVecOrMat, A::GBArray, B::GBArray, op = +; kwargs...)::GBVecOrMat

Apply the binary operator `op` elementwise on the set union of `A` and `B`. Store or
accumulate the result into C. When `op = +` this is equivalent to `A .+ B`,
however any binary operation may be substituted.

Note that the behavior of `A[i,j] op B[i,j]` may be unintuitive when one operand is an implicit
zero. The explicit operand *passes through* the function. So `A[i,j] op B[i,j]` where `B[i,j]`
is an implicit zero returns `A[i,j]` **not** `A[i,j] op zero(T)`.

For a set intersection equivalent see [`emul!`](@ref).

# Arguments
- `C::GBArray`: the output vector or matrix.
- `A, B::GBArray`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Function, AbstractBinaryOp, Monoid} = +`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, Function, AbstractBinaryOp} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eadd!(
    C::GBVecOrMat,
    A::GBArray,
    B::GBArray,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A, in2 = B)
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    op = getoperator(op, optype(A, B))
    accum = getaccum(accum, eltype(C))
    if op isa TypedSemiring
        libgb.GrB_Matrix_eWiseAdd_Semiring(C, mask, accum, op, parent(A), parent(B), desc)
        return C
    elseif op isa TypedMonoid
        libgb.GrB_Matrix_eWiseAdd_Monoid(C, mask, accum, op, parent(A), parent(B), desc)
        return C
    elseif op isa TypedBinaryOperator
        libgb.GrB_Matrix_eWiseAdd_BinaryOp(C, mask, accum, op, parent(A), parent(B), desc)
        return C
    else
        throw(ArgumentError("$op is not a valid monoid binary op or semiring."))
    end
    return C
end

"""
    eadd(A::GBArray, B::GBArray, op = +; kwargs...)::GBVecOrMat

Apply the binary operator `op` elementwise on the set union of `A` and `B`.
When `op = +` this is equivalent to `A .+ B`, however any binary operation may be substituted.

Note that the behavior of `A[i,j] op B[i,j]` may be unintuitive when one operand is an implicit
zero. The explicit operand *passes through* the function. So `A[i,j] op B[i,j]` where `B[i,j]`
is an implicit zero returns `A[i,j]` **not** `A[i,j] op zero(T)`.

For a set intersection equivalent see [`emul`](@ref).

# Arguments
- `A, B::GBArray`: A GBVector or GBMatrix, possibly transposed.
- `op::Union{Function, AbstractBinaryOp, Monoid} = +`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, Function, AbstractBinaryOp} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eadd(
    A::GBArray,
    B::GBArray,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    t = inferoutputtype(A, B, op)
    if A isa GBVector && B isa GBVector
        C = GBVector{t}(size(A))
    else
        C = GBMatrix{t}(size(A))
    end
    return eadd!(C, A, B, op; mask, accum, desc)
end


"""
    eunion!(C::GBVecOrMat, A::GBArray{T}, α::T B::GBArray, β::T, op = +; kwargs...)::GBVecOrMat

Apply the binary operator `op` elementwise on the set union of `A` and `B`. Store or
accumulate the result into C. When `op = +` this is equivalent to `A .+ B`,
however any binary operation may be substituted.

Unlike `eadd!` where an argument missing in `A` causes the `B` element to "pass-through",
`eunion!` utilizes the `α` and `β` arguments for the missing operand elements.

# Arguments
- `C::GBArray`: the output vector or matrix.
- `A, B::GBArray`: A GBVector or GBMatrix, possibly transposed.
- `α, β`: The fill-in value for `A` and `B` respectively.
- `op::Union{Function, AbstractBinaryOp, Monoid} = +`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, Function, AbstractBinaryOp} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eunion!(
    C::GBVecOrMat,
    A::GBArray{T},
    α::T,
    B::GBArray{U},
    β::U,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = nothing,
    accum = nothing,
    desc = nothing
) where {T, U}
    mask, accum = _handlenothings(mask, accum)
    desc = _handledescriptor(desc; in1=A, in2 = B)
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    op = getoperator(op, optype(A, B))
    accum = getaccum(accum, eltype(C))
    if op isa TypedBinaryOperator
        libgb.GxB_Matrix_eWiseUnion(C, mask, accum, op, parent(A), GBScalar(α), parent(B), GBScalar(β), desc)
        return C
    else
        throw(ArgumentError("$op is not a valid monoid binary op or semiring."))
    end
    return C
end

"""
    eunion(C::GBVecOrMat, A::GBArray{T}, α::T B::GBArray, β::T, op = +; kwargs...)::GBVecOrMat

Apply the binary operator `op` elementwise on the set union of `A` and `B`.
When `op = +` this is equivalent to `A .+ B`, however any binary operation may be substituted.

Unlike `eadd!` where an argument missing in `A` causes the `B` element to "pass-through",
`eunion!` utilizes the `α` and `β` arguments for the missing operand elements.

# Arguments
- `A, B::GBArray`: A GBVector or GBMatrix, possibly transposed.
- `α, β`: The fill-in value for `A` and `B` respectively.
- `op::Union{Function, AbstractBinaryOp, Monoid} = +`: the binary operation which is
    applied such that `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBVecOrMat} = nothing`: optional mask.
- `accum::Union{Nothing, Function, AbstractBinaryOp} = nothing`: binary accumulator operation
    such that `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Union{Nothing, Descriptor} = nothing`
"""
function eunion(
    A::GBArray{T},
    α::T,
    B::GBArray{U},
    β::U,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = nothing,
    accum = nothing,
    desc = nothing
) where {T, U}
    t = inferoutputtype(A, B, op)
    if A isa GBVector && B isa GBVector
        C = GBVector{t}(size(A))
    else
        C = GBMatrix{t}(size(A))
    end
    return eunion!(C, A, α, B, β, op; mask, accum, desc)
end


function emul!(C, A, B, op::Function; mask = nothing, accum = nothing, desc = nothing)
    emul!(C, A, B, BinaryOp(op); mask, accum, desc)
end

function emul(A, B, op::Function; mask = nothing, accum = nothing, desc = nothing)
    emul(A, B, BinaryOp(op); mask, accum, desc)
end

function eadd!(C, A, B, op::Function; mask = nothing, accum = nothing, desc = nothing)
    eadd!(C, A, B, BinaryOp(op); mask, accum, desc)
end

function eadd(A, B, op::Function; mask = nothing, accum = nothing, desc = nothing)
    eadd(A, B, BinaryOp(op); mask, accum, desc)
end

function eunion!(C, A, α, B, β, op::Function; mask = nothing, accum = nothing, desc = nothing)
    eunion!(C, A, α, B, β, BinaryOp(op); mask, accum, desc)
end

function eunion(A, α, B, β, op::Function; mask = nothing, accum = nothing, desc = nothing)
    eunion(A, α, B, β, BinaryOp(op); mask, accum, desc)
end

function Base.:+(A::GBArray, B::GBArray)
    eadd(A, B, +)
end

function Base.:-(A::GBArray, B::GBArray)
    eadd(A, B, -)
end

⊕(A, B, op; mask = nothing, accum = nothing, desc = nothing) =
    eadd(A, B, op; mask, accum, desc)
⊗(A, B, op; mask = nothing, accum = nothing, desc = nothing) =
    emul(A, B, op; mask, accum, desc)

⊕(f::Union{Function, BinaryUnion}) = (A, B; mask = nothing, accum = nothing, desc = nothing) ->
    eadd(A, B, f; mask, accum, desc)

⊗(f::Union{Function, BinaryUnion}) = (A, B; mask = nothing, accum = nothing, desc = nothing) ->
    emul(A, B, f; mask, accum, desc)
