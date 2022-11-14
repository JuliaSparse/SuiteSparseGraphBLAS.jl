module IndexUnaryOps

import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedIndexUnaryOperator, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, optype,
    Ntypes, Ttypes, suffix, valid_union, GBArrayOrTranspose, GBScalar, inferbinarytype
using ..UnaryOps: colindex, rowindex
using ..LibGraphBLAS
export indexunaryop, diagindex, offdiag, colleq, colgt, rowleq, rowgt,
IndexOp, isindexop, defaultthunk
import LinearAlgebra

"""
    IndexOp{F}

Wrapper which indicates to [`apply`](@ref) that an operator has the signature:
`f(x, i::Int64, j::Int64, y)` where `x` is the value at a particular index, `i` and `j` are the
indices, and `y` is an auxiliary input.

See also: [`isindexop`](@ref)
"""
struct IndexOp{F}
    op::F
end
Base.parent(I::IndexOp) = I.op

"""
    isindexop(op)::Bool

If `isindexop(op)` is true then [`apply`](@ref) will wrap `op` in `IndexOp`.
`op` must have the signature `f(x, i::Int64, j::Int64, y)`. 
This function is only called from [`apply`](@ref).
"""
isindexop(op::F) where {F} = false
isindexop(::IndexOp) = true
function defaultthunk(op, T)
    if op ∈ (rowindex, colindex, diagindex)
        return one(Int64)
    elseif op ∈ (LinearAlgebra.tril, LinearAlgebra.triu, LinearAlgebra.diag, offdiag)
        return zero(Int64)
    elseif op === ==
        return zero(T)
    else
        throw(ArgumentError("You must pass `thunk` to select for this function."))
    end
end
defaultthunk(op::IndexOp, T) = defaultthunk(op.op, T)

const IDXUNARYOPS = IdDict{Tuple{<:Any, DataType, DataType}, TypedIndexUnaryOperator}()

function fallback_idxunaryop(
    f::F, ::Type{X}, ::Type{Y}
) where {F, X, Y}
    return get!(IDXUNARYOPS, (f, X, Y)) do
        TypedIndexUnaryOperator(f, X, Y)
    end
end

indexunaryop(f, ::Type{X}, ::Type{X}) where X = fallback_idxunaryop(f, X, X)

function indexunaryop(
    f, ::Type{X}, ::Type{Y}
) where {X, Y}
    P = promote_type(X, Y)
    if isconcretetype(P) && (X <: valid_union && Y <: valid_union)
        return indexunaryop(f, P, P)
    else
        return fallback_idxunaryop(f, X, Y)
    end
end

indexunaryop(f, ::GBArrayOrTranspose{T}, ::GBScalar{U}) where {T, U} = 
    indexunaryop(f, T, U)
indexunaryop(f, ::GBArrayOrTranspose{T}, ::Type{U}) where {T, U} = indexunaryop(f, T, U)
indexunaryop(f, ::Type{T}, ::GBScalar{U}) where {T, U} = indexunaryop(f, T, U)

indexunaryop(f, type) = indexunaryop(f, type, type)
indexunaryop(op::TypedIndexUnaryOperator, ::Type{X}, ::Type{Y}) where {X, Y} = op

const ROWINDEX = TypedIndexUnaryOperator{typeof(rowindex), Any, Any, Int64}(
    true, false, "GrB_ROWINDEX_INT64", LibGraphBLAS.GrB_IndexUnaryOp(),rowindex)
indexunaryop(::typeof(rowindex), ::Type{X}, ::Type{Y}) where {X, Y} = ROWINDEX
const COLINDEX = TypedIndexUnaryOperator{typeof(colindex), Any, Any, Int64}(
    true, false, "GrB_COLINDEX_INT64", LibGraphBLAS.GrB_IndexUnaryOp(),colindex)
indexunaryop(::typeof(colindex), ::Type{X}, ::Type{Y}) where {X, Y} = COLINDEX

"""
    diagindex(xᵢⱼ) -> (j - (i + y))

Dummy function for use in [`apply`](@ref). 
Returns the column diagonal index of each element.
"""
diagindex(x...) = 1::Int64
const DIAGINDEX = TypedIndexUnaryOperator{typeof(diagindex), Any, Any, Int64}(
    true, false, "GrB_DIAGINDEX_INT64", LibGraphBLAS.GrB_IndexUnaryOp(),diagindex)
