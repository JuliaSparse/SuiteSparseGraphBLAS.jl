mutable struct Descriptor <: AbstractDescriptor
    name::String
    p::libgb.GrB_Descriptor
    function Descriptor(name, p::libgb.GrB_Descriptor)
        d = new(name, p)
        function f(descriptor)
            libgb.GrB_Descriptor_free(Ref(descriptor.p))
        end
        return finalizer(f, d)
    end
end

const DEFAULT = libgb.GxB_DEFAULT
const REPLACE = libgb.GrB_REPLACE
const COMPLEMENT = libgb.GrB_COMP
const STRUCTURE = libgb.GrB_STRUCTURE
const STRUCT_COMP = libgb.GrB_STRUCT_COMP
const TRANSPOSE = libgb.GrB_TRAN
const GUSTAVSON = libgb.GxB_AxB_GUSTAVSON
const DOT = libgb.GxB_AxB_DOT
const HASH = libgb.GxB_AxB_HASH
const SAXPY = libgb.GxB_AxB_SAXPY

const T1 = Descriptor("T1", libgb.GrB_Descriptor(C_NULL))
const T0 = Descriptor("T0", libgb.GrB_Descriptor(C_NULL))
const T0T1 = Descriptor("T0T1", libgb.GrB_Descriptor(C_NULL))
const C = Descriptor("C", libgb.GrB_Descriptor(C_NULL))
const CT1 = Descriptor("CT1", libgb.GrB_Descriptor(C_NULL))
const CT0 = Descriptor("CT0", libgb.GrB_Descriptor(C_NULL))
const CT0T1 = Descriptor("CT0T1", libgb.GrB_Descriptor(C_NULL))
const S = Descriptor("S", libgb.GrB_Descriptor(C_NULL))
const ST1 = Descriptor("ST1", libgb.GrB_Descriptor(C_NULL))
const ST0 = Descriptor("ST0", libgb.GrB_Descriptor(C_NULL))
const ST0T1 = Descriptor("ST0T1", libgb.GrB_Descriptor(C_NULL))
const SC = Descriptor("SC", libgb.GrB_Descriptor(C_NULL))
const SCT1 = Descriptor("SCT1", libgb.GrB_Descriptor(C_NULL))
const SCT0 = Descriptor("SCT0", libgb.GrB_Descriptor(C_NULL))
const SCT0T1 = Descriptor("SCT0T1", libgb.GrB_Descriptor(C_NULL))
const R = Descriptor("R", libgb.GrB_Descriptor(C_NULL))
const RT1 = Descriptor("RT1", libgb.GrB_Descriptor(C_NULL))
const RT0 = Descriptor("RT0", libgb.GrB_Descriptor(C_NULL))
const RT0T1 = Descriptor("RT0T1", libgb.GrB_Descriptor(C_NULL))
const RC = Descriptor("RC", libgb.GrB_Descriptor(C_NULL))
const RCT1 = Descriptor("RCT1", libgb.GrB_Descriptor(C_NULL))
const RCT0 = Descriptor("RCT0", libgb.GrB_Descriptor(C_NULL))
const RCT0T1 = Descriptor("RCT0T1", libgb.GrB_Descriptor(C_NULL))
const RS = Descriptor("RS", libgb.GrB_Descriptor(C_NULL))
const RST1 = Descriptor("RST1", libgb.GrB_Descriptor(C_NULL))
const RST0 = Descriptor("RST0", libgb.GrB_Descriptor(C_NULL))
const RST0T1 = Descriptor("RST0T1", libgb.GrB_Descriptor(C_NULL))
const RSC = Descriptor("RSC", libgb.GrB_Descriptor(C_NULL))
const RSCT1 = Descriptor("RSCT1", libgb.GrB_Descriptor(C_NULL))
const RSCT0 = Descriptor("RSCT0", libgb.GrB_Descriptor(C_NULL))
const RSCT0T1 = Descriptor("RSCT0T1", libgb.GrB_Descriptor(C_NULL))
const DEFAULTDESC = Descriptor("DEFAULTDESC", libgb.GrB_Descriptor(C_NULL))

function Descriptor()
    return Descriptor("", libgb.GrB_Descriptor_new())
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
        return getfield(d, s)
    end
    return libgb.GxB_Descriptor_get(d, f)
end

function Base.setproperty!(d::Descriptor, s::Symbol, x)
    if s == :p
        setfield!(d, s, x)
        return nothing
    elseif s == :output
        f = libgb.GrB_OUTP
    elseif s == :mask
        f = libgb.GrB_MASK
    elseif s == :input1
        f = libgb.GrB_INP0
    elseif s == :input2
        f = libgb.GrB_INP1
    elseif s == :nthreads
        f = libgb.GxB_DESCRIPTOR_NTHREADS
    #elseif s == :chunk
        #f = libgb.GxB_DESCRIPTOR_CHUNK
    #elseif s == :axb_method
        #f = libgb.GxB_AxB_METHOD
    #elseif s == :sort
        #f = libgb.GxB_SORT
    else
        setfield!(d, s, x)
        return nothing
    end
    libgb.GrB_Descriptor_set(d, f, x)
