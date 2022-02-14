module BinaryOps
import ..SuiteSparseGraphBLAS
using ..SuiteSparseGraphBLAS: isGxB, isGrB, TypedUnaryOperator, AbstractBinaryOp, GBType,
    valid_vec, juliaop, toGBType, symtotype, Itypes, Ftypes, Ztypes, FZtypes, Rtypes, Ntypes, Ttypes, suffix
using ..libgb
export BinaryOp, @binop


end

const BinaryUnion = Union{AbstractBinaryOp, TypedBinaryOperator}

ztype(::TypedBinaryOperator{X, Y, Z}) where {X, Y, Z} = Z
xtype(::TypedBinaryOperator{X, Y, Z}) where {X, Y, Z} = X
ytype(::TypedBinaryOperator{X, Y, Z}) where {X, Y, Z} = Y