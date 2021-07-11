module SuiteSparseGraphBLAS

using Libdl: dlsym
using SSGraphBLAS_jll
using SparseArrays
using MacroTools
using LinearAlgebra
using Random: randsubseq, default_rng, AbstractRNG, GLOBAL_RNG
using CEnum
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

_createunaryops()
_createbinaryops()
_createmonoids()
_createsemirings()

include("descriptors.jl")

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

#context/with
export with

function __init__()
    _load_globaltypes()
    _loadselectops()
    _loaddescriptors()
    # I would like to do below, it's what the docs ask for. But it *seems* to work
    # without doing it, and I get segfaults on GC.gc() if I use the cglobals...
    #libgb.GxB_init(libgb.GrB_NONBLOCKING, cglobal(:jl_malloc), cglobal(:jl_calloc), cglobal(:jl_realloc), cglobal(:jl_free), true)
    libgb.GrB_init(libgb.GrB_NONBLOCKING)
    gbset(FORMAT, BYCOL) #This may not always be performant. Should put in Preferences.jl
    gbset(BASE1, true)
    @eval(Descriptors, $:(const NULL = Descriptor()))
    atexit() do
        libgb.GrB_finalize()
    end
end

include("operators/ztypes.jl")
end #end of module
