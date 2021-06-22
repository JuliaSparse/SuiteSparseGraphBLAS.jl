"""
    emul!(C::GBArray, A::GBArray, B::GBArray; kwargs...)::Nothing

Apply the binary operator `op` elementwise on the set intersection of `A` and `B`. Store or
accumulate the result into C. When `op = BinaryOps.TIMES` this is equivalent to `A .* B`,
however any binary operation may be substituted.

As mentioned the pattern of the result is the set intersection of `A` and `B`. For a set
union equivalent see [`eadd!`](@ref).

# Arguments
- `C::GBArray`: the output vector or matrix.
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `B::GBArray`: `GBVector` or optionally transposed `GBMatrix`.

# Keywords
- `op::MonoidBinaryOrRig = BinaryOps.TIMES`: the binary operation which is applied such that
    `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in both `A` and `B`.
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: optional mask.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = Descriptors.NULL`
"""
function emul! end

"""
    emul(A::GBArray, B::GBArray; kwargs...)::GBMatrix

Apply the binary operator `op` elementwise on the set intersection of `A` and `B`. Store or
accumulate the result into C. When `op = BinaryOps.TIMES` this is equivalent to `A .* B`,
however any binary operation may be substituted.

As mentioned the pattern of the result is the set intersection of `A` and `B`. For a set
union equivalent see [`eadd`](@ref).

# Arguments
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `B::GBArray`: `GBVector` or optionally transposed `GBMatrix`.

# Keywords
- `op::MonoidBinaryOrRig = BinaryOps.TIMES`: the binary operation which is applied such that
    `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in both `A` and `B`.
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: optional mask.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = Descriptors.NULL`

# Returns
- `GBArray`: Output `GBVector` or `GBMatrix` whose eltype is determined by the `eltype` of
    `A` and `B` or the binary operation if a type specific operation is provided.
"""
function emul end

