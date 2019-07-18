module SuiteSparseGraphBLAS

import Libdl: dlopen_e, dlsym
using GraphBLASInterface

const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("SuiteSparseGraphBLAS not installed properly, run Pkg.build(\"SuiteSparseGraphBLAS\"), restart Julia and try again")
end

include(depsjl_path)
include("Structures.jl")
include("Global_Variables.jl")
include("Utils.jl")

const valid_matrix_mask_types = Union{GrB_Matrix, GrB_NULL_Type}
const valid_vector_mask_types = Union{GrB_Vector, GrB_NULL_Type}
const valid_accum_types = Union{GrB_BinaryOp, GrB_NULL_Type}
const valid_desc_types = Union{GrB_Descriptor, GrB_NULL_Type}

graphblas_lib = C_NULL

function __init__()
    check_deps()

    global libgraphblas

    global graphblas_lib = dlopen_e(libgraphblas)

    function load_global(str)
        x = dlsym(graphblas_lib, str)
        return unsafe_load(cglobal(x, Ptr{Cvoid}))
    end

    # load global variables
    for i = 1:length(global_variables)
        global_variables[i].p = load_global(global_variable_names[i])
    end
end

include("Enums.jl")
include("Context_Methods.jl")
include("Sequence_Termination.jl")
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

# Higher-level interface
include("Interface/Interface.jl")
using .Interface
export findnz, nnz, LowerTriangular, UpperTriangular, Diagonal, dropzeros!

# Extensions to the spec
export
# Print macros
@GxB_UnaryOp_fprint, @GxB_BinaryOp_fprint, @GxB_Monoid_fprint, @GxB_Semiring_fprint,
@GxB_Matrix_fprint, @GxB_Vector_fprint, @GxB_Descriptor_fprint, @GxB_fprint,
# Select Operations
GxB_Vector_select, GxB_Matrix_select, GxB_select,
# Print-level enum
GxB_Print_Level
for s in instances(GxB_Print_Level)
    @eval export $(Symbol(s))
end

#########################################################################
#                                                                       #
#                           GLOBAL VARIABLES                            #
#                                                                       #
#########################################################################
export
#########################################################################
#                       GraphBLAS types                                 #
#########################################################################

GrB_BOOL,
GrB_INT8,
GrB_UINT8,
GrB_INT16,
GrB_UINT16,
GrB_INT32,
GrB_UINT32,
GrB_INT64,
GrB_UINT64,
GrB_FP32,
GrB_FP64,

#########################################################################
#                    Built-in unary operators                           #
#########################################################################

# z and x have the same type. The suffix in the name is the type of x and z.

# z = x               z = -x             z = 1/x
# identity            additive           multiplicative
#                     inverse            inverse
GrB_IDENTITY_BOOL,    GrB_AINV_BOOL,     GrB_MINV_BOOL,
GrB_IDENTITY_INT8,    GrB_AINV_INT8,     GrB_MINV_INT8,
GrB_IDENTITY_UINT8,   GrB_AINV_UINT8,    GrB_MINV_UINT8,
GrB_IDENTITY_INT16,   GrB_AINV_INT16,    GrB_MINV_INT16,
GrB_IDENTITY_UINT16,  GrB_AINV_UINT16,   GrB_MINV_UINT16,
GrB_IDENTITY_INT32,   GrB_AINV_INT32,    GrB_MINV_INT32,
GrB_IDENTITY_UINT32,  GrB_AINV_UINT32,   GrB_MINV_UINT32,
GrB_IDENTITY_INT64,   GrB_AINV_INT64,    GrB_MINV_INT64,
GrB_IDENTITY_UINT64,  GrB_AINV_UINT64,   GrB_MINV_UINT64,
GrB_IDENTITY_FP32,    GrB_AINV_FP32,     GrB_MINV_FP32,
GrB_IDENTITY_FP64,    GrB_AINV_FP64,     GrB_MINV_FP64,

# z = !x, where both z and x are boolean.
# There is no suffix since z and x are only boolean.
GrB_LNOT,

#########################################################################
#                    Built-in binary operators                          #
#########################################################################

# x,y,z all have the same type :

# z = x             z = y               z = min(x,y)        z = max (x,y)
GrB_FIRST_BOOL,     GrB_SECOND_BOOL,    GrB_MIN_BOOL,       GrB_MAX_BOOL,
GrB_FIRST_INT8,     GrB_SECOND_INT8,    GrB_MIN_INT8,       GrB_MAX_INT8,
GrB_FIRST_UINT8,    GrB_SECOND_UINT8,   GrB_MIN_UINT8,      GrB_MAX_UINT8,
GrB_FIRST_INT16,    GrB_SECOND_INT16,   GrB_MIN_INT16,      GrB_MAX_INT16,
GrB_FIRST_UINT16,   GrB_SECOND_UINT16,  GrB_MIN_UINT16,     GrB_MAX_UINT16,
GrB_FIRST_INT32,    GrB_SECOND_INT32,   GrB_MIN_INT32,      GrB_MAX_INT32,
GrB_FIRST_UINT32,   GrB_SECOND_UINT32,  GrB_MIN_UINT32,     GrB_MAX_UINT32,
GrB_FIRST_INT64,    GrB_SECOND_INT64,   GrB_MIN_INT64,      GrB_MAX_INT64,
GrB_FIRST_UINT64,   GrB_SECOND_UINT64,  GrB_MIN_UINT64,     GrB_MAX_UINT64,
GrB_FIRST_FP32,     GrB_SECOND_FP32,    GrB_MIN_FP32,       GrB_MAX_FP32,
GrB_FIRST_FP64,     GrB_SECOND_FP64,    GrB_MIN_FP64,       GrB_MAX_FP64,

# z = x+y           z = x-y             z = x*y             z = x/y
GrB_PLUS_BOOL,      GrB_MINUS_BOOL,     GrB_TIMES_BOOL,     GrB_DIV_BOOL,
GrB_PLUS_INT8,      GrB_MINUS_INT8,     GrB_TIMES_INT8,     GrB_DIV_INT8,
GrB_PLUS_UINT8,     GrB_MINUS_UINT8,    GrB_TIMES_UINT8,    GrB_DIV_UINT8,
GrB_PLUS_INT16,     GrB_MINUS_INT16,    GrB_TIMES_INT16,    GrB_DIV_INT16,
GrB_PLUS_UINT16,    GrB_MINUS_UINT16,   GrB_TIMES_UINT16,   GrB_DIV_UINT16,
GrB_PLUS_INT32,     GrB_MINUS_INT32,    GrB_TIMES_INT32,    GrB_DIV_INT32,
GrB_PLUS_UINT32,    GrB_MINUS_UINT32,   GrB_TIMES_UINT32,   GrB_DIV_UINT32,
GrB_PLUS_INT64,     GrB_MINUS_INT64,    GrB_TIMES_INT64,    GrB_DIV_INT64,
GrB_PLUS_UINT64,    GrB_MINUS_UINT64,   GrB_TIMES_UINT64,   GrB_DIV_UINT64,
GrB_PLUS_FP32,      GrB_MINUS_FP32,     GrB_TIMES_FP32,     GrB_DIV_FP32,
GrB_PLUS_FP64,      GrB_MINUS_FP64,     GrB_TIMES_FP64,     GrB_DIV_FP64,

# z is always boolean & x,y have the same type :

