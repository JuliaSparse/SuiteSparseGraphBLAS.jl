module SuiteSparseGraphBLAS

import Libdl: dlopen_e, dlsym

const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("SuiteSparseGraphBLAS not installed properly, run Pkg.build(\"SuiteSparseGraphBLAS\"), restart Julia and try again")
end

const types = ["BOOL", "INT8", "UINT8", "INT16", "UINT16", "INT32", "UINT32",
                "INT64", "UINT64", "FP32", "FP64"]

const GrB_Index = Union{Int64, UInt64}
const valid_types = Union{Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64}
const valid_int_types = Union{Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64}

built_in_unary_operators = ["IDENTITY", "AINV", "MINV"]

built_in_binary_operators = ["EQ", "NE", "GT", "LT", "GE", "LE", "FIRST", "SECOND", "MIN", "MAX",
                    "PLUS", "MINUS", "TIMES", "DIV"]

built_in_monoids = ["MIN", "MAX", "PLUS", "TIMES"]

built_in_semirings = [  "MIN_FIRST", "MAX_FIRST", "PLUS_FIRST", "TIMES_FIRST", "MIN_SECOND",
                        "MAX_SECOND", "PLUS_SECOND", "TIMES_SECOND", "MIN_MIN", "MAX_MIN",
                        "PLUS_MIN", "TIMES_MIN", "MIN_MAX", "MAX_MAX", "PLUS_MAX", "TIMES_MAX",
                        "MIN_PLUS", "MAX_PLUS", "PLUS_PLUS", "TIMES_PLUS", "MIN_MINUS",
                        "MAX_MINUS", "PLUS_MINUS", "TIMES_MINUS", "MIN_TIMES", "MAX_TIMES",
                        "PLUS_TIMES", "TIMES_TIMES", "MIN_DIV", "MAX_DIV", "PLUS_DIV",
                        "TIMES_DIV", "MIN_ISEQ", "MAX_ISEQ", "PLUS_ISEQ", "TIMES_ISEQ", "MIN_ISNE",
                        "MAX_ISNE", "PLUS_ISNE", "TIMES_ISNE", "MIN_ISGT", "MAX_ISGT", "PLUS_ISGT",
                        "TIMES_ISGT", "MIN_ISLT", "MAX_ISLT", "PLUS_ISLT", "TIMES_ISLT", "MIN_ISGE",
                        "MAX_ISGE", "PLUS_ISGE", "TIMES_ISGE", "MIN_ISLE", "MAX_ISLE", "PLUS_ISLE",
                        "TIMES_ISLE", "MIN_LOR", "MAX_LOR", "PLUS_LOR", "TIMES_LOR", "MIN_LAND", "MAX_LAND",
                        "PLUS_LAND", "TIMES_LAND", "MIN_LXOR", "MAX_LXOR", "PLUS_LXOR", "TIMES_LXOR",
                        "LOR_EQ", "LAND_EQ", "LXOR_EQ", "EQ_EQ", "LOR_NE", "LAND_NE", "LXOR_NE", "EQ_NE",
                        "LOR_GT", "LAND_GT", "LXOR_GT", "EQ_GT", "LOR_LT", "LAND_LT", "LXOR_LT", "EQ_LT",
                        "LOR_GE", "LAND_GE", "LXOR_GE", "EQ_GE", "LOR_LE", "LAND_LE", "LXOR_LE", "EQ_LE"
                    ]

built_in_boolean_semirings = [  "LOR_FIRST", "LAND_FIRST", "LXOR_FIRST", "EQ_FIRST",
                                "LOR_SECOND", "LAND_SECOND", "LXOR_SECOND", "EQ_SECOND",
                                "LOR_LOR", "LAND_LOR", "LXOR_LOR", "EQ_LOR",
                                "LOR_LAND", "LAND_LAND", "LXOR_LAND", "EQ_LAND",
                                "LOR_LXOR", "LAND_LXOR", "LXOR_LXOR", "EQ_LXOR",
                                "LOR_EQ", "LAND_EQ", "LXOR_EQ", "EQ_EQ",
                                "LOR_GT", "LAND_GT", "LXOR_GT", "EQ_GT",
                                "LOR_LT", "LAND_LT", "LXOR_LT", "EQ_LT",
                                "LOR_GE", "LAND_GE", "LXOR_GE", "EQ_GE",
                                "LOR_LE", "LAND_LE", "LXOR_LE", "EQ_LE"
                            ]