indexunaryop(::typeof(diagindex), ::Type{X}, ::Type{Y}) where {X, Y} = DIAGINDEX


const TRIL = TypedIndexUnaryOperator{typeof(LinearAlgebra.tril), Any, Any, Bool}(
    true, false, "GrB_TRIL", LibGraphBLAS.GrB_IndexUnaryOp(),LinearAlgebra.tril)
indexunaryop(::typeof(LinearAlgebra.tril), ::Type{X}, ::Type{Y}) where {X, Y} = TRIL

const TRIU = TypedIndexUnaryOperator{typeof(LinearAlgebra.triu), Any, Any, Bool}(
    true, false, "GrB_TRIU", LibGraphBLAS.GrB_IndexUnaryOp(),LinearAlgebra.triu)
indexunaryop(::typeof(LinearAlgebra.triu), ::Type{X}, ::Type{Y}) where {X, Y} = TRIU
const DIAG = TypedIndexUnaryOperator{typeof(LinearAlgebra.diag), Any, Any, Bool}(
    true, false, "GrB_DIAG", LibGraphBLAS.GrB_IndexUnaryOp(),LinearAlgebra.diag)
indexunaryop(::typeof(LinearAlgebra.diag), ::Type{X}, ::Type{Y}) where {X, Y} = DIAG


function offdiag end
const OFFDIAG = TypedIndexUnaryOperator{typeof(offdiag), Any, Any, Bool}(
    true, false, "GrB_OFFDIAG", LibGraphBLAS.GrB_IndexUnaryOp(),offdiag)
indexunaryop(::typeof(offdiag), ::Type{X}, ::Type{Y}) where {X, Y} = OFFDIAG

function colleq end
function colgt end
function rowleq end
function rowgt end
const COLLEQ = TypedIndexUnaryOperator{typeof(colleq), Any, Any, Bool}(
    true, false, "GrB_COLLEQ", LibGraphBLAS.GrB_IndexUnaryOp(),colleq)
indexunaryop(::typeof(colleq), ::Any, ::Any) = COLLEQ
const COLGT = TypedIndexUnaryOperator{typeof(colgt), Any, Any, Bool}(
    true, false, "GrB_OFFDIAG", LibGraphBLAS.GrB_IndexUnaryOp(),colgt)
indexunaryop(::typeof(colgt), ::Any, ::Any) = COLGT
const ROWLEQ = TypedIndexUnaryOperator{typeof(rowleq), Any, Any, Bool}(
    true, false, "GrB_OFFDIAG", LibGraphBLAS.GrB_IndexUnaryOp(),rowleq)
indexunaryop(::typeof(rowleq), ::Any, ::Any) = ROWLEQ
const ROWGT = TypedIndexUnaryOperator{typeof(rowgt), Any, Any, Bool}(
    true, false, "GrB_OFFDIAG", LibGraphBLAS.GrB_IndexUnaryOp(),rowgt)
indexunaryop(::typeof(rowgt), ::Any, ::Any) = ROWGT

cardinal_vec = filter(x-> x ∉ [ComplexF64, ComplexF32], valid_vec)

for T ∈ cardinal_vec
    namestr = "GrB_VALUEEQ_$(suffix(T))"
    constname = Symbol(namestr)
    @eval begin
        const $constname = TypedIndexUnaryOperator{typeof(==), $T, $T, Bool}(
            true, false, $namestr, LibGraphBLAS.GrB_IndexUnaryOp(), ==)
        indexunaryop(::typeof(==), ::Type{$T}, ::Type{$T}) = $constname
    end
end
for T ∈ cardinal_vec
    namestr = "GrB_VALUENE_$(suffix(T))"
    constname = Symbol(namestr)
    @eval begin
        const $constname = TypedIndexUnaryOperator{typeof(!=), $T, $T, Bool}(
            true, false, $namestr, LibGraphBLAS.GrB_IndexUnaryOp(), !=)
        indexunaryop(::typeof(!=), ::Type{$T}, ::Type{$T}) = $constname
    end
