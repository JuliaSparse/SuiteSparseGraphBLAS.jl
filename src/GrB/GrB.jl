module GrB
import SparseBase
import SparseBase: RowMajor, ColMajor
import CIndices: CIndex
import MacroTools
import Libdl
import GPUCompiler
import DocStringExtensions

import SuiteSparseGraphBLAS
import ..SuiteSparseGraphBLAS: 
    rowindex, rowindex0, colindex, colindex0, frexpx, frexpe,
    second, ispair, rminus,
    lxor, xnor, bxnor, bget, bset, bclr, firsti0, firsti,
    firstj0, firstj, secondi0, secondi, secondj0, secondj,
    diagindex, isoffdiag, colindexle, rowindexle, colindexgt, rowindexgt,
    ∨, ∧, defaultmonoid

# TODO:
# - Test if _deshallow! has performance impacts when C aliases A.

# Allow users to specify a non-Artifact shared lib.
include("preferences.jl")
const libgraphblas_handle = Ref{Ptr{Nothing}}()

@static if artifact_or_path == "default"
    using SSGraphBLAS_jll
    const libgraphblas = SSGraphBLAS_jll.libgraphblas
else
    const libgraphblas = artifact_or_path
end

include("libutils.jl")
include("../../lib/LibGraphBLAS_gen.jl")
using .LibGraphBLAS

"""
    GrB.Global()

Singleton struct for the global object. 
Should only be constructed using `Global()`.

See [`get`](@ref) and [`set!`](@ref) for usage.
"""
mutable struct Global
    p::LibGraphBLAS.GrB_Global
end
Base.unsafe_convert(::Core.Type{LibGraphBLAS.GrB_Global}, g::Global) =
    g.p
const GLOBAL = Global(LibGraphBLAS.GrB_Global())
Global() = GLOBAL

"""
    IType = Union{Int64, UInt64, CIndex{Int64}, CIndex{UInt64}}

The index types which may be passed to GraphBLAS functions without
copying. 

Integer types will be decremented, while `CIndex` types
will be passed as is.
"""
const IType = Union{Int64, UInt64, CIndex{Int64}, CIndex{UInt64}}

"""
    set!(object, field, value)

Set `object.field = value`.
    
See also [`get`](@ref), [`set!`](@ref).
    
# Extended help
TODO: add table of field, values and objects.
"""
function set! end

"""
    get!(out, object::<GrB object>, field::Union{Symbol, Enum})

Store the value of `object.field` in `out`.

`out` must be of the correct type for `field`. This is typically a [`Scalar`](@ref),
    `Base.RefValue` or a `Ptr{Cvoid}`.

See also [`get`](@ref), [`set!`](@ref).

# Extended help
TODO: add table of field, outs and objects.
"""
function get! end

"""
    get(object::<GrB object>, field::Union{Symbol, Enum})

Return the value of `object.field` unwrapped. The exact type of the return value is
    determined by `field`.

See also [`get!`](@ref), [`set!`](@ref).
"""
function get end

nothrow_wait!(obj) = nothrow_wait!(obj, LibGraphBLAS.GrB_MATERIALIZE)

function wait!(obj, mode)
    info = nothrow_wait!(obj, mode)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@invalidindex info obj (Inf, Inf)
        GrB.@invalidvalue info mode
        GrB.@uninitializedobject info op
        GrB.@fallbackerror info
    end
end
wait!(obj) = wait!(obj, LibGraphBLAS.GrB_MATERIALIZE)


abstract type AbstractSparsity end
struct Dense <: AbstractSparsity end
struct Bytemap <: AbstractSparsity end
struct Sparse <: AbstractSparsity end
struct Hypersparse <: AbstractSparsity end

# All GrB object definitions:
#############################

