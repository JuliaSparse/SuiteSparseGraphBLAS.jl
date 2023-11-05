module Semirings
import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedSemiring, GBType, Utypes,
    valid_vec, juliaop, gbtype, symtotype, Itypes, Ftypes, Ztypes, FZtypes, IFtypes,
    Rtypes, Ntypes, Ttypes, nBtypes, suffix, BinaryOps.binaryop, Monoids.Monoid, BinaryOps.second, BinaryOps.rminus, BinaryOps.pair,
    BinaryOps.iseq, BinaryOps.isne, BinaryOps.isgt, BinaryOps.islt, BinaryOps.isge, BinaryOps.isle, BinaryOps.∨,
    BinaryOps.∧, BinaryOps.lxor, BinaryOps.xnor, mod, BinaryOps.bxnor, BinaryOps.bget, BinaryOps.bset,
    BinaryOps.bclr, BinaryOps.firsti0, BinaryOps.firsti, BinaryOps.firstj0, BinaryOps.firstj, BinaryOps.secondi0, 
    BinaryOps.secondi, BinaryOps.secondj0, BinaryOps.secondj, xtype, ytype, ztype,
    Monoids.typedmonoid, Monoids.defaultmonoid, valid_union, BinaryOps.inputisany, isGrB, isGxB, inferbinarytype,
    Uunion, Iunion, Funion, IFunion, Zunion, FZunion, Runion, nBunion, Nunion, Tunion, optype
using ..LibGraphBLAS
export semiring

const SEMIRINGS = IdDict{Tuple{<:Monoid, <:Any, DataType, DataType}, TypedSemiring}()
const BUILTINSEMIRINGS = IdDict{Any, Any}() # semiring tuple -> name, datatype

semiring(ops::Tuple, ::Type{T}, ::Type{U}) where {T, U} = semiring(ops..., T, U)
semiring(ops::Tuple, ::Type{T}) where {T} = semiring(ops..., T, T)
semiring(addop, mulop ::Type{T}) where {T} = semiring(addop, mulop, T, T)

semiring(s::TypedSemiring, ::Type{T}) where T = s
semiring(s::TypedSemiring, ::Type{T}, ::Type{U}) where {T, U} = s

function semiring(addop, mulop, ::Type{T}, ::Type{U}) where {T, U}
    V = inferbinarytype(T, U, mulop)
    monoid = defaultmonoid(addop, V)
    return get!(SEMIRINGS, (monoid, mulop, T, U)) do
        t, u = inputisany(mulop) ? (Any, Any) : (T, U)
        if t == u && t <: valid_union
            builtin = isbuiltinsemiring(addop, mulop, t)
            name = "GxB_$(gbname(addop))_$(gbname(mulop))_$(suffix(t))"
        else
            builtin = false
        end
        if !builtin
            name = string(addop, mulop, "_$(T)_$(U)_SEMIRING")
        end
        return TypedSemiring(
            builtin, false, name, LibGraphBLAS.GrB_Semiring(),
            typedmonoid(monoid, V), binaryop(mulop, t, u)
        )
    end
end

function isbuiltinsemiring(addop, mulop, ::Type{T}) where {T <: valid_union}
    if addop ∈ (min, max, +, *, any)
        if mulop ∈  (firsti, firsti0, secondi, secondi0, firstj, firstj0, secondj, secondj0) ||
            (mulop ∈ (
                first, second, pair, min, max, +, -, rminus, *, /, \, 
                iseq, isne, isgt, islt, isge, isle, ∨, ∧, lxor
            ) && T <: IFunion)
                return true
        end
    end
    if addop ∈ (∧, ∨, lxor, ==, any) && mulop ∈ (==, !=, >, <, >=, <=) && T <: IFunion
        return true
    elseif addop ∈ (∧, ∨, lxor, ==, any) &&
        mulop ∈ (first, second, pair, ∨, ∧, lxor, >, <, >=, <=) && t === Bool
        return true
    elseif T <: Complex && addop ∈ (+, *, any) && mulop ∈ (first, second, pair, +, -, *, /, \, rminus)
        return true
    elseif T <: Uunion && addop ∈ (|, &, ⊻, bxnor) && mulop ∈ (|, &, ⊻, bxnor)
        return true
    end
    return false
