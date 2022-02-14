ztype(::AbstractOp, intype::DataType) = intype

#UnaryOps:
# ztype(::UnaryOps.ISINF_T, ::DataType) = Bool
# ztype(::UnaryOps.ISNAN_T, ::DataType) = Bool
# ztype(::UnaryOps.ISFINITE_T, ::DataType) = Bool
# 
# ztype(::UnaryOps.CONJ_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]
# ztype(::UnaryOps.ABS_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]
# ztype(::UnaryOps.CREAL_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]
# ztype(::UnaryOps.CIMAG_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]
# ztype(::UnaryOps.CARG_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]
# 
# ztype(::UnaryOps.POSITIONI_T, ::DataType) = Int64
# ztype(::UnaryOps.POSITIONI1_T, ::DataType) = Int64
# ztype(::UnaryOps.POSITIONJ_T, ::DataType) = Int64
# ztype(::UnaryOps.POSITIONJ1_T, ::DataType) = Int64

#BinaryOps:
ztype(::BinaryOps.EQ_T, ::DataType) = Bool
ztype(::BinaryOps.NE_T, ::DataType) = Bool
ztype(::BinaryOps.GT_T, ::DataType) = Bool
ztype(::BinaryOps.LT_T, ::DataType) = Bool
ztype(::BinaryOps.GE_T, ::DataType) = Bool
ztype(::BinaryOps.LE_T, ::DataType) = Bool
ztype(::BinaryOps.CMPLX_T, intype::Type{T}) where {T <: AbstractFloat} = Complex{T}

ztype(::BinaryOps.FIRSTI_T, ::DataType) = Int64
ztype(::BinaryOps.FIRSTI1_T, ::DataType) = Int64
ztype(::BinaryOps.FIRSTJ_T, ::DataType) = Int64
ztype(::BinaryOps.FIRSTJ1_T, ::DataType) = Int64
ztype(::BinaryOps.SECONDI_T, ::DataType) = Int64
ztype(::BinaryOps.SECONDI1_T, ::DataType) = Int64
ztype(::BinaryOps.SECONDJ_T, ::DataType) = Int64
ztype(::BinaryOps.SECONDJ1_T, ::DataType) = Int64

#Semirings:
ztype(::Semirings.LAND_EQ_T, ::DataType) = Bool
ztype(::Semirings.LOR_EQ_T, ::DataType) = Bool
ztype(::Semirings.LXOR_EQ_T, ::DataType) = Bool
ztype(::Semirings.EQ_EQ_T, ::DataType) = Bool
ztype(::Semirings.ANY_EQ_T, ::DataType) = Bool
ztype(::Semirings.LAND_NE_T, ::DataType) = Bool
ztype(::Semirings.LOR_NE_T, ::DataType) = Bool
ztype(::Semirings.LXOR_NE_T, ::DataType) = Bool
ztype(::Semirings.EQ_NE_T, ::DataType) = Bool
ztype(::Semirings.ANY_NE_T, ::DataType) = Bool
ztype(::Semirings.LAND_GT_T, ::DataType) = Bool
ztype(::Semirings.LOR_GT_T, ::DataType) = Bool
ztype(::Semirings.LXOR_GT_T, ::DataType) = Bool
ztype(::Semirings.EQ_GT_T, ::DataType) = Bool
ztype(::Semirings.ANY_GT_T, ::DataType) = Bool
ztype(::Semirings.LAND_LT_T, ::DataType) = Bool
ztype(::Semirings.LOR_LT_T, ::DataType) = Bool
ztype(::Semirings.LXOR_LT_T, ::DataType) = Bool
ztype(::Semirings.EQ_LT_T, ::DataType) = Bool
ztype(::Semirings.ANY_LT_T, ::DataType) = Bool
ztype(::Semirings.LAND_GE_T, ::DataType) = Bool
ztype(::Semirings.LOR_GE_T, ::DataType) = Bool
ztype(::Semirings.LXOR_GE_T, ::DataType) = Bool
ztype(::Semirings.EQ_GE_T, ::DataType) = Bool
ztype(::Semirings.ANY_GE_T, ::DataType) = Bool
ztype(::Semirings.LAND_LE_T, ::DataType) = Bool
ztype(::Semirings.LOR_LE_T, ::DataType) = Bool
ztype(::Semirings.LXOR_LE_T, ::DataType) = Bool
ztype(::Semirings.EQ_LE_T, ::DataType) = Bool
ztype(::Semirings.ANY_LE_T, ::DataType) = Bool