# z = (x == y)      z = (x != y)        z = (x > y)         z = (x < y)
GrB_EQ_BOOL,        GrB_NE_BOOL,        GrB_GT_BOOL,        GrB_LT_BOOL,
GrB_EQ_INT8,        GrB_NE_INT8,        GrB_GT_INT8,        GrB_LT_INT8,
GrB_EQ_UINT8,       GrB_NE_UINT8,       GrB_GT_UINT8,       GrB_LT_UINT8,
GrB_EQ_INT16,       GrB_NE_INT16,       GrB_GT_INT16,       GrB_LT_INT16,
GrB_EQ_UINT16,      GrB_NE_UINT16,      GrB_GT_UINT16,      GrB_LT_UINT16,
GrB_EQ_INT32,       GrB_NE_INT32,       GrB_GT_INT32,       GrB_LT_INT32,
GrB_EQ_UINT32,      GrB_NE_UINT32,      GrB_GT_UINT32,      GrB_LT_UINT32,
GrB_EQ_INT64,       GrB_NE_INT64,       GrB_GT_INT64,       GrB_LT_INT64,
GrB_EQ_UINT64,      GrB_NE_UINT64,      GrB_GT_UINT64,      GrB_LT_UINT64,
GrB_EQ_FP32,        GrB_NE_FP32,        GrB_GT_FP32,        GrB_LT_FP32,
GrB_EQ_FP64,        GrB_NE_FP64,        GrB_GT_FP64,        GrB_LT_FP64,

# z = (x >= y)      z = (x <= y)
GrB_GE_BOOL,        GrB_LE_BOOL,
GrB_GE_INT8,        GrB_LE_INT8,
GrB_GE_UINT8,       GrB_LE_UINT8,
GrB_GE_INT16,       GrB_LE_INT16,
GrB_GE_UINT16,      GrB_LE_UINT16,
GrB_GE_INT32,       GrB_LE_INT32,
GrB_GE_UINT32,      GrB_LE_UINT32,
GrB_GE_INT64,       GrB_LE_INT64,
GrB_GE_UINT64,      GrB_LE_UINT64,
GrB_GE_FP32,        GrB_LE_FP32,
GrB_GE_FP64,        GrB_LE_FP64,

# x,y,z all are boolean :

# z = (x || y)      z = (x && y)        z = (x != y)
GrB_LOR,            GrB_LAND,           GrB_LXOR,

#########################################################################
#                   Built-in monoids (extension)                        #
#########################################################################

# MIN monoids:                    Identity

GxB_MIN_INT8_MONOID,            # INT8_MAX
GxB_MIN_UINT8_MONOID,           # UINT8_MAX
GxB_MIN_INT16_MONOID,           # INT16_MAX
GxB_MIN_UINT16_MONOID,          # UINT16_MAX
GxB_MIN_INT32_MONOID,           # INT32_MAX
GxB_MIN_UINT32_MONOID,          # UINT32_MAX
GxB_MIN_INT64_MONOID,           # INT64_MAX
GxB_MIN_UINT64_MONOID,          # UINT64_MAX
GxB_MIN_FP32_MONOID,            # INFINITY
GxB_MIN_FP64_MONOID,            # INFINITY

# MAX monoids:

GxB_MAX_INT8_MONOID,            # INT8_MIN
GxB_MAX_UINT8_MONOID,           # 0
GxB_MAX_INT16_MONOID,           # INT16_MIN
GxB_MAX_UINT16_MONOID,          # 0
GxB_MAX_INT32_MONOID,           # INT32_MIN
GxB_MAX_UINT32_MONOID,          # 0
GxB_MAX_INT64_MONOID,           # INT64_MIN
GxB_MAX_UINT64_MONOID,          # 0
GxB_MAX_FP32_MONOID,            # -INFINITY
GxB_MAX_FP64_MONOID,            # -INFINITY

# PLUS monoids:

GxB_PLUS_INT8_MONOID,           # 0
GxB_PLUS_UINT8_MONOID,          # 0
GxB_PLUS_INT16_MONOID,          # 0
GxB_PLUS_UINT16_MONOID,         # 0
GxB_PLUS_INT32_MONOID,          # 0
GxB_PLUS_UINT32_MONOID,         # 0
GxB_PLUS_INT64_MONOID,          # 0
GxB_PLUS_UINT64_MONOID,         # 0
GxB_PLUS_FP32_MONOID,           # 0
GxB_PLUS_FP64_MONOID,           # 0

# TIMES monoids:

GxB_TIMES_INT8_MONOID,          # 1
GxB_TIMES_UINT8_MONOID,         # 1
GxB_TIMES_INT16_MONOID,         # 1
GxB_TIMES_UINT16_MONOID,        # 1
GxB_TIMES_INT32_MONOID,         # 1
GxB_TIMES_UINT32_MONOID,        # 1
GxB_TIMES_INT64_MONOID,         # 1
GxB_TIMES_UINT64_MONOID,        # 1
GxB_TIMES_FP32_MONOID,          # 1
GxB_TIMES_FP64_MONOID,          # 1

# Boolean monoids:

GxB_LOR_BOOL_MONOID,            # false
GxB_LAND_BOOL_MONOID,           # true
GxB_LXOR_BOOL_MONOID,           # false
GxB_EQ_BOOL_MONOID,             # true

#########################################################################
#                   Built-in semirings (extension)                      #
#########################################################################

# Semirings with multiply op: z = FIRST (x,y), all types x,y,z the same:

GxB_MIN_FIRST_INT8,      GxB_MAX_FIRST_INT8,     GxB_PLUS_FIRST_INT8,    GxB_TIMES_FIRST_INT8,
GxB_MIN_FIRST_UINT8,     GxB_MAX_FIRST_UINT8,    GxB_PLUS_FIRST_UINT8,   GxB_TIMES_FIRST_UINT8,
GxB_MIN_FIRST_INT16,     GxB_MAX_FIRST_INT16,    GxB_PLUS_FIRST_INT16,   GxB_TIMES_FIRST_INT16,
GxB_MIN_FIRST_UINT16,    GxB_MAX_FIRST_UINT16,   GxB_PLUS_FIRST_UINT16,  GxB_TIMES_FIRST_UINT16,
GxB_MIN_FIRST_INT32,     GxB_MAX_FIRST_INT32,    GxB_PLUS_FIRST_INT32,   GxB_TIMES_FIRST_INT32,
GxB_MIN_FIRST_UINT32,    GxB_MAX_FIRST_UINT32,   GxB_PLUS_FIRST_UINT32,  GxB_TIMES_FIRST_UINT32,
GxB_MIN_FIRST_INT64,     GxB_MAX_FIRST_INT64,    GxB_PLUS_FIRST_INT64,   GxB_TIMES_FIRST_INT64,
GxB_MIN_FIRST_UINT64,    GxB_MAX_FIRST_UINT64,   GxB_PLUS_FIRST_UINT64,  GxB_TIMES_FIRST_UINT64,
GxB_MIN_FIRST_FP32,      GxB_MAX_FIRST_FP32,     GxB_PLUS_FIRST_FP32,    GxB_TIMES_FIRST_FP32,
GxB_MIN_FIRST_FP64,      GxB_MAX_FIRST_FP64,     GxB_PLUS_FIRST_FP64,    GxB_TIMES_FIRST_FP64,