mutable struct Type{T}
    const builtin::Bool
    loaded::Bool
    p::LibGraphBLAS.GrB_Type
    const typestr::String
    function Type{T}(builtin, loaded, p, typestr) where {T}
        type = new{T}(builtin, loaded, p, typestr)
        return finalizer(type) do t
            @checkfree LibGraphBLAS.GrB_Type_free(Ref(t.p))
        end
    end
end

"""
    GrB.Scalar{T}
    GrB.Scalar{T}(value)::GrB.Scalar{T}
    GrB.Scalar{T}()::GrB.Scalar{T}
    GrB.Scalar(value::T)::GrB.Scalar{T}

Low level GraphBLAS scalar type. 
This type is not an AbstractArray, and should not be used
in most user code. It internally supports all GraphBLAS calls, but only a very limited
selection of sugar. 

# Parameters:
- `T`: The type of stored values in the matrix

# Fields:
- `p::LibGraphBLAS.GrB_Scalar`: The underlying GraphBLAS matrix

# Arguments:
- `nrows`: The number of rows in the matrix
- `ncols`: The number of columns in the matrix
- `frozen::Bool`: Frozen matrices cannot be modified.
"""
mutable struct Scalar{T}
    p::LibGraphBLAS.GrB_Scalar
    function Scalar{T}(p::LibGraphBLAS.GrB_Scalar) where T
        return new{T}(p)
    end
end

"""
    GrB.Matrix{T}
    GrB.Matrix{T}(nrows::Integer, ncols::Integer, frozen = false)

Low level GraphBLAS matrix type. 
This type is not an AbstractArray, and should not be used
in most user code. It internally supports all GraphBLAS calls, but only a very limited
selection of sugar. 

# Parameters:
  - `T`: The type of stored values in the matrix

# Arguments:
  - `nrows`: The number of rows in the matrix
  - `ncols`: The number of columns in the matrix

# Keyword Arguments:
  - `shallow::Bool`
  - `storageorders::Tuple{SparseBase.StorageOrder}`: Allowed storage orders for the matrix.

# Extended help
## Fields (all internal):
  - `p::LibGraphBLAS.GrB_Matrix`: The underlying GraphBLAS matrix
  - `shallow::Bool`: Shallow matrices do not own their memory.
  - `allowedstorageorders::Set{SparseBase.StorageOrder}`: Allowed storage orders for the matrix.
Typically this is `Set([RowMajor(), ColMajor()])`, but it may be more restricted.
  - `keepalives::Vector{Any}`: A list of objects which must be kept alive as long as the matrix is alive.
"""
mutable struct Matrix{T}
    p::LibGraphBLAS.GrB_Matrix
    allowedstorageorders::Set{SparseBase.StorageOrder}
    shallow::Bool
    keepalives::Vector{Any}
end

