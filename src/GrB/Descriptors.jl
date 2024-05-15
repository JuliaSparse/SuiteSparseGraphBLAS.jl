function Descriptor(name="";kwargs...)
    d = Ref{LibGraphBLAS.GrB_Descriptor}()
    info = LibGraphBLAS.GrB_Descriptor_new(d)
    if info != LibGraphBLAS.GrB_SUCCESS
        @fallbackerror info
    end
    desc = Descriptor(name, d[])
    for (s, x) in kwargs
        set!(desc, s, x)
    end
    return desc
end

Base.unsafe_convert(::Core.Type{LibGraphBLAS.GrB_Descriptor}, d::Descriptor) = d.p

Base.:+(a::LibGraphBLAS.GrB_Desc_Value, b::LibGraphBLAS.GrB_Desc_Value) = 
    Integer(a) + Integer(b)

function Base.getproperty(d::Descriptor, s::Symbol)
    if s === :p || s === :name
        return getfield(d, s)
    end
    x = get!(d, s)
    if s === :replace_output
        return x == LibGraphBLAS.GrB_REPLACE
    elseif s === :complement_mask
        return x == Integer(LibGraphBLAS.GrB_COMP) || x == 
            (LibGraphBLAS.GrB_STRUCTURE + LibGraphBLAS.GrB_COMP)
    elseif s === :structural_mask
        return x == Integer(LibGraphBLAS.GrB_STRUCTURE) || x == 
            (LibGraphBLAS.GrB_STRUCTURE + LibGraphBLAS.GrB_COMP)
    elseif s === :transpose_input1 || s === :transpose_input2
        return x == LibGraphBLAS.GrB_TRAN
    elseif s === :sort
        return x
    end
end

function Base.setproperty!(d::Descriptor, s::Symbol, x)
    if s === :p
        setfield!(d, s, x)
        return nothing
    elseif s === :replace_output
        x ? (y = LibGraphBLAS.GrB_REPLACE) : (y = LibGraphBLAS.GxB_DEFAULT)
        set!(d, LibGraphBLAS.GrB_OUTP_FIELD, y)
    elseif s === :complement_mask
        if x == false
            if d.structural_mask
                set!(d, LibGraphBLAS.GrB_MASK_FIELD, LibGraphBLAS.GrB_STRUCTURE)
            else
                set!(d, LibGraphBLAS.GrB_MASK_FIELD, LibGraphBLAS.GrB_DEFAULT)
            end
        else
            if d.structural_mask
                set!(d, LibGraphBLAS.GrB_MASK_FIELD, LibGraphBLAS.GrB_STRUCTURE + LibGraphBLAS.GrB_COMP)
            else
                set!(d, LibGraphBLAS.GrB_MASK_FIELD, LibGraphBLAS.GrB_COMP)
            end
        end
    elseif s === :structural_mask
        if x == false
            if d.complement_mask
                set!(d, LibGraphBLAS.GrB_MASK_FIELD, LibGraphBLAS.GrB_COMP)
            else
                set!(d, LibGraphBLAS.GrB_MASK_FIELD, LibGraphBLAS.GrB_DEFAULT)
            end
        else
            set!(d, LibGraphBLAS.GrB_MASK_FIELD, LibGraphBLAS.GrB_STRUCTURE)
        end
    elseif s === :transpose_input1
        set!(d, LibGraphBLAS.GrB_INP0_FIELD, x ? LibGraphBLAS.GrB_TRAN : LibGraphBLAS.GrB_DEFAULT)
    elseif s === :transpose_input2
        set!(d, LibGraphBLAS.GrB_INP1_FIELD, x ? LibGraphBLAS.GrB_TRAN : LibGraphBLAS.GrB_DEFAULT)
    elseif s === :sort
        set!(d, LibGraphBLAS.GxB_SORT, x)
    end
end
function Base.propertynames(::Descriptor)
    return (
    :replace_output,
    :complement_mask,
    :structural_mask,
    :transpose_input1,
    :transpose_input2,
    :sort,
    )
end

function _handledescriptor(desc; out=nothing, in1 = nothing, in2 = nothing)
    in1 isa Transpose && (desc.transpose_input1 = true)
    in2 isa Transpose && (desc.transpose_input2 = true)
    return desc
end

function _handledescriptor(::Nothing; out=nothing, in1=nothing, in2=nothing)
    if in1 isa Transpose || in2 isa Transpose
        desc = Descriptor()
        return _handledescriptor(desc; out, in1, in2)
    else
        return C_NULL
    end
end

function GrB.nothrow_wait!(desc::Descriptor, mode) 
    return LibGraphBLAS.GrB_Descriptor_wait(desc, mode)
end
function GrB.wait!(desc::Descriptor, mode) 
    info = GrB.nothrow_wait!(op, mode)
    if info != LibGraphBLAS.GrB_SUCCESS
        # Technically pending OOB can throw here, but I don't see how on a Descriptor.
        GrB.@invalidvalue info mode
        GrB.@uninitializedobject info desc
        GrB.@fallbackerror info
    end
end

function GrB.GxB_fprint(x::Descriptor, name, level, file)
    info = LibGraphBLAS.GxB_Descriptor_fprint(x, name, level, file)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info x
        GrB.@fallbackerror info
    end
end
function Base.show(io::IO, ::MIME"text/plain", t::Descriptor)
    print(io, "GrB_Descriptor: ")
    gxbprint(io, t)
end