# Semirings with multiply op: z = SECOND (x,y), all types x,y,z the same:

GxB_MIN_SECOND_INT8,     GxB_MAX_SECOND_INT8,    GxB_PLUS_SECOND_INT8,   GxB_TIMES_SECOND_INT8,
GxB_MIN_SECOND_UINT8,    GxB_MAX_SECOND_UINT8,   GxB_PLUS_SECOND_UINT8,  GxB_TIMES_SECOND_UINT8,
GxB_MIN_SECOND_INT16,    GxB_MAX_SECOND_INT16,   GxB_PLUS_SECOND_INT16,  GxB_TIMES_SECOND_INT16,
GxB_MIN_SECOND_UINT16,   GxB_MAX_SECOND_UINT16,  GxB_PLUS_SECOND_UINT16, GxB_TIMES_SECOND_UINT16,
GxB_MIN_SECOND_INT32,    GxB_MAX_SECOND_INT32,   GxB_PLUS_SECOND_INT32,  GxB_TIMES_SECOND_INT32,
GxB_MIN_SECOND_UINT32,   GxB_MAX_SECOND_UINT32,  GxB_PLUS_SECOND_UINT32, GxB_TIMES_SECOND_UINT32,
GxB_MIN_SECOND_INT64,    GxB_MAX_SECOND_INT64,   GxB_PLUS_SECOND_INT64,  GxB_TIMES_SECOND_INT64,
GxB_MIN_SECOND_UINT64,   GxB_MAX_SECOND_UINT64,  GxB_PLUS_SECOND_UINT64, GxB_TIMES_SECOND_UINT64,
GxB_MIN_SECOND_FP32,     GxB_MAX_SECOND_FP32,    GxB_PLUS_SECOND_FP32,   GxB_TIMES_SECOND_FP32,
GxB_MIN_SECOND_FP64,     GxB_MAX_SECOND_FP64,    GxB_PLUS_SECOND_FP64,   GxB_TIMES_SECOND_FP64,

# Semirings with multiply op: z = MIN (x,y), all types x,y,z the same:

GxB_MIN_MIN_INT8,        GxB_MAX_MIN_INT8,       GxB_PLUS_MIN_INT8,      GxB_TIMES_MIN_INT8,
GxB_MIN_MIN_UINT8,       GxB_MAX_MIN_UINT8,      GxB_PLUS_MIN_UINT8,     GxB_TIMES_MIN_UINT8,
GxB_MIN_MIN_INT16,       GxB_MAX_MIN_INT16,      GxB_PLUS_MIN_INT16,     GxB_TIMES_MIN_INT16,
GxB_MIN_MIN_UINT16,      GxB_MAX_MIN_UINT16,     GxB_PLUS_MIN_UINT16,    GxB_TIMES_MIN_UINT16,
GxB_MIN_MIN_INT32,       GxB_MAX_MIN_INT32,      GxB_PLUS_MIN_INT32,     GxB_TIMES_MIN_INT32,
GxB_MIN_MIN_UINT32,      GxB_MAX_MIN_UINT32,     GxB_PLUS_MIN_UINT32,    GxB_TIMES_MIN_UINT32,
GxB_MIN_MIN_INT64,       GxB_MAX_MIN_INT64,      GxB_PLUS_MIN_INT64,     GxB_TIMES_MIN_INT64,
GxB_MIN_MIN_UINT64,      GxB_MAX_MIN_UINT64,     GxB_PLUS_MIN_UINT64,    GxB_TIMES_MIN_UINT64,
GxB_MIN_MIN_FP32,        GxB_MAX_MIN_FP32,       GxB_PLUS_MIN_FP32,      GxB_TIMES_MIN_FP32,
GxB_MIN_MIN_FP64,        GxB_MAX_MIN_FP64,       GxB_PLUS_MIN_FP64,      GxB_TIMES_MIN_FP64,

# Semirings with multiply op: z = MAX (x,y), all types x,y,z the same:

GxB_MIN_MAX_INT8,        GxB_MAX_MAX_INT8,       GxB_PLUS_MAX_INT8,      GxB_TIMES_MAX_INT8,
GxB_MIN_MAX_UINT8,       GxB_MAX_MAX_UINT8,      GxB_PLUS_MAX_UINT8,     GxB_TIMES_MAX_UINT8,
GxB_MIN_MAX_INT16,       GxB_MAX_MAX_INT16,      GxB_PLUS_MAX_INT16,     GxB_TIMES_MAX_INT16,
GxB_MIN_MAX_UINT16,      GxB_MAX_MAX_UINT16,     GxB_PLUS_MAX_UINT16,    GxB_TIMES_MAX_UINT16,
GxB_MIN_MAX_INT32,       GxB_MAX_MAX_INT32,      GxB_PLUS_MAX_INT32,     GxB_TIMES_MAX_INT32,
GxB_MIN_MAX_UINT32,      GxB_MAX_MAX_UINT32,     GxB_PLUS_MAX_UINT32,    GxB_TIMES_MAX_UINT32,
GxB_MIN_MAX_INT64,       GxB_MAX_MAX_INT64,      GxB_PLUS_MAX_INT64,     GxB_TIMES_MAX_INT64,
GxB_MIN_MAX_UINT64,      GxB_MAX_MAX_UINT64,     GxB_PLUS_MAX_UINT64,    GxB_TIMES_MAX_UINT64,
GxB_MIN_MAX_FP32,        GxB_MAX_MAX_FP32,       GxB_PLUS_MAX_FP32,      GxB_TIMES_MAX_FP32,
GxB_MIN_MAX_FP64,        GxB_MAX_MAX_FP64,       GxB_PLUS_MAX_FP64,      GxB_TIMES_MAX_FP64,

# Semirings with multiply op: z = PLUS (x,y), all types x,y,z the same:

GxB_MIN_PLUS_INT8,       GxB_MAX_PLUS_INT8,      GxB_PLUS_PLUS_INT8,     GxB_TIMES_PLUS_INT8,
GxB_MIN_PLUS_UINT8,      GxB_MAX_PLUS_UINT8,     GxB_PLUS_PLUS_UINT8,    GxB_TIMES_PLUS_UINT8,
GxB_MIN_PLUS_INT16,      GxB_MAX_PLUS_INT16,     GxB_PLUS_PLUS_INT16,    GxB_TIMES_PLUS_INT16,
GxB_MIN_PLUS_UINT16,     GxB_MAX_PLUS_UINT16,    GxB_PLUS_PLUS_UINT16,   GxB_TIMES_PLUS_UINT16,
GxB_MIN_PLUS_INT32,      GxB_MAX_PLUS_INT32,     GxB_PLUS_PLUS_INT32,    GxB_TIMES_PLUS_INT32,
GxB_MIN_PLUS_UINT32,     GxB_MAX_PLUS_UINT32,    GxB_PLUS_PLUS_UINT32,   GxB_TIMES_PLUS_UINT32,
GxB_MIN_PLUS_INT64,      GxB_MAX_PLUS_INT64,     GxB_PLUS_PLUS_INT64,    GxB_TIMES_PLUS_INT64,
GxB_MIN_PLUS_UINT64,     GxB_MAX_PLUS_UINT64,    GxB_PLUS_PLUS_UINT64,   GxB_TIMES_PLUS_UINT64,
GxB_MIN_PLUS_FP32,       GxB_MAX_PLUS_FP32,      GxB_PLUS_PLUS_FP32,     GxB_TIMES_PLUS_FP32,
GxB_MIN_PLUS_FP64,       GxB_MAX_PLUS_FP64,      GxB_PLUS_PLUS_FP64,     GxB_TIMES_PLUS_FP64,