ztype(::Semirings.MIN_FIRSTI_T, ::DataType) = Int64
ztype(::Semirings.MAX_FIRSTI_T, ::DataType) = Int64
ztype(::Semirings.PLUS_FIRSTI_T, ::DataType) = Int64
ztype(::Semirings.TIMES_FIRSTI_T, ::DataType) = Int64
ztype(::Semirings.ANY_FIRSTI_T, ::DataType) = Int64
ztype(::Semirings.MIN_FIRSTI1_T, ::DataType) = Int64
ztype(::Semirings.MAX_FIRSTI1_T, ::DataType) = Int64
ztype(::Semirings.PLUS_FIRSTI1_T, ::DataType) = Int64
ztype(::Semirings.TIMES_FIRSTI1_T, ::DataType) = Int64
ztype(::Semirings.ANY_FIRSTI1_T, ::DataType) = Int64
ztype(::Semirings.MIN_FIRSTJ_T, ::DataType) = Int64
ztype(::Semirings.MAX_FIRSTJ_T, ::DataType) = Int64
ztype(::Semirings.PLUS_FIRSTJ_T, ::DataType) = Int64
ztype(::Semirings.TIMES_FIRSTJ_T, ::DataType) = Int64
ztype(::Semirings.ANY_FIRSTJ_T, ::DataType) = Int64
ztype(::Semirings.MIN_FIRSTJ1_T, ::DataType) = Int64
ztype(::Semirings.MAX_FIRSTJ1_T, ::DataType) = Int64
ztype(::Semirings.PLUS_FIRSTJ1_T, ::DataType) = Int64
ztype(::Semirings.TIMES_FIRSTJ1_T, ::DataType) = Int64
ztype(::Semirings.ANY_FIRSTJ1_T, ::DataType) = Int64
ztype(::Semirings.MIN_SECONDI_T, ::DataType) = Int64
ztype(::Semirings.MAX_SECONDI_T, ::DataType) = Int64
ztype(::Semirings.PLUS_SECONDI_T, ::DataType) = Int64
ztype(::Semirings.TIMES_SECONDI_T, ::DataType) = Int64
ztype(::Semirings.ANY_SECONDI_T, ::DataType) = Int64
ztype(::Semirings.MIN_SECONDI1_T, ::DataType) = Int64
ztype(::Semirings.MAX_SECONDI1_T, ::DataType) = Int64
ztype(::Semirings.PLUS_SECONDI1_T, ::DataType) = Int64
ztype(::Semirings.TIMES_SECONDI1_T, ::DataType) = Int64
ztype(::Semirings.ANY_SECONDI1_T, ::DataType) = Int64
ztype(::Semirings.MIN_SECONDJ_T, ::DataType) = Int64
ztype(::Semirings.MAX_SECONDJ_T, ::DataType) = Int64
ztype(::Semirings.PLUS_SECONDJ_T, ::DataType) = Int64
ztype(::Semirings.TIMES_SECONDJ_T, ::DataType) = Int64
ztype(::Semirings.ANY_SECONDJ_T, ::DataType) = Int64
ztype(::Semirings.MIN_SECONDJ1_T, ::DataType) = Int64
ztype(::Semirings.MAX_SECONDJ1_T, ::DataType) = Int64
ztype(::Semirings.PLUS_SECONDJ1_T, ::DataType) = Int64
ztype(::Semirings.TIMES_SECONDJ1_T, ::DataType) = Int64
ztype(::Semirings.ANY_SECONDJ1_T, ::DataType) = Int64
