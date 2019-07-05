import GraphBLASInterface:
        GrB_init, GrB_finalize

function GrB_init(mode::GrB_Mode)
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_init"), Cint, (Cint, ), mode))
end

function GrB_finalize()
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_finalize"), Cint, (), ))
end