# Semirings with multiply op: z = MINUS (x,y), all types x,y,z the same:

GxB_MIN_MINUS_INT8,     GxB_MAX_MINUS_INT8,     GxB_PLUS_MINUS_INT8,    GxB_TIMES_MINUS_INT8,
GxB_MIN_MINUS_UINT8,    GxB_MAX_MINUS_UINT8,    GxB_PLUS_MINUS_UINT8,   GxB_TIMES_MINUS_UINT8,
GxB_MIN_MINUS_INT16,    GxB_MAX_MINUS_INT16,    GxB_PLUS_MINUS_INT16,   GxB_TIMES_MINUS_INT16,
GxB_MIN_MINUS_UINT16,   GxB_MAX_MINUS_UINT16,   GxB_PLUS_MINUS_UINT16,  GxB_TIMES_MINUS_UINT16,
GxB_MIN_MINUS_INT32,    GxB_MAX_MINUS_INT32,    GxB_PLUS_MINUS_INT32,   GxB_TIMES_MINUS_INT32,
GxB_MIN_MINUS_UINT32,   GxB_MAX_MINUS_UINT32,   GxB_PLUS_MINUS_UINT32,  GxB_TIMES_MINUS_UINT32,
GxB_MIN_MINUS_INT64,    GxB_MAX_MINUS_INT64,    GxB_PLUS_MINUS_INT64,   GxB_TIMES_MINUS_INT64,
GxB_MIN_MINUS_UINT64,   GxB_MAX_MINUS_UINT64,   GxB_PLUS_MINUS_UINT64,  GxB_TIMES_MINUS_UINT64,
GxB_MIN_MINUS_FP32,     GxB_MAX_MINUS_FP32,     GxB_PLUS_MINUS_FP32,    GxB_TIMES_MINUS_FP32,
GxB_MIN_MINUS_FP64,     GxB_MAX_MINUS_FP64,     GxB_PLUS_MINUS_FP64,    GxB_TIMES_MINUS_FP64,

# Semirings with multiply op: z = TIMES (x,y), all types x,y,z the same:

GxB_MIN_TIMES_INT8,     GxB_MAX_TIMES_INT8,     GxB_PLUS_TIMES_INT8,    GxB_TIMES_TIMES_INT8,
GxB_MIN_TIMES_UINT8,    GxB_MAX_TIMES_UINT8,    GxB_PLUS_TIMES_UINT8,   GxB_TIMES_TIMES_UINT8,
GxB_MIN_TIMES_INT16,    GxB_MAX_TIMES_INT16,    GxB_PLUS_TIMES_INT16,   GxB_TIMES_TIMES_INT16,
GxB_MIN_TIMES_UINT16,   GxB_MAX_TIMES_UINT16,   GxB_PLUS_TIMES_UINT16,  GxB_TIMES_TIMES_UINT16,
GxB_MIN_TIMES_INT32,    GxB_MAX_TIMES_INT32,    GxB_PLUS_TIMES_INT32,   GxB_TIMES_TIMES_INT32,
GxB_MIN_TIMES_UINT32,   GxB_MAX_TIMES_UINT32,   GxB_PLUS_TIMES_UINT32,  GxB_TIMES_TIMES_UINT32,
GxB_MIN_TIMES_INT64,    GxB_MAX_TIMES_INT64,    GxB_PLUS_TIMES_INT64,   GxB_TIMES_TIMES_INT64,
GxB_MIN_TIMES_UINT64,   GxB_MAX_TIMES_UINT64,   GxB_PLUS_TIMES_UINT64,  GxB_TIMES_TIMES_UINT64,
GxB_MIN_TIMES_FP32,     GxB_MAX_TIMES_FP32,     GxB_PLUS_TIMES_FP32,    GxB_TIMES_TIMES_FP32,
GxB_MIN_TIMES_FP64,     GxB_MAX_TIMES_FP64,     GxB_PLUS_TIMES_FP64,    GxB_TIMES_TIMES_FP64,

# Semirings with multiply op: z = DIV (x,y), all types x,y,z the same:

GxB_MIN_DIV_INT8,       GxB_MAX_DIV_INT8,       GxB_PLUS_DIV_INT8,      GxB_TIMES_DIV_INT8,
GxB_MIN_DIV_UINT8,      GxB_MAX_DIV_UINT8,      GxB_PLUS_DIV_UINT8,     GxB_TIMES_DIV_UINT8,
GxB_MIN_DIV_INT16,      GxB_MAX_DIV_INT16,      GxB_PLUS_DIV_INT16,     GxB_TIMES_DIV_INT16,
GxB_MIN_DIV_UINT16,     GxB_MAX_DIV_UINT16,     GxB_PLUS_DIV_UINT16,    GxB_TIMES_DIV_UINT16,
GxB_MIN_DIV_INT32,      GxB_MAX_DIV_INT32,      GxB_PLUS_DIV_INT32,     GxB_TIMES_DIV_INT32,
GxB_MIN_DIV_UINT32,     GxB_MAX_DIV_UINT32,     GxB_PLUS_DIV_UINT32,    GxB_TIMES_DIV_UINT32,
GxB_MIN_DIV_INT64,      GxB_MAX_DIV_INT64,      GxB_PLUS_DIV_INT64,     GxB_TIMES_DIV_INT64,
GxB_MIN_DIV_UINT64,     GxB_MAX_DIV_UINT64,     GxB_PLUS_DIV_UINT64,    GxB_TIMES_DIV_UINT64,
GxB_MIN_DIV_FP32,       GxB_MAX_DIV_FP32,       GxB_PLUS_DIV_FP32,      GxB_TIMES_DIV_FP32,
GxB_MIN_DIV_FP64,       GxB_MAX_DIV_FP64,       GxB_PLUS_DIV_FP64,      GxB_TIMES_DIV_FP64,

# Semirings with multiply op: z = ISEQ (x,y), all types x,y,z the same:

GxB_MIN_ISEQ_INT8,      GxB_MAX_ISEQ_INT8,      GxB_PLUS_ISEQ_INT8,     GxB_TIMES_ISEQ_INT8,
GxB_MIN_ISEQ_UINT8,     GxB_MAX_ISEQ_UINT8,     GxB_PLUS_ISEQ_UINT8,    GxB_TIMES_ISEQ_UINT8,
GxB_MIN_ISEQ_INT16,     GxB_MAX_ISEQ_INT16,     GxB_PLUS_ISEQ_INT16,    GxB_TIMES_ISEQ_INT16,
GxB_MIN_ISEQ_UINT16,    GxB_MAX_ISEQ_UINT16,    GxB_PLUS_ISEQ_UINT16,   GxB_TIMES_ISEQ_UINT16,
GxB_MIN_ISEQ_INT32,     GxB_MAX_ISEQ_INT32,     GxB_PLUS_ISEQ_INT32,    GxB_TIMES_ISEQ_INT32,
GxB_MIN_ISEQ_UINT32,    GxB_MAX_ISEQ_UINT32,    GxB_PLUS_ISEQ_UINT32,   GxB_TIMES_ISEQ_UINT32,
GxB_MIN_ISEQ_INT64,     GxB_MAX_ISEQ_INT64,     GxB_PLUS_ISEQ_INT64,    GxB_TIMES_ISEQ_INT64,
GxB_MIN_ISEQ_UINT64,    GxB_MAX_ISEQ_UINT64,    GxB_PLUS_ISEQ_UINT64,   GxB_TIMES_ISEQ_UINT64,
GxB_MIN_ISEQ_FP32,      GxB_MAX_ISEQ_FP32,      GxB_PLUS_ISEQ_FP32,     GxB_TIMES_ISEQ_FP32,
GxB_MIN_ISEQ_FP64,      GxB_MAX_ISEQ_FP64,      GxB_PLUS_ISEQ_FP64,     GxB_TIMES_ISEQ_FP64,