end

function Base.:+(d1::Descriptor, d2::Descriptor)
    d = Descriptor()
    for f ∈ propertynames(d)
        if f == :input1
            if getproperty(d1, f) == TRANSPOSE && getproperty(d2, f) == TRANSPOSE
                setproperty!(d, f, DEFAULT)
            elseif getproperty(d1, f) == TRANSPOSE || getproperty(d2, f) == TRANSPOSE
                setproperty!(d, f, TRANSPOSE)
            end
        elseif f == :input2
            if getproperty(d1, f) == TRANSPOSE && getproperty(d2, f) == TRANSPOSE
                setproperty!(d, f, DEFAULT)
            elseif getproperty(d1, f) == TRANSPOSE || getproperty(d2, f) == TRANSPOSE
                setproperty!(d, f, TRANSPOSE)
            end
        else
            if getproperty(d1, f) != DEFAULT
                setproperty!(d, f, getproperty(d1, f))
            end
            if getproperty(d2, f) != DEFAULT
                setproperty!(d, f, getproperty(d2, f))
            end
        end
    end
    return d
end

Base.:+(d1::Descriptor, ::Nothing) = d1
Base.:+(::Nothing, d2::Descriptor) = d2
Base.:+(f1::libgb.GrB_Desc_Value, f2::libgb.GrB_Desc_Value) = libgb.GrB_Desc_Value(UInt32(f1) + UInt32(f2))
function Base.propertynames(::Descriptor)
    return (
    :output,
    :mask,
    :input1,
    :input2,
    :nthreads,
    #:chunk,
    #:axb_method,
    #:sort,
    )
end

function _loaddescriptors()
    T1.p = load_global("GrB_DESC_T1", libgb.GrB_Descriptor)
    T0.p = load_global("GrB_DESC_T0", libgb.GrB_Descriptor)
    T0T1.p = load_global("GrB_DESC_T0T1", libgb.GrB_Descriptor)
    C.p = load_global("GrB_DESC_C", libgb.GrB_Descriptor)
    CT1.p = load_global("GrB_DESC_CT1", libgb.GrB_Descriptor)
    CT0.p = load_global("GrB_DESC_CT0", libgb.GrB_Descriptor)
    CT0T1.p = load_global("GrB_DESC_CT0T1", libgb.GrB_Descriptor)
    S.p = load_global("GrB_DESC_S", libgb.GrB_Descriptor)
    ST1.p = load_global("GrB_DESC_ST1", libgb.GrB_Descriptor)
    ST0.p = load_global("GrB_DESC_ST0", libgb.GrB_Descriptor)
    ST0T1.p = load_global("GrB_DESC_ST0T1", libgb.GrB_Descriptor)
    SC.p = load_global("GrB_DESC_SC", libgb.GrB_Descriptor)
    SCT1.p = load_global("GrB_DESC_SCT1", libgb.GrB_Descriptor)
    SCT0.p = load_global("GrB_DESC_SCT0", libgb.GrB_Descriptor)
    SCT0T1.p = load_global("GrB_DESC_SCT0T1", libgb.GrB_Descriptor)
    R.p = load_global("GrB_DESC_R", libgb.GrB_Descriptor)
    RT1.p = load_global("GrB_DESC_RT1", libgb.GrB_Descriptor)
    RT0.p = load_global("GrB_DESC_RT0", libgb.GrB_Descriptor)
    RT0T1.p = load_global("GrB_DESC_RT0T1", libgb.GrB_Descriptor)
    RC.p = load_global("GrB_DESC_RC", libgb.GrB_Descriptor)
    RCT1.p = load_global("GrB_DESC_RCT1", libgb.GrB_Descriptor)
    RCT0.p = load_global("GrB_DESC_RCT0", libgb.GrB_Descriptor)
    RCT0T1.p = load_global("GrB_DESC_RCT0T1", libgb.GrB_Descriptor)
    RS.p = load_global("GrB_DESC_RS", libgb.GrB_Descriptor)
    RST1.p = load_global("GrB_DESC_RST1", libgb.GrB_Descriptor)
    RST0.p = load_global("GrB_DESC_RST0", libgb.GrB_Descriptor)
    RST0T1.p = load_global("GrB_DESC_RST0T1", libgb.GrB_Descriptor)
    RSC.p = load_global("GrB_DESC_RSC", libgb.GrB_Descriptor)
    RSCT1.p = load_global("GrB_DESC_RSCT1", libgb.GrB_Descriptor)
    RSCT0.p = load_global("GrB_DESC_RSCT0", libgb.GrB_Descriptor)
    RSCT0T1.p = load_global("GrB_DESC_RSCT0T1", libgb.GrB_Descriptor)
    DEFAULTDESC.p = libgb.GrB_Descriptor_new()
end

Base.show(io::IO, ::MIME"text/plain", d::Descriptor) = gxbprint(io, d)
Base.print(io::IO, d::Descriptor) = gxbprint(io, d)
