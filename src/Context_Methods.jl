import GraphBLASInterface:
        GrB_init, GrB_finalize

"""
    GrB_init(mode)

`GrB_init` must called before any other GraphBLAS operation.
`GrB_init` defines the mode that GraphBLAS will use: blocking or non-blocking.
With blocking mode, all operations finish before returning to the user application.
With non-blocking mode, operations can be left pending, and are computed only when needed.
"""
function GrB_init(mode::GrB_Mode)
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_init"), Cint, (Cint, ), mode))
end

"""
    GrB_finalize()

`GrB_finalize` must be called as the last GraphBLAS operation.
`GrB_finalize` does not call `GrB_wait`; any pending computations are abandoned.
"""
function GrB_finalize()
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_finalize"), Cint, (), ))
end