# Semirings with multiply op: z = ISNE (x,y), all types x,y,z the same:

GxB_MIN_ISNE_INT8,      GxB_MAX_ISNE_INT8,      GxB_PLUS_ISNE_INT8,     GxB_TIMES_ISNE_INT8,
GxB_MIN_ISNE_UINT8,     GxB_MAX_ISNE_UINT8,     GxB_PLUS_ISNE_UINT8,    GxB_TIMES_ISNE_UINT8,
GxB_MIN_ISNE_INT16,     GxB_MAX_ISNE_INT16,     GxB_PLUS_ISNE_INT16,    GxB_TIMES_ISNE_INT16,
GxB_MIN_ISNE_UINT16,    GxB_MAX_ISNE_UINT16,    GxB_PLUS_ISNE_UINT16,   GxB_TIMES_ISNE_UINT16,
GxB_MIN_ISNE_INT32,     GxB_MAX_ISNE_INT32,     GxB_PLUS_ISNE_INT32,    GxB_TIMES_ISNE_INT32,
GxB_MIN_ISNE_UINT32,    GxB_MAX_ISNE_UINT32,    GxB_PLUS_ISNE_UINT32,   GxB_TIMES_ISNE_UINT32,
GxB_MIN_ISNE_INT64,     GxB_MAX_ISNE_INT64,     GxB_PLUS_ISNE_INT64,    GxB_TIMES_ISNE_INT64,
GxB_MIN_ISNE_UINT64,    GxB_MAX_ISNE_UINT64,    GxB_PLUS_ISNE_UINT64,   GxB_TIMES_ISNE_UINT64,
GxB_MIN_ISNE_FP32,      GxB_MAX_ISNE_FP32,      GxB_PLUS_ISNE_FP32,     GxB_TIMES_ISNE_FP32,
GxB_MIN_ISNE_FP64,      GxB_MAX_ISNE_FP64,      GxB_PLUS_ISNE_FP64,     GxB_TIMES_ISNE_FP64,

# Semirings with multiply op: z = ISGT (x,y), all types x,y,z the same:

GxB_MIN_ISGT_INT8,      GxB_MAX_ISGT_INT8,      GxB_PLUS_ISGT_INT8,     GxB_TIMES_ISGT_INT8,
GxB_MIN_ISGT_UINT8,     GxB_MAX_ISGT_UINT8,     GxB_PLUS_ISGT_UINT8,    GxB_TIMES_ISGT_UINT8,
GxB_MIN_ISGT_INT16,     GxB_MAX_ISGT_INT16,     GxB_PLUS_ISGT_INT16,    GxB_TIMES_ISGT_INT16,
GxB_MIN_ISGT_UINT16,    GxB_MAX_ISGT_UINT16,    GxB_PLUS_ISGT_UINT16,   GxB_TIMES_ISGT_UINT16,
GxB_MIN_ISGT_INT32,     GxB_MAX_ISGT_INT32,     GxB_PLUS_ISGT_INT32,    GxB_TIMES_ISGT_INT32,
GxB_MIN_ISGT_UINT32,    GxB_MAX_ISGT_UINT32,    GxB_PLUS_ISGT_UINT32,   GxB_TIMES_ISGT_UINT32,
GxB_MIN_ISGT_INT64,     GxB_MAX_ISGT_INT64,     GxB_PLUS_ISGT_INT64,    GxB_TIMES_ISGT_INT64,
GxB_MIN_ISGT_UINT64,    GxB_MAX_ISGT_UINT64,    GxB_PLUS_ISGT_UINT64,   GxB_TIMES_ISGT_UINT64,
GxB_MIN_ISGT_FP32,      GxB_MAX_ISGT_FP32,      GxB_PLUS_ISGT_FP32,     GxB_TIMES_ISGT_FP32,
GxB_MIN_ISGT_FP64,      GxB_MAX_ISGT_FP64,      GxB_PLUS_ISGT_FP64,     GxB_TIMES_ISGT_FP64,

# Semirings with multiply op: z = ISLT (x,y), all types x,y,z the same:

GxB_MIN_ISLT_INT8,      GxB_MAX_ISLT_INT8,      GxB_PLUS_ISLT_INT8,     GxB_TIMES_ISLT_INT8,
GxB_MIN_ISLT_UINT8,     GxB_MAX_ISLT_UINT8,     GxB_PLUS_ISLT_UINT8,    GxB_TIMES_ISLT_UINT8,
GxB_MIN_ISLT_INT16,     GxB_MAX_ISLT_INT16,     GxB_PLUS_ISLT_INT16,    GxB_TIMES_ISLT_INT16,
GxB_MIN_ISLT_UINT16,    GxB_MAX_ISLT_UINT16,    GxB_PLUS_ISLT_UINT16,   GxB_TIMES_ISLT_UINT16,
GxB_MIN_ISLT_INT32,     GxB_MAX_ISLT_INT32,     GxB_PLUS_ISLT_INT32,    GxB_TIMES_ISLT_INT32,
GxB_MIN_ISLT_UINT32,    GxB_MAX_ISLT_UINT32,    GxB_PLUS_ISLT_UINT32,   GxB_TIMES_ISLT_UINT32,
GxB_MIN_ISLT_INT64,     GxB_MAX_ISLT_INT64,     GxB_PLUS_ISLT_INT64,    GxB_TIMES_ISLT_INT64,
GxB_MIN_ISLT_UINT64,    GxB_MAX_ISLT_UINT64,    GxB_PLUS_ISLT_UINT64,   GxB_TIMES_ISLT_UINT64,
GxB_MIN_ISLT_FP32,      GxB_MAX_ISLT_FP32,      GxB_PLUS_ISLT_FP32,     GxB_TIMES_ISLT_FP32,
GxB_MIN_ISLT_FP64,      GxB_MAX_ISLT_FP64,      GxB_PLUS_ISLT_FP64,     GxB_TIMES_ISLT_FP64,

# Semirings with multiply op: z = ISGE (x,y), all types x,y,z the same:

