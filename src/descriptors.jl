"""
   Descriptor

Context object which may be optionally passed to many SuiteSparse:GraphBLAS functions.

See the SuiteSparse:GraphBLAS User Guide or the SuiteSparseGraphBLAS.jl docs for more information.

# Options
- `nthreads::Int = Sys.CPU_THREADS ÷ 2`: Specify the maximum number of threads to be used by
a function, defaults to avoid hyperthreading, which is typically most performant.
- `replace_output`: Clear the output array before assignment.
- `structural_mask::Bool`: Utilize the structure of the mask argument, rather than its values.
- `complement_mask::Bool`: Values which are true in the complement of the mask will be kept.
"""
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

function Descriptor(;kwargs...)
    desc = Descriptor("", libgb.GrB_Descriptor_new())
    for (s, x) in kwargs
        setproperty!(desc, s, x)
    end
    return desc
end

Base.unsafe_convert(::Type{libgb.GrB_Descriptor}, d::Descriptor) = d.p

function Base.getproperty(d::Descriptor, s::Symbol)
    if s === :p
        return getfield(d, s)
    elseif s === :replace_output
        x = libgb.GxB_Desc_get(d, libgb.GrB_OUTP)
        if x == libgb.GrB_REPLACE
            return true
        else
            return false
        end
    elseif s === :complement_mask
        x = libgb.GxB_Desc_get(d, libgb.libgb.GrB_MASK)
        if x == libgb.GrB_COMP || x == libgb.GrB_STRUCT_COMP
            return true
        else
            return false
        end
    elseif s === :structural_mask
        x = libgb.GxB_Desc_get(d, libgb.GrB_MASK)
        if x == libgb.GrB_STRUCTURE || x == libgb.GrB_STRUCT_COMP
            return true
        else
            return false
        end
    elseif s === :transpose_input1
        x = libgb.GxB_Desc_get(d, libgb.GrB_INP0)
        if x == libgb.GrB_TRAN
            return true
        else
            return false
        end
    elseif s === :transpose_input2
        x = libgb.GxB_Desc_get(d, libgb.GrB_INP1)
        if x == libgb.GrB_TRAN
            return true
        else
            return false
        end
    elseif s === :nthreads
        return libgb.GxB_Desc_get(d, libgb.GxB_DESCRIPTOR_NTHREADS)
    elseif s === :chunk
        return libgb.GxB_Desc_get(d, libgb.GxB_DESCRIPTOR_CHUNK)
    elseif s === :sort
        if libgb.GxB_Desc_get(d, libgb.GxB_SORT) == libgb.GxB_DEFAULT
            return false
        else
            return true
        end
    elseif s === :axb_method
        x = libgb.GxB_Desc_get(d, libgb.GxB_AxB_METHOD)
        if x == libgb.GxB_AxB_GUSTAVSON
            return :gustavson
        elseif x == libgb.GxB_AxB_DOT
            return :dot
        elseif x == libgb.AxB_HASH
            return :hash
        elseif x == libgb.GxB_AxB_SAXPY
            return :saxpy
        else
            return :default
        end
    else
        return getfield(d, s)
    end
end

function Base.setproperty!(d::Descriptor, s::Symbol, x)
    if s === :p
        setfield!(d, s, x)
        return nothing
    elseif s === :replace_output
        x ? (y = libgb.GrB_REPLACE) : (y = libgb.GxB_DEFAULT)
        libgb.GxB_Desc_set(d, libgb.GrB_OUTP, y)
    elseif s === :complement_mask
        if x == false
            if d.structural_mask
                libgb.GxB_Desc_set(d, libgb.GrB_MASK, libgb.GrB_STRUCTURE)
            else
                libgb.GxB_Desc_set(d, libgb.GrB_MASK, libgb.GxB_DEFAULT)
            end
        else
            libgb.GxB_Desc_set(d, libgb.GrB_MASK, libgb.GrB_COMP)
        end
    elseif s === :structural_mask
        if x == false
            if d.complement_mask
                libgb.GxB_Desc_set(d, libgb.GrB_MASK, libgb.GrB_COMP)
            else
                libgb.GxB_Desc_set(d, libgb.GrB_MASK, libgb.GxB_DEFAULT)
            end
        else
            libgb.GxB_Desc_set(d, libgb.GrB_MASK, libgb.GrB_STRUCTURE)
        end
    elseif s === :transpose_input1
        libgb.GxB_Desc_set(d, libgb.GrB_INP0, x ? libgb.GrB_TRAN : libgb.GxB_DEFAULT)
    elseif s === :transpose_input2
        libgb.GxB_Desc_set(d, libgb.GrB_INP1, x ? libgb.GrB_TRAN : libgb.GxB_DEFAULT)
    elseif s === :nthreads
        libgb.GxB_Desc_set(d, libgb.GxB_DESCRIPTOR_NTHREADS, x)
    elseif s === :chunk
        libgb.GxB_Desc_set(d, libgb.GxB_DESCRIPTOR_CHUNK, x)
    elseif s === :sort
        libgb.GxB_Desc_set(d, libgb.GxB_SORT, x ? 3 : 0)
    end
end
function Base.propertynames(::Descriptor)
    return (
    :replace_output,
    :complement_mask,
    :structural_mask,
    :transpose_input1,
    :transpose_input2,
    :nthreads,
    :chunk,
    :sort,
    )
end

Base.show(io::IO, ::MIME"text/plain", d::Descriptor) = gxbprint(io, d)
Base.print(io::IO, d::Descriptor) = gxbprint(io, d)

function _handledescriptor(desc; out=nothing, in1 = nothing, in2 = nothing)
    if out === nothing && in1 === nothing && in2 === nothing
        if !(desc isa Descriptor)
            return C_NULL
        else
            return desc
        end
    end
    if desc == C_NULL || desc === nothing
        desc = Descriptor()
    end
    in1 isa Transpose && (desc.transpose_input1 = true)
    in2 isa Transpose && (desc.transpose_input2 = true)
    return desc
end