"""
    $(DocStringExtensions.TYPEDEF)

Unary operator `F(x::X) -> z::Z` for use with the following GraphBLAS operations:
  - [`apply!`](@ref)

!!! warning "Internal"
    Users should not typically interact with `UnaryOp`s directly.
    
    Instead pass Julia functions directly to GraphBLAS operations,
        unless directly using the `GrB` module.

# Parameters
  - `F`: The Julia function `fn` being wrapped.
  - `F2`: The modified function `c_fn` generated by [`cunary`](@ref).
  - `X::DataType`: The input type.
  - `Z::DataType`: The output type.

# Fields
$(DocStringExtensions.TYPEDFIELDS)

# Extended help
## Internal Options
  - `:name`: Currently unused.
  - `:jit_cname`: The name of the C function to be compiled.
  - `:jit_cdef`: String with structure: `GB_ISOBJ <path to bitcode file>`.
  - `:input1typecode`
  - `:input1typestring`
  - `:outputtypecode`
  - `:outputtypestring`
"""
mutable struct UnaryOp{F, F2, X, Z}
    "true if this is a GrB or GxB builtin, otherwise false."
    const builtin::Bool
    "true if pointer `p` points to a valid constructed `GrB_UnaryOp` object."
    loaded::Bool
    "The name for this operator."
    const typestr::String
    p::LibGraphBLAS.GrB_UnaryOp
    "The user supplied Julia function being wrapped."
    const fn::F
    "The function `c_fn(z::Ptr{Z}, x::Ptr{X}) = Base.unsafe_store!(z, fn(Base.unsafe_load(x)))` created by [`cunary`](@ref)."
    const c_fn::F2
    "True if the bitcode file may be supplied to GraphBLAS for JIT compilation (one way false -> true)."
    maycompile::Bool
    "True if the bitcode file has been supplied to GraphBLAS for JIT compilation."
    compileset::Bool
    "The path to the bitcode file generated by GPUCompiler. Not stable between sessions."
    bitcodepath::Any
    function UnaryOp{F, X, Z}(
        builtin, loaded, typestr, fn, c_fn = nothing; 
        maycompile = false, irpath = nothing
    ) where {F, X, Z}
        unop = new{F, typeof(c_fn), X, Z}(
            builtin, loaded, typestr, LibGraphBLAS.GrB_UnaryOp(), 
            fn, c_fn, maycompile, false, irpath
        )
        return finalizer(unop) do op
            if op.loaded
                @checkfree LibGraphBLAS.GrB_UnaryOp_free(Ref(op.p))
            end
        end
    end
end

"""
    $(DocStringExtensions.TYPEDEF)

Index unary operator `F(x::X, i::Int64, j::Int64, thunk::T) -> z::Z` for use with the following GraphBLAS operations:
  - [`apply!`](@ref)
  - [`select!`](@ref)

!!! warning "Internal"
    Users should not typically interact with `IndexUnaryOp`s directly.
    
    Instead pass Julia functions directly to GraphBLAS operations,
        unless directly using the `GrB` module.

# Parameters
  - `F`: The Julia function `fn` being wrapped.
  - `F2`: The modified function `c_fn` generated by [`cunary`](@ref).
  - `X::DataType`: The type of the `x` argument.
  - `T::DataType`: The type of the `thunk` argument.
  - `Z::DataType`: The output type.

# Fields
$(DocStringExtensions.TYPEDFIELDS)

# Extended help
## Internal Options
  - `:name`: Currently unused.
  - `:jit_cname`: The name of the C function to be compiled.
  - `:jit_cdef`: String with structure: `GB_ISOBJ <path to bitcode file>`.
  - `:input1typecode`
  - `:input2typecode`
  - `:input1typestring`
  - `:input2typestring`
  - `:outputtypecode`
  - `:outputtypestring`
"""
mutable struct IndexUnaryOp{F, F2, X, T, Z}
    "true if this is a GrB or GxB builtin, otherwise false."
    const builtin::Bool
    "true if pointer `p` points to a valid constructed `GrB_BinaryOp` object."
    loaded::Bool
    "The name for this operator."
    const typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    "The user supplied Julia function being wrapped."
    p::LibGraphBLAS.GrB_IndexUnaryOp
    "The user supplied Julia function being wrapped."
    const fn::F
    """The function `c_fn(z::Ptr{Z}, x::Ptr{X}, i::Int64, j::Int64, thunk::Ptr{T}) = 
        Base.unsafe_store!(z, fn(Base.unsafe_load(x), i, j, Base.unsafe_load(thunk)))`"""
    const c_fn::F2
    "True if the bitcode file may be supplied to GraphBLAS for JIT compilation (one way false -> true)."
    maycompile::Bool
    "True if the bitcode file has been supplied to GraphBLAS for JIT compilation."
    compileset::Bool
    "The path to the bitcode file generated by GPUCompiler. Not stable between sessions."
    bitcodepath::Any
    function IndexUnaryOp{F, X, T, Z}(
        builtin, loaded, typestr, fn::F, c_fn = nothing;
        maycompile = false, irpath = nothing
    ) where {F, X, T, Z}
        binop = new{F, typeof(c_fn), X, T, Z}(
            builtin, loaded, typestr, LibGraphBLAS.GrB_IndexUnaryOp(), 
            fn, c_fn, maycompile, false, irpath
        )
        return finalizer(binop) do op
            if op.loaded
                @checkfree LibGraphBLAS.GrB_IndexUnaryOp_free(Ref(op.p))
            end
        end
    end