GxB_MIN_ISGE_INT8,      GxB_MAX_ISGE_INT8,      GxB_PLUS_ISGE_INT8,     GxB_TIMES_ISGE_INT8,
GxB_MIN_ISGE_UINT8,     GxB_MAX_ISGE_UINT8,     GxB_PLUS_ISGE_UINT8,    GxB_TIMES_ISGE_UINT8,
GxB_MIN_ISGE_INT16,     GxB_MAX_ISGE_INT16,     GxB_PLUS_ISGE_INT16,    GxB_TIMES_ISGE_INT16,
GxB_MIN_ISGE_UINT16,    GxB_MAX_ISGE_UINT16,    GxB_PLUS_ISGE_UINT16,   GxB_TIMES_ISGE_UINT16,
GxB_MIN_ISGE_INT32,     GxB_MAX_ISGE_INT32,     GxB_PLUS_ISGE_INT32,    GxB_TIMES_ISGE_INT32,
GxB_MIN_ISGE_UINT32,    GxB_MAX_ISGE_UINT32,    GxB_PLUS_ISGE_UINT32,   GxB_TIMES_ISGE_UINT32,
GxB_MIN_ISGE_INT64,     GxB_MAX_ISGE_INT64,     GxB_PLUS_ISGE_INT64,    GxB_TIMES_ISGE_INT64,
GxB_MIN_ISGE_UINT64,    GxB_MAX_ISGE_UINT64,    GxB_PLUS_ISGE_UINT64,   GxB_TIMES_ISGE_UINT64,
GxB_MIN_ISGE_FP32,      GxB_MAX_ISGE_FP32,      GxB_PLUS_ISGE_FP32,     GxB_TIMES_ISGE_FP32,
GxB_MIN_ISGE_FP64,      GxB_MAX_ISGE_FP64,      GxB_PLUS_ISGE_FP64,     GxB_TIMES_ISGE_FP64,

# Semirings with multiply op: z = ISLE (x,y), all types x,y,z the same:

GxB_MIN_ISLE_INT8,      GxB_MAX_ISLE_INT8,      GxB_PLUS_ISLE_INT8,     GxB_TIMES_ISLE_INT8,
GxB_MIN_ISLE_UINT8,     GxB_MAX_ISLE_UINT8,     GxB_PLUS_ISLE_UINT8,    GxB_TIMES_ISLE_UINT8,
GxB_MIN_ISLE_INT16,     GxB_MAX_ISLE_INT16,     GxB_PLUS_ISLE_INT16,    GxB_TIMES_ISLE_INT16,
GxB_MIN_ISLE_UINT16,    GxB_MAX_ISLE_UINT16,    GxB_PLUS_ISLE_UINT16,   GxB_TIMES_ISLE_UINT16,
GxB_MIN_ISLE_INT32,     GxB_MAX_ISLE_INT32,     GxB_PLUS_ISLE_INT32,    GxB_TIMES_ISLE_INT32,
GxB_MIN_ISLE_UINT32,    GxB_MAX_ISLE_UINT32,    GxB_PLUS_ISLE_UINT32,   GxB_TIMES_ISLE_UINT32,
GxB_MIN_ISLE_INT64,     GxB_MAX_ISLE_INT64,     GxB_PLUS_ISLE_INT64,    GxB_TIMES_ISLE_INT64,
GxB_MIN_ISLE_UINT64,    GxB_MAX_ISLE_UINT64,    GxB_PLUS_ISLE_UINT64,   GxB_TIMES_ISLE_UINT64,
GxB_MIN_ISLE_FP32,      GxB_MAX_ISLE_FP32,      GxB_PLUS_ISLE_FP32,     GxB_TIMES_ISLE_FP32,
GxB_MIN_ISLE_FP64,      GxB_MAX_ISLE_FP64,      GxB_PLUS_ISLE_FP64,     GxB_TIMES_ISLE_FP64,

# Semirings with multiply op: z = LOR (x,y), all types x,y,z the same:

GxB_MIN_LOR_INT8,       GxB_MAX_LOR_INT8,       GxB_PLUS_LOR_INT8,      GxB_TIMES_LOR_INT8,
GxB_MIN_LOR_UINT8,      GxB_MAX_LOR_UINT8,      GxB_PLUS_LOR_UINT8,     GxB_TIMES_LOR_UINT8,
GxB_MIN_LOR_INT16,      GxB_MAX_LOR_INT16,      GxB_PLUS_LOR_INT16,     GxB_TIMES_LOR_INT16,
GxB_MIN_LOR_UINT16,     GxB_MAX_LOR_UINT16,     GxB_PLUS_LOR_UINT16,    GxB_TIMES_LOR_UINT16,
GxB_MIN_LOR_INT32,      GxB_MAX_LOR_INT32,      GxB_PLUS_LOR_INT32,     GxB_TIMES_LOR_INT32,
GxB_MIN_LOR_UINT32,     GxB_MAX_LOR_UINT32,     GxB_PLUS_LOR_UINT32,    GxB_TIMES_LOR_UINT32,
GxB_MIN_LOR_INT64,      GxB_MAX_LOR_INT64,      GxB_PLUS_LOR_INT64,     GxB_TIMES_LOR_INT64,
GxB_MIN_LOR_UINT64,     GxB_MAX_LOR_UINT64,     GxB_PLUS_LOR_UINT64,    GxB_TIMES_LOR_UINT64,
GxB_MIN_LOR_FP32,       GxB_MAX_LOR_FP32,       GxB_PLUS_LOR_FP32,      GxB_TIMES_LOR_FP32,
GxB_MIN_LOR_FP64,       GxB_MAX_LOR_FP64,       GxB_PLUS_LOR_FP64,      GxB_TIMES_LOR_FP64,

# Semirings with multiply op: z = LAND (x,y), all types x,y,z the same:

GxB_MIN_LAND_INT8,      GxB_MAX_LAND_INT8,      GxB_PLUS_LAND_INT8,     GxB_TIMES_LAND_INT8,
GxB_MIN_LAND_UINT8,     GxB_MAX_LAND_UINT8,     GxB_PLUS_LAND_UINT8,    GxB_TIMES_LAND_UINT8,
GxB_MIN_LAND_INT16,     GxB_MAX_LAND_INT16,     GxB_PLUS_LAND_INT16,    GxB_TIMES_LAND_INT16,
GxB_MIN_LAND_UINT16,    GxB_MAX_LAND_UINT16,    GxB_PLUS_LAND_UINT16,   GxB_TIMES_LAND_UINT16,
GxB_MIN_LAND_INT32,     GxB_MAX_LAND_INT32,     GxB_PLUS_LAND_INT32,    GxB_TIMES_LAND_INT32,
GxB_MIN_LAND_UINT32,    GxB_MAX_LAND_UINT32,    GxB_PLUS_LAND_UINT32,   GxB_TIMES_LAND_UINT32,
GxB_MIN_LAND_INT64,     GxB_MAX_LAND_INT64,     GxB_PLUS_LAND_INT64,    GxB_TIMES_LAND_INT64,
GxB_MIN_LAND_UINT64,    GxB_MAX_LAND_UINT64,    GxB_PLUS_LAND_UINT64,   GxB_TIMES_LAND_UINT64,
GxB_MIN_LAND_FP32,      GxB_MAX_LAND_FP32,      GxB_PLUS_LAND_FP32,     GxB_TIMES_LAND_FP32,
GxB_MIN_LAND_FP64,      GxB_MAX_LAND_FP64,      GxB_PLUS_LAND_FP64,     GxB_TIMES_LAND_FP64,

# Semirings with multiply op: z = LXOR (x,y), all types x,y,z the same:

