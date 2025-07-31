const valid_union = Union{
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
    ComplexF64,
    }
const valid_vec = [
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
    ComplexF64,
]

const gxb_union = Union{ComplexF32, ComplexF64}
const gxb_vec = [ComplexF32, ComplexF64]

mutable struct GBType{T} <: AbstractGBType
    builtin::Bool
    loaded::Bool
    p::LibGraphBLAS.GrB_Type
    typestr::String
    function GBType{T}(builtin, loaded, p, typestr) where {T}
        type = new{T}(builtin, loaded, p, typestr)
        return finalizer(type) do t
            @wraperror LibGraphBLAS.GrB_Type_free(Ref(t.p))
        end
    end
end


const JLTOGBTYPES = IdDict{DataType, GBType}()

"""
    gbtype(x)

Determine the GBType equivalent of a Julia primitive type.

See also: [`juliatype`](@ref)
"""
function gbtype(::Type{T}; builtin = false, loaded = false, typestr = string(T)) where T
    (get!(JLTOGBTYPES, T) do
        return GBType{T}(builtin, loaded, LibGraphBLAS.GrB_Type(), typestr)
    end)::GBType{T}
end

# For maybe a tiny bit of additional speed we'll overload `gbtype` for builtins.
macro _gbtype(expr...)

    jtype = expr[1]
    if length(expr) == 2
        namestr = string(expr[2])
    else
        namestr = uppercase(string(jtype))
    end
    builtin = isGxB(namestr) || isGrB(namestr)
    namesym = Symbol(builtin ? namestr[5:end] : namestr)
    return quote
        const $(esc(namesym)) = GBType{$(esc(jtype))}($builtin, false, LibGraphBLAS.GrB_Type(), $namestr)
        $(esc(:(SuiteSparseGraphBLAS.gbtype)))(::Type{$(esc(jtype))}) = $(esc(namesym))
    end
end

function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Type}, s::GBType{T}) where {T}
    if !s.loaded
        if s.builtin
            s.p = load_global(s.typestr, LibGraphBLAS.GrB_Type)
        else
            typeref = Ref{LibGraphBLAS.GrB_Type}()
            @wraperror LibGraphBLAS.GxB_Type_new(typeref, sizeof(T), string(T), "")
            s.p = typeref[]
        end
        s.loaded = true
        ptrtogbtype[s.p] = s
    end
    if !s.loaded
        error("This type could not be loaded, and is invalid.")
    else
        return s.p
    end
end

function Base.show(io::IO, ::MIME"text/plain", t::GBType{T}) where T
    print(io, "GBType(" * string(T) * "): ")
    gxbprint(io, t)
end

mutable struct GBAllType <: AbstractGBType
    p::Ptr{LibGraphBLAS.GrB_Index}
end
Base.show(io::IO, ::MIME"text/plain", t::GBAllType) = print(io, "GraphBLAS type: GrB_ALL")
Base.unsafe_convert(::Type{Ptr{LibGraphBLAS.GrB_Index}}, s::GBAllType) = s.p
Base.length(::GBAllType) = 0 #Allow indexing with ALL

"""
    juliatype(x::GBType)

Determine the Julia equivalent of a GBType.

See also: [`gbtype`](@ref)
"""
juliatype(::GBType{T}) where {T} = T

@_gbtype Bool GrB_BOOL
@_gbtype Int8 GrB_INT8
@_gbtype UInt8 GrB_UINT8
@_gbtype Int16 GrB_INT16
@_gbtype UInt16 GrB_UINT16
@_gbtype Int32 GrB_INT32
@_gbtype UInt32 GrB_UINT32
@_gbtype Int64 GrB_INT64
@_gbtype UInt64 GrB_UINT64
@_gbtype Float32 GrB_FP32
@_gbtype Float64 GrB_FP64
@_gbtype ComplexF32 GxB_FC32
@_gbtype ComplexF64 GxB_FC64
