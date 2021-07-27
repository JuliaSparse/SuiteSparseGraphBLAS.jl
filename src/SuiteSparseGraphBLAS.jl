module SuiteSparseGraphBLAS
__precompile__(true)
using Libdl: dlsym
using SSGraphBLAS_jll
using SparseArrays
using MacroTools
using LinearAlgebra
using Random: randsubseq, default_rng, AbstractRNG, GLOBAL_RNG
using CEnum
using SpecialFunctions: lgamma, gamma, erf, erfc
include("abstracts.jl")
include("libutils.jl")
include("lib/LibGraphBLAS.jl")
using .libgb


include("operators/libgbops.jl")
include("types.jl")
include("gbtypes.jl")


include("operators/operatorutils.jl")
include("operators/unaryops.jl")
include("operators/binaryops.jl")
include("operators/monoids.jl")
include("operators/semirings.jl")
include("operators/selectops.jl")
include("descriptors.jl")
using .UnaryOps
using .BinaryOps
using .Monoids
using .Semirings
_createunaryops()
_createbinaryops()
_createmonoids()
_createsemirings()
include("indexutils.jl")


const GBVecOrMat{T} = Union{GBVector{T}, GBMatrix{T}}
const GBMatOrTranspose{T} = Union{GBMatrix{T}, Transpose{<:Any, GBMatrix{T}}}
const GBArray{T} = Union{GBVector{T}, GBMatOrTranspose{T}}
const ptrtogbtype = Dict{Ptr, AbstractGBType}()

const GrBOp = Union{
    libgb.GrB_Monoid,
    libgb.GrB_UnaryOp,
    libgb.GrB_Semiring,
    libgb.GrB_BinaryOp,
    libgb.GxB_SelectOp
}

const TypedOp = Union{
    TypedUnaryOperator,
    TypedBinaryOperator,
    TypedMonoid,
    TypedSemiring
}

const MonoidBinaryOrRig = Union{
    TypedMonoid,
    TypedSemiring,
    TypedBinaryOperator,
    AbstractSemiring,
    AbstractBinaryOp,
    AbstractMonoid
}

const OperatorUnion = Union{
    AbstractOp,
    GrBOp
}

export T1, T0, T0T1, C, CT1, CT0, CT0T1, S, ST1, ST0, ST0T1, SC, SCT1, SCT0, SCT0T1, R, RT1,
    RT0, RT0T1, RC, RCT1, RCT0, RCT0T1, RS, RST1, RST0, RST0T1, RSC, RSCT1, RSCT0, RSCT0T1

export TRIL, TRIU, DIAG, OFFDIAG, NONZERO, EQ_ZERO, GT_ZERO, GE_ZERO, LT_ZERO, LE_ZERO, NE,
    EQ, GT, GE, LT, LE
include("scalar.jl")
include("vector.jl")
include("matrix.jl")
include("random.jl")

include("operations/operationutils.jl")
include("operations/transpose.jl")
include("operations/mul.jl")
include("operations/ewise.jl")
include("operations/map.jl")
include("operations/select.jl")
include("operations/reduce.jl")
include("operations/kronecker.jl")


include("print.jl")
include("import.jl")
include("export.jl")
include("options.jl")
#EXPERIMENTAL
include("operations/argminmax.jl")
include("operations/broadcasts.jl")
include("chainrules/chainruleutils.jl")
include("chainrules/mulrules.jl")
include("chainrules/ewiserules.jl")
include("chainrules/maprules.jl")
include("chainrules/reducerules.jl")
include("chainrules/selectrules.jl")
#include("random.jl")
include("misc.jl")
export libgb
export UnaryOps, BinaryOps, Monoids, Semirings, SelectOps, Descriptors #Submodules
export UnaryOp, BinaryOp, Monoid, Semiring #UDFs
export Descriptor #Types
export xtype, ytype, ztype, validtypes #Determine input/output types of operators
export GBScalar, GBVector, GBMatrix #arrays
export clear!, extract, extract!, subassign!, assign! #array functions

#operations
export mul, select, select!, eadd, eadd!, emul, emul!, map, map!, gbtranspose, gbtranspose!
# Reexports.
export diag, Diagonal, mul!, kron, kron!, transpose, reduce
export nnz, sprand, findnz, nonzeros
function __init__()
    _load_globaltypes()

    # I would like to do below, it's what the docs ask for. But it *seems* to work
    # without doing it, and I get segfaults on GC.gc() if I use the cglobals...
    #libgb.GxB_init(libgb.GrB_NONBLOCKING, cglobal(:jl_malloc), cglobal(:jl_calloc), cglobal(:jl_realloc), cglobal(:jl_free), true)
    libgb.GrB_init(libgb.GrB_NONBLOCKING)
    _loaddescriptors()
    _loadselectops()
    gbset(FORMAT, BYCOL) #This may not always be performant. Should put in Preferences.jl
    gbset(BASE1, true)
    atexit() do
        libgb.GrB_finalize()
    end
end

include("operators/ztypes.jl")
include("operators/oplist.jl")
end #end of module