include(depsjl_path)
include("Structures.jl")
include("Utils.jl")

valid_matrix_mask_types = Union{GrB_Matrix, GrB_NULL_Type}
valid_vector_mask_types = Union{GrB_Vector, GrB_NULL_Type}
valid_accum_types = Union{GrB_BinaryOp, GrB_NULL_Type}
valid_desc_types = Union{GrB_Descriptor, GrB_NULL_Type}
valid_indices_types = Union{Vector{<:GrB_Index}, GrB_ALL_Type}

const GrB_NULL = GrB_NULL_Type(C_NULL)
const GrB_ALL = GrB_ALL_Type(C_NULL)

const GrB_LNOT = GrB_UnaryOp()
const GrB_LOR = GrB_BinaryOp(); const GrB_LAND = GrB_BinaryOp(); const GrB_LXOR = GrB_BinaryOp()
const GxB_LOR_BOOL_MONOID = GrB_Monoid(); const GxB_LAND_BOOL_MONOID = GrB_Monoid()
const GxB_LXOR_BOOL_MONOID = GrB_Monoid(); const GxB_EQ_BOOL_MONOID = GrB_Monoid()
const GxB_TRIL = GxB_SelectOp(); const GxB_TRIU = GxB_SelectOp(); const GxB_DIAG = GxB_SelectOp();
const GxB_OFFDIAG = GxB_SelectOp(); GxB_NONZERO = GxB_SelectOp()

graphblas_lib = C_NULL

function __init__()
    check_deps()

    global libgraphblas

    global graphblas_lib = dlopen_e(libgraphblas)

    function load_global(str)
        x = dlsym(graphblas_lib, str)
        return unsafe_load(cglobal(x, Ptr{Cvoid}))
    end

    GrB_ALL.p = load_global("GrB_ALL")

    #load global types
    for t in [Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32, Int64, UInt64, Float32, Float64]
        type_suffix = suffix(t)
        x = GrB_Type{t}(load_global("GrB_"*type_suffix))
        @eval const $(Symbol(:GrB_, type_suffix)) = $x
    end

    #load global unary operators
    GrB_LNOT.p = load_global("GrB_LNOT")

    for op in built_in_unary_operators
        for t in types
            varname = "GrB_" * op * "_" * t
            @eval const $(Symbol(varname)) = $(GrB_UnaryOp(load_global(varname)))
        end
    end

    #load global binary operators
    GrB_LOR.p = load_global("GrB_LOR")
    GrB_LAND.p = load_global("GrB_LAND")
    GrB_LXOR.p = load_global("GrB_LXOR")

    for op in built_in_binary_operators
        for t in types
            varname = "GrB_" * op * "_" * t
            @eval const $(Symbol(varname)) = $(GrB_BinaryOp(load_global(varname)))
        end
    end

    #load global monoids
    GxB_LOR_BOOL_MONOID.p = load_global("GxB_LOR_BOOL_MONOID")
    GxB_LAND_BOOL_MONOID.p = load_global("GxB_LAND_BOOL_MONOID")
    GxB_LXOR_BOOL_MONOID.p = load_global("GxB_LXOR_BOOL_MONOID")
    GxB_EQ_BOOL_MONOID.p = load_global("GxB_EQ_BOOL_MONOID")

    for m in built_in_monoids
        for t in types[2:end]
            varname = "GxB_" * m * "_" * t * "_MONOID"
            @eval const $(Symbol(varname)) = $(GrB_Monoid(load_global(varname)))
        end
    end

    #load global semirings
    for s in built_in_semirings
        for t in types[2:end]
            varname = "GxB_" * s * "_" * t
            @eval const $(Symbol(varname)) = $(GrB_Semiring(load_global(varname)))
        end
    end

    for bool_s in built_in_boolean_semirings
        varname = "GxB_" * bool_s * "_" * "BOOL"
        @eval const $(Symbol(varname)) = $(GrB_Semiring(load_global(varname)))
    end

    #load global select operators
    GxB_TRIL.p = load_global("GxB_TRIL")
    GxB_TRIU.p = load_global("GxB_TRIU")
    GxB_DIAG.p = load_global("GxB_DIAG")
    GxB_OFFDIAG.p = load_global("GxB_OFFDIAG")
    GxB_NONZERO.p = load_global("GxB_NONZERO")
end