function emul!(
    w::GBVector,
    u::GBVector,
    v::GBVector,
    op::MonoidBinaryOrRig = BinaryOps.TIMES;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(w) == size(u) == size(v) || throw(DimensionMismatch())
    op = getoperator(op, optype(u, v))
    accum = getoperator(accum, eltype(w))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseMult_Semiring(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseMult_Monoid(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseMult_BinaryOp(w, mask, accum, op, u, v, desc)
        return w
    end
end

function emul(
    u::GBVector,
    v::GBVector,
    op::MonoidBinaryOrRig = BinaryOps.TIMES;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(u, v)
    end
    w = GBVector{t}(size(u))
    return emul!(w, u, v, op; mask , accum, desc)
end

function emul!(
    C::GBMatrix,
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op::MonoidBinaryOrRig = BinaryOps.TIMES;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    A, desc, B = _handletranspose(A, desc, B)
    op = getoperator(op, optype(A, B))
    accum = getoperator(accum, eltype(C))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Matrix_eWiseMult_Semiring(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Matrix_eWiseMult_Monoid(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Matrix_eWiseMult_BinaryOp(C, mask, accum, op, A, B, desc)
        return C
    end
end

function emul(
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op::MonoidBinaryOrRig = BinaryOps.TIMES;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(A, B)
    end
    C = GBMatrix{t}(size(A))
    return emul!(C, A, B, op; mask, accum, desc)
end

"""
    emul!(C::GBArray, A::GBArray, B::GBArray; kwargs...)::Nothing

Apply the binary operator `op` elementwise on the set union of `A` and `B`. Store or
accumulate the result into C. When `op = BinaryOps.PLUS` this is equivalent to `A .+ B`,
however any binary operation may be substituted.

As mentioned the pattern of the result is the set union of `A` and `B`. For a set
intersection equivalent see [`eadd!`](@ref).

# Arguments
- `C::GBArray`: the output vector or matrix.
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `B::GBArray`: `GBVector` or optionally transposed `GBMatrix`.

# Keywords
- `op::MonoidBinaryOrRig = BinaryOps.TIMES`: the binary operation which is applied such that
    `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` or `B`.
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: optional mask.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = Descriptors.NULL`
"""
function eadd! end

"""
    eadd(A::GBArray, B::GBArray; kwargs...)::GBMatrix

Apply the binary operator `op` elementwise on the set union of `A` and `B`. Store or
accumulate the result into C. When `op = BinaryOps.TIMES` this is equivalent to `A .* B`,
however any binary operation may be substituted.

As mentioned the pattern of the result is the set union of `A` and `B`. For a set
intersection equivalent see [`emul`](@ref).

# Arguments
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `B::GBArray`: `GBVector` or optionally transposed `GBMatrix`.

# Keywords
- `op::MonoidBinaryOrRig = BinaryOps.TIMES`: the binary operation which is applied such that
    `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` or `B`.
- `mask::Union{Ptr{Nothing}, GBMatrix} = C_NULL`: optional mask.
- `accum::Union{Ptr{Nothing}, AbstractBinaryOp} = C_NULL`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc::Descriptor = Descriptors.NULL`

# Returns
- `GBArray`: Output `GBVector` or `GBMatrix` whose eltype is determined by the `eltype` of
    `A` and `B` or the binary operation if a type specific operation is provided.
"""
function eadd end

function eadd!(
    w::GBVector,
    u::GBVector,
    v::GBVector,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(w) == size(u) == size(v) || throw(DimensionMismatch())
    op = getoperator(op, optype(u, v))
    accum = getoperator(accum, eltype(w))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Vector_eWiseAdd_Semiring(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Vector_eWiseAdd_Monoid(w, mask, accum, op, u, v, desc)
        return w
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Vector_eWiseAdd_BinaryOp(w, mask, accum, op, u, v, desc)
        return w
    end
end

function eadd(
    u::GBVector,
    v::GBVector,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(eltype(u), eltype(v))
    end
    w = GBVector{t}(size(u))
    return eadd!(w, u, v, op; mask, accum, desc)
end

function eadd!(
    C::GBMatrix,
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    size(C) == size(A) == size(B) || throw(DimensionMismatch())
    A, desc, B = _handletranspose(A, desc, B)
    op = getoperator(op, optype(A, B))
    accum = getoperator(accum, eltype(C))
    if op isa libgb.GrB_Semiring
        libgb.GrB_Matrix_eWiseAdd_Semiring(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_Monoid
        libgb.GrB_Matrix_eWiseAdd_Monoid(C, mask, accum, op, A, B, desc)
        return C
    elseif op isa libgb.GrB_BinaryOp
        libgb.GrB_Matrix_eWiseAdd_BinaryOp(C, mask, accum, op, A, B, desc)
        return C
    else
        error("Unreachable")
    end
end

function eadd(
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(A, B)
    end
    C = GBMatrix{t}(size(A))
    return eadd!(C, A, B, op; mask, accum, desc)
end

# Note well: `.*` and `.+` have clear counterparts in the language of GraphBLAS:
# edgewiseAdd and edgewiseMul. These do not necessarily have the same semantics though.
# edgewiseAdd and edgewiseMul might better be described as edgewiseUnion and
# edgewiseIntersection respectively, and then `op` is applied at materialized indices.
#
# So the plan is thus: `.*` and `.+` will have the Union and Intersection semantics *with*
# the default ops of `*` and `+` respectively. *However*, they have `op` kwargs, which
# may be used with a macro later on down the line to override the default ops.
function Base.broadcasted(
    ::typeof(+),
    u::GBVector,
    v::GBVector,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    return eadd(u, v, op; mask, accum, desc)
end
function Base.broadcasted(
    ::typeof(*),
    u::GBVector,
    v::GBVector,
    op::MonoidBinaryOrRig = BinaryOps.TIMES;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    return emul(u, v, op; mask, accum, desc)
end

function Base.broadcasted(
    ::typeof(+),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    return eadd(A, B, op; mask, accum, desc)
end
function Base.broadcasted(
    ::typeof(*),
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op::MonoidBinaryOrRig = BinaryOps.PLUS;
    mask = C_NULL,
    accum = C_NULL,
    desc::Descriptor = Descriptors.NULL
)
    return emul(A, B, op; mask, accum, desc)
end
