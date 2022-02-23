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

function gbtype end
macro toGBType(expr...)

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

struct GBAllType <: AbstractGBType
    p::Ptr{LibGraphBLAS.GrB_Index}
end
Base.show(io::IO, ::MIME"text/plain", t::GBAllType) = print(io, "GraphBLAS type: GrB_ALL")
Base.unsafe_convert(::Type{Ptr{LibGraphBLAS.GrB_Index}}, s::GBAllType) = s.p
Base.length(::GBAllType) = 0 #Allow indexing with ALL

"""
    tojuliatype(x::GBType)

Determine the Julia equivalent of a GBType.

See also: [`toGBType`](@ref)
"""
juliatype(::GBType{T}) where {T} = T


"""
    toGBType(x)

Determine the GBType equivalent of a Julia primitive type.

See also: [`juliatype`](@ref)
"""

@gbtype Bool GrB_BOOL
@gbtype Int8 GrB_INT8
@gbtype UInt8 GrB_UINT8
@gbtype Int16 GrB_INT16
@gbtype UInt16 GrB_UINT16
@gbtype Int32 GrB_INT32
@gbtype UInt32 GrB_UINT32
@gbtype Int64 GrB_INT64
@gbtype UInt64 GrB_UINT64
@gbtype Float32 GrB_FP32
@gbtype Float64 GrB_FP64
@gbtype ComplexF32 GxB_FC32
@gbtype ComplexF64 GxB_FC64

function toGBType(x)
    if x == Bool
        return BOOL
    elseif x == Int8
        return INT8
    elseif x == UInt8
        return UINT8
    elseif x == Int16
        return INT16
    elseif x == UInt16
        return UINT16
    elseif x == Int32
        return INT32
    elseif x == UInt32
        return UINT32
    elseif x == Int64
        return INT64
    elseif x == UInt64
        return UINT64
    elseif x == Float32
        return FP32
    elseif x == Float64
        return FP64
    elseif x == ComplexF32
        return FC32
    elseif x == ComplexF64
        return FC64
    else
        throw(ArgumentError("Not a valid GrB data type"))
    end
end