end

"""
    $(DocStringExtensions.TYPEDEF)

Binary operator `F(x::X, y::Y) -> z::Z` for use with the following GraphBLAS operations:
  - [`apply!`](@ref)
  - [`emul!`](@ref)
  - [`eadd!`](@ref)
  - [`eunion!`](@ref)
  - [`kronecker!`](@ref)

as well as for construction of [`Monoid`](@ref)s and semirings, and as the `accum` argument to
    most GraphBLAS operations.

!!! warning "Internal"
    Users should not typically interact with `UnaryOp`s directly.

    Instead pass Julia functions directly to GraphBLAS operations,
        unless directly using the `GrB` module.

# Parameters
  - `F`: The Julia function `fn` being wrapped.
  - `F2`: The modified function `c_fn` generated by [`cunary`](@ref).
  - `X::DataType`: Input type of the first argument.
  - `Y::DataType`: Input type of the second argument.
  - `Z::DataType`: The output type.

# Fields
$(DocStringExtensions.TYPEDFIELDS)

# Extended help
## Internal Options
  - `:name`: Currently unused.
  - `:jit_cname`: The name of the C function to be compiled.
  - `:jit_cdef`: String with structure: `GB_ISOBJ <path to bitcode file>`.
  - `:input1typecode`
  - `:input2typecode`
  - `:input1typestring`
  - `:input2typestring`
  - `:outputtypecode`
  - `:outputtypestring`
"""
mutable struct BinaryOp{F, F2, X, Y, Z}
    "true if this is a GrB or GxB builtin, otherwise false."
    const builtin::Bool
    "true if pointer `p` points to a valid constructed `GrB_BinaryOp` object."
    loaded::Bool
    "The name for this operator."
    const typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    "The user supplied Julia function being wrapped."
    p::LibGraphBLAS.GrB_BinaryOp
    "The user supplied Julia function being wrapped."
    const fn::F
    "The function `c_fn(z::Ptr{Z}, x::Ptr{X}, y::Ptr{Y}) = Base.unsafe_store!(z, fn(Base.unsafe_load(x), Base.unsafe_load(y)))`"
    const c_fn::F2
    "True if the bitcode file may be supplied to GraphBLAS for JIT compilation (one way false -> true)."
    maycompile::Bool
    "True if the bitcode file has been supplied to GraphBLAS for JIT compilation."
    compileset::Bool
    "The path to the bitcode file generated by GPUCompiler. Not stable between sessions."
    bitcodepath::Any
    function BinaryOp{F, X, Y, Z}(
        builtin, loaded, typestr, fn::F, c_fn = nothing;
        maycompile = false, irpath = nothing
    ) where {F, X, Y, Z}
        binop = new{F, typeof(c_fn), X, Y, Z}(
            builtin, loaded, typestr, LibGraphBLAS.GrB_BinaryOp(), 
            fn, c_fn, maycompile, false, irpath
        )
        return finalizer(binop) do op
            if op.loaded
                @checkfree LibGraphBLAS.GrB_BinaryOp_free(Ref(op.p))
            end
        end
    end
end

mutable struct Monoid{F, Z, T, B}
    const builtin::Bool
    loaded::Bool
    const typestr::String # If a built-in this is something like GrB_PLUS_FP64, if not it's just some user defined string.
    p::LibGraphBLAS.GrB_Monoid
    binaryop::B
    identity::Z
    terminal::T
    function Monoid(builtin, loaded, typestr, p, binaryop::BinaryOp{F, F2, Z, Z, Z}, identity::Z, terminal::T) where {F, F2, Z, T<:Union{Z, Nothing}}
        monoid = new{F, Z, T, typeof(binaryop)}(builtin, loaded, typestr, p, binaryop, identity, terminal)
        return finalizer(monoid) do op
            GrB.@checkfree LibGraphBLAS.GrB_Monoid_free(Ref(op.p))
        end
    end
