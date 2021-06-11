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



include("types.jl")
include("gbtypes.jl")
include("print.jl")

include("operators/operatorutils.jl")
include("operators/unaryops.jl")
include("operators/binaryops.jl")
include("operators/monoids.jl")
include("operators/semirings.jl")
include("operators/selectops.jl")

include("descriptors.jl")

include("operations/operationutils.jl")

include("indexutils.jl")
include("libarray.jl")
include("scalar.jl")
include("vector.jl")
include("matrix.jl")

const GBVecOrMat = Union{GBVector, GBMatrix}
const GBMatOrTranspose = Union{<:GBMatrix, Transpose{<:Any, <:GBMatrix}}
const GBArray = Union{<:GBVector, GBMatOrTranspose}
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

include("operations/transpose.jl")
include("operations/mul.jl")
include("operations/ewise.jl")
include("operations/apply.jl")
include("operations/select.jl")
include("operations/reduce.jl")
include("operations/kronecker.jl")
include("with.jl") #EXPERIMENTAL
export libgb
export UnaryOps, BinaryOps, Monoids, Semirings, SelectOps, Descriptors
export xtype, ytype, ztype
export GBScalar, GBVector, GBMatrix
export clear!, extract, extract!, subassign!, assign!

# Reexports. Not sure if this is a good idea.
export diag, Diagonal, mul!
export nnz

export mul
function __init__()
    _createunaryops()
    _createbinaryops()
    _createmonoids()
    _createsemirings()
    _load_globaltypes()
    _loadselectops()
    _loaddescriptors()
    libgb.GrB_init(libgb.GrB_NONBLOCKING)
    @eval(Descriptors, $:(const NULL = Descriptor()))
    atexit() do
        libgb.GrB_finalize()
    end
end
end #end of module
