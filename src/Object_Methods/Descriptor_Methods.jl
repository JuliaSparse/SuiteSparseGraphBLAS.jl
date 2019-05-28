"""
    GrB_Descriptor_new(desc)

Create a new (empty or default) descriptor.
"""
function GrB_Descriptor_new(desc::GrB_Descriptor)
    desc_ptr = pointer_from_objref(desc)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Descriptor_new"),
                Cint,
                (Ptr{Cvoid}, ),
                desc_ptr
            )
        )
end

"""
    GrB_Descriptor_set(desc, field, val)

Set the content for a field for an existing descriptor.
"""
function GrB_Descriptor_set(desc::GrB_Descriptor, field::GrB_Desc_Field, val::GrB_Desc_Value)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Descriptor_set"),
                Cint,
                (Ptr{Cvoid}, Cint, Cint),
                desc.p, field, val
            )
        )
end