include("Enums.jl")
include("Context_Methods.jl")
include("Object_Methods/Matrix_Methods.jl")
include("Object_Methods/Vector_Methods.jl")
include("Object_Methods/Algebra_Methods.jl")
include("Object_Methods/Descriptor_Methods.jl")
include("Object_Methods/Print_Objects.jl")
include("Object_Methods/Free_Objects.jl")
include("Operations/Multiplication.jl")
include("Operations/Element_wise_multiplication.jl")
include("Operations/Element_wise_addition.jl")
include("Operations/Extract.jl")
include("Operations/Apply.jl")
include("Operations/Assign.jl")
include("Operations/Reduce.jl")
include("Operations/Transpose.jl")
include("Operations/Select.jl")

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

# Algebra Methods
GrB_UnaryOp_new, GrB_BinaryOp_new, GrB_Monoid_new, GrB_Semiring_new, GxB_SelectOp_new,

# Free Methods
GrB_free, GrB_UnaryOp_free, GrB_BinaryOp_free, GrB_Monoid_free, GrB_Semiring_free,
GrB_Vector_free, GrB_Matrix_free, GrB_Descriptor_free,

# Print functions
@GxB_UnaryOp_fprint, @GxB_BinaryOp_fprint, @GxB_Monoid_fprint, @GxB_Semiring_fprint,
@GxB_Matrix_fprint, @GxB_Vector_fprint, @GxB_Descriptor_fprint, @GxB_fprint,

# GraphBLAS Operations

# Multiplication
GrB_mxm, GrB_vxm, GrB_mxv,

# Element wise multiplication
GrB_eWiseMult_Vector_Semiring, GrB_eWiseMult_Vector_Monoid, GrB_eWiseMult_Vector_BinaryOp,
GrB_eWiseMult_Matrix_Semiring, GrB_eWiseMult_Matrix_Monoid, GrB_eWiseMult_Matrix_BinaryOp,
GrB_eWiseMult,

# Element wise addition
GrB_eWiseAdd_Vector_Semiring, GrB_eWiseAdd_Vector_Monoid, GrB_eWiseAdd_Vector_BinaryOp,
GrB_eWiseAdd_Matrix_Semiring, GrB_eWiseAdd_Matrix_Monoid, GrB_eWiseAdd_Matrix_BinaryOp,
GrB_eWiseAdd,

# Extract
GrB_extract, GrB_Vector_extract, GrB_Matrix_extract, GrB_Col_extract,

# Apply
GrB_apply, GrB_Vector_apply, GrB_Matrix_apply,

# Assign
GrB_assign, GrB_Vector_assign, GrB_Matrix_assign, GrB_Col_assign, GrB_Row_assign,

# Reduce
GrB_reduce, GrB_Matrix_reduce_Monoid, GrB_Matrix_reduce_BinaryOp, GrB_Matrix_reduce,
GrB_Vector_reduce,

# Transpose
GrB_transpose,

# Select
GxB_Vector_select, GxB_Matrix_select, GxB_select

# Export global variables

# Types
for t in types
    @eval export $(Symbol("GrB_", t))
end

# Unary Operators
export GrB_LNOT
for op in built_in_unary_operators
    for t in types
        varname = "GrB_" * op * "_" * t
        @eval export $(Symbol(varname))
    end
end

# Binary Operators
export GrB_LOR, GrB_LAND, GrB_LXOR
for op in built_in_binary_operators
    for t in types
        varname = "GrB_" * op * "_" * t
        @eval export $(Symbol(varname))
    end
end

# Monoids
export GxB_LOR_BOOL_MONOID, GxB_LAND_BOOL_MONOID, GxB_LXOR_BOOL_MONOID, GxB_EQ_BOOL_MONOID
for m in built_in_monoids
    for t in types[2:end]
        varname = "GxB_" * m * "_" * t * "_MONOID"
        @eval export $(Symbol(varname))
    end
end

# Semirings
for s in built_in_semirings
    for t in types[2:end]
        varname = "GxB_" * s * "_" * t
        @eval export $(Symbol(varname))
    end
end

for bool_s in built_in_boolean_semirings
    varname = "GxB_" * bool_s * "_" * "BOOL"
    @eval export $(Symbol(varname))
end

# Select Operators
export GxB_TRIL, GxB_TRIU, GxB_OFFDIAG, GxB_DIAG, GxB_NONZERO

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

# GrB_NULL
export GrB_NULL

# GrB_ALL
export GrB_ALL

# GrB_Index
export GrB_Index

end #end of module