GxB_MIN_LXOR_INT8,      GxB_MAX_LXOR_INT8,      GxB_PLUS_LXOR_INT8,     GxB_TIMES_LXOR_INT8,
GxB_MIN_LXOR_UINT8,     GxB_MAX_LXOR_UINT8,     GxB_PLUS_LXOR_UINT8,    GxB_TIMES_LXOR_UINT8,
GxB_MIN_LXOR_INT16,     GxB_MAX_LXOR_INT16,     GxB_PLUS_LXOR_INT16,    GxB_TIMES_LXOR_INT16,
GxB_MIN_LXOR_UINT16,    GxB_MAX_LXOR_UINT16,    GxB_PLUS_LXOR_UINT16,   GxB_TIMES_LXOR_UINT16,
GxB_MIN_LXOR_INT32,     GxB_MAX_LXOR_INT32,     GxB_PLUS_LXOR_INT32,    GxB_TIMES_LXOR_INT32,
GxB_MIN_LXOR_UINT32,    GxB_MAX_LXOR_UINT32,    GxB_PLUS_LXOR_UINT32,   GxB_TIMES_LXOR_UINT32,
GxB_MIN_LXOR_INT64,     GxB_MAX_LXOR_INT64,     GxB_PLUS_LXOR_INT64,    GxB_TIMES_LXOR_INT64,
GxB_MIN_LXOR_UINT64,    GxB_MAX_LXOR_UINT64,    GxB_PLUS_LXOR_UINT64,   GxB_TIMES_LXOR_UINT64,
GxB_MIN_LXOR_FP32,      GxB_MAX_LXOR_FP32,      GxB_PLUS_LXOR_FP32,     GxB_TIMES_LXOR_FP32,
GxB_MIN_LXOR_FP64,      GxB_MAX_LXOR_FP64,      GxB_PLUS_LXOR_FP64,     GxB_TIMES_LXOR_FP64,

# Semirings with multiply op: z = EQ (x,y), where z is Boolean and x,y are given by the suffix:

GxB_LOR_EQ_INT8,        GxB_LAND_EQ_INT8,       GxB_LXOR_EQ_INT8,       GxB_EQ_EQ_INT8,
GxB_LOR_EQ_UINT8,       GxB_LAND_EQ_UINT8,      GxB_LXOR_EQ_UINT8,      GxB_EQ_EQ_UINT8,
GxB_LOR_EQ_INT16,       GxB_LAND_EQ_INT16,      GxB_LXOR_EQ_INT16,      GxB_EQ_EQ_INT16,
GxB_LOR_EQ_UINT16,      GxB_LAND_EQ_UINT16,     GxB_LXOR_EQ_UINT16,     GxB_EQ_EQ_UINT16,
GxB_LOR_EQ_INT32,       GxB_LAND_EQ_INT32,      GxB_LXOR_EQ_INT32,      GxB_EQ_EQ_INT32,
GxB_LOR_EQ_UINT32,      GxB_LAND_EQ_UINT32,     GxB_LXOR_EQ_UINT32,     GxB_EQ_EQ_UINT32,
GxB_LOR_EQ_INT64,       GxB_LAND_EQ_INT64,      GxB_LXOR_EQ_INT64,      GxB_EQ_EQ_INT64,
GxB_LOR_EQ_UINT64,      GxB_LAND_EQ_UINT64,     GxB_LXOR_EQ_UINT64,     GxB_EQ_EQ_UINT64,
GxB_LOR_EQ_FP32,        GxB_LAND_EQ_FP32,       GxB_LXOR_EQ_FP32,       GxB_EQ_EQ_FP32,
GxB_LOR_EQ_FP64,        GxB_LAND_EQ_FP64,       GxB_LXOR_EQ_FP64,       GxB_EQ_EQ_FP64,

# Semirings with multiply op: z = NE (x,y), where z is Boolean and x,y are given by the suffix:

GxB_LOR_NE_INT8,        GxB_LAND_NE_INT8,       GxB_LXOR_NE_INT8,       GxB_EQ_NE_INT8,
GxB_LOR_NE_UINT8,       GxB_LAND_NE_UINT8,      GxB_LXOR_NE_UINT8,      GxB_EQ_NE_UINT8,
GxB_LOR_NE_INT16,       GxB_LAND_NE_INT16,      GxB_LXOR_NE_INT16,      GxB_EQ_NE_INT16,
GxB_LOR_NE_UINT16,      GxB_LAND_NE_UINT16,     GxB_LXOR_NE_UINT16,     GxB_EQ_NE_UINT16,
GxB_LOR_NE_INT32,       GxB_LAND_NE_INT32,      GxB_LXOR_NE_INT32,      GxB_EQ_NE_INT32,
GxB_LOR_NE_UINT32,      GxB_LAND_NE_UINT32,     GxB_LXOR_NE_UINT32,     GxB_EQ_NE_UINT32,
GxB_LOR_NE_INT64,       GxB_LAND_NE_INT64,      GxB_LXOR_NE_INT64,      GxB_EQ_NE_INT64,
GxB_LOR_NE_UINT64,      GxB_LAND_NE_UINT64,     GxB_LXOR_NE_UINT64,     GxB_EQ_NE_UINT64,
GxB_LOR_NE_FP32,        GxB_LAND_NE_FP32,       GxB_LXOR_NE_FP32,       GxB_EQ_NE_FP32,
GxB_LOR_NE_FP64,        GxB_LAND_NE_FP64,       GxB_LXOR_NE_FP64,       GxB_EQ_NE_FP64,

# Semirings with multiply op: z = GT (x,y), where z is Boolean and x,y are given by the suffix:

GxB_LOR_GT_INT8,        GxB_LAND_GT_INT8,       GxB_LXOR_GT_INT8,       GxB_EQ_GT_INT8,
GxB_LOR_GT_UINT8,       GxB_LAND_GT_UINT8,      GxB_LXOR_GT_UINT8,      GxB_EQ_GT_UINT8,
GxB_LOR_GT_INT16,       GxB_LAND_GT_INT16,      GxB_LXOR_GT_INT16,      GxB_EQ_GT_INT16,
GxB_LOR_GT_UINT16,      GxB_LAND_GT_UINT16,     GxB_LXOR_GT_UINT16,     GxB_EQ_GT_UINT16,
GxB_LOR_GT_INT32,       GxB_LAND_GT_INT32,      GxB_LXOR_GT_INT32,      GxB_EQ_GT_INT32,
GxB_LOR_GT_UINT32,      GxB_LAND_GT_UINT32,     GxB_LXOR_GT_UINT32,     GxB_EQ_GT_UINT32,
GxB_LOR_GT_INT64,       GxB_LAND_GT_INT64,      GxB_LXOR_GT_INT64,      GxB_EQ_GT_INT64,
GxB_LOR_GT_UINT64,      GxB_LAND_GT_UINT64,     GxB_LXOR_GT_UINT64,     GxB_EQ_GT_UINT64,
GxB_LOR_GT_FP32,        GxB_LAND_GT_FP32,       GxB_LXOR_GT_FP32,       GxB_EQ_GT_FP32,
GxB_LOR_GT_FP64,        GxB_LAND_GT_FP64,       GxB_LXOR_GT_FP64,       GxB_EQ_GT_FP64,

# Semirings with multiply op: z = LT (x,y), where z is Boolean and x,y are given by the suffix:

