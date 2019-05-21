module SuiteSparseGraphBLAS

import Libdl: dlopen_e, dlsym

const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("SuiteSparseGraphBLAS not installed properly, run Pkg.build(\"SuiteSparseGraphBLAS\"), restart Julia and try again")
end

include(depsjl_path)
include("Structures.jl")

types = ["BOOL", "INT8", "UINT8", "INT16", "UINT16", "INT32", "UINT32", 
         "INT64", "UINT64", "FP32", "FP64"]

GrB_Index = Union{Int64, UInt64}
valid_types = Union{Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64}

unary_operators = ["IDENTITY", "AINV", "MINV"]

binary_operators = ["EQ", "NE", "GT", "LT", "GE", "LE", "FIRST", "SECOND", "MIN", "MAX", 
                    "PLUS", "MINUS", "TIMES", "DIV"]

const GrB_LNOT = GrB_UnaryOp()
const GrB_LOR = GrB_BinaryOp(); const GrB_LAND = GrB_BinaryOp(); const GrB_LXOR = GrB_BinaryOp()
graphblas_lib = C_NULL

function __init__()
    check_deps()

    global libgraphblas

    global graphblas_lib = dlopen_e(libgraphblas)

    function load_global(str)
        x = dlsym(graphblas_lib, str)
        return unsafe_load(cglobal(x, Ptr{Cvoid}))
    end

    #load global types
    for t in types
        x = GrB_Type(load_global("GrB_"*t))
        @eval const $(Symbol(:GrB_, t)) = $x
    end

    #load global unary operators
    GrB_LNOT.p = load_global("GrB_LNOT")

    for op in unary_operators
        for t in types
            varname = "GrB_" * op * "_" * t
            @eval const $(Symbol(varname)) = $(GrB_UnaryOp(load_global(varname)))
        end
    end

    #load global binary operators
    GrB_LOR.p = load_global("GrB_LNOT")
    GrB_LAND.p = load_global("GrB_LAND")
    GrB_LXOR.p = load_global("GrB_LXOR")

    for op in binary_operators
        for t in types
            varname = "GrB_" * op * "_" * t
            @eval const $(Symbol(varname)) = $(GrB_BinaryOp(load_global(varname)))
        end
    end
end

include("Enums.jl")
include("Context_Methods.jl")
include("Object_Methods/Matrix_Methods.jl")
include("Object_Methods/Print_Objects.jl")

export
# Context Methods
GrB_init, GrB_wait, GrB_finalize, GrB_error,

# Matrix Methods
GrB_Matrix_new, GrB_Matrix_build,

# Print function
@GxB_Matrix_fprint

# Export global variables

# Types
for t in types
    @eval export $(Symbol("GrB_", t))
end

# Unary Operators
export GrB_LNOT
for op in unary_operators
    for t in types
        varname = "GrB_" * op * "_" * t
        @eval export $(Symbol(varname))
    end
end

# Binary Operators
export GrB_LOR, GrB_LAND, GrB_LXOR
for op in binary_operators
    for t in types
        varname = "GrB_" * op * "_" * t
        @eval export $(Symbol(varname))
    end
end

# Enums
for s in instances(GrB_Info)
    @eval export $(Symbol(s))
end

for s in instances(GrB_Mode)
    @eval export $(Symbol(s))
end

for s in instances(GxB_Print_Level)
    @eval export $(Symbol(s))
end

end #end of module
