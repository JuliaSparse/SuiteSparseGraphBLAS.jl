module SuiteSparseGraphBLAS

using Libdl: dlsym
using SSGraphBLAS_jll
using SparseArrays
using MacroTools
using LinearAlgebra
using Random: randsubseq, default_rng, AbstractRNG

include("abstracts.jl")
include("libutils.jl")
include("lib/LibGraphBLAS.jl")
using .libgb

#export GBScalar, GBVector, GBMatrix
#
#const GBVecOrMat = Union{GBVector, GBMatrix}

#const GBMatOrTranspose = Union{<:GBMatrix, Transpose{<:Any, <:GBMatrix}}
#const GBArray = Union{<:GBVector, GBMatOrTranspose}

include("types.jl")
include("gbtypes.jl")
include("print.jl")

include("operators/operatorutils.jl")
include("operators/unaryops.jl")
include("operators/binaryops.jl")
include("operators/monoids.jl")
include("operators/semirings.jl")
include("operators/selectops.jl")

include("operations/operationutils.jl")
const ptrtogbtype = Dict{Ptr, AbstractGBType}()

const GrBOp = Union{
    libgb.GrB_Monoid,
    libgb.GrB_UnaryOp,
    libgb.GrB_Semiring,
    libgb.GrB_BinaryOp,
    libgb.GxB_SelectOp
}

const MonoidBinaryOrRig = Union{
    libgb.GrB_Monoid,
    libgb.GrB_Semiring,
    libgb.GrB_BinaryOp,
    AbstractSemiring,
    AbstractBinaryOp,
    AbstractMonoid
}

export libgb
export UnaryOps, BinaryOps, Monoids, Semirings, SelectOps
export xtype, ytype, ztype
function __init__()
    _createunaryops()
    _createbinaryops()
    _createmonoids()
    _createsemirings()
    _load_globaltypes()
    _loadselectops()
    libgb.GrB_init(libgb.GrB_NONBLOCKING)
    atexit() do
        libgb.GrB_finalize()
    end
end
end #end of module
