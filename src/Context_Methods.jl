import Printf.@printf

function GrB_init(mode::GrB_Mode)
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_init"), Cint, (Cint, ), Cint(mode)))
end

function GrB_wait()
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_wait"), Cint, (), ))
end

function GrB_finalize()
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_finalize"), Cint, (), ))
end

function GrB_error()
    @printf("%s", unsafe_string(ccall(dlsym(graphblas_lib, "GrB_error"), Cstring, (), )))
end