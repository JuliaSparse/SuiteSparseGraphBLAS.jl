module SuiteSparseGraphBLAS

using MacroTools
using LinearAlgebra
using LinearAlgebra: copy_oftype
using Random: randsubseq, default_rng, AbstractRNG, GLOBAL_RNG
using SpecialFunctions: lgamma, gamma, erf, erfc
using Base.Broadcast
using Serialization
using Blobs
using SparseBase
using CIndices
import SparseBase: storedeltype
const NoValue = SparseBase.NoValue
const novalue = SparseBase.novalue

export ColMajor, RowMajor, storageorder #reexports from StorageOrders

# Functions used as unary or binary ops which are not available in Base / other packages.
# UnaryOps:
"""
    rowindex(xᵢⱼ) -> i

Dummy function for use with [`apply`](@ref). Returns the row index of an element.
"""
rowindex(_) = 1::Int64

"""
    rowindex0(xᵢⱼ) -> i - 1

Dummy function for use with [`apply`](@ref). Returns the 0 indexed row index of an element.
"""
rowindex0(_) = 0::Int64

"""
    colindex(xᵢⱼ) -> j

Dummy function for use with [`apply`](@ref). Returns the col index of an element.
"""
colindex(_) = 1::Int64

"""
    colindex0(xᵢⱼ) -> j - 1

Dummy function for use with [`apply`](@ref). Returns the 0 indexed col index of an element.
"""
colindex0(_) = 0::Int64
frexpx(x) = frexp(x)[1]
frexpe(x) = frexp(x)[2]
# BinaryOps:
"""
    second(xᵢⱼ, yₖₗ) -> yₖₗ

Dummy function for use with GraphBLAS operations. Returns the second of two arguments.
"""
second(_, y) = y
"""
    ispair(xᵢⱼ, yₖₗ) -> 1

Dummy function for use with GraphBLAS operations. Returns 1 if both arguments are
    explicitly stored in the matrix.
"""
ispair(::T, ::U) where {T, U} = one(promote_type(T, U))
"""
    rminus(xᵢⱼ, yₖₗ) -> yᵢⱼ - xᵢⱼ
"""
rminus(x, y) = y - x

function ∨(x::T, y::T) where T
    return (x != zero(T)) || (y != zero(T))
end
function ∧(x::T, y::T) where T
    return (x != zero(T)) && (y != zero(T))
end

lxor(x::T, y::T) where T = xor((x != zero(T)), (y != zero(T)))
xnor(x::T, y::T) where T = !(lxor(x, y))
bxnor(x::T, y::T) where T = ~⊻(x, y)
bget(x::T, y) where T = (x & (one(UInt8) << y))::T
bset(x::T, y) where T = (x | (one(UInt8) << y))::T
bclr(x::T, y) where T = (x & ~(one(UInt8) << y))::T

"""
    firsti0(xᵢⱼ, yₖₗ) -> i - 1
"""
firsti0(x, y) = 0::Int64
"""
    firsti(xᵢⱼ, yₖₗ) -> i
"""
firsti(x, y) = 1::Int64
"""
    firstj0(xᵢⱼ, yₖₗ) -> j - 1
"""
firstj0(x, y) = 0::Int64
"""
    firstj(xᵢⱼ, yₖₗ) -> j
"""
firstj(x, y) = 1::Int64
"""
    secondi0(xᵢⱼ, yₖₗ) -> k - 1
"""
secondi0(x, y) = 0::Int64
"""
    secondi(xᵢⱼ, yₖₗ) -> k
"""
secondi(x, y) = 1::Int64
"""
    secondi(xᵢⱼ, yₖₗ) -> k - 1
"""
secondj0(x, y) = 0::Int64
"""
    secondi(xᵢⱼ, yₖₗ) -> k
"""
secondj(x, y) = 1::Int64

# IndexUnaryOps

"""
    diagindex(xᵢⱼ, i, j, y=0) -> j - i + y

Diagonal index of `x`.
"""
diagindex(xᵢⱼ, i, j, y::T=0) where T = (j - (i + y))::T

"""
    rowindex(xᵢⱼ, i, j, y=1) -> i + y

Row index of `xᵢⱼ` + the integer scalar `y`
"""
rowindex(xᵢⱼ, i, j, y::T=1) where {T <: Union{Int32, Int64}} = (i + y)::T

"""
    colindex(xᵢⱼ, i, j, y=1) -> j + y

Column index of `xᵢⱼ` + the integer scalar `y`
"""
colindex(xᵢⱼ, i, j, y::T=1) where {T <: Union{Int32, Int64}} = (j + y)::T

