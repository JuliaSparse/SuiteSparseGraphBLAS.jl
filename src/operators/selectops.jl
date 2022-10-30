module IndexUnaryOps

import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedIndexUnaryOperator, GBType,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, optype,
    Ntypes, Ttypes, suffix, valid_union, GBArrayOrTranspose, GBScalar
using ..LibGraphBLAS
export indexunaryop, rowindex, colindex, diagindex, offdiag, colleq, colgt, rowleq, rowgt
import LinearAlgebra

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

function rowindex end
function colindex end
function diagindex end
const ROWINDEX = TypedIndexUnaryOperator{typeof(rowindex), Any, Any, Int64}(
    true, false, "GrB_ROWINDEX_INT64", LibGraphBLAS.GrB_IndexUnaryOp(),rowindex)
indexunaryop(::typeof(rowindex), ::Type{X}, ::Type{Y}) where {X, Y} = ROWINDEX
const COLINDEX = TypedIndexUnaryOperator{typeof(colindex), Any, Any, Int64}(
    true, false, "GrB_COLINDEX_INT64", LibGraphBLAS.GrB_IndexUnaryOp(),colindex)
indexunaryop(::typeof(colindex), ::Type{X}, ::Type{Y}) where {X, Y} = COLINDEX
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
end
ztype(::TypedIndexUnaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Z
xtype(::TypedIndexUnaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = X
ytype(::TypedIndexUnaryOperator{F, X, Y, Z}) where {F, X, Y, Z} = Y
# mutable struct SelectOp <: AbstractSelectOp
#     name::String
#     p::LibGraphBLAS.GxB_SelectOp
#     juliaop::Union{Function, Nothing}
#     function SelectOp(name, p::LibGraphBLAS.GxB_SelectOp, juliaop)
#         d = new(name, p, juliaop)
#         function f(selectop)
#             @wraperror LibGraphBLAS.GxB_SelectOp_free(Ref(selectop.p))
#         end
#         return finalizer(f, d)
#     end
# end
# 
# SelectOp(op::SelectOp) = op
# 
# const SelectUnion = Union{AbstractSelectOp, LibGraphBLAS.GxB_SelectOp}
# 
# Base.unsafe_convert(::Type{LibGraphBLAS.GxB_SelectOp}, selectop::SelectOp) = selectop.p
# 
# const TRIL = SelectOp("GxB_TRIL", LibGraphBLAS.GxB_SelectOp(), LinearAlgebra.tril)
# const TRIU = SelectOp("GxB_TRIU", LibGraphBLAS.GxB_SelectOp(), LinearAlgebra.triu)
# const DIAG = SelectOp("GxB_DIAG", LibGraphBLAS.GxB_SelectOp(), LinearAlgebra.diag)
# 
# """
#     offdiag(A::GBArray, k=0)
# 
# Select the entries **not** on the `k`th diagonal of A.
# """
# function offdiag end #I don't know of a function which does this already.
# const OFFDIAG = SelectOp("GxB_OFFDIAG", LibGraphBLAS.GxB_SelectOp(), offdiag)
# offdiag(A::GBArrayOrTranspose, k=0) = select(offdiag, A, k)
# 
# const NONZERO = SelectOp("GxB_NONZERO", LibGraphBLAS.GxB_SelectOp(), nonzeros)
# const EQ_ZERO = SelectOp("GxB_EQ_ZERO", LibGraphBLAS.GxB_SelectOp(), nothing)
# const GT_ZERO = SelectOp("GxB_GT_ZERO", LibGraphBLAS.GxB_SelectOp(), nothing)
# const GE_ZERO = SelectOp("GxB_GE_ZERO", LibGraphBLAS.GxB_SelectOp(), nothing)
# const LT_ZERO = SelectOp("GxB_LT_ZERO", LibGraphBLAS.GxB_SelectOp(), nothing)
# const LE_ZERO = SelectOp("GxB_LE_ZERO", LibGraphBLAS.GxB_SelectOp(), nothing)
# const NE = SelectOp("GxB_NE_THUNK", LibGraphBLAS.GxB_SelectOp(), !=)
# const EQ = SelectOp("GxB_EQ_THUNK", LibGraphBLAS.GxB_SelectOp(), ==)
# const GT = SelectOp("GxB_GT_THUNK", LibGraphBLAS.GxB_SelectOp(), >)
# const GE = SelectOp("GxB_GE_THUNK", LibGraphBLAS.GxB_SelectOp(), >=)
# const LT = SelectOp("GxB_LT_THUNK", LibGraphBLAS.GxB_SelectOp(), <)
# const LE = SelectOp("GxB_LE_THUNK", LibGraphBLAS.GxB_SelectOp(), <=)
# 
# function SelectOp(name)
#     simple = Symbol(replace(string(name[5:end]), "_THUNK" => ""))
#     constquote = quote
#         const $simple = SelectOp($name, LibGraphBLAS.GxB_SelectOp())
#     end
#     @eval($constquote)
# end
# 
# function _loadselectops()
#     TRIL.p = load_global("GxB_TRIL", LibGraphBLAS.GxB_SelectOp)
#     TRIU.p = load_global("GxB_TRIU", LibGraphBLAS.GxB_SelectOp)
#     DIAG.p = load_global("GxB_DIAG", LibGraphBLAS.GxB_SelectOp)
#     OFFDIAG.p = load_global("GxB_OFFDIAG", LibGraphBLAS.GxB_SelectOp)
#     NONZERO.p = load_global("GxB_NONZERO", LibGraphBLAS.GxB_SelectOp)
#     EQ_ZERO.p = load_global("GxB_EQ_ZERO", LibGraphBLAS.GxB_SelectOp)
#     GT_ZERO.p = load_global("GxB_GT_ZERO", LibGraphBLAS.GxB_SelectOp)
#     GE_ZERO.p = load_global("GxB_GE_ZERO", LibGraphBLAS.GxB_SelectOp)
#     LT_ZERO.p = load_global("GxB_LT_ZERO", LibGraphBLAS.GxB_SelectOp)
#     LE_ZERO.p = load_global("GxB_LE_ZERO", LibGraphBLAS.GxB_SelectOp)
#     NE.p = load_global("GxB_NE_THUNK", LibGraphBLAS.GxB_SelectOp)
#     EQ.p = load_global("GxB_EQ_THUNK", LibGraphBLAS.GxB_SelectOp)
#     GT.p = load_global("GxB_GT_THUNK", LibGraphBLAS.GxB_SelectOp)
#     GE.p = load_global("GxB_GE_THUNK", LibGraphBLAS.GxB_SelectOp)
#     LT.p = load_global("GxB_LT_THUNK", LibGraphBLAS.GxB_SelectOp)
#     LE.p = load_global("GxB_LE_THUNK", LibGraphBLAS.GxB_SelectOp)
# end
# 
# 
# Base.getindex(::AbstractSelectOp, ::DataType) = nothing

# 
# Base.show(io::IO, ::MIME"text/plain", s::SelectUnion) = gxbprint(io, s)
# juliaop(op::AbstractSelectOp) = op.juliaop
# 
# """
#     select(SuiteSparseGraphBLAS.TRIL, A, k=0)
#     select(tril, A, k=0)
# 
# Select the entries on or below the `k`th diagonal of A.
# 
# See also: `LinearAlgebra.tril`
# """
# TRIL
# SelectOp(::typeof(LinearAlgebra.tril)) = TRIL
# """
#     select(SuiteSparseGraphBLAS.TRIU, A, k=0)
#     select(triu, A, k=0)
# 
# Select the entries on or above the `k`th diagonal of A.
# 
# See also: `LinearAlgebra.triu`
# """
# TRIU
# SelectOp(::typeof(LinearAlgebra.triu)) = TRIU
# """
#     select(DIAG, A, k=0)
# 
# Select the entries on the `k`th diagonal of A.
# 
# See also: `LinearAlgebra.diag`
# """
# DIAG
# SelectOp(::typeof(LinearAlgebra.diag)) = DIAG
# """
#     select(OFFDIAG, A, k=0)
# 
# Select the entries **not** on the `k`th diagonal of A.
# """
# OFFDIAG
# SelectOp(::typeof(offdiag)) = OFFDIAG
# """
#     select(NONZERO, A)
#     select(nonzeros, A)
# Select all entries in A with nonzero value.
# """
# NONZERO
# SelectOp(::typeof(nonzeros)) = NONZERO
# 
# # I don't believe these should have Julia equivalents.
# # Instead select(==, A, 0) will find EQ_ZERO internally.
# """
#     select(EQ_ZERO, A)
# 
# Select all entries in A equal to zero.
# """
# EQ_ZERO
# """
#     select(GT_ZERO, A)
# 
# Select all entries in A greater than zero.
# """
# GT_ZERO
# """
#     select(GE_ZERO, A)
# 
# Select all entries in A greater than or equal to zero.
# """
# GE_ZERO
# """
#     select(LT_ZERO, A)
# 
# Select all entries in A less than zero.
# """
# LT_ZERO
# """
#     select(LE_ZERO, A)
# 
# Select all entries in A less than or equal to zero.
# """
# LE_ZERO
# """
#     select(NE, A, k)
#     select(!=, A, k)
# Select all entries not equal to `k`.
# """
# NE
# SelectOp(::typeof(!=)) = NE
# """
#     select(EQ, A, k)
#     select(==, A, k)
# Select all entries equal to `k`.
# """
# EQ
# SelectOp(::typeof(==)) = EQ
# """
#     select(GT, A, k)
#     select(>, A, k)
# Select all entries greater than `k`.
# """
# GT
# SelectOp(::typeof(>)) = GT
# """
#     select(GE, A, k)
#     select(>=, A, k)
# Select all entries greater than or equal to `k`.
# """
# GE
# SelectOp(::typeof(>=)) = GE
# """
#     select(LT, A, k)
#     select(<, A, k)
# Select all entries less than `k`.
# """
# LT
# SelectOp(::typeof(<)) = LT
# """
#     select(LE, A, k)
#     select(<=, A, k)
# Select all entries less than or equal to `k`.
# """
# LE
# SelectOp(::typeof(<=)) = LE