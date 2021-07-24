ztype(::AbstractOp, intype::DataType) = intype

#UnaryOps:
ztype(::UnaryOps.ISINF_T, ::DataType) = Bool
ztype(::UnaryOps.ISNAN_T, ::DataType) = Bool
ztype(::UnaryOps.ISFINITE_T, ::DataType) = Bool

ztype(::UnaryOps.CONJ_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]
ztype(::UnaryOps.ABS_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]
ztype(::UnaryOps.CREAL_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]
ztype(::UnaryOps.CIMAG_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]
ztype(::UnaryOps.CARG_T, intype::Type{T}) where {T <: Complex} = intype.parameters[1]

ztype(::UnaryOps.POSITIONI_T, ::DataType) = Int64
ztype(::UnaryOps.POSITIONI1_T, ::DataType) = Int64
ztype(::UnaryOps.POSITIONJ_T, ::DataType) = Int64
ztype(::UnaryOps.POSITIONJ1_T, ::DataType) = Int64

#BinaryOps:
ztype(::Types.EQ_T, ::DataType) = Bool
ztype(::Types.NE_T, ::DataType) = Bool
ztype(::Types.GT_T, ::DataType) = Bool
ztype(::Types.LT_T, ::DataType) = Bool
ztype(::Types.GE_T, ::DataType) = Bool
ztype(::Types.LE_T, ::DataType) = Bool
ztype(::Types.CMPLX_T, intype::Type{T}) where {T <: AbstractFloat} = Complex{T}

ztype(::Types.FIRSTI_T, ::DataType) = Int64
ztype(::Types.FIRSTI1_T, ::DataType) = Int64
ztype(::Types.FIRSTJ_T, ::DataType) = Int64
ztype(::Types.FIRSTJ1_T, ::DataType) = Int64
ztype(::Types.SECONDI_T, ::DataType) = Int64
ztype(::Types.SECONDI1_T, ::DataType) = Int64
ztype(::Types.SECONDJ_T, ::DataType) = Int64
ztype(::Types.SECONDJ1_T, ::DataType) = Int64

#Semirings:
ztype(::Types.LAND_EQ_T, ::DataType) = Bool
ztype(::Types.LOR_EQ_T, ::DataType) = Bool
ztype(::Types.LXOR_EQ_T, ::DataType) = Bool
ztype(::Types.EQ_EQ_T, ::DataType) = Bool
ztype(::Types.ANY_EQ_T, ::DataType) = Bool
ztype(::Types.LAND_NE_T, ::DataType) = Bool
ztype(::Types.LOR_NE_T, ::DataType) = Bool
ztype(::Types.LXOR_NE_T, ::DataType) = Bool
ztype(::Types.EQ_NE_T, ::DataType) = Bool
ztype(::Types.ANY_NE_T, ::DataType) = Bool
ztype(::Types.LAND_GT_T, ::DataType) = Bool
ztype(::Types.LOR_GT_T, ::DataType) = Bool
ztype(::Types.LXOR_GT_T, ::DataType) = Bool
ztype(::Types.EQ_GT_T, ::DataType) = Bool
ztype(::Types.ANY_GT_T, ::DataType) = Bool
ztype(::Types.LAND_LT_T, ::DataType) = Bool
ztype(::Types.LOR_LT_T, ::DataType) = Bool
ztype(::Types.LXOR_LT_T, ::DataType) = Bool
ztype(::Types.EQ_LT_T, ::DataType) = Bool
ztype(::Types.ANY_LT_T, ::DataType) = Bool
ztype(::Types.LAND_GE_T, ::DataType) = Bool
ztype(::Types.LOR_GE_T, ::DataType) = Bool
ztype(::Types.LXOR_GE_T, ::DataType) = Bool
ztype(::Types.EQ_GE_T, ::DataType) = Bool
ztype(::Types.ANY_GE_T, ::DataType) = Bool
ztype(::Types.LAND_LE_T, ::DataType) = Bool
ztype(::Types.LOR_LE_T, ::DataType) = Bool
ztype(::Types.LXOR_LE_T, ::DataType) = Bool
ztype(::Types.EQ_LE_T, ::DataType) = Bool
ztype(::Types.ANY_LE_T, ::DataType) = Bool


ztype(::Types.MIN_FIRSTI_T, ::DataType) = Int64
ztype(::Types.MAX_FIRSTI_T, ::DataType) = Int64
ztype(::Types.PLUS_FIRSTI_T, ::DataType) = Int64
ztype(::Types.TIMES_FIRSTI_T, ::DataType) = Int64
ztype(::Types.ANY_FIRSTI_T, ::DataType) = Int64
ztype(::Types.MIN_FIRSTI1_T, ::DataType) = Int64
ztype(::Types.MAX_FIRSTI1_T, ::DataType) = Int64
ztype(::Types.PLUS_FIRSTI1_T, ::DataType) = Int64
ztype(::Types.TIMES_FIRSTI1_T, ::DataType) = Int64
ztype(::Types.ANY_FIRSTI1_T, ::DataType) = Int64
ztype(::Types.MIN_FIRSTJ_T, ::DataType) = Int64
ztype(::Types.MAX_FIRSTJ_T, ::DataType) = Int64
ztype(::Types.PLUS_FIRSTJ_T, ::DataType) = Int64
ztype(::Types.TIMES_FIRSTJ_T, ::DataType) = Int64
ztype(::Types.ANY_FIRSTJ_T, ::DataType) = Int64
ztype(::Types.MIN_FIRSTJ1_T, ::DataType) = Int64
ztype(::Types.MAX_FIRSTJ1_T, ::DataType) = Int64
ztype(::Types.PLUS_FIRSTJ1_T, ::DataType) = Int64
ztype(::Types.TIMES_FIRSTJ1_T, ::DataType) = Int64
ztype(::Types.ANY_FIRSTJ1_T, ::DataType) = Int64
ztype(::Types.MIN_SECONDI_T, ::DataType) = Int64
ztype(::Types.MAX_SECONDI_T, ::DataType) = Int64
ztype(::Types.PLUS_SECONDI_T, ::DataType) = Int64
ztype(::Types.TIMES_SECONDI_T, ::DataType) = Int64
ztype(::Types.ANY_SECONDI_T, ::DataType) = Int64
ztype(::Types.MIN_SECONDI1_T, ::DataType) = Int64
ztype(::Types.MAX_SECONDI1_T, ::DataType) = Int64
ztype(::Types.PLUS_SECONDI1_T, ::DataType) = Int64
ztype(::Types.TIMES_SECONDI1_T, ::DataType) = Int64
ztype(::Types.ANY_SECONDI1_T, ::DataType) = Int64
ztype(::Types.MIN_SECONDJ_T, ::DataType) = Int64
ztype(::Types.MAX_SECONDJ_T, ::DataType) = Int64
ztype(::Types.PLUS_SECONDJ_T, ::DataType) = Int64
ztype(::Types.TIMES_SECONDJ_T, ::DataType) = Int64
ztype(::Types.ANY_SECONDJ_T, ::DataType) = Int64
ztype(::Types.MIN_SECONDJ1_T, ::DataType) = Int64
ztype(::Types.MAX_SECONDJ1_T, ::DataType) = Int64
ztype(::Types.PLUS_SECONDJ1_T, ::DataType) = Int64
ztype(::Types.TIMES_SECONDJ1_T, ::DataType) = Int64
ztype(::Types.ANY_SECONDJ1_T, ::DataType) = Int64
