module SuiteSparseGraphBLAS
__precompile__(true)
using Libdl: dlsym, dlopen, dlclose
using Preferences
include("find_binary.jl")
const libgraphblas_handle = Ref{Ptr{Nothing}}()
@static if artifact_or_path == "default"
    using SSGraphBLAS_jll
    const libgraphblas = SSGraphBLAS_jll.libgraphblas
else
    const libgraphblas = artifact_or_path
end
using SparseArrays
using MacroTools
using LinearAlgebra
using Random: randsubseq, default_rng, AbstractRNG, GLOBAL_RNG
using CEnum
using SpecialFunctions: lgamma, gamma, erf, erfc
using Base.Broadcast
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
include("operators/oplist.jl")
include("indexutils.jl")

export lgamma, gamma, erf, erfc #reexport of SpecialFunctions.
export frexpe, frexpx, positioni, positionj #UnaryOps not found in Julia/stdlibs.
#BinaryOps not found in Julia/stdlibs.
export second, rminus, pair, iseq, isne, isgt, islt, isge, isle, ∨, ∧, lxor, fmod, firsti,
    firstj, secondi, secondj
#SelectOps not found in Julia/stdlibs
export offdiag

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
include("operations/concat.jl")
include("operations/resize.jl")

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
include("chainrules/constructorrules.jl")
#include("random.jl")
include("misc.jl")
export libgb
export UnaryOps, BinaryOps, Monoids, Semirings #Submodules
export UnaryOp, BinaryOp, Monoid, Semiring #UDFs
export Descriptor #Types
export xtype, ytype, ztype, validtypes #Determine input/output types of operators
export GBScalar, GBVector, GBMatrix #arrays
export clear!, extract, extract!, subassign!, assign!, hvcat! #array functions

#operations
export mul, select, select!, eadd, eadd!, emul, emul!, map, map!, gbtranspose, gbtranspose!,
gbrand
# Reexports.
export diag, diagm, mul!, kron, kron!, transpose, reduce, tril, triu
export nnz, sprand, findnz, nonzeros, SparseArrays.nonzeroinds
function __init__()
    @static if artifact_or_path != "default"
        libgraphblas_handle[] = dlopen(libgraphblas)
    else
        #The artifact does dlopen for us.
        libgraphblas_handle[] = SSGraphBLAS_jll.libgraphblas_handle
    end
    _load_globaltypes()
    # We initialize GraphBLAS by giving it Julia's GC wrapped memory management functions.
    # In the future this should hopefully allow us to do no-copy passing of arrays between Julia and SS:GrB.
    # In the meantime it helps Julia respond to memory pressure from SS:GrB and finalize things in a timely fashion.
    libgb.GxB_init(libgb.GrB_NONBLOCKING, cglobal(:jl_malloc), cglobal(:jl_calloc), cglobal(:jl_realloc), cglobal(:jl_free), true)
    _loaddescriptors()
    _loadselectops()
    # Set printing to base-1 rather than base-0.
    gbset(BASE1, true)
    atexit() do
        # Finalize the lib. Frees a small internal memory pool.
        libgb.GrB_finalize()
        @static if artifact_or_path != "default"
            dlclose(libgraphblas_handle[])
        end
    end
end

include("operators/ztypes.jl")
end #end of module
