import Printf.@printf

"""
    GrB_init(mode)

GrB_init must called before any other GraphBLAS operation.
GrB_init defines the mode that GraphBLAS will use: blocking or non-blocking.
With blocking mode, all operations finish before returning to the user application.
With non-blocking mode, operations can be left pending, and are computed only when needed.
"""
function GrB_init(mode::GrB_Mode)
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_init"), Cint, (Cint, ), mode))
end

"""
    GrB_wait()

GrB_wait forces all pending operations to complete.
Blocking mode is as if GrB_wait is called whenever a GraphBLAS method or operation returns to the user.
"""
function GrB_wait()
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_wait"), Cint, (), ))
end

"""
    GrB_finalize()

GrB_finalize must be called as the last GraphBLAS operation.
GrB_finalize does not call GrB_wait; any pending computations are abandoned.
"""
function GrB_finalize()
    return GrB_Info(ccall(dlsym(graphblas_lib, "GrB_finalize"), Cint, (), ))
end

"""
    GrB_error()

Each GraphBLAS method and operation returns a GrB_Info error code.
GrB_error returns additional information on the error.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_init(GrB_NONBLOCKING)
GrB_INVALID_VALUE::GrB_Info = 5

julia> GrB_error()
GraphBLAS error: GrB_INVALID_VALUE
function: GrB_init (mode)
GrB_init must not be called twice
```
"""
function GrB_error()
    @printf("%s", unsafe_string(ccall(dlsym(graphblas_lib, "GrB_error"), Cstring, (), )))
end
