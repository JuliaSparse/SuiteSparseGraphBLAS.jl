"""
    emul!(C::GBArray, A::GBArray, B::GBArray, op = BinaryOps.TIMES; kwargs...)::GBArray

Apply the binary operator `op` elementwise on the set intersection of `A` and `B`. Store or
accumulate the result into C. When `op = BinaryOps.TIMES` this is equivalent to `A .* B`,
however any binary operation may be substituted.

As mentioned the pattern of the result is the set intersection of `A` and `B`. For a set
union equivalent see [`eadd!`](@ref).

# Arguments
- `C::GBArray`: the output vector or matrix.
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `B::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `op::MonoidBinaryOrRig = BinaryOps.TIMES`: the binary operation which is applied such that
    `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in both `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`
"""
emul!

"""
    emul(A::GBArray, B::GBArray, op = BinaryOps.TIMES; kwargs...)::GBMatrix

Apply the binary operator `op` elementwise on the set intersection of `A` and `B`. Store or
accumulate the result into C. When `op = BinaryOps.TIMES` this is equivalent to `A .* B`,
however any binary operation may be substituted.

As mentioned the pattern of the result is the set intersection of `A` and `B`. For a set
union equivalent see [`eadd`](@ref).

# Arguments
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `B::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `op::MonoidBinaryOrRig = BinaryOps.TIMES`: the binary operation which is applied such that
    `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in both `A` and `B`.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`

# Returns
- `GBArray`: Output `GBVector` or `GBMatrix` whose eltype is determined by the `eltype` of
    `A` and `B` or the binary operation if a type specific operation is provided.
"""
emul

function emul!(
    w::GBVector,
    u::GBVector,
    v::GBVector,
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op, mask, accum, desc = _handlectx(op, mask, accum, desc, BinaryOps.TIMES)

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
    else
        throw(ArgumentError("$op is not a valid monoid binary op or semiring."))
    end
    return w
end

function emul(
    u::GBVector,
    v::GBVector,
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op = _handlectx(op, ctxop, BinaryOps.TIMES)
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
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op, mask, accum, desc = _handlectx(op, mask, accum, desc, BinaryOps.TIMES)
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
    else
        throw(ArgumentError("$op is not a valid monoid binary op or semiring."))
    end
    return C
end

function emul(
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op = _handlectx(op, ctxop, BinaryOps.TIMES)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(A, B)
    end
    C = GBMatrix{t}(size(A))
    return emul!(C, A, B, op; mask, accum, desc)
end

"""
    eadd!(C::GBArray, A::GBArray, B::GBArray, op = BinaryOps.PLUS; kwargs...)::GBArray

Apply the binary operator `op` elementwise on the set union of `A` and `B`. Store or
accumulate the result into C. When `op = BinaryOps.PLUS` this is equivalent to `A .+ B`,
however any binary operation may be substituted.

As mentioned the pattern of the result is the set union of `A` and `B`. For a set
intersection equivalent see [`emul!`](@ref).

# Arguments
- `C::GBArray`: the output vector or matrix.
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `B::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `op::MonoidBinaryOrRig = BinaryOps.PLUS`: the binary operation which is applied such that
    `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` and/or `B`.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`
"""
eadd!

"""
    eadd(A::GBArray, B::GBArray, op = BinaryOps.PLUS; kwargs...)::GBArray

Apply the binary operator `op` elementwise on the set union of `A` and `B`. Store or
accumulate the result into C. When `op = BinaryOps.TIMES` this is equivalent to `A .* B`,
however any binary operation may be substituted.

As mentioned the pattern of the result is the set union of `A` and `B`. For a set
intersection equivalent see [`emul`](@ref).

# Arguments
- `A::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `B::GBArray`: `GBVector` or optionally transposed `GBMatrix`.
- `op::MonoidBinaryOrRig = BinaryOps.PLUS`: the binary operation which is applied such that
    `C[i,j] = op(A[i,j], B[i,j])` for all `i,j` present in either `A` or `B`.

# Keywords
- `mask::Union{Nothing, GBMatrix} = nothing`: optional mask.
- `accum::Union{Nothing, AbstractBinaryOp} = nothing`: binary accumulator operation
    where `C[i,j] = accum(C[i,j], T[i,j])` where T is the result of this function before accum is applied.
- `desc = nothing`

# Returns
- `GBArray`: Output `GBVector` or `GBMatrix` whose eltype is determined by the `eltype` of
    `A` and `B` or the binary operation if a type specific operation is provided.
"""
eadd

function eadd!(
    w::GBVector,
    u::GBVector,
    v::GBVector,
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op, mask, accum, desc = _handlectx(op, mask, accum, desc, BinaryOps.PLUS)
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
    else
        throw(ArgumentError("$op is not a valid monoid binary op or semiring."))
    end
    return w
end

function eadd(
    u::GBVector,
    v::GBVector,
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op, mask, accum, desc = _handlectx(op, mask, accum, desc, BinaryOps.PLUS)
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
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op, mask, accum, desc = _handlectx(op, mask, accum, desc, BinaryOps.PLUS)
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
        throw(ArgumentError("$op is not a valid monoid binary op or semiring."))
    end
    return C
end

function eadd(
    A::GBMatOrTranspose,
    B::GBMatOrTranspose,
    op = nothing;
    mask = nothing,
    accum = nothing,
    desc = nothing
)
    op, mask, accum, desc = _handlectx(op, mask, accum, desc, BinaryOps.PLUS)
    if op isa GrBOp
        t = ztype(op)
    else
        t = optype(A, B)
    end
    C = GBMatrix{t}(size(A))
    return eadd!(C, A, B, op; mask, accum, desc)
end

#Elementwise Broadcasts
#######################

# default argument is missing to avoid `nothing` picking up the default default :).
function Base.broadcasted(::typeof(∪), A::GBArray, B::GBArray)
    eadd(A, B, missing)
end

# default argument is missing to avoid `nothing` picking up the default default :).
function Base.broadcasted(::typeof(∩), A::GBArray, B::GBArray)
    emul(A, B, missing)
end

function Base.broadcasted(::typeof(*), A::GBArray, B::GBArray)
    emul(A, B, BinaryOps.TIMES)
end

function Base.broadcasted(::typeof(+), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.PLUS)
end

function Base.broadcasted(::typeof(-), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.MINUS)
end

#TODO: fix tricky gotchas, this will do type-specific (ie sometimes integer) division.
function Base.broadcasted(::typeof(/), A::GBArray, B::GBArray)
    emul(A, B, BinaryOps.DIV)
end

#TODO: fix tricky gotchas, this will do type-specific (ie sometimes integer) division.
function Base.broadcasted(::typeof(\), A::GBArray, B::GBArray)
    emul(A, B, BinaryOps.RDIV)
end

function Base.broadcasted(::typeof(==), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.EQ)
end

function Base.broadcasted(::typeof(!=), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.NE)
end

function Base.broadcasted(::typeof(<), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.LT)
end

function Base.broadcasted(::typeof(>), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.GT)
end

function Base.broadcasted(::typeof(<=), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.LE)
end

function Base.broadcasted(::typeof(>=), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.GE)
end

function Base.broadcasted(::typeof(^), A::GBArray, B::GBArray)
    emul(A, B, BinaryOps.POW)
end