end

gbname(f) = uppercase(string(f))
gbname(::typeof(+)) = "PLUS"
gbname(::typeof(-)) = "MINUS"
gbname(::typeof(*)) = "TIMES"
gbname(::typeof(/)) = "DIV"
gbname(::typeof(\)) = "RDIV"
gbname(::typeof(∨)) = "LOR"
gbname(::typeof(∧)) = "LAND"
gbname(::typeof(==)) = "EQ"
gbname(::typeof(!=)) = "NE"
gbname(::typeof(>)) = "GT"
gbname(::typeof(<)) = "LT"
gbname(::typeof(>=)) = "GE"
gbname(::typeof(<=)) = "LE"
gbname(::typeof(⊻)) = "BXOR"
gbname(::typeof(|)) = "BOR"
gbname(::typeof(&)) = "BAND"

# for loops or a function or two might be more maintainable.
# but this was just text edited from the official list.
# Functional form would be more difficult to add to later,
# for instance by precompiling more semirings.

# (PLUS, TIMES, ANY) × (FIRST, SECOND, PAIR(ONEB), PLUS, MINUS, RMINUS, TIMES, DIV, RDIV) × nB
# BUILTINSEMIRINGS[(+, first)] = :GxB_PLUS_FIRST, nBtypes
# BUILTINSEMIRINGS[(+, second)] = :GxB_PLUS_SECOND, nBtypes
# BUILTINSEMIRINGS[(+, pair)] = :GxB_PLUS_PAIR, nBtypes
# BUILTINSEMIRINGS[(+, +)] = :GxB_PLUS_PLUS, nBtypes
# BUILTINSEMIRINGS[(+, -)] = :GxB_PLUS_MINUS, nBtypes
# BUILTINSEMIRINGS[(+, rminus)] = :GxB_PLUS_RMINUS, nBtypes
# BUILTINSEMIRINGS[(+, *)] = :GxB_PLUS_TIMES, nBtypes
# BUILTINSEMIRINGS[(+, /)] = :GxB_PLUS_DIV, nBtypes
# BUILTINSEMIRINGS[(+, \)] = :GxB_PLUS_RDIV, nBtypes
# BUILTINSEMIRINGS[(*, first)] = :GxB_TIMES_FIRST, nBtypes
# BUILTINSEMIRINGS[(*, second)] = :GxB_TIMES_SECOND, nBtypes
# BUILTINSEMIRINGS[(*, pair)] = :GxB_TIMES_PAIR, nBtypes
# BUILTINSEMIRINGS[(*, +)] = :GxB_TIMES_PLUS, nBtypes
# BUILTINSEMIRINGS[(*, -)] = :GxB_TIMES_MINUS, nBtypes
# BUILTINSEMIRINGS[(*, rminus)] = :GxB_TIMES_RMINUS, nBtypes
# BUILTINSEMIRINGS[(*, *)] = :GxB_TIMES_TIMES, nBtypes
# BUILTINSEMIRINGS[(*, /)] = :GxB_TIMES_DIV, nBtypes
# BUILTINSEMIRINGS[(*, \)] = :GxB_TIMES_RDIV, nBtypes
# BUILTINSEMIRINGS[(any, first)] = :GxB_ANY_FIRST, Ttypes
# BUILTINSEMIRINGS[(any, second)] = :GxB_ANY_SECOND, Ttypes
# BUILTINSEMIRINGS[(any, pair)] = :GxB_ANY_PAIR, Ttypes
# BUILTINSEMIRINGS[(any, +)] = :GxB_ANY_PLUS, nBtypes
# BUILTINSEMIRINGS[(any, -)] = :GxB_ANY_MINUS, nBtypes
# BUILTINSEMIRINGS[(any, rminus)] = :GxB_ANY_RMINUS, nBtypes
# BUILTINSEMIRINGS[(any, *)] = :GxB_ANY_TIMES, nBtypes
# BUILTINSEMIRINGS[(any, /)] = :GxB_ANY_DIV, nBtypes
# BUILTINSEMIRINGS[(any, \)] = :GxB_ANY_RDIV, nBtypes
# 
# # (MIN, MAX, PLUS, TIMES, ANY) × 
# # (FIRST, SECOND, PAIR(ONEB), MIN, MAX, PLUS, MINUS, RMINUS, TIMES, DIV, RDIV, ISEQ, 
# # ISNE, ISGT, ISLT, ISGE, ISLE, LOR, LAND, LXOR) ×
# # (I..., F...) excluding previously covered.
# BUILTINSEMIRINGS[(min, first)] = :GxB_MIN_FIRST, IFtypes
# BUILTINSEMIRINGS[(min, second)] = :GxB_MIN_SECOND, IFtypes
# BUILTINSEMIRINGS[(min, pair)] = :GxB_MIN_PAIR, IFtypes
# BUILTINSEMIRINGS[(min, min)] = :GxB_MIN_MIN, IFtypes
# BUILTINSEMIRINGS[(min, max)] = :GxB_MIN_MAX, IFtypes
# BUILTINSEMIRINGS[(min, +)] = :GxB_MIN_PLUS, IFtypes
# BUILTINSEMIRINGS[(min, -)] = :GxB_MIN_MINUS, IFtypes
# BUILTINSEMIRINGS[(min, rminus)] = :GxB_MIN_RMINUS, IFtypes
# BUILTINSEMIRINGS[(min, *)] = :GxB_MIN_TIMES, IFtypes
# BUILTINSEMIRINGS[(min, /)] = :GxB_MIN_DIV, IFtypes
# BUILTINSEMIRINGS[(min, \)] = :GxB_MIN_RDIV, IFtypes
# BUILTINSEMIRINGS[(min, iseq)] = :GxB_MIN_ISEQ, IFtypes
# BUILTINSEMIRINGS[(min, isne)] = :GxB_MIN_ISNE, IFtypes
# BUILTINSEMIRINGS[(min, isgt)] = :GxB_MIN_ISGT, IFtypes
# BUILTINSEMIRINGS[(min, islt)] = :GxB_MIN_ISLT, IFtypes
# BUILTINSEMIRINGS[(min, isge)] = :GxB_MIN_ISGE, IFtypes
# BUILTINSEMIRINGS[(min, isle)] = :GxB_MIN_ISLE, IFtypes
# BUILTINSEMIRINGS[(min, ∨)] = :GxB_MIN_LOR, IFtypes
# BUILTINSEMIRINGS[(min, ∧)] = :GxB_MIN_LAND, IFtypes
# BUILTINSEMIRINGS[(min, lxor)] = :GxB_MIN_LXOR, IFtypes
# 
# BUILTINSEMIRINGS[(max, first)] = :GxB_MAX_FIRST, IFtypes
# BUILTINSEMIRINGS[(max, second)] = :GxB_MAX_SECOND, IFtypes
# BUILTINSEMIRINGS[(max, pair)] = :GxB_MAX_PAIR, IFtypes
# BUILTINSEMIRINGS[(max, min)] = :GxB_MAX_MIN, IFtypes
# BUILTINSEMIRINGS[(max, max)] = :GxB_MAX_MAX, IFtypes
# BUILTINSEMIRINGS[(max, +)] = :GxB_MAX_PLUS, IFtypes
# BUILTINSEMIRINGS[(max, -)] = :GxB_MAX_MINUS, IFtypes
# BUILTINSEMIRINGS[(max, rminus)] = :GxB_MAX_RMINUS, IFtypes
# BUILTINSEMIRINGS[(max, *)] = :GxB_MAX_TIMES, IFtypes
# BUILTINSEMIRINGS[(max, /)] = :GxB_MAX_DIV, IFtypes
# BUILTINSEMIRINGS[(max, \)] = :GxB_MAX_RDIV, IFtypes
# BUILTINSEMIRINGS[(max, iseq)] = :GxB_MAX_ISEQ, IFtypes
# BUILTINSEMIRINGS[(max, isne)] = :GxB_MAX_ISNE, IFtypes
# BUILTINSEMIRINGS[(max, isgt)] = :GxB_MAX_ISGT, IFtypes
# BUILTINSEMIRINGS[(max, islt)] = :GxB_MAX_ISLT, IFtypes
# BUILTINSEMIRINGS[(max, isge)] = :GxB_MAX_ISGE, IFtypes
# BUILTINSEMIRINGS[(max, isle)] = :GxB_MAX_ISLE, IFtypes
# BUILTINSEMIRINGS[(max, ∨)] = :GxB_MAX_LOR, IFtypes
# BUILTINSEMIRINGS[(max, ∧)] = :GxB_MAX_LAND, IFtypes
# BUILTINSEMIRINGS[(max, lxor)] = :GxB_MAX_LXOR, IFtypes
# 
# BUILTINSEMIRINGS[(+, min)] = :GxB_PLUS_MIN, IFtypes
# BUILTINSEMIRINGS[(+, max)] = :GxB_PLUS_MAX, IFtypes
# BUILTINSEMIRINGS[(+, iseq)] = :GxB_PLUS_ISEQ, IFtypes
# BUILTINSEMIRINGS[(+, isne)] = :GxB_PLUS_ISNE, IFtypes
# BUILTINSEMIRINGS[(+, isgt)] = :GxB_PLUS_ISGT, IFtypes
# BUILTINSEMIRINGS[(+, islt)] = :GxB_PLUS_ISLT, IFtypes
# BUILTINSEMIRINGS[(+, isge)] = :GxB_PLUS_ISGE, IFtypes
# BUILTINSEMIRINGS[(+, isle)] = :GxB_PLUS_ISLE, IFtypes
# BUILTINSEMIRINGS[(+, ∨)] = :GxB_PLUS_LOR, IFtypes
# BUILTINSEMIRINGS[(+, ∧)] = :GxB_PLUS_LAND, IFtypes
# BUILTINSEMIRINGS[(+, lxor)] = :GxB_PLUS_LXOR, IFtypes
# 
# BUILTINSEMIRINGS[(*, min)] = :GxB_TIMES_MIN, IFtypes
# BUILTINSEMIRINGS[(*, max)] = :GxB_TIMES_MAX, IFtypes
# BUILTINSEMIRINGS[(*, iseq)] = :GxB_TIMES_ISEQ, IFtypes
# BUILTINSEMIRINGS[(*, isne)] = :GxB_TIMES_ISNE, IFtypes
# BUILTINSEMIRINGS[(*, isgt)] = :GxB_TIMES_ISGT, IFtypes
# BUILTINSEMIRINGS[(*, islt)] = :GxB_TIMES_ISLT, IFtypes
# BUILTINSEMIRINGS[(*, isge)] = :GxB_TIMES_ISGE, IFtypes
# BUILTINSEMIRINGS[(*, isle)] = :GxB_TIMES_ISLE, IFtypes
# BUILTINSEMIRINGS[(*, ∨)] = :GxB_TIMES_LOR, IFtypes
# BUILTINSEMIRINGS[(*, ∧)] = :GxB_TIMES_LAND, IFtypes
# BUILTINSEMIRINGS[(*, lxor)] = :GxB_TIMES_LXOR, IFtypes
# 
# BUILTINSEMIRINGS[(any, min)] = :GxB_ANY_MIN, IFtypes
# BUILTINSEMIRINGS[(any, max)] = :GxB_ANY_MAX, IFtypes
# BUILTINSEMIRINGS[(any, iseq)] = :GxB_ANY_ISEQ, IFtypes
# BUILTINSEMIRINGS[(any, isne)] = :GxB_ANY_ISNE, IFtypes
# BUILTINSEMIRINGS[(any, isgt)] = :GxB_ANY_ISGT, IFtypes
# BUILTINSEMIRINGS[(any, islt)] = :GxB_ANY_ISLT, IFtypes
# BUILTINSEMIRINGS[(any, isge)] = :GxB_ANY_ISGE, IFtypes
# BUILTINSEMIRINGS[(any, isle)] = :GxB_ANY_ISLE, IFtypes
# BUILTINSEMIRINGS[(any, ∨)] = :GxB_ANY_LOR, IFtypes
# BUILTINSEMIRINGS[(any, ∧)] = :GxB_ANY_LAND, IFtypes
# BUILTINSEMIRINGS[(any, lxor)] = :GxB_ANY_LXOR, IFtypes
# 
# # (LAND, LOR, LXOR, EQ, ANY) × (EQ, NE, GT, LT, GE, LE) × (I..., F...) (and sometimes bool)
# BUILTINSEMIRINGS[(∧, ==)] = :GxB_LAND_EQ, Rtypes
# BUILTINSEMIRINGS[(∧, !=)] = :GxB_LAND_NE, IFtypes
# BUILTINSEMIRINGS[(∧, >)] = :GxB_LAND_GT, Rtypes
# BUILTINSEMIRINGS[(∧, <)] = :GxB_LAND_LT, Rtypes
# BUILTINSEMIRINGS[(∧, >=)] = :GxB_LAND_GE, Rtypes
# BUILTINSEMIRINGS[(∧, <=)] = :GxB_LAND_LE, Rtypes
# 
# BUILTINSEMIRINGS[(∨, ==)] = :GxB_LOR_EQ, Rtypes
# BUILTINSEMIRINGS[(∨, !=)] = :GxB_LOR_NE, IFtypes
# BUILTINSEMIRINGS[(∨, >)] = :GxB_LOR_GT, Rtypes
# BUILTINSEMIRINGS[(∨, <)] = :GxB_LOR_LT, Rtypes
# BUILTINSEMIRINGS[(∨, >=)] = :GxB_LOR_GE, Rtypes
# BUILTINSEMIRINGS[(∨, <=)] = :GxB_LOR_LE, Rtypes
# 
# BUILTINSEMIRINGS[(lxor, ==)] = :GxB_LXOR_EQ, Rtypes
# BUILTINSEMIRINGS[(lxor, !=)] = :GxB_LXOR_NE, IFtypes
# BUILTINSEMIRINGS[(lxor, >)] = :GxB_LXOR_GT, Rtypes
# BUILTINSEMIRINGS[(lxor, <)] = :GxB_LXOR_LT, Rtypes
# BUILTINSEMIRINGS[(lxor, >=)] = :GxB_LXOR_GE, Rtypes
# BUILTINSEMIRINGS[(lxor, <=)] = :GxB_LXOR_LE, Rtypes
# BUILTINSEMIRINGS[(==, ==)] = :GxB_EQ_EQ, Rtypes
# BUILTINSEMIRINGS[(==, !=)] = :GxB_EQ_NE, IFtypes
# BUILTINSEMIRINGS[(==, >)] = :GxB_EQ_GT, Rtypes
# BUILTINSEMIRINGS[(==, <)] = :GxB_EQ_LT, Rtypes
# BUILTINSEMIRINGS[(==, >=)] = :GxB_EQ_GE, Rtypes
# BUILTINSEMIRINGS[(==, <=)] = :GxB_EQ_LE, Rtypes
# BUILTINSEMIRINGS[(any, ==)] = :GxB_ANY_EQ, Rtypes
# BUILTINSEMIRINGS[(any, !=)] = :GxB_ANY_NE, IFtypes
# BUILTINSEMIRINGS[(any, >)] = :GxB_ANY_GT, Rtypes
# BUILTINSEMIRINGS[(any, <)] = :GxB_ANY_LT, Rtypes
# BUILTINSEMIRINGS[(any, >=)] = :GxB_ANY_GE, Rtypes
# BUILTINSEMIRINGS[(any, <=)] = :GxB_ANY_LE, Rtypes
# 
# # (LAND, LOR, LXOR, EQ, ANY) × (FIRST, SECOND, PAIR(ONEB), LOR, LAND, LXOR) × Bool
# 
# BUILTINSEMIRINGS[(∧, first)] = :GxB_LAND_FIRST, Bool
# BUILTINSEMIRINGS[(∧, second)] = :GxB_LAND_SECOND, Bool
# BUILTINSEMIRINGS[(∧, pair)] = :GxB_LAND_PAIR, Bool
# BUILTINSEMIRINGS[(∧, ∨)] = :GxB_LAND_LOR, Bool
# BUILTINSEMIRINGS[(∧, ∧)] = :GxB_LAND_LAND, Bool
# BUILTINSEMIRINGS[(∧, lxor)] = :GxB_LAND_LXOR, Bool
# BUILTINSEMIRINGS[(∨, first)] = :GxB_LOR_FIRST, Bool
# BUILTINSEMIRINGS[(∨, second)] = :GxB_LOR_SECOND, Bool
# BUILTINSEMIRINGS[(∨, pair)] = :GxB_LOR_PAIR, Bool
# BUILTINSEMIRINGS[(∨, ∨)] = :GxB_LOR_LOR, Bool
# BUILTINSEMIRINGS[(∨, ∧)] = :GxB_LOR_LAND, Bool
# BUILTINSEMIRINGS[(∨, lxor)] = :GxB_LOR_LXOR, Bool
# 
# BUILTINSEMIRINGS[(lxor, first)] = :GxB_LXOR_FIRST, Bool
# BUILTINSEMIRINGS[(lxor, second)] = :GxB_LXOR_SECOND, Bool
# BUILTINSEMIRINGS[(lxor, pair)] = :GxB_LXOR_PAIR, Bool
# BUILTINSEMIRINGS[(lxor, ∨)] = :GxB_LXOR_LOR, Bool
# BUILTINSEMIRINGS[(lxor, ∧)] = :GxB_LXOR_LAND, Bool
# BUILTINSEMIRINGS[(lxor, lxor)] = :GxB_LXOR_LXOR, Bool
# BUILTINSEMIRINGS[(==, first)] = :GxB_EQ_FIRST, Bool
# BUILTINSEMIRINGS[(==, second)] = :GxB_EQ_SECOND, Bool
# BUILTINSEMIRINGS[(==, pair)] = :GxB_EQ_PAIR, Bool
# BUILTINSEMIRINGS[(==, ∨)] = :GxB_EQ_LOR, Bool
# BUILTINSEMIRINGS[(==, ∧)] = :GxB_EQ_LAND, Bool
# BUILTINSEMIRINGS[(==, lxor)] = :GxB_EQ_LXOR, Bool
# 
# BUILTINSEMIRINGS[(any, ∨)] = :GxB_ANY_LOR, Bool
# BUILTINSEMIRINGS[(any, ∧)] = :GxB_ANY_LAND, Bool
# BUILTINSEMIRINGS[(any, lxor)] = :GxB_ANY_LXOR, Bool
# 
# BUILTINSEMIRINGS[(|, |)] = :GxB_BOR_BOR, Utypes
# BUILTINSEMIRINGS[(|, &)] = :GxB_BOR_BAND, Utypes
# BUILTINSEMIRINGS[(|, ⊻)] = :GxB_BOR_BXOR, Utypes
# BUILTINSEMIRINGS[(|, bxnor)] = :GxB_BOR_BXNOR, Utypes
# 
# BUILTINSEMIRINGS[(&, |)] = :GxB_BAND_BOR, Utypes
# BUILTINSEMIRINGS[(&, &)] = :GxB_BAND_BAND, Utypes
# BUILTINSEMIRINGS[(&, ⊻)] = :GxB_BAND_BXOR, Utypes
# BUILTINSEMIRINGS[(&, bxnor)] = :GxB_BAND_BXNOR, Utypes
# 
# BUILTINSEMIRINGS[(⊻, |)] = :GxB_BXOR_BOR, Utypes
# BUILTINSEMIRINGS[(⊻, &)] = :GxB_BXOR_BAND, Utypes
# BUILTINSEMIRINGS[(⊻, ⊻)] = :GxB_BXOR_BXOR, Utypes
# BUILTINSEMIRINGS[(⊻, bxnor)] = :GxB_BXOR_BXNOR, Utypes
# BUILTINSEMIRINGS[(bxnor, |)] = :GxB_BXNOR_BOR, Utypes
# BUILTINSEMIRINGS[(bxnor, &)] = :GxB_BXNOR_BAND, Utypes
# BUILTINSEMIRINGS[(bxnor, ⊻)] = :GxB_BXNOR_BXOR, Utypes
# BUILTINSEMIRINGS[(bxnor, bxnor)] = :GxB_BXNOR_BXNOR, Utypes
# 
# BUILTINSEMIRINGS[(min, firsti)] = :GxB_MIN_FIRSTI1, Any
# BUILTINSEMIRINGS[(min, firsti0)] = :GxB_MIN_FIRSTI, Any
# BUILTINSEMIRINGS[(min, firstj)] = :GxB_MIN_FIRSTJ1, Any
# BUILTINSEMIRINGS[(min, firstj0)] = :GxB_MIN_FIRSTJ, Any
# BUILTINSEMIRINGS[(min, secondi)] = :GxB_MIN_SECONDI1, Any
# BUILTINSEMIRINGS[(min, secondi0)] = :GxB_MIN_SECONDI, Any
# BUILTINSEMIRINGS[(min, secondj)] = :GxB_MIN_SECONDJ1, Any
# BUILTINSEMIRINGS[(min, secondj0)] = :GxB_MIN_SECONDJ, Any
# BUILTINSEMIRINGS[(max, firsti)] = :GxB_MAX_FIRSTI1, Any
# BUILTINSEMIRINGS[(max, firsti0)] = :GxB_MAX_FIRSTI, Any
# BUILTINSEMIRINGS[(max, firstj)] = :GxB_MAX_FIRSTJ1, Any
# BUILTINSEMIRINGS[(max, firstj0)] = :GxB_MAX_FIRSTJ, Any
# BUILTINSEMIRINGS[(max, secondi)] = :GxB_MAX_SECONDI1, Any
# BUILTINSEMIRINGS[(max, secondi0)] = :GxB_MAX_SECONDI, Any
# BUILTINSEMIRINGS[(max, secondj)] = :GxB_MAX_SECONDJ1, Any
# BUILTINSEMIRINGS[(max, secondj0)] = :GxB_MAX_SECONDJ, Any
# BUILTINSEMIRINGS[(+, firsti)] = :GxB_PLUS_FIRSTI1, Any
# BUILTINSEMIRINGS[(+, firsti0)] = :GxB_PLUS_FIRSTI, Any
# BUILTINSEMIRINGS[(+, firstj)] = :GxB_PLUS_FIRSTJ1, Any
# BUILTINSEMIRINGS[(+, firstj0)] = :GxB_PLUS_FIRSTJ, Any
# BUILTINSEMIRINGS[(+, secondi)] = :GxB_PLUS_SECONDI1, Any
# BUILTINSEMIRINGS[(+, secondi0)] = :GxB_PLUS_SECONDI, Any
# BUILTINSEMIRINGS[(+, secondj)] = :GxB_PLUS_SECONDJ1, Any
# BUILTINSEMIRINGS[(+, secondj0)] = :GxB_PLUS_SECONDJ, Any
# BUILTINSEMIRINGS[(*, firsti)] = :GxB_TIMES_FIRSTI1, Any
# BUILTINSEMIRINGS[(*, firsti0)] = :GxB_TIMES_FIRSTI, Any
# BUILTINSEMIRINGS[(*, firstj)] = :GxB_TIMES_FIRSTJ1, Any
# BUILTINSEMIRINGS[(*, firstj0)] = :GxB_TIMES_FIRSTJ, Any
# BUILTINSEMIRINGS[(*, secondi)] = :GxB_TIMES_SECONDI1, Any
# BUILTINSEMIRINGS[(*, secondi0)] = :GxB_TIMES_SECONDI, Any
# BUILTINSEMIRINGS[(*, secondj)] = :GxB_TIMES_SECONDJ1, Any
# BUILTINSEMIRINGS[(*, secondj0)] = :GxB_TIMES_SECONDJ, Any
# BUILTINSEMIRINGS[(any, firsti)] = :GxB_ANY_FIRSTI1, Any
# BUILTINSEMIRINGS[(any, firsti0)] = :GxB_ANY_FIRSTI, Any
# BUILTINSEMIRINGS[(any, firstj)] = :GxB_ANY_FIRSTJ1, Any
# BUILTINSEMIRINGS[(any, firstj0)] = :GxB_ANY_FIRSTJ, Any
# BUILTINSEMIRINGS[(any, secondi)] = :GxB_ANY_SECONDI1, Any
# BUILTINSEMIRINGS[(any, secondi0)] = :GxB_ANY_SECONDI, Any
# BUILTINSEMIRINGS[(any, secondj)] = :GxB_ANY_SECONDJ1, Any
# BUILTINSEMIRINGS[(any, secondj0)] = :GxB_ANY_SECONDJ, Any
end

ztype(::TypedSemiring{FA, FM, X, Y, Z, T}) where {FA, FM, X, Y, Z, T} = Z
xtype(::TypedSemiring{FA, FM, X, Y, Z, T}) where {FA, FM, X, Y, Z, T} = X
ytype(::TypedSemiring{FA, FM, X, Y, Z, T}) where {FA, FM, X, Y, Z, T} = Y
