"""
    GrB_Descriptor(d::Dict{GrB_Desc_Field, GrB_Desc_Value})

Create a new GraphBLAS descriptor from a dictionary of descriptor field and value pairs.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> desc = GrB_Descriptor(Dict(GrB_INP0 => GrB_TRAN, GrB_OUTP => GrB_REPLACE))
GrB_Descriptor
```
"""
function GrB_Descriptor(d::Dict{GrB_Desc_Field, GrB_Desc_Value})
    desc = GrB_Descriptor()
    res = GrB_Descriptor_new(desc)
    if res != GrB_SUCCESS
        error(res)
    end
    for (field, value) in d
        res = GrB_Descriptor_set(desc, field, value)
        if res != GrB_SUCCESS
            error(res)
        end
    end
    return desc
end

"""
    setindex!(desc, val, field)

Set the value for a field of an existing descriptor

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> desc = GrB_Descriptor(Dict(GrB_INP0 => GrB_TRAN))
GrB_Descriptor

julia> desc[GrB_MASK] = GrB_SCMP;
```
"""
function setindex!(desc::GrB_Descriptor, val::GrB_Desc_Value, field::GrB_Desc_Field)
    res = GrB_Descriptor_set(desc, field, val)
    if res != GrB_SUCCESS
        error(res)
    end
end
