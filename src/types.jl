# Types which are pre-compiled within SuiteSparse:GraphBLAS:
const builtin_union = Union{
    Bool,
    Int8,
    UInt8,
    Int16,
    UInt16,
    Int32,
    UInt32,
    Int64,
    UInt64,
    Float32,
    Float64,
    ComplexF32, ComplexF64
}
const builtin_vec = [
    Bool,
    Int8,
    UInt8,
    Int16,
    UInt16,
    Int32,
    UInt32,
    Int64,
    UInt64,
    Float32,
    Float64,
    ComplexF32,
    ComplexF64
]

const gxb_union = Union{ComplexF32, ComplexF64}
const gxb_vec = [ComplexF32, ComplexF64]

mutable struct GrB_Type{T}
    const builtin::Bool
    loaded::Bool
    p::LibGraphBLAS.GrB_Type
    const typestr::String
    function GrB_Type{T}(builtin, loaded, p, typestr) where {T}
        type = new{T}(builtin, loaded, p, typestr)
        return finalizer(type) do t
            @checkfree LibGraphBLAS.GrB_Type_free(Ref(t.p))
        end
    end
end

function Base.unsafe_convert(::Core.Type{LibGraphBLAS.GrB_Type}, s::GrB_Type{T}) where {T}
    if !s.loaded
        if s.builtin
            s.p = load_global(s.typestr, LibGraphBLAS.GrB_Type)
        else
            typeref = Ref{LibGraphBLAS.GrB_Type}()
            info = LibGraphBLAS.GxB_Type_new(
                typeref, 
                sizeof(T), 
                GPUCompiler.safe_name(s.typestr),
                # types are meaningless after compilation to bitcode. So we can just use char arrays.
                # If this becomes an issue we can walk the type and generate a struct.
                # TODO: TEST THIS MANUALLY
                "typedef struct { char x [$(sizeof(T))] ; } $(GPUCompiler.safe_name(s.typestr));"
            )
            if info != LibGraphBLAS.GrB_SUCCESS
                GrB.@fallbackerror info
            end
            s.p = typeref[]
        end
        s.loaded = true
        ptr_to_GrB_Type[s.p] = s
    end
    if !s.loaded
        error("This type could not be loaded, and is invalid.")
    else
        return s.p
    end
end

wait!(t::GrB_Type, mode) = LibGraphBLAS.GrB_Type_wait(t, mode)

function GrB.GxB_fprint(x::Type, name, level, file)
    info = LibGraphBLAS.GxB_Type_fprint(x, name, level, file)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info x
        GrB.@fallbackerror info
    end
end
function Base.show(io::IO, ::MIME"text/plain", t::GrB_Type{T}) where T
    print(io, "GrB_Type{" * string(T) * "}: ")
    gxbprint(io, t)
end

const ptr_to_GrB_Type = IdDict{Ptr, GrB_Type}()
const GBTYPES = IdDict{DataType, GrB_Type}()

"""
    GrB_Type(x)

Get or construct the GrB_Type equivalent of a Julia primitive type.

See also: [`juliatype`](@ref)
"""
function GrB_Type(::Core.Type{T}; typestr = string(T)) where T
    (get!(GBTYPES, T) do 
        return GrB_Type{T}(false, false, LibGraphBLAS.GrB_Type(), typestr)
    end)::GrB_Type{T}
end

const GrB_BOOL = GrB_Type{Bool}(true, false, LibGraphBLAS.GrB_Type(), "GrB_BOOL")
GrB_Type(::Core.Type{Bool}) = GrB_BOOL
const GrB_INT8 = GrB_Type{Int8}(true, false, LibGraphBLAS.GrB_Type(), "GrB_INT8")
GrB_Type(::Core.Type{Int8}) = GrB_INT8
const GrB_INT16 = GrB_Type{Int16}(true, false, LibGraphBLAS.GrB_Type(), "GrB_INT16")
GrB_Type(::Core.Type{Int16}) = GrB_INT16
const GrB_INT32 = GrB_Type{Int32}(true, false, LibGraphBLAS.GrB_Type(), "GrB_INT32")
GrB_Type(::Core.Type{Int32}) = GrB_INT32
const GrB_INT64 = GrB_Type{Int64}(true, false, LibGraphBLAS.GrB_Type(), "GrB_INT64")
GrB_Type(::Core.Type{Int64}) = GrB_INT64
const GrB_UINT8 = GrB_Type{UInt8}(true, false, LibGraphBLAS.GrB_Type(), "GrB_UINT8")
GrB_Type(::Core.Type{UInt8}) = GrB_UINT8
const GrB_UINT16 = GrB_Type{UInt16}(true, false, LibGraphBLAS.GrB_Type(), "GrB_UINT16")
GrB_Type(::Core.Type{UInt16}) = GrB_UINT16
const GrB_UINT32 = GrB_Type{UInt32}(true, false, LibGraphBLAS.GrB_Type(), "GrB_UINT32")
GrB_Type(::Core.Type{UInt32}) = GrB_UINT32
const GrB_UINT64 = GrB_Type{UInt64}(true, false, LibGraphBLAS.GrB_Type(), "GrB_UINT64")
GrB_Type(::Core.Type{UInt64}) = GrB_UINT64
const GrB_FP32 = GrB_Type{Float32}(true, false, LibGraphBLAS.GrB_Type(), "GrB_FP32")
GrB_Type(::Core.Type{Float32}) = GrB_FP32
const GrB_FP64 = GrB_Type{Float64}(true, false, LibGraphBLAS.GrB_Type(), "GrB_FP64")
GrB_Type(::Core.Type{Float64}) = GrB_FP64
const GxB_FC32 = GrB_Type{ComplexF32}(true, false, LibGraphBLAS.GrB_Type(), "GxB_FC32")
GrB_Type(::Core.Type{ComplexF32}) = GxB_FC32
const GxB_FC64 = GrB_Type{ComplexF64}(true, false, LibGraphBLAS.GrB_Type(), "GxB_FC64")
GrB_Type(::Core.Type{ComplexF64}) = GxB_FC64
