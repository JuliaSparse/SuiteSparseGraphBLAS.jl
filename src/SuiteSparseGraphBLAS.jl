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
valid_int_types = Union{Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64}

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
include("Utils.jl")
include("Object_Methods/Matrix_Methods.jl")
include("Object_Methods/Vector_Methods.jl")
include("Object_Methods/Descriptor_Methods.jl")
include("Object_Methods/Print_Objects.jl")

export
# Context Methods
GrB_init, GrB_wait, GrB_finalize, GrB_error,

# Matrix Methods
GrB_Matrix_new, GrB_Matrix_build, GrB_Matrix_dup, GrB_Matrix_clear,
GrB_Matrix_nrows, GrB_Matrix_ncols, GrB_Matrix_nvals, GrB_Matrix_setElement,
GrB_Matrix_extractElement, GrB_Matrix_extractTuples,

# Vector Methods
GrB_Vector_new, GrB_Vector_build, GrB_Vector_dup, GrB_Vector_clear, GrB_Vector_size,
GrB_Vector_nvals, GrB_Vector_setElement, GrB_Vector_extractElement, GrB_Vector_extractTuples,

# Descriptor Methods
GrB_Descriptor_new, GrB_Descriptor_set,

# Print functions
@GxB_Matrix_fprint, @GxB_Vector_fprint, @GxB_Descriptor_fprint

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
export GrB_Info
for s in instances(GrB_Info)
    @eval export $(Symbol(s))
end

export GrB_Mode
for s in instances(GrB_Mode)
    @eval export $(Symbol(s))
end

export GxB_Print_Level
for s in instances(GxB_Print_Level)
    @eval export $(Symbol(s))
end

export GrB_Desc_Field
for s in instances(GrB_Desc_Field)
    @eval export $(Symbol(s))
end

export GrB_Desc_Value
for s in instances(GrB_Desc_Value)
    @eval export $(Symbol(s))
end
end #end of module
