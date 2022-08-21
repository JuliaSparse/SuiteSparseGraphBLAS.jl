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
    p::LibGraphBLAS.GrB_Descriptor
    function Descriptor(name, p::LibGraphBLAS.GrB_Descriptor)
        d = new(name, p)
        function f(descriptor)
            LibGraphBLAS.GrB_Descriptor_free(Ref(descriptor.p))
        end
        return finalizer(f, d)
    end
end

function Descriptor(;kwargs...)
    d = Ref{LibGraphBLAS.GrB_Descriptor}()
    @wraperror LibGraphBLAS.GrB_Descriptor_new(d)
    desc = Descriptor("", d[])
    for (s, x) in kwargs
        setproperty!(desc, s, x)
    end
    return desc
end

Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Descriptor}, d::Descriptor) = d.p

Base.:+(a::LibGraphBLAS.GrB_Desc_Value, b::LibGraphBLAS.GrB_Desc_Value) = 
    Integer(a) + Integer(b)

function Base.getproperty(d::Descriptor, s::Symbol)
    if s === :p
        return getfield(d, s)
    elseif s === :replace_output
        x = LibGraphBLAS.GxB_Desc_get(d, LibGraphBLAS.GrB_OUTP)
        if x == LibGraphBLAS.GrB_REPLACE
            return true
        else
            return false
        end
    elseif s === :complement_mask
        x = LibGraphBLAS.GxB_Desc_get(d, LibGraphBLAS.GrB_MASK)
        if x == LibGraphBLAS.GrB_COMP || x == (LibGraphBLAS.GrB_STRUCTURE + LibGraphBLAS.GrB_COMP)
            return true
        else
            return false
        end
    elseif s === :structural_mask
        x = LibGraphBLAS.GxB_Desc_get(d, LibGraphBLAS.GrB_MASK)
        if x == LibGraphBLAS.GrB_STRUCTURE || x == (LibGraphBLAS.GrB_STRUCTURE + LibGraphBLAS.GrB_COMP)
            return true
        else
            return false
        end
    elseif s === :transpose_input1
        x = LibGraphBLAS.GxB_Desc_get(d, LibGraphBLAS.GrB_INP0)
        if x == LibGraphBLAS.GrB_TRAN
            return true
        else
            return false
        end
    elseif s === :transpose_input2
        x = LibGraphBLAS.GxB_Desc_get(d, LibGraphBLAS.GrB_INP1)
        if x == LibGraphBLAS.GrB_TRAN
            return true
        else
            return false
        end
    elseif s === :nthreads
        return LibGraphBLAS.GxB_Desc_get(d, LibGraphBLAS.GxB_DESCRIPTOR_NTHREADS)
    elseif s === :chunk
        return LibGraphBLAS.GxB_Desc_get(d, LibGraphBLAS.GxB_DESCRIPTOR_CHUNK)
    elseif s === :sort
        if LibGraphBLAS.GxB_Desc_get(d, LibGraphBLAS.GxB_SORT) == LibGraphBLAS.GxB_DEFAULT
            return false
        else
            return true
        end
    elseif s === :axb_method
        x = LibGraphBLAS.GxB_Desc_get(d, LibGraphBLAS.GxB_AxB_METHOD)
        if x == LibGraphBLAS.GxB_AxB_GUSTAVSON
            return :gustavson
        elseif x == LibGraphBLAS.GxB_AxB_DOT
            return :dot
        elseif x == LibGraphBLAS.AxB_HASH
            return :hash
        elseif x == LibGraphBLAS.GxB_AxB_SAXPY
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
        x ? (y = LibGraphBLAS.GrB_REPLACE) : (y = LibGraphBLAS.GxB_DEFAULT)
        LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_OUTP, y)
    elseif s === :complement_mask
        if x == false
            if d.structural_mask
                LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_MASK, LibGraphBLAS.GrB_STRUCTURE)
            else
                LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_MASK, LibGraphBLAS.GxB_DEFAULT)
            end
        else
            if d.structural_mask
                LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_MASK, LibGraphBLAS.GrB_STRUCTURE + LibGraphBLAS.GrB_COMP)
            else
                LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_MASK, LibGraphBLAS.GrB_COMP)
            end
        end
    elseif s === :structural_mask
        if x == false
            if d.complement_mask
                LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_MASK, LibGraphBLAS.GrB_COMP)
            else
                LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_MASK, LibGraphBLAS.GxB_DEFAULT)
            end
        else
            LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_MASK, LibGraphBLAS.GrB_STRUCTURE)
        end
    elseif s === :transpose_input1
        LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_INP0, x ? LibGraphBLAS.GrB_TRAN : LibGraphBLAS.GxB_DEFAULT)
    elseif s === :transpose_input2
        LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GrB_INP1, x ? LibGraphBLAS.GrB_TRAN : LibGraphBLAS.GxB_DEFAULT)
    elseif s === :nthreads
        LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GxB_DESCRIPTOR_NTHREADS, x)
    elseif s === :chunk
        LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GxB_DESCRIPTOR_CHUNK, x)
    elseif s === :sort
        LibGraphBLAS.GxB_Desc_set(d, LibGraphBLAS.GxB_SORT, x ? 3 : 0)
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
