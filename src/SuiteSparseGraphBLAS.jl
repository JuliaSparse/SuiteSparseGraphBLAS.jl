module SuiteSparseGraphBLAS

using Libdl

const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("SuiteSparseGraphBLAS not installed properly, run Pkg.build(\"SuiteSparseGraphBLAS\"), restart Julia and try again")
end

include(depsjl_path)
include("Structures.jl")

const types = ["BOOL", "INT8", "UINT8", "INT16", "UINT16",
                "INT32", "UINT32", "INT64", "UINT64", "FP32", "FP64"]

const GrB_LNOT = GrB_UnaryOp()
const GrB_LOR = GrB_BinaryOp(); const GrB_LAND = GrB_BinaryOp(); const GrB_LXOR = GrB_BinaryOp()

function __init__()
    check_deps()

    global libgraphblas
    hdl = dlopen(libgraphblas)

    function load_global(str)
        x = dlsym(hdl, str)
        return unsafe_load(cglobal(x, Ptr{Cvoid}))
    end

    #load global types
    for t in types
        x = GrB_Type(load_global("GrB_"*t))
        @eval const $(Symbol(:GrB_, t)) = $x
    end

    #load global unary operators
    GrB_LNOT.p = load_global("GrB_LNOT")

    for op in ["GrB_IDENTITY_", "GrB_AINV_", "GrB_MINV_"]
        for t in types
            @eval const $(Symbol(:($op), t)) = $(GrB_UnaryOp(load_global(op*t)))
        end
    end

    #load global binary operators
    GrB_LOR.p = load_global("GrB_LNOT")
    GrB_LAND.p = load_global("GrB_LAND")
    GrB_LXOR.p = load_global("GrB_LXOR")

    for op in ["GrB_EQ_", "GrB_NE_", "GrB_GT_", "GrB_LT_", "GrB_GE_", 
                "GrB_LE_", "GrB_FIRST_", "GrB_SECOND_", "GrB_MIN_", "GrB_MAX_", 
                "GrB_PLUS_", "GrB_MINUS_", "GrB_TIMES_", "GrB_DIV_"]
        for t in types
            @eval const $(Symbol(:($op), t)) = $(GrB_BinaryOp(load_global(op*t)))
        end
    end
end

export  
# Types
        
GrB_BOOL, GrB_INT8, GrB_UINT8, GrB_INT16, GrB_UINT16, GrB_INT32, 
GrB_UINT32, GrB_INT64, GrB_UINT64, GrB_FP32, GrB_FP64,

# Unary Operators

GrB_LNOT,
# GrB_IDENTITY_<type>
GrB_IDENTITY_BOOL, GrB_IDENTITY_INT8, GrB_IDENTITY_UINT8, GrB_IDENTITY_INT16, 
GrB_IDENTITY_UINT16, GrB_IDENTITY_INT32, GrB_IDENTITY_UINT32, GrB_IDENTITY_INT64, 
GrB_IDENTITY_UINT64, GrB_IDENTITY_FP32, GrB_IDENTITY_FP64, 
# GrB_AINV_<type>
GrB_AINV_BOOL, GrB_AINV_INT8, GrB_AINV_UINT8, GrB_AINV_INT16, GrB_AINV_UINT16, 
GrB_AINV_INT32, GrB_AINV_UINT32, GrB_AINV_INT64, GrB_AINV_UINT64, GrB_AINV_FP32, GrB_AINV_FP64, 
# GrB_MINV_<type>
GrB_MINV_BOOL, GrB_MINV_INT8, GrB_MINV_UINT8, GrB_MINV_INT16, GrB_MINV_UINT16, GrB_MINV_INT32, 
GrB_MINV_UINT32, GrB_MINV_INT64, GrB_MINV_UINT64, GrB_MINV_FP32, GrB_MINV_FP64, 

# Binary Operators

