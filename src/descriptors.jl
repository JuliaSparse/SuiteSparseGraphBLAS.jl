mutable struct Descriptor <: AbstractDescriptor
    p::libgb.GrB_Descriptor
    function Descriptor(p::libgb.GrB_Descriptor)
        d = new(p)
        function f(descriptor)
            libgb.GrB_Descriptor_free(Ref(descriptor.p))
        end
        return finalizer(f, d)
    end
end

function Descriptor()
    return Descriptor(libgb.GrB_Descriptor_new())
end

Base.unsafe_convert(::Type{libgb.GrB_Descriptor}, d::Descriptor) = d.p

function Base.getproperty(d::Descriptor, s::Symbol)
    if s == :p
        return getfield(d, s)
    elseif s == :output
        f = libgb.GrB_OUTP
    elseif s == :mask
        f = libgb.GrB_MASK
    elseif s == :input1
        f = libgb.GrB_INP0
    elseif s == :input2
        f = libgb.GrB_INP1
    #elseif s == :nthreads
        #f = libgb.GxB_DESCRIPTOR_NTHREADS
    #elseif s == :chunk
        #f = libgb.GxB_DESCRIPTOR_CHUNK
    #elseif s == :axb_method
        #f = libgb.GxB_AxB_METHOD
    #elseif s == :sort
        #f = libgb.GxB_SORT
    else
        error("type Descriptor has no field $s")
    end
    return libgb.GxB_Descriptor_get(d, f)
end

function Base.setproperty!(d::Descriptor, s::Symbol, x)
    if s == :p
        setfield!(d, s, x)
    elseif s == :output
        f = libgb.GrB_OUTP
    elseif s == :mask
        f = libgb.GrB_MASK
    elseif s == :input1
        f = libgb.GrB_INP0
    elseif s == :input2
        f = libgb.GrB_INP1
    #elseif s == :nthreads
        #f = libgb.GxB_DESCRIPTOR_NTHREADS
    #elseif s == :chunk
        #f = libgb.GxB_DESCRIPTOR_CHUNK
    #elseif s == :axb_method
        #f = libgb.GxB_AxB_METHOD
    #elseif s == :sort
        #f = libgb.GxB_SORT
    else
        error("type Descriptor has no field $s")
    end
    libgb.GrB_Descriptor_set(d, f, x)
end

function Base.:+(d1::Descriptor, d2::Descriptor)
    d = Descriptor()
    for f ∈ propertynames(d)
        if f == :input1
            if getproperty(d1, f) == Descriptors.TRANSPOSE && getproperty(d2, f) == Descriptors.TRANSPOSE
                setproperty!(d, f, Descriptors.DEFAULT)
            elseif getproperty(d1, f) == Descriptors.TRANSPOSE || getproperty(d2, f) == Descriptors.TRANSPOSE
                setproperty!(d, f, Descriptors.TRANSPOSE)
            end
        elseif f == :input2
            if getproperty(d1, f) == Descriptors.TRANSPOSE && getproperty(d2, f) == Descriptors.TRANSPOSE
                setproperty!(d, f, Descriptors.DEFAULT)
            elseif getproperty(d1, f) == Descriptors.TRANSPOSE || getproperty(d2, f) == Descriptors.TRANSPOSE
                setproperty!(d, f, Descriptors.TRANSPOSE)
            end
        else
            if getproperty(d1, f) != Descriptors.DEFAULT
                setproperty!(d, f, getproperty(d1, f))
            end
            if getproperty(d2, f) != Descriptors.DEFAULT
                setproperty!(d, f, getproperty(d2, f))
            end
        end
    end
    return d
end

#This is probably not ideal. Perhaps kwargs = nothing by default is better
Base.:+(d1::Descriptor, ::Nothing) = d1
Base.:+(::Nothing, d2::Descriptor) = d2
Base.:+(f1::libgb.GrB_Desc_Value, f2::libgb.GrB_Desc_Value) = libgb.GrB_Desc_Value(UInt32(f1) + UInt32(f2))
function Base.propertynames(d::Descriptor)
    return (
    :output,
    :mask,
    :input1,
    :input2,
    #:nthreads,
    #:chunk,
    #:axb_method,
    #:sort,
    )
end
baremodule Descriptors
import ..SuiteSparseGraphBLAS: load_global, Descriptor
import ..libgb:
GB_Descriptor_opaque,
GrB_Descriptor,
GxB_DEFAULT,
GrB_REPLACE,
GrB_COMP,
GrB_STRUCTURE,
GrB_STRUCT_COMP,
GrB_TRAN,
GxB_GPU_ALWAYS,
GxB_GPU_NEVER,
GxB_AxB_GUSTAVSON,
GxB_AxB_DOT,
GxB_AxB_HASH,
GxB_AxB_SAXPY
import ..Types
import Base.C_NULL

const DEFAULT = GxB_DEFAULT
const REPLACE = GrB_REPLACE
const COMPLEMENT = GrB_COMP
const STRUCTURE = GrB_STRUCTURE
const STRUCT_COMP = GrB_STRUCT_COMP
const TRANSPOSE = GrB_TRAN
const GUSTAVSON = GxB_AxB_GUSTAVSON
const DOT = GxB_AxB_DOT
const HASH = GxB_AxB_HASH
const SAXPY = GxB_AxB_SAXPY
end

function _loaddescriptors()
    builtins = ["GrB_DESC_T1",
    "GrB_DESC_T0",
    "GrB_DESC_T0T1",
    "GrB_DESC_C",
    "GrB_DESC_CT1",
    "GrB_DESC_CT0",
    "GrB_DESC_CT0T1",
    "GrB_DESC_S",
    "GrB_DESC_ST1",
    "GrB_DESC_ST0",
    "GrB_DESC_ST0T1",
    "GrB_DESC_SC",
    "GrB_DESC_SCT1",
    "GrB_DESC_SCT0",
    "GrB_DESC_SCT0T1",
    "GrB_DESC_R",
    "GrB_DESC_RT1",
    "GrB_DESC_RT0",
    "GrB_DESC_RT0T1",
    "GrB_DESC_RC",
    "GrB_DESC_RCT1",
    "GrB_DESC_RCT0",
    "GrB_DESC_RCT0T1",
    "GrB_DESC_RS",
    "GrB_DESC_RST1",
    "GrB_DESC_RST0",
    "GrB_DESC_RST0T1",
    "GrB_DESC_RSC",
    "GrB_DESC_RSCT1",
    "GrB_DESC_RSCT0",
    "GrB_DESC_RSCT0T1"]
    for name ∈ builtins
        simple = Symbol(string(name[10:end]))
        constquote = quote
            const $simple = Descriptor(load_global($name, GB_Descriptor_opaque))
        end
        @eval(Descriptors, $constquote)
    end

end

Base.show(io::IO, ::MIME"text/plain", d::Descriptor) = gxbprint(io, d)
