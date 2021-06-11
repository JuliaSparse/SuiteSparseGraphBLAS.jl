module SuiteSparseGraphBLAS

using Libdl: dlsym
using SSGraphBLAS_jll
using SparseArrays
using MacroTools
using LinearAlgebra
using Random: randsubseq, default_rng, AbstractRNG

#export GBScalar, GBVector, GBMatrix
#
#const GBVecOrMat = Union{GBVector, GBMatrix}
#const GrBOp = Union{
#    libgb.GrB_Monoid,
#    libgb.GrB_UnaryOp,
#    libgb.GrB_Semiring,
#    libgb.GrB_BinaryOp,
#    libgb.GxB_SelectOp
#}
#
#const MonoidBinaryOrRig = Union{
#    libgb.GrB_Monoid,
#    libgb.GrB_Semiring,
#    libgb.GrB_BinaryOp,
#    AbstractSemiring,
#    AbstractBinaryOp,
#    AbstractMonoid
#}
#
#const GBMatOrTranspose = Union{<:GBMatrix, Transpose{<:Any, <:GBMatrix}}
#const GBArray = Union{<:GBVector, GBMatOrTranspose}

include("abstracts.jl")
include("libutils.jl")
include("lib/LibGraphBLAS.jl")
using .libgb

include("types.jl")
end #end of module