GrB_LOR,
GrB_LAND,
GrB_LXOR,
# GrB_EQ_<type>
GrB_EQ_BOOL, GrB_EQ_INT8, GrB_EQ_UINT8, GrB_EQ_INT16, GrB_EQ_UINT16, GrB_EQ_INT32, GrB_EQ_UINT32, 
GrB_EQ_INT64, GrB_EQ_UINT64, GrB_EQ_FP32, GrB_EQ_FP64, 
# GrB_NE_<type>
GrB_NE_BOOL, GrB_NE_INT8, GrB_NE_UINT8, GrB_NE_INT16, GrB_NE_UINT16, GrB_NE_INT32, GrB_NE_UINT32, 
GrB_NE_INT64, GrB_NE_UINT64, GrB_NE_FP32, GrB_NE_FP64, 
# GrB_GT_<type>
GrB_GT_BOOL, GrB_GT_INT8, GrB_GT_UINT8, GrB_GT_INT16, GrB_GT_UINT16, GrB_GT_INT32, GrB_GT_UINT32, 
GrB_GT_INT64, GrB_GT_UINT64, GrB_GT_FP32, GrB_GT_FP64, 
# GrB_LT_<type>
GrB_LT_BOOL, GrB_LT_INT8, GrB_LT_UINT8, GrB_LT_INT16, GrB_LT_UINT16, GrB_LT_INT32, GrB_LT_UINT32, 
GrB_LT_INT64, GrB_LT_UINT64, GrB_LT_FP32, GrB_LT_FP64, 
# GrB_GE_<type>
GrB_GE_BOOL, GrB_GE_INT8, GrB_GE_UINT8, GrB_GE_INT16, GrB_GE_UINT16, GrB_GE_INT32, GrB_GE_UINT32, 
GrB_GE_INT64, GrB_GE_UINT64, GrB_GE_FP32, GrB_GE_FP64, 
# GrB_LE_<type>
GrB_LE_BOOL, GrB_LE_INT8, GrB_LE_UINT8, GrB_LE_INT16, GrB_LE_UINT16, GrB_LE_INT32, GrB_LE_UINT32, 
GrB_LE_INT64, GrB_LE_UINT64, GrB_LE_FP32, GrB_LE_FP64, 
# GrB_FIRST_<type>
GrB_FIRST_BOOL, GrB_FIRST_INT8, GrB_FIRST_UINT8, GrB_FIRST_INT16, GrB_FIRST_UINT16, GrB_FIRST_INT32, 
GrB_FIRST_UINT32, GrB_FIRST_INT64, GrB_FIRST_UINT64, GrB_FIRST_FP32, GrB_FIRST_FP64, 
# GrB_SECOND_<type>
GrB_SECOND_BOOL, GrB_SECOND_INT8, GrB_SECOND_UINT8, GrB_SECOND_INT16, GrB_SECOND_UINT16, GrB_SECOND_INT32, 
GrB_SECOND_UINT32, GrB_SECOND_INT64, GrB_SECOND_UINT64, GrB_SECOND_FP32, GrB_SECOND_FP64, 
# GrB_MIN_<type>
GrB_MIN_BOOL, GrB_MIN_INT8, GrB_MIN_UINT8, GrB_MIN_INT16, GrB_MIN_UINT16, GrB_MIN_INT32, GrB_MIN_UINT32, 
GrB_MIN_INT64, GrB_MIN_UINT64, GrB_MIN_FP32, GrB_MIN_FP64, 
# GrB_MAX_<type>
GrB_MAX_BOOL, GrB_MAX_INT8, GrB_MAX_UINT8, GrB_MAX_INT16, GrB_MAX_UINT16, GrB_MAX_INT32, GrB_MAX_UINT32, 
GrB_MAX_INT64, GrB_MAX_UINT64, GrB_MAX_FP32, GrB_MAX_FP64, 
# GrB_PLUS_<type>
GrB_PLUS_BOOL, GrB_PLUS_INT8, GrB_PLUS_UINT8, GrB_PLUS_INT16, GrB_PLUS_UINT16, GrB_PLUS_INT32, 
GrB_PLUS_UINT32, GrB_PLUS_INT64, GrB_PLUS_UINT64, GrB_PLUS_FP32, GrB_PLUS_FP64, 
# GrB_MINUS_<type>
GrB_MINUS_BOOL, GrB_MINUS_INT8, GrB_MINUS_UINT8, GrB_MINUS_INT16, GrB_MINUS_UINT16, GrB_MINUS_INT32, 
GrB_MINUS_UINT32, GrB_MINUS_INT64, GrB_MINUS_UINT64, GrB_MINUS_FP32, GrB_MINUS_FP64, 
# GrB_TIMES_<type>
GrB_TIMES_BOOL, GrB_TIMES_INT8, GrB_TIMES_UINT8, GrB_TIMES_INT16, GrB_TIMES_UINT16, GrB_TIMES_INT32, 
GrB_TIMES_UINT32, GrB_TIMES_INT64, GrB_TIMES_UINT64, GrB_TIMES_FP32, GrB_TIMES_FP64, 
# GrB_DIV_<type>
GrB_DIV_BOOL, GrB_DIV_INT8, GrB_DIV_UINT8, GrB_DIV_INT16, GrB_DIV_UINT16, GrB_DIV_INT32, GrB_DIV_UINT32, 
GrB_DIV_INT64, GrB_DIV_UINT64, GrB_DIV_FP32, GrB_DIV_FP64

end
