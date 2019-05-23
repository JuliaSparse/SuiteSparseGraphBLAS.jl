function get_suffix(T::DataType)
    if T == Bool
        return "BOOL" 
    elseif T == Int8
        return "INT8" 
    elseif T == UInt8
        return "UINT8" 
    elseif T == Int16
        return "INT16" 
    elseif T == UInt16
        return "UINT16" 
    elseif T == Int32
        return "INT32" 
    elseif T == UInt32
        return "UINT32" 
    elseif T == Int64
        return "INT64" 
    elseif T == UInt64
        return "UINT64" 
    elseif  T == Float32
        return "FP32"
    end
    return "FP64"
end

function get_suffix_and_type(T::GrB_Type)
    if T == GrB_BOOL
        return "BOOL", Bool
    elseif T == GrB_INT8
        return "INT8", Int8
    elseif T == GrB_UINT8
        return "UINT8", UInt8
    elseif T == GrB_INT16
        return "INT16", Int16
    elseif T == GrB_UINT16
        return "UINT16", UInt16
    elseif T == GrB_INT32
        return "INT32", Int32
    elseif T == GrB_UINT32
        return "UINT32", UInt32
    elseif T == GrB_INT64
        return "INT64", Int64
    elseif T == GrB_UINT64
        return "UINT64", UInt64
    elseif  T == GrB_FP32
        return "FP32", Float32
    end
    return "FP64", Float64
end

function GxB_Matrix_type(A::GrB_Matrix)
    type = GrB_Type()
    type_ptr = pointer_from_objref(type)
    result = GrB_Info(
            ccall(
                dlsym(graphblas_lib, "GxB_Matrix_type"),
                Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}),
                type_ptr, A.p
            )
        )
    return result, type
end
