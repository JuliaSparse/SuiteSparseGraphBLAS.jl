function suffix(T::DataType)
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

function jl_type(T::GrB_Type)
    if T == GrB_BOOL
        return Bool
    elseif T == GrB_INT8
        return Int8
    elseif T == GrB_UINT8
        return UInt8
    elseif T == GrB_INT16
        return Int16
    elseif T == GrB_UINT16
        return UInt16
    elseif T == GrB_INT32
        return Int32
    elseif T == GrB_UINT32
        return UInt32
    elseif T == GrB_INT64
        return Int64
    elseif T == GrB_UINT64
        return UInt64
    elseif  T == GrB_FP32
        return Float32
    end
    return Float64
end

function _GrB_Index(x::T) where T <: GrB_Index
    x > typemax(Int64) && return x
    return Int64(x)
end
