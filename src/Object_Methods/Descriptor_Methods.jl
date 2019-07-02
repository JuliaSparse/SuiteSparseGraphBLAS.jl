import GraphBLASInterface:
        GrB_Descriptor_new, GrB_Descriptor_set

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