end

const GxB_VALUEEQ_FC64 = TypedIndexUnaryOperator{typeof(==), ComplexF64, ComplexF64, Bool}(
    true, false, "GxB_VALUEEQ_FC64", LibGraphBLAS.GrB_IndexUnaryOp(), ==)
indexunaryop(::typeof(==), ::Type{ComplexF64}, ::Type{ComplexF64}) = GxB_VALUEEQ_FC64
const GxB_VALUEEQ_FC32 = TypedIndexUnaryOperator{typeof(==), ComplexF32, ComplexF32, Bool}(
    true, false, "GxB_VALUEEQ_FC64", LibGraphBLAS.GrB_IndexUnaryOp(), ==)
indexunaryop(::typeof(==), ::Type{ComplexF32}, ::Type{ComplexF32}) = GxB_VALUEEQ_FC32

const GxB_VALUENE_FC64 = TypedIndexUnaryOperator{typeof(!=), ComplexF64, ComplexF64, Bool}(
    true, false, "GxB_VALUENE_FC64", LibGraphBLAS.GrB_IndexUnaryOp(), !=)
indexunaryop(::typeof(!=), ::Type{ComplexF64}, ::Type{ComplexF64}) = GxB_VALUENE_FC64
const GxB_VALUENE_FC32 = TypedIndexUnaryOperator{typeof(!=), ComplexF32, ComplexF32, Bool}(
    true, false, "GxB_VALUENE_FC64", LibGraphBLAS.GrB_IndexUnaryOp(), !=)
indexunaryop(::typeof(!=), ::Type{ComplexF32}, ::Type{ComplexF32}) = GxB_VALUENE_FC32

for T ∈ cardinal_vec
    namestr = "GrB_VALUELT_$(suffix(T))"
    constname = Symbol(namestr)
    @eval begin
        const $constname = TypedIndexUnaryOperator{typeof(<), $T, $T, Bool}(
            true, false, $namestr, LibGraphBLAS.GrB_IndexUnaryOp(), <)
        indexunaryop(::typeof(<), ::Type{$T}, ::Type{$T}) = $constname
    end
end
for T ∈ cardinal_vec
    namestr = "GrB_VALUELE_$(suffix(T))"
    constname = Symbol(namestr)
    @eval begin
        const $constname = TypedIndexUnaryOperator{typeof(<=), $T, $T, Bool}(
            true, false, $namestr, LibGraphBLAS.GrB_IndexUnaryOp(), <=)
        indexunaryop(::typeof(<=), ::Type{$T}, ::Type{$T}) = $constname
    end
end

for T ∈ cardinal_vec
    namestr = "GrB_VALUEGT_$(suffix(T))"
    constname = Symbol(namestr)
    @eval begin
        const $constname = TypedIndexUnaryOperator{typeof(>), $T, $T, Bool}(
            true, false, $namestr, LibGraphBLAS.GrB_IndexUnaryOp(), >)
        indexunaryop(::typeof(>), ::Type{$T}, ::Type{$T}) = $constname
    end
end
for T ∈ cardinal_vec
    namestr = "GrB_VALUEGE_$(suffix(T))"
    constname = Symbol(namestr)
    @eval begin
        const $constname = TypedIndexUnaryOperator{typeof(>=), $T, $T, Bool}(
            true, false, $namestr, LibGraphBLAS.GrB_IndexUnaryOp(), >=)
        indexunaryop(::typeof(>=), ::Type{$T}, ::Type{$T}) = $constname
    end
end


for F ∈ [rowindex, colindex, diagindex]
    @eval isindexop(::typeof($F)) = true
end

for F ∈ [
    LinearAlgebra.tril, 
    LinearAlgebra.triu, 
    LinearAlgebra.diag, 
    offdiag, 
    colleq, 
    colgt, 
    rowleq, 
    rowgt
]
    @eval isindexop(::typeof($F)) = true
    @eval SuiteSparseGraphBLAS.inferbinarytype(::Any, ::Any, ::typeof($F)) = Bool
end

end
ztype(::TypedIndexUnaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Z
xtype(::TypedIndexUnaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = X
ytype(::TypedIndexUnaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Y