end

mutable struct Semiring{X, Y, Z, M, B}
    const builtin::Bool
    loaded::Bool
    const typestr::String
    p::LibGraphBLAS.GrB_Semiring
    addop::M
    mulop::B
    function Semiring(
        builtin, loaded, typestr, p, 
        addop::Monoid{FA, Z}, mulop::BinaryOp{FM, F2, X, Y, Z}
    ) where {FA, FM, F2, X, Y, Z}
        semiring = new{X, Y, Z, typeof(addop), typeof(mulop)}(builtin, loaded, typestr, p, addop, mulop)
        return finalizer(semiring) do rig
            @checkfree LibGraphBLAS.GrB_Semiring_free(Ref(rig.p))
        end
    end
end

"""
   Descriptor

Control object which may be optionally passed to many SuiteSparse:GraphBLAS functions.

See the SuiteSparse:GraphBLAS User Guide or the SuiteSparseGraphBLAS.jl docs for more information.

# Options
- `replace_output`: Clear the output array before assignment.
- `structural_mask::Bool`: Utilize the structure of the mask argument, rather than its values.
- `complement_mask::Bool`: Values which are true in the complement of the mask will be kept.
"""
mutable struct Descriptor
    name::String
    p::LibGraphBLAS.GrB_Descriptor
    function Descriptor(name, p::LibGraphBLAS.GrB_Descriptor)
        d = new(name, p)
        function f(descriptor)
            @checkfree LibGraphBLAS.GrB_Descriptor_free(Ref(descriptor.p))
        end
        return finalizer(f, d)
    end
end

#Utilities:
include("print.jl")
include("Types.jl")
include("Scalar.jl")
include("Matrix.jl")
include("packunpack.jl")

include("operatorutils.jl")
include("indexutils.jl")
include("mem.jl")

include("compiler.jl")
include("UnaryOps.jl")
include("IndexUnaryOps.jl")
include("BinaryOps.jl")
include("Monoids.jl")
include("Semirings.jl")
include("Descriptors.jl")

include("Operations.jl")
include("getset.jl")



function __init__()
    @static if artifact_or_path != "default"
        libgraphblas_handle[] = Libdl.dlopen(libgraphblas)
    else
        #The artifact does dlopen for us.
        libgraphblas_handle[] = SSGraphBLAS_jll.libgraphblas_handle
    end
    # We initialize GraphBLAS by giving it Julia's GC wrapped memory management functions.
    # In the future this should hopefully allow us to do no-copy passing of arrays between Julia and SS:GrB.
    # In the meantime it helps Julia respond to memory pressure from SS:GrB and finalize things in a timely fashion.
    info = LibGraphBLAS.GxB_init(LibGraphBLAS.GrB_NONBLOCKING, cglobal(:jl_malloc), cglobal(:jl_calloc), cglobal(:jl_realloc), cglobal(:jl_free))
    if info != LibGraphBLAS.GrB_SUCCESS
        @fallbackerror info
    end
    ALL.p = load_global("GrB_ALL", LibGraphBLAS.GrB_Index)
    GLOBAL.p = load_global("GrB_GLOBAL", LibGraphBLAS.GrB_Global)
    OperatorCompiler.initcompiler()
    set!(Global(), :print1based, 1)
    atexit() do
        # Finalize the lib, for now only frees a small internal memory pool.
        @checkfree LibGraphBLAS.GrB_finalize()
        @static if artifact_or_path != "default"
            Libdl.dlclose(libgraphblas_handle[])
        end
    end
end
end # module GrB