GxB_LOR_LT_INT8,        GxB_LAND_LT_INT8,       GxB_LXOR_LT_INT8,       GxB_EQ_LT_INT8,
GxB_LOR_LT_UINT8,       GxB_LAND_LT_UINT8,      GxB_LXOR_LT_UINT8,      GxB_EQ_LT_UINT8,
GxB_LOR_LT_INT16,       GxB_LAND_LT_INT16,      GxB_LXOR_LT_INT16,      GxB_EQ_LT_INT16,
GxB_LOR_LT_UINT16,      GxB_LAND_LT_UINT16,     GxB_LXOR_LT_UINT16,     GxB_EQ_LT_UINT16,
GxB_LOR_LT_INT32,       GxB_LAND_LT_INT32,      GxB_LXOR_LT_INT32,      GxB_EQ_LT_INT32,
GxB_LOR_LT_UINT32,      GxB_LAND_LT_UINT32,     GxB_LXOR_LT_UINT32,     GxB_EQ_LT_UINT32,
GxB_LOR_LT_INT64,       GxB_LAND_LT_INT64,      GxB_LXOR_LT_INT64,      GxB_EQ_LT_INT64,
GxB_LOR_LT_UINT64,      GxB_LAND_LT_UINT64,     GxB_LXOR_LT_UINT64,     GxB_EQ_LT_UINT64,
GxB_LOR_LT_FP32,        GxB_LAND_LT_FP32,       GxB_LXOR_LT_FP32,       GxB_EQ_LT_FP32,
GxB_LOR_LT_FP64,        GxB_LAND_LT_FP64,       GxB_LXOR_LT_FP64,       GxB_EQ_LT_FP64,

# Semirings with multiply op: z = GE (x,y), where z is Boolean and x,y are given by the suffix:

GxB_LOR_GE_INT8,        GxB_LAND_GE_INT8,       GxB_LXOR_GE_INT8,       GxB_EQ_GE_INT8,
GxB_LOR_GE_UINT8,       GxB_LAND_GE_UINT8,      GxB_LXOR_GE_UINT8,      GxB_EQ_GE_UINT8,
GxB_LOR_GE_INT16,       GxB_LAND_GE_INT16,      GxB_LXOR_GE_INT16,      GxB_EQ_GE_INT16,
GxB_LOR_GE_UINT16,      GxB_LAND_GE_UINT16,     GxB_LXOR_GE_UINT16,     GxB_EQ_GE_UINT16,
GxB_LOR_GE_INT32,       GxB_LAND_GE_INT32,      GxB_LXOR_GE_INT32,      GxB_EQ_GE_INT32,
GxB_LOR_GE_UINT32,      GxB_LAND_GE_UINT32,     GxB_LXOR_GE_UINT32,     GxB_EQ_GE_UINT32,
GxB_LOR_GE_INT64,       GxB_LAND_GE_INT64,      GxB_LXOR_GE_INT64,      GxB_EQ_GE_INT64,
GxB_LOR_GE_UINT64,      GxB_LAND_GE_UINT64,     GxB_LXOR_GE_UINT64,     GxB_EQ_GE_UINT64,
GxB_LOR_GE_FP32,        GxB_LAND_GE_FP32,       GxB_LXOR_GE_FP32,       GxB_EQ_GE_FP32,
GxB_LOR_GE_FP64,        GxB_LAND_GE_FP64,       GxB_LXOR_GE_FP64,       GxB_EQ_GE_FP64,

# Semirings with multiply op: z = LE (x,y), where z is Boolean and x,y are given by the suffix:

GxB_LOR_LE_INT8,        GxB_LAND_LE_INT8,       GxB_LXOR_LE_INT8,       GxB_EQ_LE_INT8,
GxB_LOR_LE_UINT8,       GxB_LAND_LE_UINT8,      GxB_LXOR_LE_UINT8,      GxB_EQ_LE_UINT8,
GxB_LOR_LE_INT16,       GxB_LAND_LE_INT16,      GxB_LXOR_LE_INT16,      GxB_EQ_LE_INT16,
GxB_LOR_LE_UINT16,      GxB_LAND_LE_UINT16,     GxB_LXOR_LE_UINT16,     GxB_EQ_LE_UINT16,
GxB_LOR_LE_INT32,       GxB_LAND_LE_INT32,      GxB_LXOR_LE_INT32,      GxB_EQ_LE_INT32,
GxB_LOR_LE_UINT32,      GxB_LAND_LE_UINT32,     GxB_LXOR_LE_UINT32,     GxB_EQ_LE_UINT32,
GxB_LOR_LE_INT64,       GxB_LAND_LE_INT64,      GxB_LXOR_LE_INT64,      GxB_EQ_LE_INT64,
GxB_LOR_LE_UINT64,      GxB_LAND_LE_UINT64,     GxB_LXOR_LE_UINT64,     GxB_EQ_LE_UINT64,
GxB_LOR_LE_FP32,        GxB_LAND_LE_FP32,       GxB_LXOR_LE_FP32,       GxB_EQ_LE_FP32,
GxB_LOR_LE_FP64,        GxB_LAND_LE_FP64,       GxB_LXOR_LE_FP64,       GxB_EQ_LE_FP64,

# Purely boolean semirings (in the form GxB_(add monoid)_(multipy operator)_BOOL:

GxB_LOR_FIRST_BOOL,     GxB_LAND_FIRST_BOOL,    GxB_LXOR_FIRST_BOOL,    GxB_EQ_FIRST_BOOL,
GxB_LOR_SECOND_BOOL,    GxB_LAND_SECOND_BOOL,   GxB_LXOR_SECOND_BOOL,   GxB_EQ_SECOND_BOOL,
GxB_LOR_LOR_BOOL,       GxB_LAND_LOR_BOOL,      GxB_LXOR_LOR_BOOL,      GxB_EQ_LOR_BOOL,
GxB_LOR_LAND_BOOL,      GxB_LAND_LAND_BOOL,     GxB_LXOR_LAND_BOOL,     GxB_EQ_LAND_BOOL,
GxB_LOR_LXOR_BOOL,      GxB_LAND_LXOR_BOOL,     GxB_LXOR_LXOR_BOOL,     GxB_EQ_LXOR_BOOL,
GxB_LOR_EQ_BOOL,        GxB_LAND_EQ_BOOL,       GxB_LXOR_EQ_BOOL,       GxB_EQ_EQ_BOOL,
GxB_LOR_GT_BOOL,        GxB_LAND_GT_BOOL,       GxB_LXOR_GT_BOOL,       GxB_EQ_GT_BOOL,
GxB_LOR_LT_BOOL,        GxB_LAND_LT_BOOL,       GxB_LXOR_LT_BOOL,       GxB_EQ_LT_BOOL,
GxB_LOR_GE_BOOL,        GxB_LAND_GE_BOOL,       GxB_LXOR_GE_BOOL,       GxB_EQ_GE_BOOL,
GxB_LOR_LE_BOOL,        GxB_LAND_LE_BOOL,       GxB_LXOR_LE_BOOL,       GxB_EQ_LE_BOOL,

#########################################################################
#                 Built-in select operators (extension)                 #
#########################################################################

GxB_TRIL, GxB_TRIU, GxB_OFFDIAG, GxB_DIAG, GxB_NONZERO,

#########################################################################
#                               GrB_NULL                                #
#########################################################################

GrB_NULL,

#########################################################################
#                               GrB_ALL                                 #
#########################################################################

GrB_ALL

end #end of module
