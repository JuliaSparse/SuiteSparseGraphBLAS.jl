module Consts
using ..SuiteSparseGraphBLAS: isGxB, isGrB, libgb, libgb.GrB_UnaryOp, libgb.GrB_BinaryOp, libgb.GrB_Monoid, suffix, AbstractTypedOp, load_global, AbstractUnaryOp,
AbstractBinaryOp, AbstractMonoid, AbstractSemiring
using SpecialFunctions
export @unop, @binop, @monoid, @rig
function juliaop end
function unaryop end
function binaryop end
function monoid end
# UnaryOps
# unaryop(<jlop>) = singletonOP
# singletonOP(T::Type{}) = <OP>_<T>
# const <OP>_<T> = (<OPSTRING>, Ref(false), TypedUnaryOperator2)
# const AINV_INT32 = (true, "GrB_AINV_INT32", [false], [0x000000...])
# @unop GrB_IDENTITY T=>T | F=>F | I=>I | A=>N | Z=>Z | Z=>F
const Itypes = (:Int8, :Int16, :Int32, :Int64, :UInt8, :UInt16, :UInt32, :UInt64)
const Ftypes = (:Float32, :Float64)
const Ztypes = (:ComplexF32, :ComplexF64)
const FZtypes = (Ftypes..., Ztypes...)
const Rtypes = (Itypes..., Ftypes..., :Bool)
const Ntypes = (:Int64, ) # :Int32 as well, but can't disambiguate, and hopefully unecessary
const Ttypes = (Rtypes..., Ztypes...)
function symtotype(sym)
    if sym === :I
        return Itypes
    elseif sym === :F
        return Ftypes
    elseif sym === :Z
        return Ztypes
    elseif sym === :R
        return Rtypes
    elseif sym === :N
        return Ntypes
    elseif sym === :FZ
        return FZtypes
    elseif sym === :T
        return Ttypes
    else
        return sym
    end
end

include("operators/unaryops2.jl")
include("operators/binaryops2.jl")
include("operators/monoids2.jl")
include("operators/semirings2.jl")
end

# module testing
# using ..Consts
# Consts.@unop atand F=>F
# end