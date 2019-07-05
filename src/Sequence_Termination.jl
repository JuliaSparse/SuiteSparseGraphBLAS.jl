import Printf.@printf
import GraphBLASInterface:
        GrB_wait, GrB_error

function GrB_error()
    @printf("%s", unsafe_string(ccall(dlsym(graphblas_lib, "GrB_error"), Cstring, (), )))
end

function GrB_wait()
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_wait"), Cint, (), ))
end