"""
    istril(xᵢⱼ, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0) -> j <= (i + y)

Returns true if `xᵢⱼ` is in the lower triangular part of the matrix.
For use in GraphBLAS higher order functions like [`select`](@ref) and 
    [`apply`](@ref).
"""
istril(x, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0)
"""
    istriu(xᵢⱼ, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0) -> j >= (i + y)

Returns true if `xᵢⱼ` is in the lower triangular part of the matrix.
For use in GraphBLAS higher order functions like [`select`](@ref) and 
    [`apply`](@ref).
"""
istriu(x, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0)
"""
    isdiag(xᵢⱼ, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0) -> j == (i + y)

Returns true if `xᵢⱼ` is in the yth diagonal of the matrix.
For use in GraphBLAS higher order functions like [`select`](@ref) and 
    [`apply`](@ref).
"""
isdiag(x, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0)
"""
    isoffdiag(xᵢⱼ, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0) -> j != (i + y)

Returns true if `xᵢⱼ` is in the yth diagonal of the matrix.
For use in GraphBLAS higher order functions like [`select`](@ref) and 
    [`apply`](@ref).
"""
isoffdiag(x, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0) = j != (i + y)
"""
    colindexle(xᵢⱼ, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0) -> j <= y

Returns true if `xᵢⱼ` is in the `y`th column or below.
For use in GraphBLAS higher order functions like [`select`](@ref) and 
    [`apply`](@ref).
"""
colindexle(x, i::CIndex{Int64}, j::CIndex{Int64}, y::CIndex{Int64}) = j <= y
"""
    rowindexle(xᵢⱼ, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0) -> i <= y

Returns true if `xᵢⱼ` is in the `y`th row or below.
For use in GraphBLAS higher order functions like [`select`](@ref) and 
    [`apply`](@ref).
"""
rowindexle(x, i::CIndex{Int64}, j::CIndex{Int64}, y::CIndex{Int64}) = i <= y
"""
    colindexle(xᵢⱼ, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0) -> j <= y

Returns true if `xᵢⱼ` is above the `y`th column.
For use in GraphBLAS higher order functions like [`select`](@ref) and 
    [`apply`](@ref).
"""
colindexgt(x, i::CIndex{Int64}, j::CIndex{Int64}, y::CIndex{Int64}) = j > y
"""
    rowindexle(xᵢⱼ, i::CIndex{Int64}, j::CIndex{Int64}, y::Int64=0) -> i <= y

Returns true if `xᵢⱼ` is above the `y`th row.
For use in GraphBLAS higher order functions like [`select`](@ref) and 
    [`apply`](@ref).
"""
rowindexgt(x, i::CIndex{Int64}, j::CIndex{Int64}, y::CIndex{Int64}) = i > y

"""
    Monoid{F, I, T}

A Monoid is a binary function `fn` along with an identity and an optional terminal value.

The `identity` and `terminal` should be functions of a type, or `nothing` for the `terminal`.
For instance `Monoid(*, one, zero)` would be the `Monoid` for scalar multiplication.

Monoids are translated into `GrB_Monoid`s before calling into GraphBLAS itself.
"""
struct Monoid{F, I, T}
    fn::F
    identity::I
    terminal::T
end
Monoid(fn, identity) = Monoid(fn, identity, nothing)
# We default to no available monoid.
defaultmonoid(f::F, ::Type{T}) where {F, T} = throw(
    ArgumentError("Function $f does not have a default monoid.
    You must either extend defaultmonoid(::$F, ::Type{T}) = 
    Monoid($f, <identity> [, <terminal>]) or pass the struct
    Monoid($f, <identity>, [, <terminal>]) to the operation.")
)

function extract! end
function extract end

function select! end
function select end

# mul and ewise are taken care of by Base.mul! and Base.map resp.
function reduce! end

include("GrB/GrB.jl")

# include("highlevel/highlevel.jl")

# include("types.jl")
# include("scalar.jl")
# include("mem.jl")

# include("constants.jl")
# include("wait.jl")

# include("descriptors.jl")
# using .UnaryOps
# using .BinaryOps
# using .Monoids
# using .Semirings
# using .IndexUnaryOps

# include("indexutils.jl")
# # 
# include("operations/extract.jl")
# include("gbvector.jl")
# include("gbmatrix.jl")
# include("abstractgbarray.jl")
# 
# # EXPERIMENTAL array types:
# include("shallowtypes.jl")
# include("oriented.jl")
# 
# include("convert.jl")
# include("random.jl")
# # Miscellaneous Operations
# include("pack.jl")
# include("unpack.jl")
# include("options.jl")
# # Core operations (mul, elementwise, etc)
# include("operations/operationutils.jl")
# include("operations/transpose.jl")
# include("operations/mul.jl")
# include("operations/ewise.jl")
# include("operations/map.jl")
# include("operations/select.jl")
# include("operations/reduce.jl")
# include("operations/kronecker.jl")
# include("operations/concat.jl")
# include("operations/resize.jl")
# include("operations/sort.jl")
# # 
# 
# include("operations/broadcasts.jl")
# include("chainrules/chainruleutils.jl")
# include("chainrules/mulrules.jl")
# include("chainrules/ewiserules.jl")
# include("chainrules/maprules.jl")
# include("chainrules/reducerules.jl")
# include("chainrules/selectrules.jl")
# include("chainrules/constructorrules.jl")
# 
# include("serialization.jl")
# 
# #EXPERIMENTAL
# include("linalg.jl")
# include("mmread.jl")
# include("iterator.jl")
# include("solvers/klu.jl")
# include("solvers/umfpack.jl")
# include("solvers/cholmod.jl")
end #end of module
