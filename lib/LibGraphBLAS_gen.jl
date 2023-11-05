module LibGraphBLAS
import ..libgraphblas
to_c_type(t::Type) = t
to_c_type(::Type{Base.RefValue{T}}) where T = Base.Ptr{T}
to_c_type_pairs(va_list) = map(enumerate(to_c_type.(va_list))) do (ind, type)
    :(va_list[$ind]::$type)
end

NULL = C_NULL
INT64_MAX = typemax(Int64)

"""
GrB_Index: row or column index, or matrix dimension.  This typedef is used
for row and column indices, or matrix and vector dimensions.
"""
const GrB_Index = UInt64

const GxB_FC32_t = ComplexF32

const GxB_FC64_t = ComplexF64

mutable struct GB_Vector_opaque end

"""
==============================================================================
GrB_Vector: a GraphBLAS vector
==============================================================================
"""
const GrB_Vector = Ptr{GB_Vector_opaque}

mutable struct GB_Scalar_opaque end

const GrB_Scalar = Ptr{GB_Scalar_opaque}

"""
    GrB_Info

The v1.3 C API did not specify the enum values, but they appear in v2.0.
Changing them will require SuiteSparse:GraphBLAS to bump to v6.x.
Error codes GrB_NOT_IMPLEMENTED and GrB_EMPTY_OBJECT are new to v2.0.
"""
@enum GrB_Info::Int32 begin
    GrB_SUCCESS = 0
    GrB_NO_VALUE = 1
    GxB_EXHAUSTED = 7089
    GrB_UNINITIALIZED_OBJECT = -1
    GrB_NULL_POINTER = -2
    GrB_INVALID_VALUE = -3
    GrB_INVALID_INDEX = -4
    GrB_DOMAIN_MISMATCH = -5
    GrB_DIMENSION_MISMATCH = -6
    GrB_OUTPUT_NOT_EMPTY = -7
    GrB_NOT_IMPLEMENTED = -8
    GrB_ALREADY_SET = -9
    GrB_PANIC = -101
    GrB_OUT_OF_MEMORY = -102
    GrB_INSUFFICIENT_SPACE = -103
    GrB_INVALID_OBJECT = -104
    GrB_INDEX_OUT_OF_BOUNDS = -105
    GrB_EMPTY_OBJECT = -106
end

"""
    GrB_Vector_setElement_Scalar(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_Scalar ( GrB_Vector w, GrB_Scalar x, GrB_Index i );
```
"""
function GrB_Vector_setElement_Scalar(w, x, i)
    ccall((:GrB_Vector_setElement_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Scalar, GrB_Index), w, x, i)
end

"""
    GrB_Vector_extractElement_Scalar(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_Scalar ( GrB_Scalar x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_Scalar(x, v, i)
    ccall((:GrB_Vector_extractElement_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_Vector, GrB_Index), x, v, i)
end

mutable struct GB_Matrix_opaque end

"""
==============================================================================
GrB_Matrix: a GraphBLAS matrix
==============================================================================
"""
const GrB_Matrix = Ptr{GB_Matrix_opaque}

"""
    GrB_Matrix_setElement_Scalar(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_Scalar ( GrB_Matrix C, GrB_Scalar x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_Scalar(C, x, i, j)
    ccall((:GrB_Matrix_setElement_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Scalar, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_extractElement_Scalar(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_Scalar ( GrB_Scalar x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_Scalar(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Global_Option_set(arg1, va_list...)
        :(@ccall(libgraphblas.GxB_Global_Option_set(arg1::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

"""
    GxB_Option_Field

The following options modify how SuiteSparse:GraphBLAS stores and operates
on its matrices.  The GrB_get/set methods allow the user to suggest how the
internal representation of a matrix, or all matrices, should be held.  These
options have no effect on the result (except for minor roundoff differences
for floating-point types). They only affect the time and memory usage of the
computations.
"""
@enum GxB_Option_Field::UInt32 begin
    GxB_HYPER_SWITCH2 = 10000
end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Vector_Option_set(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Vector_Option_set(arg1::GrB_Vector, arg2::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Matrix_Option_set(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Matrix_Option_set(arg1::GrB_Matrix, arg2::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

mutable struct GB_Descriptor_opaque end

const GrB_Descriptor = Ptr{GB_Descriptor_opaque}

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Desc_set(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Desc_set(arg1::GrB_Descriptor, arg2::GrB_Desc_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

mutable struct GB_Context_opaque end

"""
==============================================================================
GxB_Context: for managing computational resources
==============================================================================
"""
const GxB_Context = Ptr{GB_Context_opaque}

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Context_set(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Context_set(arg1::GxB_Context, arg2::GxB_Context_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Global_Option_get(arg1, va_list...)
        :(@ccall(libgraphblas.GxB_Global_Option_get(arg1::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Vector_Option_get(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Vector_Option_get(arg1::GrB_Vector, arg2::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Matrix_Option_get(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Matrix_Option_get(arg1::GrB_Matrix, arg2::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Desc_get(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Desc_get(arg1::GrB_Descriptor, arg2::GrB_Desc_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Context_get(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Context_get(arg1::GxB_Context, arg2::GxB_Context_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

@enum GrB_Field::UInt32 begin
    GrB_OUTP_FIELD = 0
    GrB_MASK_FIELD = 1
    GrB_INP0_FIELD = 2
    GrB_INP1_FIELD = 3
    GrB_NAME = 10
    GrB_LIBRARY_VER_MAJOR = 11
    GrB_LIBRARY_VER_MINOR = 12
    GrB_LIBRARY_VER_PATCH = 13
    GrB_API_VER_MAJOR = 14
    GrB_API_VER_MINOR = 15
    GrB_API_VER_PATCH = 16
    GrB_BLOCKING_MODE = 17
    GrB_STORAGE_ORIENTATION_HINT = 100
    GrB_ELTYPE_CODE = 102
    GrB_ELTYPE_STRING = 106
    GrB_INPUT1TYPE_CODE = 103
    GrB_INPUT2TYPE_CODE = 104
    GrB_OUTPUTTYPE_CODE = 105
    GrB_INPUT1TYPE_STRING = 107
    GrB_INPUT2TYPE_STRING = 108
    GrB_OUTPUTTYPE_STRING = 109
    GrB_SIZE = 110
    GxB_JIT_C_NAME = 7041
    GxB_JIT_C_DEFINITION = 7042
    GxB_MONOID_IDENTITY = 7043
    GxB_MONOID_TERMINAL = 7044
    GxB_MONOID_OPERATOR = 7045
    GxB_SEMIRING_MONOID = 7046
    GxB_SEMIRING_MULTIPLY = 7047

    GxB_HYPER_SWITCH = 7000
    GxB_HYPER_HASH = 7048
    GxB_BITMAP_SWITCH = 7001
    GxB_FORMAT = 7002
    GxB_MODE = 7003
    GxB_LIBRARY_NAME = 7004
    GxB_LIBRARY_VERSION = 7005
    GxB_LIBRARY_DATE = 7006
    GxB_LIBRARY_ABOUT = 7007
    GxB_LIBRARY_URL = 7008
    GxB_LIBRARY_LICENSE = 7009
    GxB_LIBRARY_COMPILE_DATE = 7010
    GxB_LIBRARY_COMPILE_TIME = 7011
    GxB_API_VERSION = 7012
    GxB_API_DATE = 7013
    GxB_API_ABOUT = 7014
    GxB_API_URL = 7015
    GxB_COMPILER_VERSION = 7016
    GxB_COMPILER_NAME = 7017
    GxB_LIBRARY_OPENMP = 7018
    GxB_MALLOC_FUNCTION = 7037
    GxB_CALLOC_FUNCTION = 7038
    GxB_REALLOC_FUNCTION = 7039
    GxB_FREE_FUNCTION = 7040
    GxB_GLOBAL_NTHREADS = 7086
    GxB_GLOBAL_CHUNK = 7087
    GxB_GLOBAL_GPU_ID = 7088
    GxB_BURBLE = 7019
    GxB_PRINTF = 7020
    GxB_FLUSH = 7021
    GxB_MEMORY_POOL = 7022
    GxB_PRINT_1BASED = 7023
    GxB_JIT_C_COMPILER_NAME = 7024
    GxB_JIT_C_COMPILER_FLAGS = 7025
    GxB_JIT_C_LINKER_FLAGS = 7026
    GxB_JIT_C_LIBRARIES = 7027
    GxB_JIT_C_PREFACE = 7028
    GxB_JIT_C_CONTROL = 7029
    GxB_JIT_CACHE_PATH = 7030
    GxB_JIT_C_CMAKE_LIBS = 7031
    GxB_JIT_USE_CMAKE = 7032
    GxB_JIT_ERROR_LOG = 7033
    GxB_JIT_CMAKE = 7049
    GxB_SPARSITY_STATUS = 7034
    GxB_IS_HYPER = 7035
    GxB_SPARSITY_CONTROL = 7036
end

"""
    GrB_Scalar_get_Scalar(arg1, arg2, arg3)

------------------------------------------------------------------------------
GrB_get: get a scalar, string, enum, size, or void * from an object
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GrB_Scalar_get_Scalar (GrB_Scalar, GrB_Scalar, GrB_Field);
```
"""
function GrB_Scalar_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Scalar_get_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Scalar_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Scalar_get_String (GrB_Scalar, char * , GrB_Field);
```
"""
function GrB_Scalar_get_String(arg1, arg2, arg3)
    ccall((:GrB_Scalar_get_String, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Scalar_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Scalar_get_INT32 (GrB_Scalar, int32_t * , GrB_Field);
```
"""
function GrB_Scalar_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_Scalar_get_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Scalar_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Scalar_get_SIZE (GrB_Scalar, size_t * , GrB_Field);
```
"""
function GrB_Scalar_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_Scalar_get_SIZE, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Scalar_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Scalar_get_VOID (GrB_Scalar, void * , GrB_Field);
```
"""
function GrB_Scalar_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_Scalar_get_VOID, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Vector_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Vector_get_Scalar (GrB_Vector, GrB_Scalar, GrB_Field);
```
"""
function GrB_Vector_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Vector_get_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Vector_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Vector_get_String (GrB_Vector, char * , GrB_Field);
```
"""
function GrB_Vector_get_String(arg1, arg2, arg3)
    ccall((:GrB_Vector_get_String, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Vector_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Vector_get_INT32 (GrB_Vector, int32_t * , GrB_Field);
```
"""
function GrB_Vector_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_Vector_get_INT32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Vector_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Vector_get_SIZE (GrB_Vector, size_t * , GrB_Field);
```
"""
function GrB_Vector_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_Vector_get_SIZE, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Vector_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Vector_get_VOID (GrB_Vector, void * , GrB_Field);
```
"""
function GrB_Vector_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_Vector_get_VOID, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Matrix_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Matrix_get_Scalar (GrB_Matrix, GrB_Scalar, GrB_Field);
```
"""
function GrB_Matrix_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Matrix_get_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Matrix_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Matrix_get_String (GrB_Matrix, char * , GrB_Field);
```
"""
function GrB_Matrix_get_String(arg1, arg2, arg3)
    ccall((:GrB_Matrix_get_String, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Matrix_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Matrix_get_INT32 (GrB_Matrix, int32_t * , GrB_Field);
```
"""
function GrB_Matrix_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_Matrix_get_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Matrix_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Matrix_get_SIZE (GrB_Matrix, size_t * , GrB_Field);
```
"""
function GrB_Matrix_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_Matrix_get_SIZE, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Matrix_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Matrix_get_VOID (GrB_Matrix, void * , GrB_Field);
```
"""
function GrB_Matrix_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_Matrix_get_VOID, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

mutable struct GB_UnaryOp_opaque end

"""
The pointers are void * but they are always of pointers to objects of type
ztype and xtype, respectively.  The function must typecast its arguments as
needed from void* to ztype* and xtype*.
"""
const GrB_UnaryOp = Ptr{GB_UnaryOp_opaque}

"""
    GrB_UnaryOp_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_UnaryOp_get_Scalar (GrB_UnaryOp, GrB_Scalar, GrB_Field);
```
"""
function GrB_UnaryOp_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_UnaryOp_get_Scalar, libgraphblas), GrB_Info, (GrB_UnaryOp, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_UnaryOp_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_UnaryOp_get_String (GrB_UnaryOp, char * , GrB_Field);
```
"""
function GrB_UnaryOp_get_String(arg1, arg2, arg3)
    ccall((:GrB_UnaryOp_get_String, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_UnaryOp_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_UnaryOp_get_INT32 (GrB_UnaryOp, int32_t * , GrB_Field);
```
"""
function GrB_UnaryOp_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_UnaryOp_get_INT32, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_UnaryOp_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_UnaryOp_get_SIZE (GrB_UnaryOp, size_t * , GrB_Field);
```
"""
function GrB_UnaryOp_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_UnaryOp_get_SIZE, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_UnaryOp_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_UnaryOp_get_VOID (GrB_UnaryOp, void * , GrB_Field);
```
"""
function GrB_UnaryOp_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_UnaryOp_get_VOID, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

mutable struct GB_IndexUnaryOp_opaque end

"""
The indexop has the form z = f(aij, i, j, y) where aij is the numerical
value of the A(i,j) entry, i and j are its row and column index, and y
is a scalar.  For vectors, it has the form z = f(vi, i, 0, y).
"""
const GrB_IndexUnaryOp = Ptr{GB_IndexUnaryOp_opaque}

"""
    GrB_IndexUnaryOp_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_get_Scalar (GrB_IndexUnaryOp, GrB_Scalar, GrB_Field);
```
"""
function GrB_IndexUnaryOp_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_Scalar, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_get_String (GrB_IndexUnaryOp, char * , GrB_Field);
```
"""
function GrB_IndexUnaryOp_get_String(arg1, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_String, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_get_INT32 (GrB_IndexUnaryOp, int32_t * , GrB_Field);
```
"""
function GrB_IndexUnaryOp_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_INT32, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_get_SIZE (GrB_IndexUnaryOp, size_t * , GrB_Field);
```
"""
function GrB_IndexUnaryOp_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_SIZE, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_get_VOID (GrB_IndexUnaryOp, void * , GrB_Field);
```
"""
function GrB_IndexUnaryOp_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_VOID, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

mutable struct GB_BinaryOp_opaque end

"""
The pointers are void * but they are always of pointers to objects of type
ztype, xtype, and ytype, respectively.  See Demo/usercomplex.c for examples.
"""
const GrB_BinaryOp = Ptr{GB_BinaryOp_opaque}

"""
    GrB_BinaryOp_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_BinaryOp_get_Scalar (GrB_BinaryOp, GrB_Scalar, GrB_Field);
```
"""
function GrB_BinaryOp_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_BinaryOp_get_Scalar, libgraphblas), GrB_Info, (GrB_BinaryOp, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_BinaryOp_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_BinaryOp_get_String (GrB_BinaryOp, char * , GrB_Field);
```
"""
function GrB_BinaryOp_get_String(arg1, arg2, arg3)
    ccall((:GrB_BinaryOp_get_String, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_BinaryOp_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_BinaryOp_get_INT32 (GrB_BinaryOp, int32_t * , GrB_Field);
```
"""
function GrB_BinaryOp_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_BinaryOp_get_INT32, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_BinaryOp_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_BinaryOp_get_SIZE (GrB_BinaryOp, size_t * , GrB_Field);
```
"""
function GrB_BinaryOp_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_BinaryOp_get_SIZE, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_BinaryOp_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_BinaryOp_get_VOID (GrB_BinaryOp, void * , GrB_Field);
```
"""
function GrB_BinaryOp_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_BinaryOp_get_VOID, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

mutable struct GB_Monoid_opaque end

"""
A monoid is an associative operator z=op(x,y) where all three types of z, x,
and y are identical.  The monoid also has an identity element, such that
op(x,identity) = op(identity,x) = x.
"""
const GrB_Monoid = Ptr{GB_Monoid_opaque}

"""
    GrB_Monoid_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Monoid_get_Scalar (GrB_Monoid, GrB_Scalar, GrB_Field);
```
"""
function GrB_Monoid_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Monoid_get_Scalar, libgraphblas), GrB_Info, (GrB_Monoid, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Monoid_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Monoid_get_String (GrB_Monoid, char * , GrB_Field);
```
"""
function GrB_Monoid_get_String(arg1, arg2, arg3)
    ccall((:GrB_Monoid_get_String, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Monoid_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Monoid_get_INT32 (GrB_Monoid, int32_t * , GrB_Field);
```
"""
function GrB_Monoid_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_Monoid_get_INT32, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Monoid_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Monoid_get_SIZE (GrB_Monoid, size_t * , GrB_Field);
```
"""
function GrB_Monoid_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_Monoid_get_SIZE, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Monoid_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Monoid_get_VOID (GrB_Monoid, void * , GrB_Field);
```
"""
function GrB_Monoid_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_Monoid_get_VOID, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

mutable struct GB_Semiring_opaque end

"""
==============================================================================
GrB_Semiring
==============================================================================
"""
const GrB_Semiring = Ptr{GB_Semiring_opaque}

"""
    GrB_Semiring_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Semiring_get_Scalar (GrB_Semiring, GrB_Scalar, GrB_Field);
```
"""
function GrB_Semiring_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Semiring_get_Scalar, libgraphblas), GrB_Info, (GrB_Semiring, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Semiring_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Semiring_get_String (GrB_Semiring, char * , GrB_Field);
```
"""
function GrB_Semiring_get_String(arg1, arg2, arg3)
    ccall((:GrB_Semiring_get_String, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Semiring_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Semiring_get_INT32 (GrB_Semiring, int32_t * , GrB_Field);
```
"""
function GrB_Semiring_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_Semiring_get_INT32, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Semiring_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Semiring_get_SIZE (GrB_Semiring, size_t * , GrB_Field);
```
"""
function GrB_Semiring_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_Semiring_get_SIZE, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Semiring_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Semiring_get_VOID (GrB_Semiring, void * , GrB_Field);
```
"""
function GrB_Semiring_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_Semiring_get_VOID, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

mutable struct GB_Type_opaque end

"""
==============================================================================
GrB_Type: data types
==============================================================================
"""
const GrB_Type = Ptr{GB_Type_opaque}

"""
    GrB_Type_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Type_get_Scalar (GrB_Type, GrB_Scalar, GrB_Field);
```
"""
function GrB_Type_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Type_get_Scalar, libgraphblas), GrB_Info, (GrB_Type, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Type_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Type_get_String (GrB_Type, char * , GrB_Field);
```
"""
function GrB_Type_get_String(arg1, arg2, arg3)
    ccall((:GrB_Type_get_String, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Type_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Type_get_INT32 (GrB_Type, int32_t * , GrB_Field);
```
"""
function GrB_Type_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_Type_get_INT32, libgraphblas), GrB_Info, (GrB_Type, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Type_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Type_get_SIZE (GrB_Type, size_t * , GrB_Field);
```
"""
function GrB_Type_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_Type_get_SIZE, libgraphblas), GrB_Info, (GrB_Type, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Type_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Type_get_VOID (GrB_Type, void * , GrB_Field);
```
"""
function GrB_Type_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_Type_get_VOID, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Descriptor_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Descriptor_get_Scalar (GrB_Descriptor, GrB_Scalar, GrB_Field);
```
"""
function GrB_Descriptor_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_get_Scalar, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Descriptor_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Descriptor_get_String (GrB_Descriptor, char * , GrB_Field);
```
"""
function GrB_Descriptor_get_String(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_get_String, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Descriptor_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Descriptor_get_INT32 (GrB_Descriptor, int32_t * , GrB_Field);
```
"""
function GrB_Descriptor_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_get_INT32, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Descriptor_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Descriptor_get_SIZE (GrB_Descriptor, size_t * , GrB_Field);
```
"""
function GrB_Descriptor_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_get_SIZE, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Descriptor_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Descriptor_get_VOID (GrB_Descriptor, void * , GrB_Field);
```
"""
function GrB_Descriptor_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_get_VOID, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

mutable struct GB_Global_opaque end

"""
==============================================================================
GrB_set and GrB_get
==============================================================================
"""
const GrB_Global = Ptr{GB_Global_opaque}

"""
    GrB_Global_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Global_get_Scalar (GrB_Global, GrB_Scalar, GrB_Field);
```
"""
function GrB_Global_get_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Global_get_Scalar, libgraphblas), GrB_Info, (GrB_Global, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Global_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Global_get_String (GrB_Global, char * , GrB_Field);
```
"""
function GrB_Global_get_String(arg1, arg2, arg3)
    ccall((:GrB_Global_get_String, libgraphblas), GrB_Info, (GrB_Global, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Global_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Global_get_INT32 (GrB_Global, int32_t * , GrB_Field);
```
"""
function GrB_Global_get_INT32(arg1, arg2, arg3)
    ccall((:GrB_Global_get_INT32, libgraphblas), GrB_Info, (GrB_Global, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Global_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Global_get_SIZE (GrB_Global, size_t * , GrB_Field);
```
"""
function GrB_Global_get_SIZE(arg1, arg2, arg3)
    ccall((:GrB_Global_get_SIZE, libgraphblas), GrB_Info, (GrB_Global, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Global_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Global_get_VOID (GrB_Global, void * , GrB_Field);
```
"""
function GrB_Global_get_VOID(arg1, arg2, arg3)
    ccall((:GrB_Global_get_VOID, libgraphblas), GrB_Info, (GrB_Global, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

"""
    GxB_Context_get_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_Scalar (GxB_Context, GrB_Scalar, GrB_Field);
```
"""
function GxB_Context_get_Scalar(arg1, arg2, arg3)
    ccall((:GxB_Context_get_Scalar, libgraphblas), GrB_Info, (GxB_Context, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GxB_Context_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_String (GxB_Context, char * , GrB_Field);
```
"""
function GxB_Context_get_String(arg1, arg2, arg3)
    ccall((:GxB_Context_get_String, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GxB_Context_get_INT(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_INT (GxB_Context, int32_t * , GrB_Field);
```
"""
function GxB_Context_get_INT(arg1, arg2, arg3)
    ccall((:GxB_Context_get_INT, libgraphblas), GrB_Info, (GxB_Context, Ptr{Int32}, GrB_Field), arg1, arg2, arg3)
end

"""
    GxB_Context_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_SIZE (GxB_Context, size_t * , GrB_Field);
```
"""
function GxB_Context_get_SIZE(arg1, arg2, arg3)
    ccall((:GxB_Context_get_SIZE, libgraphblas), GrB_Info, (GxB_Context, Ptr{Csize_t}, GrB_Field), arg1, arg2, arg3)
end

"""
    GxB_Context_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_VOID (GxB_Context, void * , GrB_Field);
```
"""
function GxB_Context_get_VOID(arg1, arg2, arg3)
    ccall((:GxB_Context_get_VOID, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cvoid}, GrB_Field), arg1, arg2, arg3)
end

"""
    GxB_Serialized_get_Scalar(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_Scalar (const void *, GrB_Scalar, GrB_Field, size_t);
```
"""
function GxB_Serialized_get_Scalar(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_Scalar, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Scalar, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GxB_Serialized_get_String(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_String (const void *, char * , GrB_Field, size_t);
```
"""
function GxB_Serialized_get_String(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_String, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{Cchar}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GxB_Serialized_get_INT32(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_INT32 (const void *, int32_t * , GrB_Field, size_t);
```
"""
function GxB_Serialized_get_INT32(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_INT32, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{Int32}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GxB_Serialized_get_SIZE(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_SIZE (const void *, size_t * , GrB_Field, size_t);
```
"""
function GxB_Serialized_get_SIZE(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_SIZE, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{Csize_t}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GxB_Serialized_get_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_VOID (const void *, void * , GrB_Field, size_t);
```
"""
function GxB_Serialized_get_VOID(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_VOID, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Scalar_set_Scalar(arg1, arg2, arg3)

------------------------------------------------------------------------------
GrB_set: set a scalar, string, enum, size, or void * of an object
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GrB_Scalar_set_Scalar (GrB_Scalar, GrB_Scalar, GrB_Field);
```
"""
function GrB_Scalar_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Scalar_set_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Scalar_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Scalar_set_String (GrB_Scalar, char * , GrB_Field);
```
"""
function GrB_Scalar_set_String(arg1, arg2, arg3)
    ccall((:GrB_Scalar_set_String, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Scalar_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Scalar_set_INT32 (GrB_Scalar, int32_t , GrB_Field);
```
"""
function GrB_Scalar_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_Scalar_set_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Scalar_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_Scalar_set_VOID (GrB_Scalar, void * , GrB_Field, size_t);
```
"""
function GrB_Scalar_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_Scalar_set_VOID, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Vector_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Vector_set_Scalar (GrB_Vector, GrB_Scalar, GrB_Field);
```
"""
function GrB_Vector_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Vector_set_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Vector_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Vector_set_String (GrB_Vector, char * , GrB_Field);
```
"""
function GrB_Vector_set_String(arg1, arg2, arg3)
    ccall((:GrB_Vector_set_String, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Vector_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Vector_set_INT32 (GrB_Vector, int32_t , GrB_Field);
```
"""
function GrB_Vector_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_Vector_set_INT32, libgraphblas), GrB_Info, (GrB_Vector, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Vector_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_Vector_set_VOID (GrB_Vector, void * , GrB_Field, size_t);
```
"""
function GrB_Vector_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_Vector_set_VOID, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Matrix_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Matrix_set_Scalar (GrB_Matrix, GrB_Scalar, GrB_Field);
```
"""
function GrB_Matrix_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Matrix_set_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Matrix_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Matrix_set_String (GrB_Matrix, char * , GrB_Field);
```
"""
function GrB_Matrix_set_String(arg1, arg2, arg3)
    ccall((:GrB_Matrix_set_String, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Matrix_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Matrix_set_INT32 (GrB_Matrix, int32_t , GrB_Field);
```
"""
function GrB_Matrix_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_Matrix_set_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Matrix_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_Matrix_set_VOID (GrB_Matrix, void * , GrB_Field, size_t);
```
"""
function GrB_Matrix_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_Matrix_set_VOID, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_UnaryOp_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_UnaryOp_set_Scalar (GrB_UnaryOp, GrB_Scalar, GrB_Field);
```
"""
function GrB_UnaryOp_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_UnaryOp_set_Scalar, libgraphblas), GrB_Info, (GrB_UnaryOp, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_UnaryOp_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_UnaryOp_set_String (GrB_UnaryOp, char * , GrB_Field);
```
"""
function GrB_UnaryOp_set_String(arg1, arg2, arg3)
    ccall((:GrB_UnaryOp_set_String, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_UnaryOp_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_UnaryOp_set_INT32 (GrB_UnaryOp, int32_t , GrB_Field);
```
"""
function GrB_UnaryOp_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_UnaryOp_set_INT32, libgraphblas), GrB_Info, (GrB_UnaryOp, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_UnaryOp_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_UnaryOp_set_VOID (GrB_UnaryOp, void * , GrB_Field, size_t);
```
"""
function GrB_UnaryOp_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_UnaryOp_set_VOID, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_IndexUnaryOp_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_set_Scalar (GrB_IndexUnaryOp, GrB_Scalar, GrB_Field);
```
"""
function GrB_IndexUnaryOp_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_set_Scalar, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_set_String (GrB_IndexUnaryOp, char * , GrB_Field);
```
"""
function GrB_IndexUnaryOp_set_String(arg1, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_set_String, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_set_INT32 (GrB_IndexUnaryOp, int32_t , GrB_Field);
```
"""
function GrB_IndexUnaryOp_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_set_INT32, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_set_VOID (GrB_IndexUnaryOp, void * , GrB_Field, size_t);
```
"""
function GrB_IndexUnaryOp_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_IndexUnaryOp_set_VOID, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_BinaryOp_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_BinaryOp_set_Scalar (GrB_BinaryOp, GrB_Scalar, GrB_Field);
```
"""
function GrB_BinaryOp_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_BinaryOp_set_Scalar, libgraphblas), GrB_Info, (GrB_BinaryOp, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_BinaryOp_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_BinaryOp_set_String (GrB_BinaryOp, char * , GrB_Field);
```
"""
function GrB_BinaryOp_set_String(arg1, arg2, arg3)
    ccall((:GrB_BinaryOp_set_String, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_BinaryOp_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_BinaryOp_set_INT32 (GrB_BinaryOp, int32_t , GrB_Field);
```
"""
function GrB_BinaryOp_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_BinaryOp_set_INT32, libgraphblas), GrB_Info, (GrB_BinaryOp, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_BinaryOp_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_BinaryOp_set_VOID (GrB_BinaryOp, void * , GrB_Field, size_t);
```
"""
function GrB_BinaryOp_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_BinaryOp_set_VOID, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Monoid_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Monoid_set_Scalar (GrB_Monoid, GrB_Scalar, GrB_Field);
```
"""
function GrB_Monoid_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Monoid_set_Scalar, libgraphblas), GrB_Info, (GrB_Monoid, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Monoid_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Monoid_set_String (GrB_Monoid, char * , GrB_Field);
```
"""
function GrB_Monoid_set_String(arg1, arg2, arg3)
    ccall((:GrB_Monoid_set_String, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Monoid_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Monoid_set_INT32 (GrB_Monoid, int32_t , GrB_Field);
```
"""
function GrB_Monoid_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_Monoid_set_INT32, libgraphblas), GrB_Info, (GrB_Monoid, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Monoid_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_Monoid_set_VOID (GrB_Monoid, void * , GrB_Field, size_t);
```
"""
function GrB_Monoid_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_Monoid_set_VOID, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Semiring_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Semiring_set_Scalar (GrB_Semiring, GrB_Scalar, GrB_Field);
```
"""
function GrB_Semiring_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Semiring_set_Scalar, libgraphblas), GrB_Info, (GrB_Semiring, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Semiring_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Semiring_set_String (GrB_Semiring, char * , GrB_Field);
```
"""
function GrB_Semiring_set_String(arg1, arg2, arg3)
    ccall((:GrB_Semiring_set_String, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Semiring_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Semiring_set_INT32 (GrB_Semiring, int32_t , GrB_Field);
```
"""
function GrB_Semiring_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_Semiring_set_INT32, libgraphblas), GrB_Info, (GrB_Semiring, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Semiring_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_Semiring_set_VOID (GrB_Semiring, void * , GrB_Field, size_t);
```
"""
function GrB_Semiring_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_Semiring_set_VOID, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Type_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Type_set_Scalar (GrB_Type, GrB_Scalar, GrB_Field);
```
"""
function GrB_Type_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Type_set_Scalar, libgraphblas), GrB_Info, (GrB_Type, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Type_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Type_set_String (GrB_Type, char * , GrB_Field);
```
"""
function GrB_Type_set_String(arg1, arg2, arg3)
    ccall((:GrB_Type_set_String, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Type_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Type_set_INT32 (GrB_Type, int32_t , GrB_Field);
```
"""
function GrB_Type_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_Type_set_INT32, libgraphblas), GrB_Info, (GrB_Type, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Type_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_Type_set_VOID (GrB_Type, void * , GrB_Field, size_t);
```
"""
function GrB_Type_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_Type_set_VOID, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Descriptor_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Descriptor_set_Scalar (GrB_Descriptor, GrB_Scalar, GrB_Field);
```
"""
function GrB_Descriptor_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_set_Scalar, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Descriptor_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Descriptor_set_String (GrB_Descriptor, char * , GrB_Field);
```
"""
function GrB_Descriptor_set_String(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_set_String, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Descriptor_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Descriptor_set_INT32 (GrB_Descriptor, int32_t , GrB_Field);
```
"""
function GrB_Descriptor_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_set_INT32, libgraphblas), GrB_Info, (GrB_Descriptor, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Descriptor_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_Descriptor_set_VOID (GrB_Descriptor, void * , GrB_Field, size_t);
```
"""
function GrB_Descriptor_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_Descriptor_set_VOID, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Global_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Global_set_Scalar (GrB_Global, GrB_Scalar, GrB_Field);
```
"""
function GrB_Global_set_Scalar(arg1, arg2, arg3)
    ccall((:GrB_Global_set_Scalar, libgraphblas), GrB_Info, (GrB_Global, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Global_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Global_set_String (GrB_Global, char * , GrB_Field);
```
"""
function GrB_Global_set_String(arg1, arg2, arg3)
    ccall((:GrB_Global_set_String, libgraphblas), GrB_Info, (GrB_Global, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Global_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GrB_Global_set_INT32 (GrB_Global, int32_t , GrB_Field);
```
"""
function GrB_Global_set_INT32(arg1, arg2, arg3)
    ccall((:GrB_Global_set_INT32, libgraphblas), GrB_Info, (GrB_Global, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GrB_Global_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GrB_Global_set_VOID (GrB_Global, void * , GrB_Field, size_t);
```
"""
function GrB_Global_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GrB_Global_set_VOID, libgraphblas), GrB_Info, (GrB_Global, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GxB_Context_set_Scalar(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_set_Scalar (GxB_Context, GrB_Scalar, GrB_Field);
```
"""
function GxB_Context_set_Scalar(arg1, arg2, arg3)
    ccall((:GxB_Context_set_Scalar, libgraphblas), GrB_Info, (GxB_Context, GrB_Scalar, GrB_Field), arg1, arg2, arg3)
end

"""
    GxB_Context_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_set_String (GxB_Context, char * , GrB_Field);
```
"""
function GxB_Context_set_String(arg1, arg2, arg3)
    ccall((:GxB_Context_set_String, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cchar}, GrB_Field), arg1, arg2, arg3)
end

"""
    GxB_Context_set_INT(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_set_INT (GxB_Context, int32_t , GrB_Field);
```
"""
function GxB_Context_set_INT(arg1, arg2, arg3)
    ccall((:GxB_Context_set_INT, libgraphblas), GrB_Info, (GxB_Context, Int32, GrB_Field), arg1, arg2, arg3)
end

"""
    GxB_Context_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Context_set_VOID (GxB_Context, void * , GrB_Field, size_t);
```
"""
function GxB_Context_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GxB_Context_set_VOID, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cvoid}, GrB_Field, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Type_free(type)


### Prototype
```c
GrB_Info GrB_Type_free ( GrB_Type *type );
```
"""
function GrB_Type_free(type)
    ccall((:GrB_Type_free, libgraphblas), GrB_Info, (Ptr{GrB_Type},), type)
end

"""
    GrB_UnaryOp_free(unaryop)


### Prototype
```c
GrB_Info GrB_UnaryOp_free ( GrB_UnaryOp *unaryop );
```
"""
function GrB_UnaryOp_free(unaryop)
    ccall((:GrB_UnaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp},), unaryop)
end

"""
    GrB_BinaryOp_free(binaryop)


### Prototype
```c
GrB_Info GrB_BinaryOp_free ( GrB_BinaryOp *binaryop );
```
"""
function GrB_BinaryOp_free(binaryop)
    ccall((:GrB_BinaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp},), binaryop)
end

"""
    GrB_IndexUnaryOp_free(op)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_free ( GrB_IndexUnaryOp *op );
```
"""
function GrB_IndexUnaryOp_free(op)
    ccall((:GrB_IndexUnaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_IndexUnaryOp},), op)
end

"""
    GrB_Monoid_free(monoid)


### Prototype
```c
GrB_Info GrB_Monoid_free ( GrB_Monoid *monoid );
```
"""
function GrB_Monoid_free(monoid)
    ccall((:GrB_Monoid_free, libgraphblas), GrB_Info, (Ptr{GrB_Monoid},), monoid)
end

"""
    GrB_Semiring_free(semiring)


### Prototype
```c
GrB_Info GrB_Semiring_free ( GrB_Semiring *semiring );
```
"""
function GrB_Semiring_free(semiring)
    ccall((:GrB_Semiring_free, libgraphblas), GrB_Info, (Ptr{GrB_Semiring},), semiring)
end

"""
    GrB_Scalar_free(s)


### Prototype
```c
GrB_Info GrB_Scalar_free ( GrB_Scalar *s );
```
"""
function GrB_Scalar_free(s)
    ccall((:GrB_Scalar_free, libgraphblas), GrB_Info, (Ptr{GrB_Scalar},), s)
end

"""
    GrB_Vector_free(v)


### Prototype
```c
GrB_Info GrB_Vector_free ( GrB_Vector *v );
```
"""
function GrB_Vector_free(v)
    ccall((:GrB_Vector_free, libgraphblas), GrB_Info, (Ptr{GrB_Vector},), v)
end

"""
    GrB_Matrix_free(A)


### Prototype
```c
GrB_Info GrB_Matrix_free ( GrB_Matrix *A );
```
"""
function GrB_Matrix_free(A)
    ccall((:GrB_Matrix_free, libgraphblas), GrB_Info, (Ptr{GrB_Matrix},), A)
end

"""
    GrB_Descriptor_free(descriptor)


### Prototype
```c
GrB_Info GrB_Descriptor_free ( GrB_Descriptor *descriptor );
```
"""
function GrB_Descriptor_free(descriptor)
    ccall((:GrB_Descriptor_free, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), descriptor)
end

"""
    GxB_Context_free(Context)


### Prototype
```c
GrB_Info GxB_Context_free ( GxB_Context *Context );
```
"""
function GxB_Context_free(Context)
    ccall((:GxB_Context_free, libgraphblas), GrB_Info, (Ptr{GxB_Context},), Context)
end

"""
    GB_Iterator_opaque

The contents of an iterator must not be directly accessed by the user
application.  Only the functions and macros provided here may access
"iterator->..." contents.  The iterator is defined here only so that macros
can be used to speed up the use of the iterator methods.  User applications
must not use "iterator->..." directly.
"""
struct GB_Iterator_opaque
    pstart::Int64
    pend::Int64
    p::Int64
    k::Int64
    header_size::Csize_t
    pmax::Int64
    avlen::Int64
    avdim::Int64
    anvec::Int64
    Ap::Ptr{Int64}
    Ah::Ptr{Int64}
    Ab::Ptr{Int8}
    Ai::Ptr{Int64}
    Ax::Ptr{Cvoid}
    type_size::Csize_t
    A_sparsity::Cint
    iso::Bool
    by_col::Bool
end

const GxB_Iterator = Ptr{GB_Iterator_opaque}

"""
    GxB_Iterator_free(iterator)

GxB_Iterator_free: free an iterator
### Prototype
```c
GrB_Info GxB_Iterator_free (GxB_Iterator *iterator);
```
"""
function GxB_Iterator_free(iterator)
    ccall((:GxB_Iterator_free, libgraphblas), GrB_Info, (Ptr{GxB_Iterator},), iterator)
end

"""
    GrB_WaitMode

==============================================================================
GrB_wait: finish computations
==============================================================================
"""
@enum GrB_WaitMode::UInt32 begin
    GrB_COMPLETE = 0
    GrB_MATERIALIZE = 1
end

"""
    GrB_Type_wait(type, waitmode)

Finish all pending work in a specific object.
### Prototype
```c
GrB_Info GrB_Type_wait (GrB_Type type , GrB_WaitMode waitmode);
```
"""
function GrB_Type_wait(type, waitmode)
    ccall((:GrB_Type_wait, libgraphblas), GrB_Info, (GrB_Type, GrB_WaitMode), type, waitmode)
end

"""
    GrB_UnaryOp_wait(op, waitmode)


### Prototype
```c
GrB_Info GrB_UnaryOp_wait (GrB_UnaryOp op , GrB_WaitMode waitmode);
```
"""
function GrB_UnaryOp_wait(op, waitmode)
    ccall((:GrB_UnaryOp_wait, libgraphblas), GrB_Info, (GrB_UnaryOp, GrB_WaitMode), op, waitmode)
end

"""
    GrB_BinaryOp_wait(op, waitmode)


### Prototype
```c
GrB_Info GrB_BinaryOp_wait (GrB_BinaryOp op , GrB_WaitMode waitmode);
```
"""
function GrB_BinaryOp_wait(op, waitmode)
    ccall((:GrB_BinaryOp_wait, libgraphblas), GrB_Info, (GrB_BinaryOp, GrB_WaitMode), op, waitmode)
end

"""
    GrB_IndexUnaryOp_wait(op, waitmode)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_wait (GrB_IndexUnaryOp op , GrB_WaitMode waitmode);
```
"""
function GrB_IndexUnaryOp_wait(op, waitmode)
    ccall((:GrB_IndexUnaryOp_wait, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, GrB_WaitMode), op, waitmode)
end

"""
    GrB_Monoid_wait(monoid, waitmode)


### Prototype
```c
GrB_Info GrB_Monoid_wait (GrB_Monoid monoid , GrB_WaitMode waitmode);
```
"""
function GrB_Monoid_wait(monoid, waitmode)
    ccall((:GrB_Monoid_wait, libgraphblas), GrB_Info, (GrB_Monoid, GrB_WaitMode), monoid, waitmode)
end

"""
    GrB_Semiring_wait(semiring, waitmode)


### Prototype
```c
GrB_Info GrB_Semiring_wait (GrB_Semiring semiring, GrB_WaitMode waitmode);
```
"""
function GrB_Semiring_wait(semiring, waitmode)
    ccall((:GrB_Semiring_wait, libgraphblas), GrB_Info, (GrB_Semiring, GrB_WaitMode), semiring, waitmode)
end

"""
    GrB_Scalar_wait(s, waitmode)


### Prototype
```c
GrB_Info GrB_Scalar_wait (GrB_Scalar s , GrB_WaitMode waitmode);
```
"""
function GrB_Scalar_wait(s, waitmode)
    ccall((:GrB_Scalar_wait, libgraphblas), GrB_Info, (GrB_Scalar, GrB_WaitMode), s, waitmode)
end

"""
    GrB_Vector_wait(v, waitmode)


### Prototype
```c
GrB_Info GrB_Vector_wait (GrB_Vector v , GrB_WaitMode waitmode);
```
"""
function GrB_Vector_wait(v, waitmode)
    ccall((:GrB_Vector_wait, libgraphblas), GrB_Info, (GrB_Vector, GrB_WaitMode), v, waitmode)
end

"""
    GrB_Matrix_wait(A, waitmode)


### Prototype
```c
GrB_Info GrB_Matrix_wait (GrB_Matrix A , GrB_WaitMode waitmode);
```
"""
function GrB_Matrix_wait(A, waitmode)
    ccall((:GrB_Matrix_wait, libgraphblas), GrB_Info, (GrB_Matrix, GrB_WaitMode), A, waitmode)
end

"""
    GxB_Context_wait(Context, waitmode)


### Prototype
```c
GrB_Info GxB_Context_wait (GxB_Context Context , GrB_WaitMode waitmode);
```
"""
function GxB_Context_wait(Context, waitmode)
    ccall((:GxB_Context_wait, libgraphblas), GrB_Info, (GxB_Context, GrB_WaitMode), Context, waitmode)
end

"""
    GrB_Descriptor_wait(desc, waitmode)


### Prototype
```c
GrB_Info GrB_Descriptor_wait (GrB_Descriptor desc , GrB_WaitMode waitmode);
```
"""
function GrB_Descriptor_wait(desc, waitmode)
    ccall((:GrB_Descriptor_wait, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_WaitMode), desc, waitmode)
end

"""
    GrB_Type_error(error, type)

Each GraphBLAS method and operation returns a GrB_Info error code.
GrB_error returns additional information on the error in a thread-safe
null-terminated string.  The string returned by GrB_error is owned by
the GraphBLAS library and must not be free'd.
### Prototype
```c
GrB_Info GrB_Type_error (const char **error, const GrB_Type type);
```
"""
function GrB_Type_error(error, type)
    ccall((:GrB_Type_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Type), error, type)
end

"""
    GrB_UnaryOp_error(error, op)


### Prototype
```c
GrB_Info GrB_UnaryOp_error (const char **error, const GrB_UnaryOp op);
```
"""
function GrB_UnaryOp_error(error, op)
    ccall((:GrB_UnaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_UnaryOp), error, op)
end

"""
    GrB_BinaryOp_error(error, op)


### Prototype
```c
GrB_Info GrB_BinaryOp_error (const char **error, const GrB_BinaryOp op);
```
"""
function GrB_BinaryOp_error(error, op)
    ccall((:GrB_BinaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_BinaryOp), error, op)
end

"""
    GrB_IndexUnaryOp_error(error, op)


### Prototype
```c
GrB_Info GrB_IndexUnaryOp_error (const char **error, const GrB_IndexUnaryOp op);
```
"""
function GrB_IndexUnaryOp_error(error, op)
    ccall((:GrB_IndexUnaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_IndexUnaryOp), error, op)
end

"""
    GrB_Monoid_error(error, monoid)


### Prototype
```c
GrB_Info GrB_Monoid_error (const char **error, const GrB_Monoid monoid);
```
"""
function GrB_Monoid_error(error, monoid)
    ccall((:GrB_Monoid_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Monoid), error, monoid)
end

"""
    GrB_Semiring_error(error, semiring)


### Prototype
```c
GrB_Info GrB_Semiring_error (const char **error, const GrB_Semiring semiring);
```
"""
function GrB_Semiring_error(error, semiring)
    ccall((:GrB_Semiring_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Semiring), error, semiring)
end

"""
    GrB_Scalar_error(error, s)


### Prototype
```c
GrB_Info GrB_Scalar_error (const char **error, const GrB_Scalar s);
```
"""
function GrB_Scalar_error(error, s)
    ccall((:GrB_Scalar_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Scalar), error, s)
end

"""
    GrB_Vector_error(error, v)


### Prototype
```c
GrB_Info GrB_Vector_error (const char **error, const GrB_Vector v);
```
"""
function GrB_Vector_error(error, v)
    ccall((:GrB_Vector_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Vector), error, v)
end

"""
    GrB_Matrix_error(error, A)


### Prototype
```c
GrB_Info GrB_Matrix_error (const char **error, const GrB_Matrix A);
```
"""
function GrB_Matrix_error(error, A)
    ccall((:GrB_Matrix_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Matrix), error, A)
end

"""
    GxB_Context_error(error, Context)


### Prototype
```c
GrB_Info GxB_Context_error (const char **error, const GxB_Context Context);
```
"""
function GxB_Context_error(error, Context)
    ccall((:GxB_Context_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GxB_Context), error, Context)
end

"""
    GrB_Descriptor_error(error, d)


### Prototype
```c
GrB_Info GrB_Descriptor_error (const char **error, const GrB_Descriptor d);
```
"""
function GrB_Descriptor_error(error, d)
    ccall((:GrB_Descriptor_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Descriptor), error, d)
end

"""
    GrB_Matrix_eWiseMult_Semiring(C, Mask, accum, semiring, A, B, desc)


### Prototype
```c
GrB_Info GrB_Matrix_eWiseMult_Semiring ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Semiring semiring, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_eWiseMult_Semiring(C, Mask, accum, semiring, A, B, desc)
    ccall((:GrB_Matrix_eWiseMult_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

"""
    GrB_Matrix_eWiseMult_Monoid(C, Mask, accum, monoid, A, B, desc)


### Prototype
```c
GrB_Info GrB_Matrix_eWiseMult_Monoid ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_eWiseMult_Monoid(C, Mask, accum, monoid, A, B, desc)
    ccall((:GrB_Matrix_eWiseMult_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, monoid, A, B, desc)
end

"""
    GrB_Matrix_eWiseMult_BinaryOp(C, Mask, accum, mult, A, B, desc)


### Prototype
```c
GrB_Info GrB_Matrix_eWiseMult_BinaryOp ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp mult, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_eWiseMult_BinaryOp(C, Mask, accum, mult, A, B, desc)
    ccall((:GrB_Matrix_eWiseMult_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, mult, A, B, desc)
end

"""
    GrB_Vector_eWiseMult_Semiring(w, mask, accum, semiring, u, v, desc)

GrB_eWiseMult computes C<Mask> = accum (C, A.*B), where ".*" is the Hadamard
product, and where pairs of elements in two matrices (or vectors) are
pairwise "multiplied" with C(i,j) = mult (A(i,j),B(i,j)).
### Prototype
```c
GrB_Info GrB_Vector_eWiseMult_Semiring ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Semiring semiring, const GrB_Vector u, const GrB_Vector v, const GrB_Descriptor desc );
```
"""
function GrB_Vector_eWiseMult_Semiring(w, mask, accum, semiring, u, v, desc)
    ccall((:GrB_Vector_eWiseMult_Semiring, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, u, v, desc)
end

"""
    GrB_Vector_eWiseMult_Monoid(w, mask, accum, monoid, u, v, desc)


### Prototype
```c
GrB_Info GrB_Vector_eWiseMult_Monoid ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Vector v, const GrB_Descriptor desc );
```
"""
function GrB_Vector_eWiseMult_Monoid(w, mask, accum, monoid, u, v, desc)
    ccall((:GrB_Vector_eWiseMult_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, monoid, u, v, desc)
end

"""
    GrB_Vector_eWiseMult_BinaryOp(w, mask, accum, mult, u, v, desc)


### Prototype
```c
GrB_Info GrB_Vector_eWiseMult_BinaryOp ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp mult, const GrB_Vector u, const GrB_Vector v, const GrB_Descriptor desc );
```
"""
function GrB_Vector_eWiseMult_BinaryOp(w, mask, accum, mult, u, v, desc)
    ccall((:GrB_Vector_eWiseMult_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, mult, u, v, desc)
end

"""
    GrB_Matrix_eWiseAdd_Semiring(C, Mask, accum, semiring, A, B, desc)


### Prototype
```c
GrB_Info GrB_Matrix_eWiseAdd_Semiring ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Semiring semiring, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_eWiseAdd_Semiring(C, Mask, accum, semiring, A, B, desc)
    ccall((:GrB_Matrix_eWiseAdd_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

"""
    GrB_Matrix_eWiseAdd_Monoid(C, Mask, accum, monoid, A, B, desc)


### Prototype
```c
GrB_Info GrB_Matrix_eWiseAdd_Monoid ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_eWiseAdd_Monoid(C, Mask, accum, monoid, A, B, desc)
    ccall((:GrB_Matrix_eWiseAdd_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, monoid, A, B, desc)
end

"""
    GrB_Matrix_eWiseAdd_BinaryOp(C, Mask, accum, add, A, B, desc)


### Prototype
```c
GrB_Info GrB_Matrix_eWiseAdd_BinaryOp ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp add, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_eWiseAdd_BinaryOp(C, Mask, accum, add, A, B, desc)
    ccall((:GrB_Matrix_eWiseAdd_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, add, A, B, desc)
end

"""
    GrB_Vector_eWiseAdd_Semiring(w, mask, accum, semiring, u, v, desc)

GrB_eWiseAdd computes C<Mask> = accum (C, A+B), where pairs of elements in
two matrices (or two vectors) are pairwise "added".
### Prototype
```c
GrB_Info GrB_Vector_eWiseAdd_Semiring ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Semiring semiring, const GrB_Vector u, const GrB_Vector v, const GrB_Descriptor desc );
```
"""
function GrB_Vector_eWiseAdd_Semiring(w, mask, accum, semiring, u, v, desc)
    ccall((:GrB_Vector_eWiseAdd_Semiring, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, u, v, desc)
end

"""
    GrB_Vector_eWiseAdd_Monoid(w, mask, accum, monoid, u, v, desc)


### Prototype
```c
GrB_Info GrB_Vector_eWiseAdd_Monoid ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Vector v, const GrB_Descriptor desc );
```
"""
function GrB_Vector_eWiseAdd_Monoid(w, mask, accum, monoid, u, v, desc)
    ccall((:GrB_Vector_eWiseAdd_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, monoid, u, v, desc)
end

"""
    GrB_Vector_eWiseAdd_BinaryOp(w, mask, accum, add, u, v, desc)


### Prototype
```c
GrB_Info GrB_Vector_eWiseAdd_BinaryOp ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp add, const GrB_Vector u, const GrB_Vector v, const GrB_Descriptor desc );
```
"""
function GrB_Vector_eWiseAdd_BinaryOp(w, mask, accum, add, u, v, desc)
    ccall((:GrB_Vector_eWiseAdd_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, add, u, v, desc)
end

"""
    GxB_Matrix_eWiseUnion(C, Mask, accum, add, A, alpha, B, beta, desc)


### Prototype
```c
GrB_Info GxB_Matrix_eWiseUnion ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp add, const GrB_Matrix A, const GrB_Scalar alpha, const GrB_Matrix B, const GrB_Scalar beta, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_eWiseUnion(C, Mask, accum, add, A, alpha, B, beta, desc)
    ccall((:GxB_Matrix_eWiseUnion, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Scalar, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, add, A, alpha, B, beta, desc)
end

"""
    GxB_Vector_eWiseUnion(w, mask, accum, add, u, alpha, v, beta, desc)

if A(i,j) and B(i,j) are both present:
         C(i,j) = A(i,j) + B(i,j)
     else if A(i,j) is present but not B(i,j)
         C(i,j) = A(i,j) + beta
     else if B(i,j) is present but not A(i,j)
C(i,j) = alpha + B(i,j)
### Prototype
```c
GrB_Info GxB_Vector_eWiseUnion ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp add, const GrB_Vector u, const GrB_Scalar alpha, const GrB_Vector v, const GrB_Scalar beta, const GrB_Descriptor desc );
```
"""
function GxB_Vector_eWiseUnion(w, mask, accum, add, u, alpha, v, beta, desc)
    ccall((:GxB_Vector_eWiseUnion, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Scalar, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, add, u, alpha, v, beta, desc)
end

"""
    GrB_Vector_extract(w, mask, accum, u, I, ni, desc)

GrB_Index I [3], ni = GxB_BACKWARDS ;
     I [GxB_BEGIN ] = 10 ;               // the start of the sequence
     I [GxB_INC   ] = 2 ;                // the magnitude of the increment
I [GxB_END   ] = 1 ;                // the end of the sequence
### Prototype
```c
GrB_Info GrB_Vector_extract ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_extract(w, mask, accum, u, I, ni, desc)
    ccall((:GrB_Vector_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

"""
    GrB_Col_extract(w, mask, accum, A, I, ni, j, desc)


### Prototype
```c
GrB_Info GrB_Col_extract ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Index *I, GrB_Index ni, GrB_Index j, const GrB_Descriptor desc );
```
"""
function GrB_Col_extract(w, mask, accum, A, I, ni, j, desc)
    ccall((:GrB_Col_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), w, mask, accum, A, I, ni, j, desc)
end

"""
    GrB_Matrix_extract(C, Mask, accum, A, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_extract ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_extract(C, Mask, accum, A, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_extract, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

"""
    GxB_Vector_subassign_Scalar(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_Scalar ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, GrB_Scalar x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_Scalar(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign(w, mask, accum, u, I, ni, desc)

--- assign ------------------------------------------------------------------

GrB_Matrix_assign      C<M>(I,J) += A        M same size as matrix C.
                                             A is |I|-by-|J|

GrB_Vector_assign      w<m>(I)   += u        m same size as column vector w.
                                             u is |I|-by-1

GrB_Row_assign         C<m'>(i,J) += u'      m is a column vector the same
                                             size as a row of C.
                                             u is |J|-by-1, i is a scalar.

GrB_Col_assign         C<m>(I,j) += u        m is a column vector the same
                                             size as a column of C.
                                             u is |I|-by-1, j is a scalar.

--- subassign ---------------------------------------------------------------

GxB_Matrix_subassign   C(I,J)<M> += A        M same size as matrix A.
                                             A is |I|-by-|J|

GxB_Vector_subassign   w(I)<m>   += u        m same size as column vector u.
                                             u is |I|-by-1

GxB_Row_subassign      C(i,J)<m'> += u'      m same size as column vector u.
                                             u is |J|-by-1, i is a scalar.

GxB_Col_subassign      C(I,j)<m> += u        m same size as column vector u.
u is |I|-by-1, j is a scalar.
### Prototype
```c
GrB_Info GxB_Vector_subassign ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign(w, mask, accum, u, I, ni, desc)
    ccall((:GxB_Vector_subassign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

"""
    GxB_Matrix_subassign_Scalar(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_Scalar ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, GrB_Scalar x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_Scalar(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Col_subassign(C, mask, accum, u, I, ni, j, desc)


### Prototype
```c
GrB_Info GxB_Col_subassign ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I, GrB_Index ni, GrB_Index j, const GrB_Descriptor desc );
```
"""
function GxB_Col_subassign(C, mask, accum, u, I, ni, j, desc)
    ccall((:GxB_Col_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I, ni, j, desc)
end

"""
    GxB_Row_subassign(C, mask, accum, u, i, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Row_subassign ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, GrB_Index i, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Row_subassign(C, mask, accum, u, i, J, nj, desc)
    ccall((:GxB_Row_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, mask, accum, u, i, J, nj, desc)
end

"""
    GxB_Matrix_subassign(C, Mask, accum, A, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign(C, Mask, accum, A, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

"""
    GrB_Vector_assign_Scalar(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_Scalar ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, GrB_Scalar x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_Scalar(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign(w, mask, accum, u, I, ni, desc)

Assign entries in a matrix or vector; C(I,J) = A.
Each of these can be used with their generic name, GrB_assign.
### Prototype
```c
GrB_Info GrB_Vector_assign ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign(w, mask, accum, u, I, ni, desc)
    ccall((:GrB_Vector_assign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

"""
    GrB_Matrix_assign_Scalar(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_Scalar ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, GrB_Scalar x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_Scalar(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Col_assign(C, mask, accum, u, I, ni, j, desc)


### Prototype
```c
GrB_Info GrB_Col_assign ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I, GrB_Index ni, GrB_Index j, const GrB_Descriptor desc );
```
"""
function GrB_Col_assign(C, mask, accum, u, I, ni, j, desc)
    ccall((:GrB_Col_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I, ni, j, desc)
end

"""
    GrB_Row_assign(C, mask, accum, u, i, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Row_assign ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, GrB_Index i, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Row_assign(C, mask, accum, u, i, J, nj, desc)
    ccall((:GrB_Row_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, mask, accum, u, i, J, nj, desc)
end

"""
    GrB_Matrix_assign(C, Mask, accum, A, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign(C, Mask, accum, A, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

"""
    GrB_Vector_apply(w, mask, accum, op, u, desc)

Apply a unary, index_unary, or binary operator to entries in a matrix or
vector, C<M> = accum (C, op (A)).
### Prototype
```c
GrB_Info GrB_Vector_apply ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_UnaryOp op, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply(w, mask, accum, op, u, desc)
    ccall((:GrB_Vector_apply, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_UnaryOp, GrB_Vector, GrB_Descriptor), w, mask, accum, op, u, desc)
end

"""
    GrB_Matrix_apply(C, Mask, accum, op, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_UnaryOp op, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply(C, Mask, accum, op, A, desc)
    ccall((:GrB_Matrix_apply, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_UnaryOp, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, A, desc)
end

"""
    GrB_Vector_select_Scalar(w, mask, accum, op, u, y, desc)

-------------------------------------------
vector select using an IndexUnaryOp
-------------------------------------------
### Prototype
```c
GrB_Info GrB_Vector_select_Scalar ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, const GrB_Scalar y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_Scalar(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Matrix_select_Scalar(C, Mask, accum, op, A, y, desc)

-------------------------------------------
matrix select using an IndexUnaryOp
-------------------------------------------
### Prototype
```c
GrB_Info GrB_Matrix_select_Scalar ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, const GrB_Scalar y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_Scalar(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

mutable struct GB_SelectOp_opaque end

"""
historical; use GrB_select and GrB_IndexUnaryOp instead:
"""
const GxB_SelectOp = Ptr{GB_SelectOp_opaque}

"""
    GxB_Vector_select(w, mask, accum, op, u, Thunk, desc)

==============================================================================
GxB_select: matrix and vector selection (DEPRECATED: use GrB_select instead)
==============================================================================
### Prototype
```c
GrB_Info GxB_Vector_select (GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GxB_SelectOp op, const GrB_Vector u, const GrB_Scalar Thunk, const GrB_Descriptor desc);
```
"""
function GxB_Vector_select(w, mask, accum, op, u, Thunk, desc)
    ccall((:GxB_Vector_select, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_SelectOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, Thunk, desc)
end

"""
    GxB_Matrix_select(C, Mask, accum, op, A, Thunk, desc)


### Prototype
```c
GrB_Info GxB_Matrix_select (GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GxB_SelectOp op, const GrB_Matrix A, const GrB_Scalar Thunk, const GrB_Descriptor desc);
```
"""
function GxB_Matrix_select(C, Mask, accum, op, A, Thunk, desc)
    ccall((:GxB_Matrix_select, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_SelectOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, Thunk, desc)
end

"""
    GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)

For GrB_Matrix_reduce_BinaryOp, the GrB_BinaryOp op must correspond to a
known built-in monoid:

     operator                data-types (all built-in)
     ----------------------  ---------------------------
     MIN, MAX                INT*, UINT*, FP*
     TIMES, PLUS             INT*, UINT*, FP*, FC*
     ANY                     INT*, UINT*, FP*, FC*, BOOL
     LOR, LAND, LXOR, EQ     BOOL
BOR, BAND, BXOR, BXNOR  UINT*
### Prototype
```c
GrB_Info GrB_Matrix_reduce_Monoid ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), w, mask, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_BinaryOp(w, mask, accum, op, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_BinaryOp ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_BinaryOp(w, mask, accum, op, A, desc)
    ccall((:GrB_Matrix_reduce_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), w, mask, accum, op, A, desc)
end

"""
    GrB_Matrix_kronecker_Semiring(C, M, accum, semiring, A, B, desc)


### Prototype
```c
GrB_Info GrB_Matrix_kronecker_Semiring ( GrB_Matrix C, const GrB_Matrix M, const GrB_BinaryOp accum, const GrB_Semiring semiring, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_kronecker_Semiring(C, M, accum, semiring, A, B, desc)
    ccall((:GrB_Matrix_kronecker_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, semiring, A, B, desc)
end

"""
    GrB_Matrix_kronecker_Monoid(C, M, accum, monoid, A, B, desc)


### Prototype
```c
GrB_Info GrB_Matrix_kronecker_Monoid ( GrB_Matrix C, const GrB_Matrix M, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_kronecker_Monoid(C, M, accum, monoid, A, B, desc)
    ccall((:GrB_Matrix_kronecker_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, monoid, A, B, desc)
end

"""
    GrB_Matrix_kronecker_BinaryOp(C, M, accum, op, A, B, desc)


### Prototype
```c
GrB_Info GrB_Matrix_kronecker_BinaryOp ( GrB_Matrix C, const GrB_Matrix M, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_kronecker_BinaryOp(C, M, accum, op, A, B, desc)
    ccall((:GrB_Matrix_kronecker_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, op, A, B, desc)
end

"""
    GrB_Vector_resize(w, nrows_new)


### Prototype
```c
GrB_Info GrB_Vector_resize ( GrB_Vector w, GrB_Index nrows_new );
```
"""
function GrB_Vector_resize(w, nrows_new)
    ccall((:GrB_Vector_resize, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), w, nrows_new)
end

"""
    GrB_Matrix_resize(C, nrows_new, ncols_new)

If the dimensions decrease, entries that fall outside the resized matrix or
vector are deleted.
### Prototype
```c
GrB_Info GrB_Matrix_resize ( GrB_Matrix C, GrB_Index nrows_new, GrB_Index ncols_new );
```
"""
function GrB_Matrix_resize(C, nrows_new, ncols_new)
    ccall((:GrB_Matrix_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, nrows_new, ncols_new)
end

"""
    GxB_Print_Level

GxB_fprint (object, GxB_Print_Level pr, FILE *f) prints the contents of any
of the 9 GraphBLAS objects to the file f, and also does an extensive test on
the object to determine if it is valid.  It returns one of the following
error conditions:

     GrB_SUCCESS               object is valid
     GrB_UNINITIALIZED_OBJECT  object is not initialized
     GrB_INVALID_OBJECT        object is not valid
     GrB_NULL_POINTER          object is a NULL pointer
     GrB_INVALID_VALUE         fprintf returned an I/O error; see the ANSI C
                               errno or GrB_error( )for details.

GxB_fprint does not modify the status of any object.  If a matrix or vector
has not been completed, the pending computations are guaranteed to *not* be
performed by GxB_fprint.  The reason is simple.  It is possible for a bug in
the user application (such as accessing memory outside the bounds of an
array) to mangle the internal content of a GraphBLAS object, and GxB_fprint
can be a helpful tool to track down this bug.  If GxB_fprint attempted to
complete any computations prior to printing or checking the contents of the
matrix or vector, then further errors could occur, including a segfault.

The type-specific functions include an additional argument, the name string.
The name is printed at the beginning of the display (assuming pr is not
GxB_SILENT) so that the object can be more easily identified in the output.
For the type-generic methods GxB_fprint and GxB_print, the name string is
the variable name of the object itself.

If f is NULL, stdout is used; this is not an error condition.  If pr is
outside the bounds 0 to 3, negative values are treated as GxB_SILENT, and
values > 3 are treated as GxB_COMPLETE.  If name is NULL, it is treated as
the empty string.

GxB_print (object, GxB_Print_Level pr) is the same as GxB_fprint, except
that it prints the contents with printf instead of fprintf to a file f.

The exact content and format of what is printed is implementation-dependent,
and will change from version to version of SuiteSparse:GraphBLAS.  Do not
attempt to rely on the exact content or format by trying to parse the
resulting output via another program.  The intent of these functions is to
produce a report of the object for visual inspection.
"""
@enum GxB_Print_Level::UInt32 begin
    GxB_SILENT = 0
    GxB_SUMMARY = 1
    GxB_SHORT = 2
    GxB_COMPLETE = 3
    GxB_SHORT_VERBOSE = 4
    GxB_COMPLETE_VERBOSE = 5
end

"""
    GxB_Type_fprint(type, name, pr, f)


### Prototype
```c
GrB_Info GxB_Type_fprint ( GrB_Type type, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_Type_fprint(type, name, pr, f)
    ccall((:GxB_Type_fprint, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), type, name, pr, f)
end

"""
    GxB_UnaryOp_fprint(unaryop, name, pr, f)


### Prototype
```c
GrB_Info GxB_UnaryOp_fprint ( GrB_UnaryOp unaryop, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_UnaryOp_fprint(unaryop, name, pr, f)
    ccall((:GxB_UnaryOp_fprint, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), unaryop, name, pr, f)
end

"""
    GxB_BinaryOp_fprint(binaryop, name, pr, f)


### Prototype
```c
GrB_Info GxB_BinaryOp_fprint ( GrB_BinaryOp binaryop, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_BinaryOp_fprint(binaryop, name, pr, f)
    ccall((:GxB_BinaryOp_fprint, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), binaryop, name, pr, f)
end

"""
    GxB_IndexUnaryOp_fprint(op, name, pr, f)


### Prototype
```c
GrB_Info GxB_IndexUnaryOp_fprint ( GrB_IndexUnaryOp op, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_IndexUnaryOp_fprint(op, name, pr, f)
    ccall((:GxB_IndexUnaryOp_fprint, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), op, name, pr, f)
end

"""
    GxB_SelectOp_fprint(op, name, pr, f)


### Prototype
```c
GrB_Info GxB_SelectOp_fprint (GxB_SelectOp op, const char *name, GxB_Print_Level pr, FILE *f);
```
"""
function GxB_SelectOp_fprint(op, name, pr, f)
    ccall((:GxB_SelectOp_fprint, libgraphblas), GrB_Info, (GxB_SelectOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), op, name, pr, f)
end

"""
    GxB_Monoid_fprint(monoid, name, pr, f)


### Prototype
```c
GrB_Info GxB_Monoid_fprint ( GrB_Monoid monoid, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_Monoid_fprint(monoid, name, pr, f)
    ccall((:GxB_Monoid_fprint, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), monoid, name, pr, f)
end

"""
    GxB_Semiring_fprint(semiring, name, pr, f)


### Prototype
```c
GrB_Info GxB_Semiring_fprint ( GrB_Semiring semiring, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_Semiring_fprint(semiring, name, pr, f)
    ccall((:GxB_Semiring_fprint, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), semiring, name, pr, f)
end

"""
    GxB_Scalar_fprint(s, name, pr, f)


### Prototype
```c
GrB_Info GxB_Scalar_fprint ( GrB_Scalar s, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_Scalar_fprint(s, name, pr, f)
    ccall((:GxB_Scalar_fprint, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), s, name, pr, f)
end

"""
    GxB_Vector_fprint(v, name, pr, f)


### Prototype
```c
GrB_Info GxB_Vector_fprint ( GrB_Vector v, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_Vector_fprint(v, name, pr, f)
    ccall((:GxB_Vector_fprint, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), v, name, pr, f)
end

"""
    GxB_Matrix_fprint(A, name, pr, f)


### Prototype
```c
GrB_Info GxB_Matrix_fprint ( GrB_Matrix A, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_Matrix_fprint(A, name, pr, f)
    ccall((:GxB_Matrix_fprint, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), A, name, pr, f)
end

"""
    GxB_Descriptor_fprint(descriptor, name, pr, f)


### Prototype
```c
GrB_Info GxB_Descriptor_fprint ( GrB_Descriptor descriptor, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_Descriptor_fprint(descriptor, name, pr, f)
    ccall((:GxB_Descriptor_fprint, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), descriptor, name, pr, f)
end

"""
    GxB_Context_fprint(Context, name, pr, f)


### Prototype
```c
GrB_Info GxB_Context_fprint ( GxB_Context Context, const char *name, GxB_Print_Level pr, FILE *f );
```
"""
function GxB_Context_fprint(Context, name, pr, f)
    ccall((:GxB_Context_fprint, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), Context, name, pr, f)
end

"""
    GxB_Vector_sort(w, p, op, u, desc)

==============================================================================
GxB_Vector_sort and GxB_Matrix_sort: sort a matrix or vector
==============================================================================
### Prototype
```c
GrB_Info GxB_Vector_sort ( GrB_Vector w, GrB_Vector p, GrB_BinaryOp op, GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GxB_Vector_sort(w, p, op, u, desc)
    ccall((:GxB_Vector_sort, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Descriptor), w, p, op, u, desc)
end

"""
    GxB_Matrix_sort(C, P, op, A, desc)


### Prototype
```c
GrB_Info GxB_Matrix_sort ( GrB_Matrix C, GrB_Matrix P, GrB_BinaryOp op, GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_sort(C, P, op, A, desc)
    ccall((:GxB_Matrix_sort, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), C, P, op, A, desc)
end

"""
    GB_Iterator_rc_bitmap_next(iterator)

------------------------------------------------------------------------------
GB_Iterator_rc_bitmap_next: move a row/col iterator to next entry in bitmap
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GB_Iterator_rc_bitmap_next (GxB_Iterator iterator);
```
"""
function GB_Iterator_rc_bitmap_next(iterator)
    ccall((:GB_Iterator_rc_bitmap_next, libgraphblas), GrB_Info, (GxB_Iterator,), iterator)
end

"""
    GxB_Format_Value

GxB_FORMAT is historical, but it can be by row or by column:
"""
@enum GxB_Format_Value::Int32 begin
    GxB_BY_ROW = 0
    GxB_BY_COL = 1
    GxB_NO_FORMAT = -1
end

"""
    GB_Iterator_attach(iterator, A, format, desc)

------------------------------------------------------------------------------
GB_Iterator_attach: attach a row/col/entry iterator to a matrix
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GB_Iterator_attach ( GxB_Iterator iterator, GrB_Matrix A, GxB_Format_Value format, GrB_Descriptor desc );
```
"""
function GB_Iterator_attach(iterator, A, format, desc)
    ccall((:GB_Iterator_attach, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Matrix, GxB_Format_Value, GrB_Descriptor), iterator, A, format, desc)
end

"""
    GB_Iterator_rc_seek(iterator, j, jth_vector)

------------------------------------------------------------------------------
GB_Iterator_rc_seek: seek a row/col iterator to a particular vector
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GB_Iterator_rc_seek ( GxB_Iterator iterator, GrB_Index j, bool jth_vector );
```
"""
function GB_Iterator_rc_seek(iterator, j, jth_vector)
    ccall((:GB_Iterator_rc_seek, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Index, Bool), iterator, j, jth_vector)
end

"""
    GB_Vector_Iterator_bitmap_seek(iterator, unused)

Returns GrB_SUCCESS if the iterator is at an entry that exists in the
vector, or GxB_EXHAUSTED if the iterator is exhausted.
### Prototype
```c
GrB_Info GB_Vector_Iterator_bitmap_seek (GxB_Iterator iterator, GrB_Index unused);
```
"""
function GB_Vector_Iterator_bitmap_seek(iterator, unused)
    ccall((:GB_Vector_Iterator_bitmap_seek, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Index), iterator, unused)
end

"""
    GrB_Mode

The extension GxB_init does the work of GrB_init, but it also defines the
memory management functions that SuiteSparse:GraphBLAS will use internally.
"""
@enum GrB_Mode::UInt32 begin
    GrB_NONBLOCKING = 0
    GrB_BLOCKING = 1
    GxB_NONBLOCKING_GPU = 7099
    GxB_BLOCKING_GPU = 7098
end

"""
    GrB_init(mode)


### Prototype
```c
GrB_Info GrB_init ( GrB_Mode mode );
```
"""
function GrB_init(mode)
    ccall((:GrB_init, libgraphblas), GrB_Info, (GrB_Mode,), mode)
end

"""
    GxB_init(mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)


### Prototype
```c
GrB_Info GxB_init ( GrB_Mode mode, void * (* user_malloc_function ) (size_t), void * (* user_calloc_function ) (size_t, size_t), void * (* user_realloc_function ) (void *, size_t), void (* user_free_function ) (void *) );
```
"""
function GxB_init(mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)
    ccall((:GxB_init, libgraphblas), GrB_Info, (GrB_Mode, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}), mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)
end

"""
    GrB_finalize()


### Prototype
```c
GrB_Info GrB_finalize (void);
```
"""
function GrB_finalize()
    ccall((:GrB_finalize, libgraphblas), GrB_Info, ())
end

"""
    GrB_getVersion(version, subversion)

GrB_getVersion provides a runtime access of the C API Version.  Can also be
done with two calls to GrB_Global_get_INT32 with the v2.1 C API:

     GrB_get (GrB_GLOBAL, &version,    GrB_API_VER_MAJOR) ;
GrB_get (GrB_GLOBAL, &subversion, GrB_API_VER_MINOR) ;
### Prototype
```c
GrB_Info GrB_getVersion ( unsigned int *version, unsigned int *subversion );
```
"""
function GrB_getVersion(version, subversion)
    ccall((:GrB_getVersion, libgraphblas), GrB_Info, (Ptr{Cuint}, Ptr{Cuint}), version, subversion)
end

@enum GrB_Desc_Field::UInt32 begin
    GrB_OUTP = 0
    GrB_MASK = 1
    GrB_INP0 = 2
    GrB_INP1 = 3
    GxB_AxB_METHOD = 7090
    GxB_SORT = 7091
    GxB_COMPRESSION = 7092
    GxB_IMPORT = 7093
end

@enum GrB_Desc_Value::UInt32 begin
    GrB_DEFAULT = 0
    # GxB_DEFAULT = 0
    GrB_REPLACE = 1
    GrB_COMP = 2
    GrB_STRUCTURE = 4
    GrB_COMP_STRUCTURE = 6
    GrB_TRAN = 3
    GxB_AxB_GUSTAVSON = 7081
    GxB_AxB_DOT = 7083
    GxB_AxB_HASH = 7084
    GxB_AxB_SAXPY = 7085
    GxB_SECURE_IMPORT = 7080
end

"""
    GrB_Descriptor_new(descriptor)


### Prototype
```c
GrB_Info GrB_Descriptor_new ( GrB_Descriptor *descriptor );
```
"""
function GrB_Descriptor_new(descriptor)
    ccall((:GrB_Descriptor_new, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), descriptor)
end

"""
    GrB_Descriptor_set(arg1, arg2, arg3)

historical methods; use GrB_set and GrB_get instead:
### Prototype
```c
GrB_Info GrB_Descriptor_set (GrB_Descriptor, GrB_Desc_Field, GrB_Desc_Value);
```
"""
function GrB_Descriptor_set(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_set, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Desc_Field, GrB_Desc_Value), arg1, arg2, arg3)
end

"""
    GxB_Descriptor_get(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Descriptor_get (GrB_Desc_Value *, GrB_Descriptor, GrB_Desc_Field);
```
"""
function GxB_Descriptor_get(arg1, arg2, arg3)
    ccall((:GxB_Descriptor_get, libgraphblas), GrB_Info, (Ptr{GrB_Desc_Value}, GrB_Descriptor, GrB_Desc_Field), arg1, arg2, arg3)
end

"""
    GxB_Desc_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Desc_set_INT32 (GrB_Descriptor, GrB_Desc_Field, int32_t);
```
"""
function GxB_Desc_set_INT32(arg1, arg2, arg3)
    ccall((:GxB_Desc_set_INT32, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Desc_Field, Int32), arg1, arg2, arg3)
end

"""
    GxB_Desc_set_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Desc_set_FP64 (GrB_Descriptor, GrB_Desc_Field, double);
```
"""
function GxB_Desc_set_FP64(arg1, arg2, arg3)
    ccall((:GxB_Desc_set_FP64, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Desc_Field, Cdouble), arg1, arg2, arg3)
end

"""
    GxB_Desc_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Desc_get_INT32 (GrB_Descriptor, GrB_Desc_Field, int32_t *);
```
"""
function GxB_Desc_get_INT32(arg1, arg2, arg3)
    ccall((:GxB_Desc_get_INT32, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Desc_Field, Ptr{Int32}), arg1, arg2, arg3)
end

"""
    GxB_Desc_get_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Desc_get_FP64 (GrB_Descriptor, GrB_Desc_Field, double *);
```
"""
function GxB_Desc_get_FP64(arg1, arg2, arg3)
    ccall((:GxB_Desc_get_FP64, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Desc_Field, Ptr{Cdouble}), arg1, arg2, arg3)
end

"""
    GrB_Type_new(type, sizeof_ctype)

------------------------------------------------------------------------------
GrB_Type_new:  create a new type
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GrB_Type_new ( GrB_Type *type, size_t sizeof_ctype );
```
"""
function GrB_Type_new(type, sizeof_ctype)
    ccall((:GrB_Type_new, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Csize_t), type, sizeof_ctype)
end

"""
    GxB_Type_new(type, sizeof_ctype, type_name, type_defn)


### Prototype
```c
GrB_Info GxB_Type_new ( GrB_Type *type, size_t sizeof_ctype, const char *type_name, const char *type_defn );
```
"""
function GxB_Type_new(type, sizeof_ctype, type_name, type_defn)
    ccall((:GxB_Type_new, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Csize_t, Ptr{Cchar}, Ptr{Cchar}), type, sizeof_ctype, type_name, type_defn)
end

"""
    GxB_Type_name(type_name, type)

historical; use GrB_get instead:
### Prototype
```c
GrB_Info GxB_Type_name (char *type_name, const GrB_Type type);
```
"""
function GxB_Type_name(type_name, type)
    ccall((:GxB_Type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Type), type_name, type)
end

"""
    GxB_Type_size(size, type)


### Prototype
```c
GrB_Info GxB_Type_size (size_t *size, const GrB_Type type);
```
"""
function GxB_Type_size(size, type)
    ccall((:GxB_Type_size, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Type), size, type)
end

"""
    GxB_Type_from_name(type, type_name)


### Prototype
```c
GrB_Info GxB_Type_from_name ( GrB_Type *type, const char *type_name );
```
"""
function GxB_Type_from_name(type, type_name)
    ccall((:GxB_Type_from_name, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Ptr{Cchar}), type, type_name)
end

# typedef void ( * GxB_unary_function ) ( void * , const void * )
"""
------------------------------------------------------------------------------
methods for unary operators
------------------------------------------------------------------------------
"""
const GxB_unary_function = Ptr{Cvoid}

"""
    GrB_UnaryOp_new(unaryop, _function, ztype, xtype)

GrB_UnaryOp_new creates a user-defined unary op (with no name or defn)
### Prototype
```c
GrB_Info GrB_UnaryOp_new ( GrB_UnaryOp *unaryop, GxB_unary_function function, GrB_Type ztype, GrB_Type xtype );
```
"""
function GrB_UnaryOp_new(unaryop, _function, ztype, xtype)
    ccall((:GrB_UnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp}, GxB_unary_function, GrB_Type, GrB_Type), unaryop, _function, ztype, xtype)
end

"""
    GxB_UnaryOp_new(unaryop, _function, ztype, xtype, unop_name, unop_defn)

GxB_UnaryOp_new creates a named and defined user-defined unary op.
### Prototype
```c
GrB_Info GxB_UnaryOp_new ( GrB_UnaryOp *unaryop, GxB_unary_function function, GrB_Type ztype, GrB_Type xtype, const char *unop_name, const char *unop_defn );
```
"""
function GxB_UnaryOp_new(unaryop, _function, ztype, xtype, unop_name, unop_defn)
    ccall((:GxB_UnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp}, GxB_unary_function, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), unaryop, _function, ztype, xtype, unop_name, unop_defn)
end

"""
    GxB_UnaryOp_ztype(ztype, unaryop)

historical; use GrB_get instead:
### Prototype
```c
GrB_Info GxB_UnaryOp_ztype (GrB_Type *ztype, GrB_UnaryOp unaryop);
```
"""
function GxB_UnaryOp_ztype(ztype, unaryop)
    ccall((:GxB_UnaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), ztype, unaryop)
end

"""
    GxB_UnaryOp_ztype_name(type_name, unaryop)


### Prototype
```c
GrB_Info GxB_UnaryOp_ztype_name (char *type_name, const GrB_UnaryOp unaryop);
```
"""
function GxB_UnaryOp_ztype_name(type_name, unaryop)
    ccall((:GxB_UnaryOp_ztype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_UnaryOp), type_name, unaryop)
end

"""
    GxB_UnaryOp_xtype(xtype, unaryop)


### Prototype
```c
GrB_Info GxB_UnaryOp_xtype (GrB_Type *xtype, GrB_UnaryOp unaryop);
```
"""
function GxB_UnaryOp_xtype(xtype, unaryop)
    ccall((:GxB_UnaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), xtype, unaryop)
end

"""
    GxB_UnaryOp_xtype_name(type_name, unaryop)


### Prototype
```c
GrB_Info GxB_UnaryOp_xtype_name (char *type_name, const GrB_UnaryOp unaryop);
```
"""
function GxB_UnaryOp_xtype_name(type_name, unaryop)
    ccall((:GxB_UnaryOp_xtype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_UnaryOp), type_name, unaryop)
end

# typedef void ( * GxB_binary_function ) ( void * , const void * , const void * )
"""
------------------------------------------------------------------------------
methods for binary operators
------------------------------------------------------------------------------
"""
const GxB_binary_function = Ptr{Cvoid}

"""
    GrB_BinaryOp_new(binaryop, _function, ztype, xtype, ytype)

GrB_BinaryOp_new creates a user-defined binary op (no name or defn)
### Prototype
```c
GrB_Info GrB_BinaryOp_new ( GrB_BinaryOp *binaryop, GxB_binary_function function, GrB_Type ztype, GrB_Type xtype, GrB_Type ytype );
```
"""
function GrB_BinaryOp_new(binaryop, _function, ztype, xtype, ytype)
    ccall((:GrB_BinaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_binary_function, GrB_Type, GrB_Type, GrB_Type), binaryop, _function, ztype, xtype, ytype)
end

"""
    GxB_BinaryOp_new(op, _function, ztype, xtype, ytype, binop_name, binop_defn)

GxB_BinaryOp_new creates a named and defined user-defined binary op.
### Prototype
```c
GrB_Info GxB_BinaryOp_new ( GrB_BinaryOp *op, GxB_binary_function function, GrB_Type ztype, GrB_Type xtype, GrB_Type ytype, const char *binop_name, const char *binop_defn );
```
"""
function GxB_BinaryOp_new(op, _function, ztype, xtype, ytype, binop_name, binop_defn)
    ccall((:GxB_BinaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_binary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), op, _function, ztype, xtype, ytype, binop_name, binop_defn)
end

"""
    GxB_BinaryOp_ztype(ztype, op)

historical; use GrB_get instead:
### Prototype
```c
GrB_Info GxB_BinaryOp_ztype (GrB_Type *ztype, GrB_BinaryOp op);
```
"""
function GxB_BinaryOp_ztype(ztype, op)
    ccall((:GxB_BinaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), ztype, op)
end

"""
    GxB_BinaryOp_ztype_name(type_name, op)


### Prototype
```c
GrB_Info GxB_BinaryOp_ztype_name (char *type_name, const GrB_BinaryOp op);
```
"""
function GxB_BinaryOp_ztype_name(type_name, op)
    ccall((:GxB_BinaryOp_ztype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_BinaryOp), type_name, op)
end

"""
    GxB_BinaryOp_xtype(xtype, op)


### Prototype
```c
GrB_Info GxB_BinaryOp_xtype (GrB_Type *xtype, GrB_BinaryOp op);
```
"""
function GxB_BinaryOp_xtype(xtype, op)
    ccall((:GxB_BinaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), xtype, op)
end

"""
    GxB_BinaryOp_xtype_name(type_name, op)


### Prototype
```c
GrB_Info GxB_BinaryOp_xtype_name (char *type_name, const GrB_BinaryOp op);
```
"""
function GxB_BinaryOp_xtype_name(type_name, op)
    ccall((:GxB_BinaryOp_xtype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_BinaryOp), type_name, op)
end

"""
    GxB_BinaryOp_ytype(ytype, op)


### Prototype
```c
GrB_Info GxB_BinaryOp_ytype (GrB_Type *ytype, GrB_BinaryOp op);
```
"""
function GxB_BinaryOp_ytype(ytype, op)
    ccall((:GxB_BinaryOp_ytype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), ytype, op)
end

"""
    GxB_BinaryOp_ytype_name(type_name, op)


### Prototype
```c
GrB_Info GxB_BinaryOp_ytype_name (char *type_name, const GrB_BinaryOp op);
```
"""
function GxB_BinaryOp_ytype_name(type_name, op)
    ccall((:GxB_BinaryOp_ytype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_BinaryOp), type_name, op)
end

"""
    GxB_SelectOp_xtype(xtype, selectop)


### Prototype
```c
GrB_Info GxB_SelectOp_xtype (GrB_Type *xtype, GxB_SelectOp selectop);
```
"""
function GxB_SelectOp_xtype(xtype, selectop)
    ccall((:GxB_SelectOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), xtype, selectop)
end

"""
    GxB_SelectOp_ttype(ttype, selectop)


### Prototype
```c
GrB_Info GxB_SelectOp_ttype (GrB_Type *ttype, GxB_SelectOp selectop);
```
"""
function GxB_SelectOp_ttype(ttype, selectop)
    ccall((:GxB_SelectOp_ttype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), ttype, selectop)
end

# typedef void ( * GxB_index_unary_function ) ( void * z , // output value z, of type ztype const void * x , // input value x of type xtype; value of v(i) or A(i,j) GrB_Index i , // row index of A(i,j) GrB_Index j , // column index of A(i,j), or zero for v(i) const void * y // input scalar y )
const GxB_index_unary_function = Ptr{Cvoid}

"""
    GrB_IndexUnaryOp_new(op, _function, ztype, xtype, ytype)

GrB_IndexUnaryOp_new creates a user-defined unary op (no name or defn)
### Prototype
```c
GrB_Info GrB_IndexUnaryOp_new ( GrB_IndexUnaryOp *op, GxB_index_unary_function function, GrB_Type ztype, GrB_Type xtype, GrB_Type ytype );
```
"""
function GrB_IndexUnaryOp_new(op, _function, ztype, xtype, ytype)
    ccall((:GrB_IndexUnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_IndexUnaryOp}, GxB_index_unary_function, GrB_Type, GrB_Type, GrB_Type), op, _function, ztype, xtype, ytype)
end

"""
    GxB_IndexUnaryOp_new(op, _function, ztype, xtype, ytype, idxop_name, idxop_defn)


### Prototype
```c
GrB_Info GxB_IndexUnaryOp_new ( GrB_IndexUnaryOp *op, GxB_index_unary_function function, GrB_Type ztype, GrB_Type xtype, GrB_Type ytype, const char *idxop_name, const char *idxop_defn );
```
"""
function GxB_IndexUnaryOp_new(op, _function, ztype, xtype, ytype, idxop_name, idxop_defn)
    ccall((:GxB_IndexUnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_IndexUnaryOp}, GxB_index_unary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), op, _function, ztype, xtype, ytype, idxop_name, idxop_defn)
end

"""
    GxB_IndexUnaryOp_ztype_name(arg1, op)

historical; use GrB_get instead:
### Prototype
```c
GrB_Info GxB_IndexUnaryOp_ztype_name (char *, const GrB_IndexUnaryOp op);
```
"""
function GxB_IndexUnaryOp_ztype_name(arg1, op)
    ccall((:GxB_IndexUnaryOp_ztype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_IndexUnaryOp), arg1, op)
end

"""
    GxB_IndexUnaryOp_xtype_name(arg1, op)


### Prototype
```c
GrB_Info GxB_IndexUnaryOp_xtype_name (char *, const GrB_IndexUnaryOp op);
```
"""
function GxB_IndexUnaryOp_xtype_name(arg1, op)
    ccall((:GxB_IndexUnaryOp_xtype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_IndexUnaryOp), arg1, op)
end

"""
    GxB_IndexUnaryOp_ytype_name(arg1, op)


### Prototype
```c
GrB_Info GxB_IndexUnaryOp_ytype_name (char *, const GrB_IndexUnaryOp op);
```
"""
function GxB_IndexUnaryOp_ytype_name(arg1, op)
    ccall((:GxB_IndexUnaryOp_ytype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_IndexUnaryOp), arg1, op)
end

"""
    GrB_Monoid_new_BOOL(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_BOOL ( GrB_Monoid *monoid, GrB_BinaryOp op, bool identity );
```
"""
function GrB_Monoid_new_BOOL(monoid, op, identity)
    ccall((:GrB_Monoid_new_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool), monoid, op, identity)
end

"""
    GrB_Monoid_new_INT8(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_INT8 ( GrB_Monoid *monoid, GrB_BinaryOp op, int8_t identity );
```
"""
function GrB_Monoid_new_INT8(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8), monoid, op, identity)
end

"""
    GrB_Monoid_new_UINT8(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_UINT8 ( GrB_Monoid *monoid, GrB_BinaryOp op, uint8_t identity );
```
"""
function GrB_Monoid_new_UINT8(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8), monoid, op, identity)
end

"""
    GrB_Monoid_new_INT16(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_INT16 ( GrB_Monoid *monoid, GrB_BinaryOp op, int16_t identity );
```
"""
function GrB_Monoid_new_INT16(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16), monoid, op, identity)
end

"""
    GrB_Monoid_new_UINT16(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_UINT16 ( GrB_Monoid *monoid, GrB_BinaryOp op, uint16_t identity );
```
"""
function GrB_Monoid_new_UINT16(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16), monoid, op, identity)
end

"""
    GrB_Monoid_new_INT32(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_INT32 ( GrB_Monoid *monoid, GrB_BinaryOp op, int32_t identity );
```
"""
function GrB_Monoid_new_INT32(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32), monoid, op, identity)
end

"""
    GrB_Monoid_new_UINT32(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_UINT32 ( GrB_Monoid *monoid, GrB_BinaryOp op, uint32_t identity );
```
"""
function GrB_Monoid_new_UINT32(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32), monoid, op, identity)
end

"""
    GrB_Monoid_new_INT64(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_INT64 ( GrB_Monoid *monoid, GrB_BinaryOp op, int64_t identity );
```
"""
function GrB_Monoid_new_INT64(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64), monoid, op, identity)
end

"""
    GrB_Monoid_new_UINT64(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_UINT64 ( GrB_Monoid *monoid, GrB_BinaryOp op, uint64_t identity );
```
"""
function GrB_Monoid_new_UINT64(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64), monoid, op, identity)
end

"""
    GrB_Monoid_new_FP32(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_FP32 ( GrB_Monoid *monoid, GrB_BinaryOp op, float identity );
```
"""
function GrB_Monoid_new_FP32(monoid, op, identity)
    ccall((:GrB_Monoid_new_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat), monoid, op, identity)
end

"""
    GrB_Monoid_new_FP64(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_FP64 ( GrB_Monoid *monoid, GrB_BinaryOp op, double identity );
```
"""
function GrB_Monoid_new_FP64(monoid, op, identity)
    ccall((:GrB_Monoid_new_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble), monoid, op, identity)
end

"""
    GxB_Monoid_new_FC32(monoid, op, identity)


### Prototype
```c
GrB_Info GxB_Monoid_new_FC32 ( GrB_Monoid *monoid, GrB_BinaryOp op, GxB_FC32_t identity );
```
"""
function GxB_Monoid_new_FC32(monoid, op, identity)
    ccall((:GxB_Monoid_new_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t), monoid, op, identity)
end

"""
    GxB_Monoid_new_FC64(monoid, op, identity)


### Prototype
```c
GrB_Info GxB_Monoid_new_FC64 ( GrB_Monoid *monoid, GrB_BinaryOp op, GxB_FC64_t identity );
```
"""
function GxB_Monoid_new_FC64(monoid, op, identity)
    ccall((:GxB_Monoid_new_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t), monoid, op, identity)
end

"""
    GrB_Monoid_new_UDT(monoid, op, identity)


### Prototype
```c
GrB_Info GrB_Monoid_new_UDT ( GrB_Monoid *monoid, GrB_BinaryOp op, void *identity );
```
"""
function GrB_Monoid_new_UDT(monoid, op, identity)
    ccall((:GrB_Monoid_new_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}), monoid, op, identity)
end

"""
    GxB_Monoid_terminal_new_BOOL(monoid, op, identity, terminal)

GxB_Monoid_terminal_new is identical to GrB_Monoid_new, except that a
terminal value can be specified.  The terminal may be NULL, which indicates
no terminal value (and in this case, it is identical to GrB_Monoid_new).
The terminal value, if not NULL, must have the same type as the identity.
### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_BOOL ( GrB_Monoid *monoid, GrB_BinaryOp op, bool identity, bool terminal );
```
"""
function GxB_Monoid_terminal_new_BOOL(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool, Bool), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_INT8(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_INT8 ( GrB_Monoid *monoid, GrB_BinaryOp op, int8_t identity, int8_t terminal );
```
"""
function GxB_Monoid_terminal_new_INT8(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8, Int8), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UINT8(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_UINT8 ( GrB_Monoid *monoid, GrB_BinaryOp op, uint8_t identity, uint8_t terminal );
```
"""
function GxB_Monoid_terminal_new_UINT8(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8, UInt8), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_INT16(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_INT16 ( GrB_Monoid *monoid, GrB_BinaryOp op, int16_t identity, int16_t terminal );
```
"""
function GxB_Monoid_terminal_new_INT16(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16, Int16), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UINT16(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_UINT16 ( GrB_Monoid *monoid, GrB_BinaryOp op, uint16_t identity, uint16_t terminal );
```
"""
function GxB_Monoid_terminal_new_UINT16(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16, UInt16), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_INT32(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_INT32 ( GrB_Monoid *monoid, GrB_BinaryOp op, int32_t identity, int32_t terminal );
```
"""
function GxB_Monoid_terminal_new_INT32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32, Int32), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UINT32(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_UINT32 ( GrB_Monoid *monoid, GrB_BinaryOp op, uint32_t identity, uint32_t terminal );
```
"""
function GxB_Monoid_terminal_new_UINT32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32, UInt32), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_INT64(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_INT64 ( GrB_Monoid *monoid, GrB_BinaryOp op, int64_t identity, int64_t terminal );
```
"""
function GxB_Monoid_terminal_new_INT64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64, Int64), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UINT64(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_UINT64 ( GrB_Monoid *monoid, GrB_BinaryOp op, uint64_t identity, uint64_t terminal );
```
"""
function GxB_Monoid_terminal_new_UINT64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64, UInt64), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_FP32(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_FP32 ( GrB_Monoid *monoid, GrB_BinaryOp op, float identity, float terminal );
```
"""
function GxB_Monoid_terminal_new_FP32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat, Cfloat), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_FP64(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_FP64 ( GrB_Monoid *monoid, GrB_BinaryOp op, double identity, double terminal );
```
"""
function GxB_Monoid_terminal_new_FP64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble, Cdouble), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_FC32(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_FC32 ( GrB_Monoid *monoid, GrB_BinaryOp op, GxB_FC32_t identity, GxB_FC32_t terminal );
```
"""
function GxB_Monoid_terminal_new_FC32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t, GxB_FC32_t), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_FC64(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_FC64 ( GrB_Monoid *monoid, GrB_BinaryOp op, GxB_FC64_t identity, GxB_FC64_t terminal );
```
"""
function GxB_Monoid_terminal_new_FC64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t, GxB_FC64_t), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UDT(monoid, op, identity, terminal)


### Prototype
```c
GrB_Info GxB_Monoid_terminal_new_UDT ( GrB_Monoid *monoid, GrB_BinaryOp op, void *identity, void *terminal );
```
"""
function GxB_Monoid_terminal_new_UDT(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}, Ptr{Cvoid}), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_operator(op, monoid)

historical; use GrB_get instead:
### Prototype
```c
GrB_Info GxB_Monoid_operator (GrB_BinaryOp *op, GrB_Monoid monoid);
```
"""
function GxB_Monoid_operator(op, monoid)
    ccall((:GxB_Monoid_operator, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GrB_Monoid), op, monoid)
end

"""
    GxB_Monoid_identity(identity, monoid)


### Prototype
```c
GrB_Info GxB_Monoid_identity (void *identity, GrB_Monoid monoid);
```
"""
function GxB_Monoid_identity(identity, monoid)
    ccall((:GxB_Monoid_identity, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Monoid), identity, monoid)
end

"""
    GxB_Monoid_terminal(arg1, terminal, monoid)


### Prototype
```c
GrB_Info GxB_Monoid_terminal (bool *, void *terminal, GrB_Monoid monoid);
```
"""
function GxB_Monoid_terminal(arg1, terminal, monoid)
    ccall((:GxB_Monoid_terminal, libgraphblas), GrB_Info, (Ptr{Bool}, Ptr{Cvoid}, GrB_Monoid), arg1, terminal, monoid)
end

"""
    GrB_Semiring_new(semiring, add, multiply)


### Prototype
```c
GrB_Info GrB_Semiring_new ( GrB_Semiring *semiring, GrB_Monoid add, GrB_BinaryOp multiply );
```
"""
function GrB_Semiring_new(semiring, add, multiply)
    ccall((:GrB_Semiring_new, libgraphblas), GrB_Info, (Ptr{GrB_Semiring}, GrB_Monoid, GrB_BinaryOp), semiring, add, multiply)
end

"""
    GxB_Semiring_add(add, semiring)

historical; use GrB_get instead:
### Prototype
```c
GrB_Info GxB_Semiring_add (GrB_Monoid *add, GrB_Semiring semiring);
```
"""
function GxB_Semiring_add(add, semiring)
    ccall((:GxB_Semiring_add, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_Semiring), add, semiring)
end

"""
    GxB_Semiring_multiply(multiply, semiring)


### Prototype
```c
GrB_Info GxB_Semiring_multiply (GrB_BinaryOp *multiply, GrB_Semiring semiring);
```
"""
function GxB_Semiring_multiply(multiply, semiring)
    ccall((:GxB_Semiring_multiply, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GrB_Semiring), multiply, semiring)
end

"""
==============================================================================
GrB_Scalar: a GraphBLAS scalar
==============================================================================
"""
const GxB_Scalar = Ptr{GB_Scalar_opaque}

"""
    GrB_Scalar_new(s, type)

These methods create, free, copy, and clear a GrB_Scalar.  The nvals,
and type methods return basic information about a GrB_Scalar.
### Prototype
```c
GrB_Info GrB_Scalar_new ( GrB_Scalar *s, GrB_Type type );
```
"""
function GrB_Scalar_new(s, type)
    ccall((:GrB_Scalar_new, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Type), s, type)
end

"""
    GrB_Scalar_dup(s, t)


### Prototype
```c
GrB_Info GrB_Scalar_dup ( GrB_Scalar *s, const GrB_Scalar t );
```
"""
function GrB_Scalar_dup(s, t)
    ccall((:GrB_Scalar_dup, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Scalar), s, t)
end

"""
    GrB_Scalar_clear(s)


### Prototype
```c
GrB_Info GrB_Scalar_clear ( GrB_Scalar s );
```
"""
function GrB_Scalar_clear(s)
    ccall((:GrB_Scalar_clear, libgraphblas), GrB_Info, (GrB_Scalar,), s)
end

"""
    GrB_Scalar_nvals(nvals, s)


### Prototype
```c
GrB_Info GrB_Scalar_nvals ( GrB_Index *nvals, const GrB_Scalar s );
```
"""
function GrB_Scalar_nvals(nvals, s)
    ccall((:GrB_Scalar_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Scalar), nvals, s)
end

"""
    GxB_Scalar_type(type, s)

historical; use GrB_get instead:
### Prototype
```c
GrB_Info GxB_Scalar_type (GrB_Type *type, const GrB_Scalar s);
```
"""
function GxB_Scalar_type(type, s)
    ccall((:GxB_Scalar_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Scalar), type, s)
end

"""
    GxB_Scalar_type_name(type_name, s)


### Prototype
```c
GrB_Info GxB_Scalar_type_name (char *type_name, const GrB_Scalar s);
```
"""
function GxB_Scalar_type_name(type_name, s)
    ccall((:GxB_Scalar_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Scalar), type_name, s)
end

"""
    GxB_Scalar_memoryUsage(size, s)


### Prototype
```c
GrB_Info GxB_Scalar_memoryUsage ( size_t *size, const GrB_Scalar s );
```
"""
function GxB_Scalar_memoryUsage(size, s)
    ccall((:GxB_Scalar_memoryUsage, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Scalar), size, s)
end

"""
    GxB_Scalar_new(s, type)

historical names identical to GrB_Scalar_methods above:
### Prototype
```c
GrB_Info GxB_Scalar_new (GrB_Scalar *s, GrB_Type type);
```
"""
function GxB_Scalar_new(s, type)
    ccall((:GxB_Scalar_new, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Type), s, type)
end

"""
    GxB_Scalar_dup(s, t)


### Prototype
```c
GrB_Info GxB_Scalar_dup (GrB_Scalar *s, const GrB_Scalar t);
```
"""
function GxB_Scalar_dup(s, t)
    ccall((:GxB_Scalar_dup, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Scalar), s, t)
end

"""
    GxB_Scalar_clear(s)


### Prototype
```c
GrB_Info GxB_Scalar_clear (GrB_Scalar s);
```
"""
function GxB_Scalar_clear(s)
    ccall((:GxB_Scalar_clear, libgraphblas), GrB_Info, (GrB_Scalar,), s)
end

"""
    GxB_Scalar_nvals(nvals, s)


### Prototype
```c
GrB_Info GxB_Scalar_nvals (GrB_Index *nvals, const GrB_Scalar s);
```
"""
function GxB_Scalar_nvals(nvals, s)
    ccall((:GxB_Scalar_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Scalar), nvals, s)
end

"""
    GxB_Scalar_free(s)


### Prototype
```c
GrB_Info GxB_Scalar_free (GrB_Scalar *s);
```
"""
function GxB_Scalar_free(s)
    ccall((:GxB_Scalar_free, libgraphblas), GrB_Info, (Ptr{GrB_Scalar},), s)
end

"""
    GrB_Scalar_setElement_BOOL(s, x)

Set a single GrB_Scalar s, from a user scalar x: s = x, typecasting from the
type of x to the type of w as needed.
### Prototype
```c
GrB_Info GrB_Scalar_setElement_BOOL ( GrB_Scalar s, bool x );
```
"""
function GrB_Scalar_setElement_BOOL(s, x)
    ccall((:GrB_Scalar_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Scalar, Bool), s, x)
end

"""
    GrB_Scalar_setElement_INT8(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_INT8 ( GrB_Scalar s, int8_t x );
```
"""
function GrB_Scalar_setElement_INT8(s, x)
    ccall((:GrB_Scalar_setElement_INT8, libgraphblas), GrB_Info, (GrB_Scalar, Int8), s, x)
end

"""
    GrB_Scalar_setElement_UINT8(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_UINT8 ( GrB_Scalar s, uint8_t x );
```
"""
function GrB_Scalar_setElement_UINT8(s, x)
    ccall((:GrB_Scalar_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Scalar, UInt8), s, x)
end

"""
    GrB_Scalar_setElement_INT16(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_INT16 ( GrB_Scalar s, int16_t x );
```
"""
function GrB_Scalar_setElement_INT16(s, x)
    ccall((:GrB_Scalar_setElement_INT16, libgraphblas), GrB_Info, (GrB_Scalar, Int16), s, x)
end

"""
    GrB_Scalar_setElement_UINT16(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_UINT16 ( GrB_Scalar s, uint16_t x );
```
"""
function GrB_Scalar_setElement_UINT16(s, x)
    ccall((:GrB_Scalar_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Scalar, UInt16), s, x)
end

"""
    GrB_Scalar_setElement_INT32(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_INT32 ( GrB_Scalar s, int32_t x );
```
"""
function GrB_Scalar_setElement_INT32(s, x)
    ccall((:GrB_Scalar_setElement_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Int32), s, x)
end

"""
    GrB_Scalar_setElement_UINT32(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_UINT32 ( GrB_Scalar s, uint32_t x );
```
"""
function GrB_Scalar_setElement_UINT32(s, x)
    ccall((:GrB_Scalar_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Scalar, UInt32), s, x)
end

"""
    GrB_Scalar_setElement_INT64(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_INT64 ( GrB_Scalar s, int64_t x );
```
"""
function GrB_Scalar_setElement_INT64(s, x)
    ccall((:GrB_Scalar_setElement_INT64, libgraphblas), GrB_Info, (GrB_Scalar, Int64), s, x)
end

"""
    GrB_Scalar_setElement_UINT64(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_UINT64 ( GrB_Scalar s, uint64_t x );
```
"""
function GrB_Scalar_setElement_UINT64(s, x)
    ccall((:GrB_Scalar_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Scalar, UInt64), s, x)
end

"""
    GrB_Scalar_setElement_FP32(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_FP32 ( GrB_Scalar s, float x );
```
"""
function GrB_Scalar_setElement_FP32(s, x)
    ccall((:GrB_Scalar_setElement_FP32, libgraphblas), GrB_Info, (GrB_Scalar, Cfloat), s, x)
end

"""
    GrB_Scalar_setElement_FP64(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_FP64 ( GrB_Scalar s, double x );
```
"""
function GrB_Scalar_setElement_FP64(s, x)
    ccall((:GrB_Scalar_setElement_FP64, libgraphblas), GrB_Info, (GrB_Scalar, Cdouble), s, x)
end

"""
    GxB_Scalar_setElement_FC32(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_FC32 ( GrB_Scalar s, GxB_FC32_t x );
```
"""
function GxB_Scalar_setElement_FC32(s, x)
    ccall((:GxB_Scalar_setElement_FC32, libgraphblas), GrB_Info, (GrB_Scalar, GxB_FC32_t), s, x)
end

"""
    GxB_Scalar_setElement_FC64(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_FC64 ( GrB_Scalar s, GxB_FC64_t x );
```
"""
function GxB_Scalar_setElement_FC64(s, x)
    ccall((:GxB_Scalar_setElement_FC64, libgraphblas), GrB_Info, (GrB_Scalar, GxB_FC64_t), s, x)
end

"""
    GrB_Scalar_setElement_UDT(s, x)


### Prototype
```c
GrB_Info GrB_Scalar_setElement_UDT ( GrB_Scalar s, void *x );
```
"""
function GrB_Scalar_setElement_UDT(s, x)
    ccall((:GrB_Scalar_setElement_UDT, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}), s, x)
end

"""
    GxB_Scalar_setElement_BOOL(s, x)

historical names identical to GrB_Scalar_methods above:
### Prototype
```c
GrB_Info GxB_Scalar_setElement_BOOL (GrB_Scalar s, bool x);
```
"""
function GxB_Scalar_setElement_BOOL(s, x)
    ccall((:GxB_Scalar_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Scalar, Bool), s, x)
end

"""
    GxB_Scalar_setElement_INT8(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_INT8 (GrB_Scalar s, int8_t x);
```
"""
function GxB_Scalar_setElement_INT8(s, x)
    ccall((:GxB_Scalar_setElement_INT8, libgraphblas), GrB_Info, (GrB_Scalar, Int8), s, x)
end

"""
    GxB_Scalar_setElement_INT16(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_INT16 (GrB_Scalar s, int16_t x);
```
"""
function GxB_Scalar_setElement_INT16(s, x)
    ccall((:GxB_Scalar_setElement_INT16, libgraphblas), GrB_Info, (GrB_Scalar, Int16), s, x)
end

"""
    GxB_Scalar_setElement_INT32(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_INT32 (GrB_Scalar s, int32_t x);
```
"""
function GxB_Scalar_setElement_INT32(s, x)
    ccall((:GxB_Scalar_setElement_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Int32), s, x)
end

"""
    GxB_Scalar_setElement_INT64(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_INT64 (GrB_Scalar s, int64_t x);
```
"""
function GxB_Scalar_setElement_INT64(s, x)
    ccall((:GxB_Scalar_setElement_INT64, libgraphblas), GrB_Info, (GrB_Scalar, Int64), s, x)
end

"""
    GxB_Scalar_setElement_UINT8(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UINT8 (GrB_Scalar s, uint8_t x);
```
"""
function GxB_Scalar_setElement_UINT8(s, x)
    ccall((:GxB_Scalar_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Scalar, UInt8), s, x)
end

"""
    GxB_Scalar_setElement_UINT16(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UINT16 (GrB_Scalar s, uint16_t x);
```
"""
function GxB_Scalar_setElement_UINT16(s, x)
    ccall((:GxB_Scalar_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Scalar, UInt16), s, x)
end

"""
    GxB_Scalar_setElement_UINT32(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UINT32 (GrB_Scalar s, uint32_t x);
```
"""
function GxB_Scalar_setElement_UINT32(s, x)
    ccall((:GxB_Scalar_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Scalar, UInt32), s, x)
end

"""
    GxB_Scalar_setElement_UINT64(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UINT64 (GrB_Scalar s, uint64_t x);
```
"""
function GxB_Scalar_setElement_UINT64(s, x)
    ccall((:GxB_Scalar_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Scalar, UInt64), s, x)
end

"""
    GxB_Scalar_setElement_FP32(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_FP32 (GrB_Scalar s, float x);
```
"""
function GxB_Scalar_setElement_FP32(s, x)
    ccall((:GxB_Scalar_setElement_FP32, libgraphblas), GrB_Info, (GrB_Scalar, Cfloat), s, x)
end

"""
    GxB_Scalar_setElement_FP64(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_FP64 (GrB_Scalar s, double x);
```
"""
function GxB_Scalar_setElement_FP64(s, x)
    ccall((:GxB_Scalar_setElement_FP64, libgraphblas), GrB_Info, (GrB_Scalar, Cdouble), s, x)
end

"""
    GxB_Scalar_setElement_UDT(s, x)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UDT (GrB_Scalar s, void *x);
```
"""
function GxB_Scalar_setElement_UDT(s, x)
    ccall((:GxB_Scalar_setElement_UDT, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}), s, x)
end

"""
    GrB_Scalar_extractElement_BOOL(x, s)

Extract a single entry from a GrB_Scalar, x = s, typecasting from the type
of s to the type of x as needed.
### Prototype
```c
GrB_Info GrB_Scalar_extractElement_BOOL ( bool *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_BOOL(x, s)
    ccall((:GrB_Scalar_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_INT8(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_INT8 ( int8_t *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_INT8(x, s)
    ccall((:GrB_Scalar_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UINT8(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_UINT8 ( uint8_t *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_UINT8(x, s)
    ccall((:GrB_Scalar_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_INT16(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_INT16 ( int16_t *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_INT16(x, s)
    ccall((:GrB_Scalar_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UINT16(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_UINT16 ( uint16_t *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_UINT16(x, s)
    ccall((:GrB_Scalar_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_INT32(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_INT32 ( int32_t *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_INT32(x, s)
    ccall((:GrB_Scalar_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UINT32(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_UINT32 ( uint32_t *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_UINT32(x, s)
    ccall((:GrB_Scalar_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_INT64(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_INT64 ( int64_t *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_INT64(x, s)
    ccall((:GrB_Scalar_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UINT64(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_UINT64 ( uint64_t *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_UINT64(x, s)
    ccall((:GrB_Scalar_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_FP32(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_FP32 ( float *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_FP32(x, s)
    ccall((:GrB_Scalar_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_FP64(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_FP64 ( double *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_FP64(x, s)
    ccall((:GrB_Scalar_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_FC32(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_FC32 ( GxB_FC32_t *x, const GrB_Scalar s );
```
"""
function GxB_Scalar_extractElement_FC32(x, s)
    ccall((:GxB_Scalar_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_FC64(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_FC64 ( GxB_FC64_t *x, const GrB_Scalar s );
```
"""
function GxB_Scalar_extractElement_FC64(x, s)
    ccall((:GxB_Scalar_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UDT(x, s)


### Prototype
```c
GrB_Info GrB_Scalar_extractElement_UDT ( void *x, const GrB_Scalar s );
```
"""
function GrB_Scalar_extractElement_UDT(x, s)
    ccall((:GrB_Scalar_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_BOOL(x, s)

historical names identical to GrB_Scalar_methods above:
### Prototype
```c
GrB_Info GxB_Scalar_extractElement_BOOL (bool *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_BOOL(x, s)
    ccall((:GxB_Scalar_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_INT8(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_INT8 (int8_t *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_INT8(x, s)
    ccall((:GxB_Scalar_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_INT16(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_INT16 (int16_t *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_INT16(x, s)
    ccall((:GxB_Scalar_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_INT32(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_INT32 (int32_t *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_INT32(x, s)
    ccall((:GxB_Scalar_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_INT64(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_INT64 (int64_t *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_INT64(x, s)
    ccall((:GxB_Scalar_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_UINT8(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UINT8 (uint8_t *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_UINT8(x, s)
    ccall((:GxB_Scalar_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_UINT16(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UINT16 (uint16_t *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_UINT16(x, s)
    ccall((:GxB_Scalar_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_UINT32(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UINT32 (uint32_t *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_UINT32(x, s)
    ccall((:GxB_Scalar_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_UINT64(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UINT64 (uint64_t *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_UINT64(x, s)
    ccall((:GxB_Scalar_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_FP32(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_FP32 (float *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_FP32(x, s)
    ccall((:GxB_Scalar_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_FP64(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_FP64 (double *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_FP64(x, s)
    ccall((:GxB_Scalar_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_UDT(x, s)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UDT (void *x, const GrB_Scalar s);
```
"""
function GxB_Scalar_extractElement_UDT(x, s)
    ccall((:GxB_Scalar_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Scalar), x, s)
end

"""
    GrB_Vector_new(v, type, n)

These methods create, free, copy, and clear a vector.  The size, nvals,
and type methods return basic information about a vector.
### Prototype
```c
GrB_Info GrB_Vector_new ( GrB_Vector *v, GrB_Type type, GrB_Index n );
```
"""
function GrB_Vector_new(v, type, n)
    ccall((:GrB_Vector_new, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index), v, type, n)
end

"""
    GrB_Vector_dup(w, u)


### Prototype
```c
GrB_Info GrB_Vector_dup ( GrB_Vector *w, const GrB_Vector u );
```
"""
function GrB_Vector_dup(w, u)
    ccall((:GrB_Vector_dup, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Vector), w, u)
end

"""
    GrB_Vector_clear(v)


### Prototype
```c
GrB_Info GrB_Vector_clear ( GrB_Vector v );
```
"""
function GrB_Vector_clear(v)
    ccall((:GrB_Vector_clear, libgraphblas), GrB_Info, (GrB_Vector,), v)
end

"""
    GrB_Vector_size(n, v)


### Prototype
```c
GrB_Info GrB_Vector_size ( GrB_Index *n, const GrB_Vector v );
```
"""
function GrB_Vector_size(n, v)
    ccall((:GrB_Vector_size, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Vector), n, v)
end

"""
    GrB_Vector_nvals(nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_nvals ( GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_nvals(nvals, v)
    ccall((:GrB_Vector_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Vector), nvals, v)
end

"""
    GxB_Vector_type(type, v)

historical; use GrB_get instead:
### Prototype
```c
GrB_Info GxB_Vector_type (GrB_Type *type, const GrB_Vector v);
```
"""
function GxB_Vector_type(type, v)
    ccall((:GxB_Vector_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Vector), type, v)
end

"""
    GxB_Vector_type_name(type_name, v)


### Prototype
```c
GrB_Info GxB_Vector_type_name (char *type_name, const GrB_Vector v);
```
"""
function GxB_Vector_type_name(type_name, v)
    ccall((:GxB_Vector_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Vector), type_name, v)
end

"""
    GxB_Vector_memoryUsage(size, v)


### Prototype
```c
GrB_Info GxB_Vector_memoryUsage ( size_t *size, const GrB_Vector v );
```
"""
function GxB_Vector_memoryUsage(size, v)
    ccall((:GxB_Vector_memoryUsage, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Vector), size, v)
end

"""
    GxB_Vector_iso(iso, v)


### Prototype
```c
GrB_Info GxB_Vector_iso ( bool *iso, const GrB_Vector v );
```
"""
function GxB_Vector_iso(iso, v)
    ccall((:GxB_Vector_iso, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Vector), iso, v)
end

"""
    GrB_Vector_build_BOOL(w, I, X, nvals, dup)

GrB_Vector_build:  w = sparse (I,1,X), but using any
associative operator to assemble duplicate entries.
### Prototype
```c
GrB_Info GrB_Vector_build_BOOL ( GrB_Vector w, const GrB_Index *I, const bool *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_BOOL(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_BOOL, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Bool}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_INT8(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_INT8 ( GrB_Vector w, const GrB_Index *I, const int8_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_INT8(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_INT8, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int8}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_UINT8(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_UINT8 ( GrB_Vector w, const GrB_Index *I, const uint8_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_UINT8(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT8, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt8}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_INT16(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_INT16 ( GrB_Vector w, const GrB_Index *I, const int16_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_INT16(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_INT16, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int16}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_UINT16(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_UINT16 ( GrB_Vector w, const GrB_Index *I, const uint16_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_UINT16(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT16, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt16}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_INT32(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_INT32 ( GrB_Vector w, const GrB_Index *I, const int32_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_INT32(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_INT32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int32}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_UINT32(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_UINT32 ( GrB_Vector w, const GrB_Index *I, const uint32_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_UINT32(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt32}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_INT64(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_INT64 ( GrB_Vector w, const GrB_Index *I, const int64_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_INT64(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_INT64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int64}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_UINT64(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_UINT64 ( GrB_Vector w, const GrB_Index *I, const uint64_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_UINT64(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt64}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_FP32(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_FP32 ( GrB_Vector w, const GrB_Index *I, const float *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_FP32(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_FP32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cfloat}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_FP64(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_FP64 ( GrB_Vector w, const GrB_Index *I, const double *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_FP64(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_FP64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cdouble}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GxB_Vector_build_FC32(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GxB_Vector_build_FC32 ( GrB_Vector w, const GrB_Index *I, const GxB_FC32_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GxB_Vector_build_FC32(w, I, X, nvals, dup)
    ccall((:GxB_Vector_build_FC32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GxB_Vector_build_FC64(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GxB_Vector_build_FC64 ( GrB_Vector w, const GrB_Index *I, const GxB_FC64_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GxB_Vector_build_FC64(w, I, X, nvals, dup)
    ccall((:GxB_Vector_build_FC64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GrB_Vector_build_UDT(w, I, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Vector_build_UDT ( GrB_Vector w, const GrB_Index *I, const void *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Vector_build_UDT(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UDT, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

"""
    GxB_Vector_build_Scalar(w, I, scalar, nvals)


### Prototype
```c
GrB_Info GxB_Vector_build_Scalar ( GrB_Vector w, const GrB_Index *I, GrB_Scalar scalar, GrB_Index nvals );
```
"""
function GxB_Vector_build_Scalar(w, I, scalar, nvals)
    ccall((:GxB_Vector_build_Scalar, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, GrB_Scalar, GrB_Index), w, I, scalar, nvals)
end

"""
    GrB_Vector_setElement_BOOL(w, x, i)

Set a single scalar in a vector, w(i) = x, typecasting from the type of x to
the type of w as needed.
### Prototype
```c
GrB_Info GrB_Vector_setElement_BOOL ( GrB_Vector w, bool x, GrB_Index i );
```
"""
function GrB_Vector_setElement_BOOL(w, x, i)
    ccall((:GrB_Vector_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Vector, Bool, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_INT8(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_INT8 ( GrB_Vector w, int8_t x, GrB_Index i );
```
"""
function GrB_Vector_setElement_INT8(w, x, i)
    ccall((:GrB_Vector_setElement_INT8, libgraphblas), GrB_Info, (GrB_Vector, Int8, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UINT8(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_UINT8 ( GrB_Vector w, uint8_t x, GrB_Index i );
```
"""
function GrB_Vector_setElement_UINT8(w, x, i)
    ccall((:GrB_Vector_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Vector, UInt8, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_INT16(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_INT16 ( GrB_Vector w, int16_t x, GrB_Index i );
```
"""
function GrB_Vector_setElement_INT16(w, x, i)
    ccall((:GrB_Vector_setElement_INT16, libgraphblas), GrB_Info, (GrB_Vector, Int16, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UINT16(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_UINT16 ( GrB_Vector w, uint16_t x, GrB_Index i );
```
"""
function GrB_Vector_setElement_UINT16(w, x, i)
    ccall((:GrB_Vector_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Vector, UInt16, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_INT32(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_INT32 ( GrB_Vector w, int32_t x, GrB_Index i );
```
"""
function GrB_Vector_setElement_INT32(w, x, i)
    ccall((:GrB_Vector_setElement_INT32, libgraphblas), GrB_Info, (GrB_Vector, Int32, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UINT32(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_UINT32 ( GrB_Vector w, uint32_t x, GrB_Index i );
```
"""
function GrB_Vector_setElement_UINT32(w, x, i)
    ccall((:GrB_Vector_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Vector, UInt32, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_INT64(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_INT64 ( GrB_Vector w, int64_t x, GrB_Index i );
```
"""
function GrB_Vector_setElement_INT64(w, x, i)
    ccall((:GrB_Vector_setElement_INT64, libgraphblas), GrB_Info, (GrB_Vector, Int64, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UINT64(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_UINT64 ( GrB_Vector w, uint64_t x, GrB_Index i );
```
"""
function GrB_Vector_setElement_UINT64(w, x, i)
    ccall((:GrB_Vector_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Vector, UInt64, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_FP32(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_FP32 ( GrB_Vector w, float x, GrB_Index i );
```
"""
function GrB_Vector_setElement_FP32(w, x, i)
    ccall((:GrB_Vector_setElement_FP32, libgraphblas), GrB_Info, (GrB_Vector, Cfloat, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_FP64(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_FP64 ( GrB_Vector w, double x, GrB_Index i );
```
"""
function GrB_Vector_setElement_FP64(w, x, i)
    ccall((:GrB_Vector_setElement_FP64, libgraphblas), GrB_Info, (GrB_Vector, Cdouble, GrB_Index), w, x, i)
end

"""
    GxB_Vector_setElement_FC32(w, x, i)


### Prototype
```c
GrB_Info GxB_Vector_setElement_FC32 ( GrB_Vector w, GxB_FC32_t x, GrB_Index i );
```
"""
function GxB_Vector_setElement_FC32(w, x, i)
    ccall((:GxB_Vector_setElement_FC32, libgraphblas), GrB_Info, (GrB_Vector, GxB_FC32_t, GrB_Index), w, x, i)
end

"""
    GxB_Vector_setElement_FC64(w, x, i)


### Prototype
```c
GrB_Info GxB_Vector_setElement_FC64 ( GrB_Vector w, GxB_FC64_t x, GrB_Index i );
```
"""
function GxB_Vector_setElement_FC64(w, x, i)
    ccall((:GxB_Vector_setElement_FC64, libgraphblas), GrB_Info, (GrB_Vector, GxB_FC64_t, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UDT(w, x, i)


### Prototype
```c
GrB_Info GrB_Vector_setElement_UDT ( GrB_Vector w, void *x, GrB_Index i );
```
"""
function GrB_Vector_setElement_UDT(w, x, i)
    ccall((:GrB_Vector_setElement_UDT, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cvoid}, GrB_Index), w, x, i)
end

"""
    GrB_Vector_extractElement_BOOL(x, v, i)

Extract a single entry from a vector, x = v(i), typecasting from the type of
v to the type of x as needed.
### Prototype
```c
GrB_Info GrB_Vector_extractElement_BOOL ( bool *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_BOOL(x, v, i)
    ccall((:GrB_Vector_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_INT8(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_INT8 ( int8_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_INT8(x, v, i)
    ccall((:GrB_Vector_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UINT8(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_UINT8 ( uint8_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_UINT8(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_INT16(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_INT16 ( int16_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_INT16(x, v, i)
    ccall((:GrB_Vector_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UINT16(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_UINT16 ( uint16_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_UINT16(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_INT32(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_INT32 ( int32_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_INT32(x, v, i)
    ccall((:GrB_Vector_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UINT32(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_UINT32 ( uint32_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_UINT32(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_INT64(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_INT64 ( int64_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_INT64(x, v, i)
    ccall((:GrB_Vector_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UINT64(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_UINT64 ( uint64_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_UINT64(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_FP32(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_FP32 ( float *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_FP32(x, v, i)
    ccall((:GrB_Vector_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_FP64(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_FP64 ( double *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_FP64(x, v, i)
    ccall((:GrB_Vector_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GxB_Vector_extractElement_FC32(x, v, i)


### Prototype
```c
GrB_Info GxB_Vector_extractElement_FC32 ( GxB_FC32_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GxB_Vector_extractElement_FC32(x, v, i)
    ccall((:GxB_Vector_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GxB_Vector_extractElement_FC64(x, v, i)


### Prototype
```c
GrB_Info GxB_Vector_extractElement_FC64 ( GxB_FC64_t *x, const GrB_Vector v, GrB_Index i );
```
"""
function GxB_Vector_extractElement_FC64(x, v, i)
    ccall((:GxB_Vector_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UDT(x, v, i)


### Prototype
```c
GrB_Info GrB_Vector_extractElement_UDT ( void *x, const GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_extractElement_UDT(x, v, i)
    ccall((:GrB_Vector_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GxB_Vector_isStoredElement(v, i)

GxB_Vector_isStoredElement determines if v(i) is present in the structure
of the vector v, as a stored element.  It does not return the value.  It
returns GrB_SUCCESS if the element is present, or GrB_NO_VALUE otherwise.
### Prototype
```c
GrB_Info GxB_Vector_isStoredElement ( const GrB_Vector v, GrB_Index i );
```
"""
function GxB_Vector_isStoredElement(v, i)
    ccall((:GxB_Vector_isStoredElement, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), v, i)
end

"""
    GrB_Vector_removeElement(v, i)

GrB_Vector_removeElement (v,i) removes the element v(i) from the vector v.
### Prototype
```c
GrB_Info GrB_Vector_removeElement ( GrB_Vector v, GrB_Index i );
```
"""
function GrB_Vector_removeElement(v, i)
    ccall((:GrB_Vector_removeElement, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), v, i)
end

"""
    GrB_Vector_extractTuples_BOOL(I, X, nvals, v)

Extracts all tuples from a vector, like [I,~,X] = find (v).  If
any parameter I and/or X is NULL, then that component is not extracted.  For
example, to extract just the row indices, pass I as non-NULL, and X as NULL.
This is like [I,~,~] = find (v).
### Prototype
```c
GrB_Info GrB_Vector_extractTuples_BOOL ( GrB_Index *I, bool *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_BOOL(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_INT8(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_INT8 ( GrB_Index *I, int8_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_INT8(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int8}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_UINT8(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_UINT8 ( GrB_Index *I, uint8_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_UINT8(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt8}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_INT16(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_INT16 ( GrB_Index *I, int16_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_INT16(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int16}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_UINT16(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_UINT16 ( GrB_Index *I, uint16_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_UINT16(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt16}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_INT32(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_INT32 ( GrB_Index *I, int32_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_INT32(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int32}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_UINT32(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_UINT32 ( GrB_Index *I, uint32_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_UINT32(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt32}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_INT64(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_INT64 ( GrB_Index *I, int64_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_INT64(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int64}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_UINT64(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_UINT64 ( GrB_Index *I, uint64_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_UINT64(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt64}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_FP32(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_FP32 ( GrB_Index *I, float *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_FP32(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cfloat}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_FP64(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_FP64 ( GrB_Index *I, double *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_FP64(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cdouble}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GxB_Vector_extractTuples_FC32(I, X, nvals, v)


### Prototype
```c
GrB_Info GxB_Vector_extractTuples_FC32 ( GrB_Index *I, GxB_FC32_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GxB_Vector_extractTuples_FC32(I, X, nvals, v)
    ccall((:GxB_Vector_extractTuples_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GxB_FC32_t}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GxB_Vector_extractTuples_FC64(I, X, nvals, v)


### Prototype
```c
GrB_Info GxB_Vector_extractTuples_FC64 ( GrB_Index *I, GxB_FC64_t *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GxB_Vector_extractTuples_FC64(I, X, nvals, v)
    ccall((:GxB_Vector_extractTuples_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GxB_FC64_t}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Vector_extractTuples_UDT(I, X, nvals, v)


### Prototype
```c
GrB_Info GrB_Vector_extractTuples_UDT ( GrB_Index *I, void *X, GrB_Index *nvals, const GrB_Vector v );
```
"""
function GrB_Vector_extractTuples_UDT(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

"""
    GrB_Matrix_new(A, type, nrows, ncols)

These methods create, free, copy, and clear a matrix.  The nrows, ncols,
nvals, and type methods return basic information about a matrix.
### Prototype
```c
GrB_Info GrB_Matrix_new ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols );
```
"""
function GrB_Matrix_new(A, type, nrows, ncols)
    ccall((:GrB_Matrix_new, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index), A, type, nrows, ncols)
end

"""
    GrB_Matrix_dup(C, A)


### Prototype
```c
GrB_Info GrB_Matrix_dup ( GrB_Matrix *C, const GrB_Matrix A );
```
"""
function GrB_Matrix_dup(C, A)
    ccall((:GrB_Matrix_dup, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Matrix), C, A)
end

"""
    GrB_Matrix_clear(A)


### Prototype
```c
GrB_Info GrB_Matrix_clear ( GrB_Matrix A );
```
"""
function GrB_Matrix_clear(A)
    ccall((:GrB_Matrix_clear, libgraphblas), GrB_Info, (GrB_Matrix,), A)
end

"""
    GrB_Matrix_nrows(nrows, A)


### Prototype
```c
GrB_Info GrB_Matrix_nrows ( GrB_Index *nrows, const GrB_Matrix A );
```
"""
function GrB_Matrix_nrows(nrows, A)
    ccall((:GrB_Matrix_nrows, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), nrows, A)
end

"""
    GrB_Matrix_ncols(ncols, A)


### Prototype
```c
GrB_Info GrB_Matrix_ncols ( GrB_Index *ncols, const GrB_Matrix A );
```
"""
function GrB_Matrix_ncols(ncols, A)
    ccall((:GrB_Matrix_ncols, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), ncols, A)
end

"""
    GrB_Matrix_nvals(nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_nvals ( GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_nvals(nvals, A)
    ccall((:GrB_Matrix_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), nvals, A)
end

"""
    GxB_Matrix_type(type, A)

historical; use GrB_get instead:
### Prototype
```c
GrB_Info GxB_Matrix_type (GrB_Type *type, const GrB_Matrix A);
```
"""
function GxB_Matrix_type(type, A)
    ccall((:GxB_Matrix_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Matrix), type, A)
end

"""
    GxB_Matrix_type_name(type_name, A)


### Prototype
```c
GrB_Info GxB_Matrix_type_name (char *type_name, const GrB_Matrix A);
```
"""
function GxB_Matrix_type_name(type_name, A)
    ccall((:GxB_Matrix_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Matrix), type_name, A)
end

"""
    GxB_Matrix_memoryUsage(size, A)


### Prototype
```c
GrB_Info GxB_Matrix_memoryUsage ( size_t *size, const GrB_Matrix A );
```
"""
function GxB_Matrix_memoryUsage(size, A)
    ccall((:GxB_Matrix_memoryUsage, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Matrix), size, A)
end

"""
    GxB_Matrix_iso(iso, A)


### Prototype
```c
GrB_Info GxB_Matrix_iso ( bool *iso, const GrB_Matrix A );
```
"""
function GxB_Matrix_iso(iso, A)
    ccall((:GxB_Matrix_iso, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Matrix), iso, A)
end

"""
    GrB_Matrix_build_BOOL(C, I, J, X, nvals, dup)

GrB_Matrix_build:  C = sparse (I,J,X), but using any
associative operator to assemble duplicate entries.
### Prototype
```c
GrB_Info GrB_Matrix_build_BOOL ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const bool *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_BOOL(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_INT8(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_INT8 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const int8_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_INT8(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT8, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UINT8(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_UINT8 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const uint8_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_UINT8(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_INT16(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_INT16 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const int16_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_INT16(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT16, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UINT16(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_UINT16 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const uint16_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_UINT16(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_INT32(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_INT32 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const int32_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_INT32(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UINT32(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_UINT32 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const uint32_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_UINT32(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_INT64(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_INT64 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const int64_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_INT64(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UINT64(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_UINT64 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const uint64_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_UINT64(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_FP32(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_FP32 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const float *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_FP32(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_FP32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_FP64(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_FP64 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const double *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_FP64(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_FP64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GxB_Matrix_build_FC32(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GxB_Matrix_build_FC32 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const GxB_FC32_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GxB_Matrix_build_FC32(C, I, J, X, nvals, dup)
    ccall((:GxB_Matrix_build_FC32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GxB_Matrix_build_FC64(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GxB_Matrix_build_FC64 ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const GxB_FC64_t *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GxB_Matrix_build_FC64(C, I, J, X, nvals, dup)
    ccall((:GxB_Matrix_build_FC64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UDT(C, I, J, X, nvals, dup)


### Prototype
```c
GrB_Info GrB_Matrix_build_UDT ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, const void *X, GrB_Index nvals, const GrB_BinaryOp dup );
```
"""
function GrB_Matrix_build_UDT(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UDT, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

"""
    GxB_Matrix_build_Scalar(C, I, J, scalar, nvals)


### Prototype
```c
GrB_Info GxB_Matrix_build_Scalar ( GrB_Matrix C, const GrB_Index *I, const GrB_Index *J, GrB_Scalar scalar, GrB_Index nvals );
```
"""
function GxB_Matrix_build_Scalar(C, I, J, scalar, nvals)
    ccall((:GxB_Matrix_build_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Scalar, GrB_Index), C, I, J, scalar, nvals)
end

"""
    GrB_Matrix_setElement_BOOL(C, x, i, j)

Set a single entry in a matrix, C(i,j) = x, typecasting
from the type of x to the type of C, as needed.
### Prototype
```c
GrB_Info GrB_Matrix_setElement_BOOL ( GrB_Matrix C, bool x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_BOOL(C, x, i, j)
    ccall((:GrB_Matrix_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, Bool, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_INT8(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_INT8 ( GrB_Matrix C, int8_t x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_INT8(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT8, libgraphblas), GrB_Info, (GrB_Matrix, Int8, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UINT8(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_UINT8 ( GrB_Matrix C, uint8_t x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_UINT8(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, UInt8, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_INT16(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_INT16 ( GrB_Matrix C, int16_t x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_INT16(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT16, libgraphblas), GrB_Info, (GrB_Matrix, Int16, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UINT16(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_UINT16 ( GrB_Matrix C, uint16_t x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_UINT16(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, UInt16, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_INT32(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_INT32 ( GrB_Matrix C, int32_t x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_INT32(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Int32, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UINT32(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_UINT32 ( GrB_Matrix C, uint32_t x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_UINT32(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, UInt32, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_INT64(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_INT64 ( GrB_Matrix C, int64_t x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_INT64(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT64, libgraphblas), GrB_Info, (GrB_Matrix, Int64, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UINT64(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_UINT64 ( GrB_Matrix C, uint64_t x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_UINT64(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, UInt64, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_FP32(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_FP32 ( GrB_Matrix C, float x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_FP32(C, x, i, j)
    ccall((:GrB_Matrix_setElement_FP32, libgraphblas), GrB_Info, (GrB_Matrix, Cfloat, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_FP64(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_FP64 ( GrB_Matrix C, double x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_FP64(C, x, i, j)
    ccall((:GrB_Matrix_setElement_FP64, libgraphblas), GrB_Info, (GrB_Matrix, Cdouble, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GxB_Matrix_setElement_FC32(C, x, i, j)


### Prototype
```c
GrB_Info GxB_Matrix_setElement_FC32 ( GrB_Matrix C, GxB_FC32_t x, GrB_Index i, GrB_Index j );
```
"""
function GxB_Matrix_setElement_FC32(C, x, i, j)
    ccall((:GxB_Matrix_setElement_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GxB_FC32_t, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GxB_Matrix_setElement_FC64(C, x, i, j)


### Prototype
```c
GrB_Info GxB_Matrix_setElement_FC64 ( GrB_Matrix C, GxB_FC64_t x, GrB_Index i, GrB_Index j );
```
"""
function GxB_Matrix_setElement_FC64(C, x, i, j)
    ccall((:GxB_Matrix_setElement_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GxB_FC64_t, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UDT(C, x, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_setElement_UDT ( GrB_Matrix C, void *x, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_setElement_UDT(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UDT, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cvoid}, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_extractElement_BOOL(x, A, i, j)

Extract a single entry from a matrix, x = A(i,j), typecasting from the type
of A to the type of x, as needed.
### Prototype
```c
GrB_Info GrB_Matrix_extractElement_BOOL ( bool *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_BOOL(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_INT8(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_INT8 ( int8_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_INT8(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UINT8(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_UINT8 ( uint8_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_UINT8(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_INT16(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_INT16 ( int16_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_INT16(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UINT16(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_UINT16 ( uint16_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_UINT16(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_INT32(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_INT32 ( int32_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_INT32(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UINT32(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_UINT32 ( uint32_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_UINT32(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_INT64(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_INT64 ( int64_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_INT64(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UINT64(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_UINT64 ( uint64_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_UINT64(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_FP32(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_FP32 ( float *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_FP32(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_FP64(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_FP64 ( double *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_FP64(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GxB_Matrix_extractElement_FC32(x, A, i, j)


### Prototype
```c
GrB_Info GxB_Matrix_extractElement_FC32 ( GxB_FC32_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GxB_Matrix_extractElement_FC32(x, A, i, j)
    ccall((:GxB_Matrix_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GxB_Matrix_extractElement_FC64(x, A, i, j)


### Prototype
```c
GrB_Info GxB_Matrix_extractElement_FC64 ( GxB_FC64_t *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GxB_Matrix_extractElement_FC64(x, A, i, j)
    ccall((:GxB_Matrix_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UDT(x, A, i, j)


### Prototype
```c
GrB_Info GrB_Matrix_extractElement_UDT ( void *x, const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_extractElement_UDT(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GxB_Matrix_isStoredElement(A, i, j)

GxB_Matrix_isStoredElement determines if A(i,j) is present in the structure
of the matrix A, as a stored element.  It does not return the value.  It
returns GrB_SUCCESS if the element is present, or GrB_NO_VALUE otherwise.
### Prototype
```c
GrB_Info GxB_Matrix_isStoredElement ( const GrB_Matrix A, GrB_Index i, GrB_Index j );
```
"""
function GxB_Matrix_isStoredElement(A, i, j)
    ccall((:GxB_Matrix_isStoredElement, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), A, i, j)
end

"""
    GrB_Matrix_removeElement(C, i, j)

GrB_Matrix_removeElement (A,i,j) removes the entry A(i,j) from the matrix A.
### Prototype
```c
GrB_Info GrB_Matrix_removeElement ( GrB_Matrix C, GrB_Index i, GrB_Index j );
```
"""
function GrB_Matrix_removeElement(C, i, j)
    ccall((:GrB_Matrix_removeElement, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, i, j)
end

"""
    GrB_Matrix_extractTuples_BOOL(I, J, X, nvals, A)

Extracts all tuples from a matrix, like [I,J,X] = find (A).  If
any parameter I, J and/or X is NULL, then that component is not extracted.
For example, to extract just the row and col indices, pass I and J as
non-NULL, and X as NULL.  This is like [I,J,~] = find (A).
### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_BOOL ( GrB_Index *I, GrB_Index *J, bool *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_BOOL(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_INT8(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_INT8 ( GrB_Index *I, GrB_Index *J, int8_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_INT8(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UINT8(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_UINT8 ( GrB_Index *I, GrB_Index *J, uint8_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_UINT8(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_INT16(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_INT16 ( GrB_Index *I, GrB_Index *J, int16_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_INT16(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UINT16(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_UINT16 ( GrB_Index *I, GrB_Index *J, uint16_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_UINT16(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_INT32(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_INT32 ( GrB_Index *I, GrB_Index *J, int32_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_INT32(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UINT32(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_UINT32 ( GrB_Index *I, GrB_Index *J, uint32_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_UINT32(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_INT64(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_INT64 ( GrB_Index *I, GrB_Index *J, int64_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_INT64(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UINT64(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_UINT64 ( GrB_Index *I, GrB_Index *J, uint64_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_UINT64(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_FP32(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_FP32 ( GrB_Index *I, GrB_Index *J, float *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_FP32(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_FP64(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_FP64 ( GrB_Index *I, GrB_Index *J, double *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_FP64(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GxB_Matrix_extractTuples_FC32(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GxB_Matrix_extractTuples_FC32 ( GrB_Index *I, GrB_Index *J, GxB_FC32_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GxB_Matrix_extractTuples_FC32(I, J, X, nvals, A)
    ccall((:GxB_Matrix_extractTuples_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GxB_Matrix_extractTuples_FC64(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GxB_Matrix_extractTuples_FC64 ( GrB_Index *I, GrB_Index *J, GxB_FC64_t *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GxB_Matrix_extractTuples_FC64(I, J, X, nvals, A)
    ccall((:GxB_Matrix_extractTuples_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UDT(I, J, X, nvals, A)


### Prototype
```c
GrB_Info GrB_Matrix_extractTuples_UDT ( GrB_Index *I, GrB_Index *J, void *X, GrB_Index *nvals, const GrB_Matrix A );
```
"""
function GrB_Matrix_extractTuples_UDT(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

"""
    GxB_Matrix_concat(C, Tiles, m, n, desc)

The type of C is unchanged, and all matrices A{i,j} are typecasted into the
type of C.  Any settings made to C by GrB_set (format by row
or by column, bitmap switch, hyper switch, and sparsity control) are
unchanged.
### Prototype
```c
GrB_Info GxB_Matrix_concat ( GrB_Matrix C, const GrB_Matrix *Tiles, const GrB_Index m, const GrB_Index n, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_concat(C, Tiles, m, n, desc)
    ccall((:GxB_Matrix_concat, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Matrix}, GrB_Index, GrB_Index, GrB_Descriptor), C, Tiles, m, n, desc)
end

"""
    GxB_Matrix_split(Tiles, m, n, Tile_nrows, Tile_ncols, A, desc)

GxB_Matrix_split does the opposite of GxB_Matrix_concat.  It splits a single
input matrix A into a 2D array of tiles.  On input, the Tiles array must be
a non-NULL pointer to a previously allocated array of size at least m*n
where both m and n must be > 0.  The Tiles_nrows array has size m, and
Tiles_ncols has size n.  The (i,j)th tile has dimension
Tiles_nrows[i]-by-Tiles_ncols[j].  The sum of Tiles_nrows [0:m-1] must equal
the number of rows of A, and the sum of Tiles_ncols [0:n-1] must equal the
number of columns of A.  The type of each tile is the same as the type of A;
no typecasting is done.
### Prototype
```c
GrB_Info GxB_Matrix_split ( GrB_Matrix *Tiles, const GrB_Index m, const GrB_Index n, const GrB_Index *Tile_nrows, const GrB_Index *Tile_ncols, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_split(Tiles, m, n, Tile_nrows, Tile_ncols, A, desc)
    ccall((:GxB_Matrix_split, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Matrix, GrB_Descriptor), Tiles, m, n, Tile_nrows, Tile_ncols, A, desc)
end

"""
    GrB_Matrix_diag(C, v, k)

GrB_Matrix_diag constructs a new matrix from a vector.  Let n be the length
of the v vector, from GrB_Vector_size (&n, v).  If k = 0, then C is an
n-by-n diagonal matrix with the entries from v along the main diagonal of C,
with C(i,i) = v(i).  If k is nonzero, C is square with dimension n+abs(k).
If k is positive, it denotes diagonals above the main diagonal, with
C(i,i+k) = v(i).  If k is negative, it denotes diagonals below the main
diagonal of C, with C(i-k,i) = v(i).  C is constructed with the same type
as v.
### Prototype
```c
GrB_Info GrB_Matrix_diag ( GrB_Matrix *C, const GrB_Vector v, int64_t k );
```
"""
function GrB_Matrix_diag(C, v, k)
    ccall((:GrB_Matrix_diag, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Vector, Int64), C, v, k)
end

"""
    GxB_Matrix_diag(C, v, k, desc)

GrB_Matrix_diag is like GxB_Matrix_diag (&C, v, k, NULL), except that C must
already exist on input, of the correct size.  Any existing entries in C are
discarded.  The type of C is preserved, so that if the type of C and v
differ, the entries are typecasted into the type of C.  Any settings made to
C by GrB_set (format by row or by column, bitmap switch, hyper
switch, and sparsity control) are unchanged.
### Prototype
```c
GrB_Info GxB_Matrix_diag ( GrB_Matrix C, const GrB_Vector v, int64_t k, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_diag(C, v, k, desc)
    ccall((:GxB_Matrix_diag, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, Int64, GrB_Descriptor), C, v, k, desc)
end

"""
    GxB_Vector_diag(v, A, k, desc)

v must already exist on input, of the correct length; that is
GrB_Vector_size (&len,v) must return len = 0 if k >= n or k <= -m, len =
min(m,n-k) if k is in the range 0 to n-1, and len = min(m+k,n) if k is in
the range -1 to -m+1.  Any existing entries in v are discarded.  The type of
v is preserved, so that if the type of A and v differ, the entries are
typecasted into the type of v.  Any settings made to v by
GrB_set (bitmap switch and sparsity control) are unchanged.
### Prototype
```c
GrB_Info GxB_Vector_diag ( GrB_Vector v, const GrB_Matrix A, int64_t k, const GrB_Descriptor desc );
```
"""
function GxB_Vector_diag(v, A, k, desc)
    ccall((:GxB_Vector_diag, libgraphblas), GrB_Info, (GrB_Vector, GrB_Matrix, Int64, GrB_Descriptor), v, A, k, desc)
end

"""
    GxB_JIT_Control

for GxB_JIT_C_CONTROL:
"""
@enum GxB_JIT_Control::UInt32 begin
    GxB_JIT_OFF = 0
    GxB_JIT_PAUSE = 1
    GxB_JIT_RUN = 2
    GxB_JIT_LOAD = 3
    GxB_JIT_ON = 4
end

@enum GxB_Context_Field::UInt32 begin
    GxB_CONTEXT_NTHREADS = 7086
    GxB_CONTEXT_CHUNK = 7087
    GxB_CONTEXT_GPU_ID = 7088
end

"""
    GxB_Context_new(Context)


### Prototype
```c
GrB_Info GxB_Context_new ( GxB_Context *Context );
```
"""
function GxB_Context_new(Context)
    ccall((:GxB_Context_new, libgraphblas), GrB_Info, (Ptr{GxB_Context},), Context)
end

"""
    GxB_Context_engage(Context)


### Prototype
```c
GrB_Info GxB_Context_engage ( GxB_Context Context );
```
"""
function GxB_Context_engage(Context)
    ccall((:GxB_Context_engage, libgraphblas), GrB_Info, (GxB_Context,), Context)
end

"""
    GxB_Context_disengage(Context)


### Prototype
```c
GrB_Info GxB_Context_disengage ( GxB_Context Context );
```
"""
function GxB_Context_disengage(Context)
    ccall((:GxB_Context_disengage, libgraphblas), GrB_Info, (GxB_Context,), Context)
end

"""
    GxB_Matrix_Option_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Matrix_Option_set_INT32 (GrB_Matrix, GxB_Option_Field, int32_t);
```
"""
function GxB_Matrix_Option_set_INT32(arg1, arg2, arg3)
    ccall((:GxB_Matrix_Option_set_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GxB_Option_Field, Int32), arg1, arg2, arg3)
end

"""
    GxB_Matrix_Option_set_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Matrix_Option_set_FP64 (GrB_Matrix, GxB_Option_Field, double);
```
"""
function GxB_Matrix_Option_set_FP64(arg1, arg2, arg3)
    ccall((:GxB_Matrix_Option_set_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GxB_Option_Field, Cdouble), arg1, arg2, arg3)
end

"""
    GxB_Matrix_Option_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Matrix_Option_get_INT32 (GrB_Matrix, GxB_Option_Field, int32_t *);
```
"""
function GxB_Matrix_Option_get_INT32(arg1, arg2, arg3)
    ccall((:GxB_Matrix_Option_get_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GxB_Option_Field, Ptr{Int32}), arg1, arg2, arg3)
end

"""
    GxB_Matrix_Option_get_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Matrix_Option_get_FP64 (GrB_Matrix, GxB_Option_Field, double *);
```
"""
function GxB_Matrix_Option_get_FP64(arg1, arg2, arg3)
    ccall((:GxB_Matrix_Option_get_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GxB_Option_Field, Ptr{Cdouble}), arg1, arg2, arg3)
end

"""
    GxB_Vector_Option_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Vector_Option_set_INT32 (GrB_Vector, GxB_Option_Field, int32_t);
```
"""
function GxB_Vector_Option_set_INT32(arg1, arg2, arg3)
    ccall((:GxB_Vector_Option_set_INT32, libgraphblas), GrB_Info, (GrB_Vector, GxB_Option_Field, Int32), arg1, arg2, arg3)
end

"""
    GxB_Vector_Option_set_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Vector_Option_set_FP64 (GrB_Vector, GxB_Option_Field, double);
```
"""
function GxB_Vector_Option_set_FP64(arg1, arg2, arg3)
    ccall((:GxB_Vector_Option_set_FP64, libgraphblas), GrB_Info, (GrB_Vector, GxB_Option_Field, Cdouble), arg1, arg2, arg3)
end

"""
    GxB_Vector_Option_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Vector_Option_get_INT32 (GrB_Vector, GxB_Option_Field, int32_t *);
```
"""
function GxB_Vector_Option_get_INT32(arg1, arg2, arg3)
    ccall((:GxB_Vector_Option_get_INT32, libgraphblas), GrB_Info, (GrB_Vector, GxB_Option_Field, Ptr{Int32}), arg1, arg2, arg3)
end

"""
    GxB_Vector_Option_get_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Vector_Option_get_FP64 (GrB_Vector, GxB_Option_Field, double *);
```
"""
function GxB_Vector_Option_get_FP64(arg1, arg2, arg3)
    ccall((:GxB_Vector_Option_get_FP64, libgraphblas), GrB_Info, (GrB_Vector, GxB_Option_Field, Ptr{Cdouble}), arg1, arg2, arg3)
end

"""
    GxB_Global_Option_set_INT32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_INT32 (GxB_Option_Field, int32_t);
```
"""
function GxB_Global_Option_set_INT32(arg1, arg2)
    ccall((:GxB_Global_Option_set_INT32, libgraphblas), GrB_Info, (GxB_Option_Field, Int32), arg1, arg2)
end

"""
    GxB_Global_Option_set_FP64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_FP64 (GxB_Option_Field, double);
```
"""
function GxB_Global_Option_set_FP64(arg1, arg2)
    ccall((:GxB_Global_Option_set_FP64, libgraphblas), GrB_Info, (GxB_Option_Field, Cdouble), arg1, arg2)
end

"""
    GxB_Global_Option_set_FP64_ARRAY(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_FP64_ARRAY (GxB_Option_Field, double *);
```
"""
function GxB_Global_Option_set_FP64_ARRAY(arg1, arg2)
    ccall((:GxB_Global_Option_set_FP64_ARRAY, libgraphblas), GrB_Info, (GxB_Option_Field, Ptr{Cdouble}), arg1, arg2)
end

"""
    GxB_Global_Option_set_INT64_ARRAY(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_INT64_ARRAY (GxB_Option_Field, int64_t *);
```
"""
function GxB_Global_Option_set_INT64_ARRAY(arg1, arg2)
    ccall((:GxB_Global_Option_set_INT64_ARRAY, libgraphblas), GrB_Info, (GxB_Option_Field, Ptr{Int64}), arg1, arg2)
end

"""
    GxB_Global_Option_set_CHAR(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_CHAR (GxB_Option_Field, const char *);
```
"""
function GxB_Global_Option_set_CHAR(arg1, arg2)
    ccall((:GxB_Global_Option_set_CHAR, libgraphblas), GrB_Info, (GxB_Option_Field, Ptr{Cchar}), arg1, arg2)
end

"""
    GxB_Global_Option_set_FUNCTION(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_FUNCTION (GxB_Option_Field, void *);
```
"""
function GxB_Global_Option_set_FUNCTION(arg1, arg2)
    ccall((:GxB_Global_Option_set_FUNCTION, libgraphblas), GrB_Info, (GxB_Option_Field, Ptr{Cvoid}), arg1, arg2)
end

"""
    GxB_Global_Option_get_INT32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_INT32 (GxB_Option_Field, int32_t *);
```
"""
function GxB_Global_Option_get_INT32(arg1, arg2)
    ccall((:GxB_Global_Option_get_INT32, libgraphblas), GrB_Info, (GxB_Option_Field, Ptr{Int32}), arg1, arg2)
end

"""
    GxB_Global_Option_get_FP64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_FP64 (GxB_Option_Field, double *);
```
"""
function GxB_Global_Option_get_FP64(arg1, arg2)
    ccall((:GxB_Global_Option_get_FP64, libgraphblas), GrB_Info, (GxB_Option_Field, Ptr{Cdouble}), arg1, arg2)
end

"""
    GxB_Global_Option_get_INT64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_INT64 (GxB_Option_Field, int64_t *);
```
"""
function GxB_Global_Option_get_INT64(arg1, arg2)
    ccall((:GxB_Global_Option_get_INT64, libgraphblas), GrB_Info, (GxB_Option_Field, Ptr{Int64}), arg1, arg2)
end

"""
    GxB_Global_Option_get_CHAR(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_CHAR (GxB_Option_Field, const char **);
```
"""
function GxB_Global_Option_get_CHAR(arg1, arg2)
    ccall((:GxB_Global_Option_get_CHAR, libgraphblas), GrB_Info, (GxB_Option_Field, Ptr{Ptr{Cchar}}), arg1, arg2)
end

"""
    GxB_Global_Option_get_FUNCTION(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_FUNCTION (GxB_Option_Field, void **);
```
"""
function GxB_Global_Option_get_FUNCTION(arg1, arg2)
    ccall((:GxB_Global_Option_get_FUNCTION, libgraphblas), GrB_Info, (GxB_Option_Field, Ptr{Ptr{Cvoid}}), arg1, arg2)
end

"""
    GxB_Context_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_set_INT32 (GxB_Context, GxB_Context_Field, int32_t);
```
"""
function GxB_Context_set_INT32(arg1, arg2, arg3)
    ccall((:GxB_Context_set_INT32, libgraphblas), GrB_Info, (GxB_Context, GxB_Context_Field, Int32), arg1, arg2, arg3)
end

"""
    GxB_Context_set_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_set_FP64 (GxB_Context, GxB_Context_Field, double);
```
"""
function GxB_Context_set_FP64(arg1, arg2, arg3)
    ccall((:GxB_Context_set_FP64, libgraphblas), GrB_Info, (GxB_Context, GxB_Context_Field, Cdouble), arg1, arg2, arg3)
end

"""
    GxB_Context_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_INT32 (GxB_Context, GxB_Context_Field, int32_t *);
```
"""
function GxB_Context_get_INT32(arg1, arg2, arg3)
    ccall((:GxB_Context_get_INT32, libgraphblas), GrB_Info, (GxB_Context, GxB_Context_Field, Ptr{Int32}), arg1, arg2, arg3)
end

"""
    GxB_Context_get_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_FP64 (GxB_Context, GxB_Context_Field, double *);
```
"""
function GxB_Context_get_FP64(arg1, arg2, arg3)
    ccall((:GxB_Context_get_FP64, libgraphblas), GrB_Info, (GxB_Context, GxB_Context_Field, Ptr{Cdouble}), arg1, arg2, arg3)
end

@enum GrB_Orientation::UInt32 begin
    GrB_ROWMAJOR = 0
    GrB_COLMAJOR = 1
    GrB_BOTH = 2
    GrB_UNKNOWN = 3
end

@enum GrB_Type_Code::UInt32 begin
    GrB_UDT_CODE = 0
    GrB_BOOL_CODE = 1
    GrB_INT8_CODE = 2
    GrB_UINT8_CODE = 3
    GrB_INT16_CODE = 4
    GrB_UINT16_CODE = 5
    GrB_INT32_CODE = 6
    GrB_UINT32_CODE = 7
    GrB_INT64_CODE = 8
    GrB_UINT64_CODE = 9
    GrB_FP32_CODE = 10
    GrB_FP64_CODE = 11
    GxB_FC32_CODE = 7070
    GxB_FC64_CODE = 7071
end

"""
    GxB_Scalar_wait(s)

NOTE: GxB_Scalar_wait is historical; use GrB_Scalar_wait instead
### Prototype
```c
GrB_Info GxB_Scalar_wait (GrB_Scalar *s);
```
"""
function GxB_Scalar_wait(s)
    ccall((:GxB_Scalar_wait, libgraphblas), GrB_Info, (Ptr{GrB_Scalar},), s)
end

"""
    GxB_Scalar_error(error, s)

GxB_Scalar_error is historical: use GrB_Scalar_error instead
### Prototype
```c
GrB_Info GxB_Scalar_error (const char **error, const GrB_Scalar s);
```
"""
function GxB_Scalar_error(error, s)
    ccall((:GxB_Scalar_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Scalar), error, s)
end

"""
    GrB_mxm(C, Mask, accum, semiring, A, B, desc)

==============================================================================
GrB_mxm, vxm, mxv: matrix multiplication over a semiring
==============================================================================
### Prototype
```c
GrB_Info GrB_mxm ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Semiring semiring, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GrB_mxm(C, Mask, accum, semiring, A, B, desc)
    ccall((:GrB_mxm, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

"""
    GrB_vxm(w, mask, accum, semiring, u, A, desc)


### Prototype
```c
GrB_Info GrB_vxm ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Semiring semiring, const GrB_Vector u, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_vxm(w, mask, accum, semiring, u, A, desc)
    ccall((:GrB_vxm, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Matrix, GrB_Descriptor), w, mask, accum, semiring, u, A, desc)
end

"""
    GrB_mxv(w, mask, accum, semiring, A, u, desc)


### Prototype
```c
GrB_Info GrB_mxv ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Semiring semiring, const GrB_Matrix A, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_mxv(w, mask, accum, semiring, A, u, desc)
    ccall((:GrB_mxv, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, A, u, desc)
end

"""
    GxB_Vector_subassign_BOOL(w, mask, accum, x, I, ni, desc)

Assigns a single scalar to a subvector, w(I)<mask> = accum(w(I),x).  The
scalar x is implicitly expanded into a vector u of size ni-by-1, with each
entry in u equal to x, and then w(I)<mask> = accum(w(I),u) is done.
### Prototype
```c
GrB_Info GxB_Vector_subassign_BOOL ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, bool x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_BOOL(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_INT8(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_INT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, int8_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_INT8(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_UINT8(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_UINT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, uint8_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_UINT8(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_INT16(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_INT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, int16_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_INT16(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_UINT16(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_UINT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, uint16_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_UINT16(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_INT32(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_INT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, int32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_INT32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_UINT32(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_UINT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, uint32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_UINT32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_INT64(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_INT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, int64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_INT64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_UINT64(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_UINT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, uint64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_UINT64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_FP32(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_FP32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, float x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_FP32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_FP64(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_FP64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, double x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_FP64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_FC32(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_FC32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, GxB_FC32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_FC32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_FC64(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_FC64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, GxB_FC64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_FC64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_subassign_UDT(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_UDT ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, void *x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_UDT(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Matrix_subassign_BOOL(C, Mask, accum, x, I, ni, J, nj, desc)

Assigns a single scalar to a submatrix, C(I,J)<Mask> = accum(C(I,J),x).  The
scalar x is implicitly expanded into a matrix A of size ni-by-nj, with each
entry in A equal to x, and then C(I,J)<Mask> = accum(C(I,J),A) is done.
### Prototype
```c
GrB_Info GxB_Matrix_subassign_BOOL ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, bool x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_BOOL(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_INT8(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_INT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, int8_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_INT8(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UINT8(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_UINT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, uint8_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_UINT8(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_INT16(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_INT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, int16_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_INT16(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UINT16(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_UINT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, uint16_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_UINT16(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_INT32(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_INT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, int32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_INT32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UINT32(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_UINT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, uint32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_UINT32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_INT64(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_INT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, int64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_INT64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UINT64(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_UINT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, uint64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_UINT64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_FP32(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_FP32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, float x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_FP32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_FP64(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_FP64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, double x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_FP64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_FC32(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_FC32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, GxB_FC32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_FC32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_FC64(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_FC64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, GxB_FC64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_FC64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UDT(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_UDT ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, void *x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_UDT(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Vector_assign_BOOL(w, mask, accum, x, I, ni, desc)

Assigns a single scalar to a subvector, w<mask>(I) = accum(w(I),x).  The
scalar x is implicitly expanded into a vector u of size ni-by-1, with each
entry in u equal to x, and then w<mask>(I) = accum(w(I),u) is done.
### Prototype
```c
GrB_Info GrB_Vector_assign_BOOL ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, bool x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_BOOL(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_INT8(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_INT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, int8_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_INT8(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_UINT8(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_UINT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, uint8_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_UINT8(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_INT16(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_INT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, int16_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_INT16(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_UINT16(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_UINT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, uint16_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_UINT16(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_INT32(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_INT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, int32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_INT32(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_UINT32(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_UINT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, uint32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_UINT32(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_INT64(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_INT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, int64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_INT64(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_UINT64(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_UINT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, uint64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_UINT64(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_FP32(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_FP32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, float x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_FP32(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_FP64(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_FP64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, double x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_FP64(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_assign_FC32(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_assign_FC32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, GxB_FC32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_assign_FC32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_assign_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GxB_Vector_assign_FC64(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_assign_FC64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, GxB_FC64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_assign_FC64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_assign_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Vector_assign_UDT(w, mask, accum, x, I, ni, desc)


### Prototype
```c
GrB_Info GrB_Vector_assign_UDT ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, void *x, const GrB_Index *I, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_UDT(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

"""
    GrB_Matrix_assign_BOOL(C, Mask, accum, x, I, ni, J, nj, desc)

Assigns a single scalar to a submatrix, C<Mask>(I,J) = accum(C(I,J),x).  The
scalar x is implicitly expanded into a matrix A of size ni-by-nj, with each
entry in A equal to x, and then C<Mask>(I,J) = accum(C(I,J),A) is done.
### Prototype
```c
GrB_Info GrB_Matrix_assign_BOOL ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, bool x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_BOOL(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_INT8(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_INT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, int8_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_INT8(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UINT8(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_UINT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, uint8_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_UINT8(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_INT16(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_INT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, int16_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_INT16(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UINT16(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_UINT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, uint16_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_UINT16(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_INT32(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_INT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, int32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_INT32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UINT32(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_UINT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, uint32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_UINT32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_INT64(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_INT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, int64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_INT64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UINT64(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_UINT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, uint64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_UINT64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_FP32(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_FP32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, float x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_FP32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_FP64(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_FP64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, double x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_FP64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_assign_FC32(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_assign_FC32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, GxB_FC32_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_assign_FC32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_assign_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GxB_Matrix_assign_FC64(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_assign_FC64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, GxB_FC64_t x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_assign_FC64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_assign_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UDT(C, Mask, accum, x, I, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign_UDT ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, void *x, const GrB_Index *I, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_UDT(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_Scalar(w, mask, accum, op, x, u, desc)

Apply a binary operator to the entries in a vector, binding the first
input to a scalar x, w<mask> = accum (w, op (x,u)).
### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_Scalar ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Scalar x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_Scalar(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GxB_Vector_apply_BinaryOp1st(w, mask, accum, op, x, u, desc)

historical: identical to GxB_Vector_apply_BinaryOp1st
### Prototype
```c
GrB_Info GxB_Vector_apply_BinaryOp1st ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Scalar x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GxB_Vector_apply_BinaryOp1st(w, mask, accum, op, x, u, desc)
    ccall((:GxB_Vector_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_BOOL(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_BOOL ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, bool x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_BOOL(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Bool, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_INT8(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_INT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, int8_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_INT8(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int8, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_INT16(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_INT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, int16_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_INT16(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int16, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_INT32(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_INT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, int32_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_INT32(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int32, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_INT64(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_INT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, int64_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_INT64(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int64, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UINT8(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_UINT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, uint8_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_UINT8(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt8, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UINT16(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_UINT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, uint16_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_UINT16(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt16, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UINT32(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_UINT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, uint32_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_UINT32(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt32, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UINT64(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_UINT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, uint64_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_UINT64(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt64, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_FP32(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_FP32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, float x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_FP32(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Cfloat, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_FP64(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_FP64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, double x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_FP64(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Cdouble, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GxB_Vector_apply_BinaryOp1st_FC32(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GxB_Vector_apply_BinaryOp1st_FC32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, GxB_FC32_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GxB_Vector_apply_BinaryOp1st_FC32(w, mask, accum, op, x, u, desc)
    ccall((:GxB_Vector_apply_BinaryOp1st_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_FC32_t, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GxB_Vector_apply_BinaryOp1st_FC64(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GxB_Vector_apply_BinaryOp1st_FC64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, GxB_FC64_t x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GxB_Vector_apply_BinaryOp1st_FC64(w, mask, accum, op, x, u, desc)
    ccall((:GxB_Vector_apply_BinaryOp1st_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_FC64_t, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UDT(w, mask, accum, op, x, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp1st_UDT ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const void *x, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp1st_UDT(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Ptr{Cvoid}, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_Scalar(w, mask, accum, op, u, y, desc)

Apply a binary operator to the entries in a vector, binding the second
input to a scalar y, w<mask> = accum (w, op (u,y)).
### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_Scalar ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, const GrB_Scalar y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_Scalar(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_apply_BinaryOp2nd(w, mask, accum, op, u, y, desc)

historical: identical to GrB_Vector_apply_BinaryOp2nd_Scalar
### Prototype
```c
GrB_Info GxB_Vector_apply_BinaryOp2nd ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, const GrB_Scalar y, const GrB_Descriptor desc );
```
"""
function GxB_Vector_apply_BinaryOp2nd(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_BOOL(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_BOOL ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, bool y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_BOOL(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_INT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_INT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, int8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_INT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_INT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_INT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, int16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_INT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_INT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_INT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, int32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_INT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_INT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_INT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, int64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_INT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UINT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_UINT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, uint8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_UINT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UINT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_UINT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, uint16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_UINT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UINT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_UINT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, uint32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_UINT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UINT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_UINT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, uint64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_UINT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_FP32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_FP32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, float y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_FP32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_FP64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_FP64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, double y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_FP64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_apply_BinaryOp2nd_FC32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GxB_Vector_apply_BinaryOp2nd_FC32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, GxB_FC32_t y, const GrB_Descriptor desc );
```
"""
function GxB_Vector_apply_BinaryOp2nd_FC32(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_BinaryOp2nd_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_apply_BinaryOp2nd_FC64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GxB_Vector_apply_BinaryOp2nd_FC64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, GxB_FC64_t y, const GrB_Descriptor desc );
```
"""
function GxB_Vector_apply_BinaryOp2nd_FC64(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_BinaryOp2nd_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UDT(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_BinaryOp2nd_UDT ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, const void *y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_BinaryOp2nd_UDT(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Ptr{Cvoid}, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_Scalar(w, mask, accum, op, u, y, desc)

Apply a GrB_IndexUnaryOp to the entries in a vector
### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_Scalar ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, const GrB_Scalar y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_Scalar(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_BOOL(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_BOOL ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, bool y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_BOOL(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_INT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_INT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, int8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_INT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_INT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_INT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, int16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_INT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_INT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_INT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, int32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_INT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_INT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_INT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, int64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_INT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UINT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_UINT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, uint8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_UINT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UINT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_UINT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, uint16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_UINT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UINT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_UINT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, uint32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_UINT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UINT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_UINT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, uint64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_UINT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_FP32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_FP32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, float y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_FP32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_FP64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_FP64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, double y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_FP64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_apply_IndexOp_FC32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GxB_Vector_apply_IndexOp_FC32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, GxB_FC32_t y, const GrB_Descriptor desc );
```
"""
function GxB_Vector_apply_IndexOp_FC32(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_IndexOp_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_apply_IndexOp_FC64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GxB_Vector_apply_IndexOp_FC64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, GxB_FC64_t y, const GrB_Descriptor desc );
```
"""
function GxB_Vector_apply_IndexOp_FC64(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_IndexOp_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UDT(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_apply_IndexOp_UDT ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, const void *y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_apply_IndexOp_UDT(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Ptr{Cvoid}, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_Scalar(C, Mask, accum, op, x, A, desc)

Apply a binary operator to the entries in a matrix, binding the first input
to a scalar x, C<Mask> = accum (C, op (x,A)), or op(x,A').
### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_Scalar ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Scalar x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_Scalar(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GxB_Matrix_apply_BinaryOp1st(C, Mask, accum, op, x, A, desc)

historical: identical to GrB_Matrix_apply_BinaryOp1st_Scalar
### Prototype
```c
GrB_Info GxB_Matrix_apply_BinaryOp1st ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Scalar x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_apply_BinaryOp1st(C, Mask, accum, op, x, A, desc)
    ccall((:GxB_Matrix_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_BOOL(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_BOOL ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, bool x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_BOOL(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Bool, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_INT8(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_INT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, int8_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_INT8(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int8, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_INT16(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_INT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, int16_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_INT16(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int16, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_INT32(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_INT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, int32_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_INT32(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int32, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_INT64(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_INT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, int64_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_INT64(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int64, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UINT8(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_UINT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, uint8_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_UINT8(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt8, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UINT16(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_UINT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, uint16_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_UINT16(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt16, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UINT32(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_UINT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, uint32_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_UINT32(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt32, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UINT64(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_UINT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, uint64_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_UINT64(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt64, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_FP32(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_FP32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, float x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_FP32(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Cfloat, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_FP64(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_FP64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, double x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_FP64(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Cdouble, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GxB_Matrix_apply_BinaryOp1st_FC32(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GxB_Matrix_apply_BinaryOp1st_FC32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, GxB_FC32_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_apply_BinaryOp1st_FC32(C, Mask, accum, op, x, A, desc)
    ccall((:GxB_Matrix_apply_BinaryOp1st_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_FC32_t, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GxB_Matrix_apply_BinaryOp1st_FC64(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GxB_Matrix_apply_BinaryOp1st_FC64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, GxB_FC64_t x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_apply_BinaryOp1st_FC64(C, Mask, accum, op, x, A, desc)
    ccall((:GxB_Matrix_apply_BinaryOp1st_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_FC64_t, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UDT(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp1st_UDT ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const void *x, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp1st_UDT(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Ptr{Cvoid}, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_Scalar(C, Mask, accum, op, A, y, desc)

Apply a binary operator to the entries in a matrix, binding the second input
to a scalar y, C<Mask> = accum (C, op (A,y)), or op(A',y).
### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_Scalar ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, const GrB_Scalar y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_Scalar(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_apply_BinaryOp2nd(C, Mask, accum, op, A, y, desc)

historical: identical to GrB_Matrix_apply_BinaryOp2nd_Scalar
### Prototype
```c
GrB_Info GxB_Matrix_apply_BinaryOp2nd ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, const GrB_Scalar y, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_apply_BinaryOp2nd(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_BOOL(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_BOOL ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, bool y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_BOOL(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_INT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_INT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, int8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_INT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_INT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_INT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, int16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_INT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_INT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_INT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, int32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_INT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_INT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_INT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, int64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_INT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UINT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_UINT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, uint8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_UINT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UINT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_UINT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, uint16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_UINT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UINT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_UINT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, uint32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_UINT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UINT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_UINT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, uint64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_UINT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_FP32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_FP32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, float y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_FP32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_FP64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_FP64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, double y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_FP64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_apply_BinaryOp2nd_FC32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GxB_Matrix_apply_BinaryOp2nd_FC32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, GxB_FC32_t y, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_apply_BinaryOp2nd_FC32(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_BinaryOp2nd_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_apply_BinaryOp2nd_FC64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GxB_Matrix_apply_BinaryOp2nd_FC64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, GxB_FC64_t y, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_apply_BinaryOp2nd_FC64(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_BinaryOp2nd_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UDT(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_BinaryOp2nd_UDT ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, const void *y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_BinaryOp2nd_UDT(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Ptr{Cvoid}, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_Scalar(C, Mask, accum, op, A, y, desc)

Apply a GrB_IndexUnaryOp to the entries in a matrix.
### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_Scalar ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, const GrB_Scalar y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_Scalar(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_BOOL(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_BOOL ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, bool y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_BOOL(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_INT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_INT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, int8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_INT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_INT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_INT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, int16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_INT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_INT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_INT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, int32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_INT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_INT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_INT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, int64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_INT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UINT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_UINT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, uint8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_UINT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UINT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_UINT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, uint16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_UINT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UINT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_UINT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, uint32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_UINT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UINT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_UINT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, uint64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_UINT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_FP32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_FP32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, float y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_FP32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_FP64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_FP64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, double y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_FP64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_apply_IndexOp_FC32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GxB_Matrix_apply_IndexOp_FC32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, GxB_FC32_t y, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_apply_IndexOp_FC32(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_IndexOp_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_apply_IndexOp_FC64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GxB_Matrix_apply_IndexOp_FC64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, GxB_FC64_t y, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_apply_IndexOp_FC64(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_IndexOp_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UDT(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_apply_IndexOp_UDT ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, const void *y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_apply_IndexOp_UDT(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Ptr{Cvoid}, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Vector_select_BOOL(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_BOOL ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, bool y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_BOOL(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_INT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_INT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, int8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_INT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_INT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_INT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, int16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_INT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_INT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_INT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, int32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_INT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_INT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_INT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, int64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_INT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UINT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_UINT8 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, uint8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_UINT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UINT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_UINT16 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, uint16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_UINT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UINT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_UINT32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, uint32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_UINT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UINT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_UINT64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, uint64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_UINT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_FP32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_FP32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, float y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_FP32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_FP64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_FP64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, double y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_FP64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_select_FC32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GxB_Vector_select_FC32 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, GxB_FC32_t y, const GrB_Descriptor desc );
```
"""
function GxB_Vector_select_FC32(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_select_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_select_FC64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GxB_Vector_select_FC64 ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, GxB_FC64_t y, const GrB_Descriptor desc );
```
"""
function GxB_Vector_select_FC64(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_select_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UDT(w, mask, accum, op, u, y, desc)


### Prototype
```c
GrB_Info GrB_Vector_select_UDT ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Vector u, const void *y, const GrB_Descriptor desc );
```
"""
function GrB_Vector_select_UDT(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Ptr{Cvoid}, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Matrix_select_BOOL(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_BOOL ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, bool y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_BOOL(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_INT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_INT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, int8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_INT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_INT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_INT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, int16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_INT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_INT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_INT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, int32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_INT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_INT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_INT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, int64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_INT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UINT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_UINT8 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, uint8_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_UINT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UINT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_UINT16 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, uint16_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_UINT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UINT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_UINT32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, uint32_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_UINT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UINT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_UINT64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, uint64_t y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_UINT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_FP32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_FP32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, float y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_FP32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_FP64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_FP64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, double y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_FP64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_select_FC32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GxB_Matrix_select_FC32 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, GxB_FC32_t y, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_select_FC32(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_select_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_select_FC64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GxB_Matrix_select_FC64 ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, GxB_FC64_t y, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_select_FC64(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_select_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UDT(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GrB_Info GrB_Matrix_select_UDT ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_IndexUnaryOp op, const GrB_Matrix A, const void *y, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_select_UDT(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Ptr{Cvoid}, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Vector_reduce_BOOL(c, accum, monoid, u, desc)

Reduce entries in a vector to a scalar, c = accum (c, reduce_to_scalar(u))
### Prototype
```c
GrB_Info GrB_Vector_reduce_BOOL ( bool *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_BOOL(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_INT8(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_INT8 ( int8_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_INT8(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UINT8(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_UINT8 ( uint8_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_UINT8(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_INT16(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_INT16 ( int16_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_INT16(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UINT16(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_UINT16 ( uint16_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_UINT16(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_INT32(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_INT32 ( int32_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_INT32(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UINT32(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_UINT32 ( uint32_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_UINT32(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_INT64(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_INT64 ( int64_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_INT64(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UINT64(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_UINT64 ( uint64_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_UINT64(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_FP32(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_FP32 ( float *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_FP32(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_FP64(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_FP64 ( double *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_FP64(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GxB_Vector_reduce_FC32(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GxB_Vector_reduce_FC32 ( GxB_FC32_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GxB_Vector_reduce_FC32(c, accum, monoid, u, desc)
    ccall((:GxB_Vector_reduce_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GxB_Vector_reduce_FC64(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GxB_Vector_reduce_FC64 ( GxB_FC64_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GxB_Vector_reduce_FC64(c, accum, monoid, u, desc)
    ccall((:GxB_Vector_reduce_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UDT(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_UDT ( void *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_UDT(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_Monoid_Scalar(c, accum, monoid, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_Monoid_Scalar ( GrB_Scalar c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_Monoid_Scalar(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_Monoid_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_BinaryOp_Scalar(c, accum, op, u, desc)


### Prototype
```c
GrB_Info GrB_Vector_reduce_BinaryOp_Scalar ( GrB_Scalar c, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_BinaryOp_Scalar(c, accum, op, u, desc)
    ccall((:GrB_Vector_reduce_BinaryOp_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Descriptor), c, accum, op, u, desc)
end

"""
    GrB_Matrix_reduce_BOOL(c, accum, monoid, A, desc)

Reduce entries in a matrix to a scalar, c = accum (c, reduce_to_scalar(A))
### Prototype
```c
GrB_Info GrB_Matrix_reduce_BOOL ( bool *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_BOOL(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_INT8(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_INT8 ( int8_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_INT8(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UINT8(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_UINT8 ( uint8_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_UINT8(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_INT16(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_INT16 ( int16_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_INT16(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UINT16(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_UINT16 ( uint16_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_UINT16(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_INT32(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_INT32 ( int32_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_INT32(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UINT32(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_UINT32 ( uint32_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_UINT32(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_INT64(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_INT64 ( int64_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_INT64(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UINT64(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_UINT64 ( uint64_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_UINT64(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_FP32(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_FP32 ( float *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_FP32(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_FP64(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_FP64 ( double *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_FP64(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GxB_Matrix_reduce_FC32(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GxB_Matrix_reduce_FC32 ( GxB_FC32_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_reduce_FC32(c, accum, monoid, A, desc)
    ccall((:GxB_Matrix_reduce_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GxB_Matrix_reduce_FC64(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GxB_Matrix_reduce_FC64 ( GxB_FC64_t *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_reduce_FC64(c, accum, monoid, A, desc)
    ccall((:GxB_Matrix_reduce_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UDT(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_UDT ( void *c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_UDT(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_Monoid_Scalar(c, accum, monoid, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_Monoid_Scalar ( GrB_Scalar c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_Monoid_Scalar(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_Monoid_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_BinaryOp_Scalar(S, accum, op, A, desc)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_BinaryOp_Scalar ( GrB_Scalar S, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_BinaryOp_Scalar(S, accum, op, A, desc)
    ccall((:GrB_Matrix_reduce_BinaryOp_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), S, accum, op, A, desc)
end

"""
    GrB_transpose(C, Mask, accum, A, desc)

==============================================================================
GrB_transpose: matrix transpose
==============================================================================
### Prototype
```c
GrB_Info GrB_transpose ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_transpose(C, Mask, accum, A, desc)
    ccall((:GrB_transpose, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), C, Mask, accum, A, desc)
end

"""
    GxB_kron(C, Mask, accum, op, A, B, desc)

GxB_kron is historical; use GrB_kronecker instead
### Prototype
```c
GrB_Info GxB_kron ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_BinaryOp op, const GrB_Matrix A, const GrB_Matrix B, const GrB_Descriptor desc );
```
"""
function GxB_kron(C, Mask, accum, op, A, B, desc)
    ccall((:GxB_kron, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, A, B, desc)
end

"""
    GxB_Matrix_resize(C, nrows_new, ncols_new)

GxB_*_resize are identical to the GrB_*resize methods above
### Prototype
```c
GrB_Info GxB_Matrix_resize ( GrB_Matrix C, GrB_Index nrows_new, GrB_Index ncols_new );
```
"""
function GxB_Matrix_resize(C, nrows_new, ncols_new)
    ccall((:GxB_Matrix_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, nrows_new, ncols_new)
end

"""
    GxB_Vector_resize(w, nrows_new)


### Prototype
```c
GrB_Info GxB_Vector_resize ( GrB_Vector w, GrB_Index nrows_new );
```
"""
function GxB_Vector_resize(w, nrows_new)
    ccall((:GxB_Vector_resize, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), w, nrows_new)
end

"""
    GxB_Matrix_import_CSR(A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)

------------------------------------------------------------------------------
GxB_Matrix_pack_CSR: pack a CSR matrix
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Matrix_import_CSR ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, GrB_Index **Ap, GrB_Index **Aj, void **Ax, GrB_Index Ap_size, GrB_Index Aj_size, GrB_Index Ax_size, bool iso, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_import_CSR(A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_import_CSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
end

"""
    GxB_Matrix_pack_CSR(A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_pack_CSR ( GrB_Matrix A, GrB_Index **Ap, GrB_Index **Aj, void **Ax, GrB_Index Ap_size, GrB_Index Aj_size, GrB_Index Ax_size, bool iso, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_pack_CSR(A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_pack_CSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
end

"""
    GxB_Matrix_import_CSC(A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)

------------------------------------------------------------------------------
GxB_Matrix_pack_CSC: pack a CSC matrix
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Matrix_import_CSC ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, GrB_Index **Ap, GrB_Index **Ai, void **Ax, GrB_Index Ap_size, GrB_Index Ai_size, GrB_Index Ax_size, bool iso, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_import_CSC(A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_import_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
end

"""
    GxB_Matrix_pack_CSC(A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_pack_CSC ( GrB_Matrix A, GrB_Index **Ap, GrB_Index **Ai, void **Ax, GrB_Index Ap_size, GrB_Index Ai_size, GrB_Index Ax_size, bool iso, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_pack_CSC(A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_pack_CSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
end

"""
    GxB_Matrix_import_HyperCSR(A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)

------------------------------------------------------------------------------
GxB_Matrix_pack_HyperCSR: pack a hypersparse CSR matrix
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Matrix_import_HyperCSR ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, GrB_Index **Ap, GrB_Index **Ah, GrB_Index **Aj, void **Ax, GrB_Index Ap_size, GrB_Index Ah_size, GrB_Index Aj_size, GrB_Index Ax_size, bool iso, GrB_Index nvec, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_import_HyperCSR(A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_import_HyperCSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
end

"""
    GxB_Matrix_pack_HyperCSR(A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_pack_HyperCSR ( GrB_Matrix A, GrB_Index **Ap, GrB_Index **Ah, GrB_Index **Aj, void **Ax, GrB_Index Ap_size, GrB_Index Ah_size, GrB_Index Aj_size, GrB_Index Ax_size, bool iso, GrB_Index nvec, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_pack_HyperCSR(A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_pack_HyperCSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
end

"""
    GxB_Matrix_import_HyperCSC(A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)

------------------------------------------------------------------------------
GxB_Matrix_pack_HyperCSC: pack a hypersparse CSC matrix
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Matrix_import_HyperCSC ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, GrB_Index **Ap, GrB_Index **Ah, GrB_Index **Ai, void **Ax, GrB_Index Ap_size, GrB_Index Ah_size, GrB_Index Ai_size, GrB_Index Ax_size, bool iso, GrB_Index nvec, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_import_HyperCSC(A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_import_HyperCSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
end

"""
    GxB_Matrix_pack_HyperCSC(A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_pack_HyperCSC ( GrB_Matrix A, GrB_Index **Ap, GrB_Index **Ah, GrB_Index **Ai, void **Ax, GrB_Index Ap_size, GrB_Index Ah_size, GrB_Index Ai_size, GrB_Index Ax_size, bool iso, GrB_Index nvec, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_pack_HyperCSC(A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_pack_HyperCSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
end

"""
    GxB_Matrix_import_BitmapR(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)

------------------------------------------------------------------------------
GxB_Matrix_pack_BitmapR: pack a bitmap matrix, held by row
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Matrix_import_BitmapR ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, int8_t **Ab, void **Ax, GrB_Index Ab_size, GrB_Index Ax_size, bool iso, GrB_Index nvals, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_import_BitmapR(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_import_BitmapR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

"""
    GxB_Matrix_pack_BitmapR(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)


### Prototype
```c
GrB_Info GxB_Matrix_pack_BitmapR ( GrB_Matrix A, int8_t **Ab, void **Ax, GrB_Index Ab_size, GrB_Index Ax_size, bool iso, GrB_Index nvals, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_pack_BitmapR(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_pack_BitmapR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

"""
    GxB_Matrix_import_BitmapC(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)

------------------------------------------------------------------------------
GxB_Matrix_pack_BitmapC: pack a bitmap matrix, held by column
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Matrix_import_BitmapC ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, int8_t **Ab, void **Ax, GrB_Index Ab_size, GrB_Index Ax_size, bool iso, GrB_Index nvals, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_import_BitmapC(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_import_BitmapC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

"""
    GxB_Matrix_pack_BitmapC(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)


### Prototype
```c
GrB_Info GxB_Matrix_pack_BitmapC ( GrB_Matrix A, int8_t **Ab, void **Ax, GrB_Index Ab_size, GrB_Index Ax_size, bool iso, GrB_Index nvals, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_pack_BitmapC(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_pack_BitmapC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

"""
    GxB_Matrix_import_FullR(A, type, nrows, ncols, Ax, Ax_size, iso, desc)

------------------------------------------------------------------------------
GxB_Matrix_pack_FullR:  pack a full matrix, held by row
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Matrix_import_FullR ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, void **Ax, GrB_Index Ax_size, bool iso, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_import_FullR(A, type, nrows, ncols, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_import_FullR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, iso, desc)
end

"""
    GxB_Matrix_pack_FullR(A, Ax, Ax_size, iso, desc)


### Prototype
```c
GrB_Info GxB_Matrix_pack_FullR ( GrB_Matrix A, void **Ax, GrB_Index Ax_size, bool iso, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_pack_FullR(A, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_pack_FullR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, Ax, Ax_size, iso, desc)
end

"""
    GxB_Matrix_import_FullC(A, type, nrows, ncols, Ax, Ax_size, iso, desc)

------------------------------------------------------------------------------
GxB_Matrix_pack_FullC: pack a full matrix, held by column
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Matrix_import_FullC ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, void **Ax, GrB_Index Ax_size, bool iso, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_import_FullC(A, type, nrows, ncols, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_import_FullC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, iso, desc)
end

"""
    GxB_Matrix_pack_FullC(A, Ax, Ax_size, iso, desc)


### Prototype
```c
GrB_Info GxB_Matrix_pack_FullC ( GrB_Matrix A, void **Ax, GrB_Index Ax_size, bool iso, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_pack_FullC(A, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_pack_FullC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, Ax, Ax_size, iso, desc)
end

"""
    GxB_Vector_import_CSC(v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)

------------------------------------------------------------------------------
GxB_Vector_pack_CSC: import/pack a vector in CSC format
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Vector_import_CSC ( GrB_Vector *v, GrB_Type type, GrB_Index n, GrB_Index **vi, void **vx, GrB_Index vi_size, GrB_Index vx_size, bool iso, GrB_Index nvals, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Vector_import_CSC(v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
    ccall((:GxB_Vector_import_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
end

"""
    GxB_Vector_pack_CSC(v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Vector_pack_CSC ( GrB_Vector v, GrB_Index **vi, void **vx, GrB_Index vi_size, GrB_Index vx_size, bool iso, GrB_Index nvals, bool jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Vector_pack_CSC(v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
    ccall((:GxB_Vector_pack_CSC, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
end

"""
    GxB_Vector_import_Bitmap(v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)

------------------------------------------------------------------------------
GxB_Vector_pack_Bitmap: pack a vector in bitmap format
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Vector_import_Bitmap ( GrB_Vector *v, GrB_Type type, GrB_Index n, int8_t **vb, void **vx, GrB_Index vb_size, GrB_Index vx_size, bool iso, GrB_Index nvals, const GrB_Descriptor desc );
```
"""
function GxB_Vector_import_Bitmap(v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)
    ccall((:GxB_Vector_import_Bitmap, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)
end

"""
    GxB_Vector_pack_Bitmap(v, vb, vx, vb_size, vx_size, iso, nvals, desc)


### Prototype
```c
GrB_Info GxB_Vector_pack_Bitmap ( GrB_Vector v, int8_t **vb, void **vx, GrB_Index vb_size, GrB_Index vx_size, bool iso, GrB_Index nvals, const GrB_Descriptor desc );
```
"""
function GxB_Vector_pack_Bitmap(v, vb, vx, vb_size, vx_size, iso, nvals, desc)
    ccall((:GxB_Vector_pack_Bitmap, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), v, vb, vx, vb_size, vx_size, iso, nvals, desc)
end

"""
    GxB_Vector_import_Full(v, type, n, vx, vx_size, iso, desc)

------------------------------------------------------------------------------
GxB_Vector_pack_Full: pack a vector in full format
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GxB_Vector_import_Full ( GrB_Vector *v, GrB_Type type, GrB_Index n, void **vx, GrB_Index vx_size, bool iso, const GrB_Descriptor desc );
```
"""
function GxB_Vector_import_Full(v, type, n, vx, vx_size, iso, desc)
    ccall((:GxB_Vector_import_Full, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), v, type, n, vx, vx_size, iso, desc)
end

"""
    GxB_Vector_pack_Full(v, vx, vx_size, iso, desc)


### Prototype
```c
GrB_Info GxB_Vector_pack_Full ( GrB_Vector v, void **vx, GrB_Index vx_size, bool iso, const GrB_Descriptor desc );
```
"""
function GxB_Vector_pack_Full(v, vx, vx_size, iso, desc)
    ccall((:GxB_Vector_pack_Full, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), v, vx, vx_size, iso, desc)
end

"""
    GxB_Matrix_export_CSR(A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)

The GxB_*_export/unpack functions are symmetric with the GxB_*_import/pack
functions.  The export/unpack functions force completion of any pending
operations, prior to the export, except if the only pending operation is to
unjumble the matrix.

If there are no entries in the matrix or vector, then the index arrays (Ai,
Aj, or vi) and value arrays (Ax or vx) are returned as NULL.  This is not an
error condition.

A GrB_Matrix may be exported/unpacked in any one of four different formats.
On successful export, the input GrB_Matrix A is freed, and the output arrays
Ah, Ap, Ai, Aj, and/or Ax are returned to the user application as arrays
allocated by the ANSI C malloc function.  The four formats are the same as
the import formats for GxB_Matrix_import/pack.

If jumbled is NULL on input, this indicates to GxB_*export/unpack* that the
exported/unpacked matrix cannot be returned in a jumbled format.  In this
case, if the matrix is jumbled, it is sorted before exporting it to the
caller.

If iso is NULL on input, this indicates to the export/unpack methods that
the exported/unpacked matrix cannot be returned in a iso format, with an Ax
array with just one entry.  In this case, if the matrix is iso, it is
expanded before exporting/unpacking it to the caller.

For the export/unpack*Full* methods, all entries in the matrix or must be
present.  That is, GrB_*_nvals must report nvals equal to nrows*ncols or a
matrix.  If this condition does not hold, the matrix/vector is not exported,
and GrB_INVALID_VALUE is returned.

If the export/unpack is not successful, the export/unpack functions do not
modify matrix or vector and the user arrays are returned as NULL.
### Prototype
```c
GrB_Info GxB_Matrix_export_CSR ( GrB_Matrix *A, GrB_Type *type, GrB_Index *nrows, GrB_Index *ncols, GrB_Index **Ap, GrB_Index **Aj, void **Ax, GrB_Index *Ap_size, GrB_Index *Aj_size, GrB_Index *Ax_size, bool *iso, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_export_CSR(A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_export_CSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
end

"""
    GxB_Matrix_unpack_CSR(A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_CSR ( GrB_Matrix A, GrB_Index **Ap, GrB_Index **Aj, void **Ax, GrB_Index *Ap_size, GrB_Index *Aj_size, GrB_Index *Ax_size, bool *iso, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_unpack_CSR(A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_unpack_CSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
end

"""
    GxB_Matrix_export_CSC(A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_export_CSC ( GrB_Matrix *A, GrB_Type *type, GrB_Index *nrows, GrB_Index *ncols, GrB_Index **Ap, GrB_Index **Ai, void **Ax, GrB_Index *Ap_size, GrB_Index *Ai_size, GrB_Index *Ax_size, bool *iso, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_export_CSC(A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_export_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
end

"""
    GxB_Matrix_unpack_CSC(A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_CSC ( GrB_Matrix A, GrB_Index **Ap, GrB_Index **Ai, void **Ax, GrB_Index *Ap_size, GrB_Index *Ai_size, GrB_Index *Ax_size, bool *iso, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_unpack_CSC(A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_unpack_CSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
end

"""
    GxB_Matrix_export_HyperCSR(A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_export_HyperCSR ( GrB_Matrix *A, GrB_Type *type, GrB_Index *nrows, GrB_Index *ncols, GrB_Index **Ap, GrB_Index **Ah, GrB_Index **Aj, void **Ax, GrB_Index *Ap_size, GrB_Index *Ah_size, GrB_Index *Aj_size, GrB_Index *Ax_size, bool *iso, GrB_Index *nvec, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_export_HyperCSR(A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_export_HyperCSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
end

"""
    GxB_Matrix_unpack_HyperCSR(A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_HyperCSR ( GrB_Matrix A, GrB_Index **Ap, GrB_Index **Ah, GrB_Index **Aj, void **Ax, GrB_Index *Ap_size, GrB_Index *Ah_size, GrB_Index *Aj_size, GrB_Index *Ax_size, bool *iso, GrB_Index *nvec, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_unpack_HyperCSR(A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_unpack_HyperCSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
end

"""
    GxB_Matrix_export_HyperCSC(A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_export_HyperCSC ( GrB_Matrix *A, GrB_Type *type, GrB_Index *nrows, GrB_Index *ncols, GrB_Index **Ap, GrB_Index **Ah, GrB_Index **Ai, void **Ax, GrB_Index *Ap_size, GrB_Index *Ah_size, GrB_Index *Ai_size, GrB_Index *Ax_size, bool *iso, GrB_Index *nvec, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_export_HyperCSC(A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_export_HyperCSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
end

"""
    GxB_Matrix_unpack_HyperCSC(A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_HyperCSC ( GrB_Matrix A, GrB_Index **Ap, GrB_Index **Ah, GrB_Index **Ai, void **Ax, GrB_Index *Ap_size, GrB_Index *Ah_size, GrB_Index *Ai_size, GrB_Index *Ax_size, bool *iso, GrB_Index *nvec, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_unpack_HyperCSC(A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_unpack_HyperCSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
end

"""
    GxB_Matrix_export_BitmapR(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)


### Prototype
```c
GrB_Info GxB_Matrix_export_BitmapR ( GrB_Matrix *A, GrB_Type *type, GrB_Index *nrows, GrB_Index *ncols, int8_t **Ab, void **Ax, GrB_Index *Ab_size, GrB_Index *Ax_size, bool *iso, GrB_Index *nvals, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_export_BitmapR(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_export_BitmapR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

"""
    GxB_Matrix_unpack_BitmapR(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_BitmapR ( GrB_Matrix A, int8_t **Ab, void **Ax, GrB_Index *Ab_size, GrB_Index *Ax_size, bool *iso, GrB_Index *nvals, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_unpack_BitmapR(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_unpack_BitmapR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

"""
    GxB_Matrix_export_BitmapC(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)


### Prototype
```c
GrB_Info GxB_Matrix_export_BitmapC ( GrB_Matrix *A, GrB_Type *type, GrB_Index *nrows, GrB_Index *ncols, int8_t **Ab, void **Ax, GrB_Index *Ab_size, GrB_Index *Ax_size, bool *iso, GrB_Index *nvals, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_export_BitmapC(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_export_BitmapC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

"""
    GxB_Matrix_unpack_BitmapC(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_BitmapC ( GrB_Matrix A, int8_t **Ab, void **Ax, GrB_Index *Ab_size, GrB_Index *Ax_size, bool *iso, GrB_Index *nvals, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_unpack_BitmapC(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_unpack_BitmapC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

"""
    GxB_Matrix_export_FullR(A, type, nrows, ncols, Ax, Ax_size, iso, desc)


### Prototype
```c
GrB_Info GxB_Matrix_export_FullR ( GrB_Matrix *A, GrB_Type *type, GrB_Index *nrows, GrB_Index *ncols, void **Ax, GrB_Index *Ax_size, bool *iso, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_export_FullR(A, type, nrows, ncols, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_export_FullR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, iso, desc)
end

"""
    GxB_Matrix_unpack_FullR(A, Ax, Ax_size, iso, desc)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_FullR ( GrB_Matrix A, void **Ax, GrB_Index *Ax_size, bool *iso, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_unpack_FullR(A, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_unpack_FullR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, Ax, Ax_size, iso, desc)
end

"""
    GxB_Matrix_export_FullC(A, type, nrows, ncols, Ax, Ax_size, iso, desc)


### Prototype
```c
GrB_Info GxB_Matrix_export_FullC ( GrB_Matrix *A, GrB_Type *type, GrB_Index *nrows, GrB_Index *ncols, void **Ax, GrB_Index *Ax_size, bool *iso, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_export_FullC(A, type, nrows, ncols, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_export_FullC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, iso, desc)
end

"""
    GxB_Matrix_unpack_FullC(A, Ax, Ax_size, iso, desc)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_FullC ( GrB_Matrix A, void **Ax, GrB_Index *Ax_size, bool *iso, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_unpack_FullC(A, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_unpack_FullC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, Ax, Ax_size, iso, desc)
end

"""
    GxB_Vector_export_CSC(v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Vector_export_CSC ( GrB_Vector *v, GrB_Type *type, GrB_Index *n, GrB_Index **vi, void **vx, GrB_Index *vi_size, GrB_Index *vx_size, bool *iso, GrB_Index *nvals, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Vector_export_CSC(v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
    ccall((:GxB_Vector_export_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
end

"""
    GxB_Vector_unpack_CSC(v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)


### Prototype
```c
GrB_Info GxB_Vector_unpack_CSC ( GrB_Vector v, GrB_Index **vi, void **vx, GrB_Index *vi_size, GrB_Index *vx_size, bool *iso, GrB_Index *nvals, bool *jumbled, const GrB_Descriptor desc );
```
"""
function GxB_Vector_unpack_CSC(v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
    ccall((:GxB_Vector_unpack_CSC, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
end

"""
    GxB_Vector_export_Bitmap(v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)


### Prototype
```c
GrB_Info GxB_Vector_export_Bitmap ( GrB_Vector *v, GrB_Type *type, GrB_Index *n, int8_t **vb, void **vx, GrB_Index *vb_size, GrB_Index *vx_size, bool *iso, GrB_Index *nvals, const GrB_Descriptor desc );
```
"""
function GxB_Vector_export_Bitmap(v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)
    ccall((:GxB_Vector_export_Bitmap, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)
end

"""
    GxB_Vector_unpack_Bitmap(v, vb, vx, vb_size, vx_size, iso, nvals, desc)


### Prototype
```c
GrB_Info GxB_Vector_unpack_Bitmap ( GrB_Vector v, int8_t **vb, void **vx, GrB_Index *vb_size, GrB_Index *vx_size, bool *iso, GrB_Index *nvals, const GrB_Descriptor desc );
```
"""
function GxB_Vector_unpack_Bitmap(v, vb, vx, vb_size, vx_size, iso, nvals, desc)
    ccall((:GxB_Vector_unpack_Bitmap, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), v, vb, vx, vb_size, vx_size, iso, nvals, desc)
end

"""
    GxB_Vector_export_Full(v, type, n, vx, vx_size, iso, desc)


### Prototype
```c
GrB_Info GxB_Vector_export_Full ( GrB_Vector *v, GrB_Type *type, GrB_Index *n, void **vx, GrB_Index *vx_size, bool *iso, const GrB_Descriptor desc );
```
"""
function GxB_Vector_export_Full(v, type, n, vx, vx_size, iso, desc)
    ccall((:GxB_Vector_export_Full, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, type, n, vx, vx_size, iso, desc)
end

"""
    GxB_Vector_unpack_Full(v, vx, vx_size, iso, desc)


### Prototype
```c
GrB_Info GxB_Vector_unpack_Full ( GrB_Vector v, void **vx, GrB_Index *vx_size, bool *iso, const GrB_Descriptor desc );
```
"""
function GxB_Vector_unpack_Full(v, vx, vx_size, iso, desc)
    ccall((:GxB_Vector_unpack_Full, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, vx, vx_size, iso, desc)
end

"""
    GxB_unpack_HyperHash(A, Y, desc)

If this method is called to remove the hyper_hash Y from the hypersparse
matrix A, and then GrB_Matrix_wait (A) is called, a new hyper_hash matrix is
constructed for A.
### Prototype
```c
GrB_Info GxB_unpack_HyperHash ( GrB_Matrix A, GrB_Matrix *Y, const GrB_Descriptor desc );
```
"""
function GxB_unpack_HyperHash(A, Y, desc)
    ccall((:GxB_unpack_HyperHash, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Matrix}, GrB_Descriptor), A, Y, desc)
end

"""
    GxB_pack_HyperHash(A, Y, desc)

Results are undefined if the input Y was not created by GxB_unpack_HyperHash
(see the example above) or if the Ah contents or nvec of the matrix A are
modified after they were exported/unpacked by
GxB_Matrix_(export/unpack)_Hyper(CSR/CSC).
### Prototype
```c
GrB_Info GxB_pack_HyperHash ( GrB_Matrix A, GrB_Matrix *Y, const GrB_Descriptor desc );
```
"""
function GxB_pack_HyperHash(A, Y, desc)
    ccall((:GxB_pack_HyperHash, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Matrix}, GrB_Descriptor), A, Y, desc)
end

"""
    GrB_Format

The GrB C API specification supports 3 formats:
"""
@enum GrB_Format::UInt32 begin
    GrB_CSR_FORMAT = 0
    GrB_CSC_FORMAT = 1
    GrB_COO_FORMAT = 2
end

"""
    GrB_Matrix_import_BOOL(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_BOOL ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const bool *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_BOOL(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_INT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_INT8 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const int8_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_INT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_INT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_INT16 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const int16_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_INT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_INT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_INT32 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const int32_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_INT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_INT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_INT64 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const int64_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_INT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UINT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_UINT8 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const uint8_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_UINT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UINT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_UINT16 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const uint16_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_UINT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UINT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_UINT32 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const uint32_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_UINT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UINT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_UINT64 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const uint64_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_UINT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_FP32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_FP32 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const float *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_FP32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_FP64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_FP64 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const double *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_FP64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GxB_Matrix_import_FC32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GxB_Matrix_import_FC32 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const GxB_FC32_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GxB_Matrix_import_FC32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GxB_Matrix_import_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GxB_Matrix_import_FC64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GxB_Matrix_import_FC64 ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const GxB_FC64_t *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GxB_Matrix_import_FC64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GxB_Matrix_import_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UDT(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GrB_Info GrB_Matrix_import_UDT ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const GrB_Index *Ap, const GrB_Index *Ai, const void *Ax, GrB_Index Ap_len, GrB_Index Ai_len, GrB_Index Ax_len, GrB_Format format );
```
"""
function GrB_Matrix_import_UDT(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_export_BOOL(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)

For GrB_Matrix_export_T: on input, Ap_len, Ai_len, and Ax_len are
the size of the 3 arrays Ap, Ai, and Ax, in terms of the # of entries.
On output, these 3 values are modified to be the # of entries copied
into those 3 arrays.
### Prototype
```c
GrB_Info GrB_Matrix_export_BOOL ( GrB_Index *Ap, GrB_Index *Ai, bool *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_BOOL(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_INT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_INT8 ( GrB_Index *Ap, GrB_Index *Ai, int8_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_INT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_INT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_INT16 ( GrB_Index *Ap, GrB_Index *Ai, int16_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_INT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_INT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_INT32 ( GrB_Index *Ap, GrB_Index *Ai, int32_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_INT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_INT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_INT64 ( GrB_Index *Ap, GrB_Index *Ai, int64_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_INT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UINT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_UINT8 ( GrB_Index *Ap, GrB_Index *Ai, uint8_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_UINT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UINT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_UINT16 ( GrB_Index *Ap, GrB_Index *Ai, uint16_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_UINT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UINT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_UINT32 ( GrB_Index *Ap, GrB_Index *Ai, uint32_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_UINT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UINT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_UINT64 ( GrB_Index *Ap, GrB_Index *Ai, uint64_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_UINT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_FP32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_FP32 ( GrB_Index *Ap, GrB_Index *Ai, float *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_FP32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_FP64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_FP64 ( GrB_Index *Ap, GrB_Index *Ai, double *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_FP64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GxB_Matrix_export_FC32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GxB_Matrix_export_FC32 ( GrB_Index *Ap, GrB_Index *Ai, GxB_FC32_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GxB_Matrix_export_FC32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GxB_Matrix_export_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GxB_Matrix_export_FC64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GxB_Matrix_export_FC64 ( GrB_Index *Ap, GrB_Index *Ai, GxB_FC64_t *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GxB_Matrix_export_FC64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GxB_Matrix_export_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UDT(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_export_UDT ( GrB_Index *Ap, GrB_Index *Ai, void *Ax, GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_export_UDT(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_exportSize(Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_exportSize ( GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, GrB_Format format, GrB_Matrix A );
```
"""
function GrB_Matrix_exportSize(Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_exportSize, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_exportHint(format, A)


### Prototype
```c
GrB_Info GrB_Matrix_exportHint ( GrB_Format *format, GrB_Matrix A );
```
"""
function GrB_Matrix_exportHint(format, A)
    ccall((:GrB_Matrix_exportHint, libgraphblas), GrB_Info, (Ptr{GrB_Format}, GrB_Matrix), format, A)
end

"""
    GxB_Matrix_serialize(blob_handle, blob_size_handle, A, desc)

If the level setting is out of range, the default is used for that method.
If the method is negative, no compression is performed.  If the method is
positive but unrecognized, the default is used (GxB_COMPRESSION_ZSTD,
level 1).
### Prototype
```c
GrB_Info GxB_Matrix_serialize ( void **blob_handle, GrB_Index *blob_size_handle, GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_serialize(blob_handle, blob_size_handle, A, desc)
    ccall((:GxB_Matrix_serialize, libgraphblas), GrB_Info, (Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, GrB_Matrix, GrB_Descriptor), blob_handle, blob_size_handle, A, desc)
end

"""
    GrB_Matrix_serialize(blob, blob_size_handle, A)


### Prototype
```c
GrB_Info GrB_Matrix_serialize ( void *blob, GrB_Index *blob_size_handle, GrB_Matrix A );
```
"""
function GrB_Matrix_serialize(blob, blob_size_handle, A)
    ccall((:GrB_Matrix_serialize, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Matrix), blob, blob_size_handle, A)
end

"""
    GxB_Vector_serialize(blob_handle, blob_size_handle, u, desc)


### Prototype
```c
GrB_Info GxB_Vector_serialize ( void **blob_handle, GrB_Index *blob_size_handle, GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GxB_Vector_serialize(blob_handle, blob_size_handle, u, desc)
    ccall((:GxB_Vector_serialize, libgraphblas), GrB_Info, (Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, GrB_Vector, GrB_Descriptor), blob_handle, blob_size_handle, u, desc)
end

"""
    GrB_Matrix_serializeSize(blob_size_handle, A)


### Prototype
```c
GrB_Info GrB_Matrix_serializeSize ( GrB_Index *blob_size_handle, GrB_Matrix A );
```
"""
function GrB_Matrix_serializeSize(blob_size_handle, A)
    ccall((:GrB_Matrix_serializeSize, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), blob_size_handle, A)
end

"""
    GxB_Matrix_deserialize(C, type, blob, blob_size, desc)

The GrB* and GxB* deserialize methods are nearly identical.  The GxB*
deserialize methods simply add the descriptor, which allows for optional
control of the # of threads used to deserialize the blob.
### Prototype
```c
GrB_Info GxB_Matrix_deserialize ( GrB_Matrix *C, GrB_Type type, const void *blob, GrB_Index blob_size, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_deserialize(C, type, blob, blob_size, desc)
    ccall((:GxB_Matrix_deserialize, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Ptr{Cvoid}, GrB_Index, GrB_Descriptor), C, type, blob, blob_size, desc)
end

"""
    GrB_Matrix_deserialize(C, type, blob, blob_size)


### Prototype
```c
GrB_Info GrB_Matrix_deserialize ( GrB_Matrix *C, GrB_Type type, const void *blob, GrB_Index blob_size );
```
"""
function GrB_Matrix_deserialize(C, type, blob, blob_size)
    ccall((:GrB_Matrix_deserialize, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Ptr{Cvoid}, GrB_Index), C, type, blob, blob_size)
end

"""
    GxB_Vector_deserialize(w, type, blob, blob_size, desc)


### Prototype
```c
GrB_Info GxB_Vector_deserialize ( GrB_Vector *w, GrB_Type type, const void *blob, GrB_Index blob_size, const GrB_Descriptor desc );
```
"""
function GxB_Vector_deserialize(w, type, blob, blob_size, desc)
    ccall((:GxB_Vector_deserialize, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, Ptr{Cvoid}, GrB_Index, GrB_Descriptor), w, type, blob, blob_size, desc)
end

"""
    GxB_deserialize_type_name(arg1, arg2, arg3)

historical; use GrB_get with GxB_JIT_C_NAME instead.
### Prototype
```c
GrB_Info GxB_deserialize_type_name (char *, const void *, GrB_Index);
```
"""
function GxB_deserialize_type_name(arg1, arg2, arg3)
    ccall((:GxB_deserialize_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, Ptr{Cvoid}, GrB_Index), arg1, arg2, arg3)
end

"""
    GxB_Matrix_reshape(C, by_col, nrows_new, ncols_new, desc)

If the input matrix is nrows-by-ncols, and the size of the reshaped matrix
is nrows_new-by-ncols_new, then nrows*ncols must equal nrows_new*ncols_new.
The format of the input matrix (by row or by column) is unchanged; this
format need not match the by_col input parameter.
### Prototype
```c
GrB_Info GxB_Matrix_reshape ( GrB_Matrix C, bool by_col, GrB_Index nrows_new, GrB_Index ncols_new, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_reshape(C, by_col, nrows_new, ncols_new, desc)
    ccall((:GxB_Matrix_reshape, libgraphblas), GrB_Info, (GrB_Matrix, Bool, GrB_Index, GrB_Index, GrB_Descriptor), C, by_col, nrows_new, ncols_new, desc)
end

"""
    GxB_Matrix_reshapeDup(C, A, by_col, nrows_new, ncols_new, desc)

If the input matrix A is nrows-by-ncols, and the size of the newly-created
matrix C is nrows_new-by-ncols_new, then nrows*ncols must equal
nrows_new*ncols_new.  The format of the input matrix A (by row or by column)
determines the format of the output matrix C, which need not match the
by_col input parameter.
### Prototype
```c
GrB_Info GxB_Matrix_reshapeDup ( GrB_Matrix *C, GrB_Matrix A, bool by_col, GrB_Index nrows_new, GrB_Index ncols_new, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_reshapeDup(C, A, by_col, nrows_new, ncols_new, desc)
    ccall((:GxB_Matrix_reshapeDup, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Matrix, Bool, GrB_Index, GrB_Index, GrB_Descriptor), C, A, by_col, nrows_new, ncols_new, desc)
end

"""
    GxB_Iterator_new(iterator)

GxB_Iterator_new: create a new iterator, not attached to any matrix/vector
### Prototype
```c
GrB_Info GxB_Iterator_new (GxB_Iterator *iterator);
```
"""
function GxB_Iterator_new(iterator)
    ccall((:GxB_Iterator_new, libgraphblas), GrB_Info, (Ptr{GxB_Iterator},), iterator)
end

"""
    GxB_Matrix_Iterator_attach(iterator, A, desc)

If successful, the entry iterator is attached to the matrix, but not to any
specific entry.  Use GxB_Matrix_Iterator_*seek* to move the iterator to a
particular entry.
### Prototype
```c
GrB_Info GxB_Matrix_Iterator_attach ( GxB_Iterator iterator, GrB_Matrix A, GrB_Descriptor desc );
```
"""
function GxB_Matrix_Iterator_attach(iterator, A, desc)
    ccall((:GxB_Matrix_Iterator_attach, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Matrix, GrB_Descriptor), iterator, A, desc)
end

"""
    GxB_Matrix_Iterator_getpmax(iterator)

Entries in a matrix are given an index p, ranging from 0 to pmax-1, where
pmax >= nvals(A).  For sparse, hypersparse, and full matrices, pmax is equal
to nvals(A).  For an m-by-n bitmap matrix, pmax=m*n, or pmax=0 if the
matrix has no entries.
### Prototype
```c
GrB_Index GxB_Matrix_Iterator_getpmax (GxB_Iterator iterator);
```
"""
function GxB_Matrix_Iterator_getpmax(iterator)
    ccall((:GxB_Matrix_Iterator_getpmax, libgraphblas), GrB_Index, (GxB_Iterator,), iterator)
end

"""
    GxB_Matrix_Iterator_seek(iterator, p)

Returns GrB_SUCCESS if the iterator is at an entry that exists in the
matrix, or GxB_EXHAUSTED if the iterator is exhausted.
### Prototype
```c
GrB_Info GxB_Matrix_Iterator_seek (GxB_Iterator iterator, GrB_Index p);
```
"""
function GxB_Matrix_Iterator_seek(iterator, p)
    ccall((:GxB_Matrix_Iterator_seek, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Index), iterator, p)
end

"""
    GxB_Matrix_Iterator_next(iterator)

Returns GrB_SUCCESS if the iterator is at an entry that exists in the
matrix, or GxB_EXHAUSTED if the iterator is exhausted.
### Prototype
```c
GrB_Info GxB_Matrix_Iterator_next (GxB_Iterator iterator);
```
"""
function GxB_Matrix_Iterator_next(iterator)
    ccall((:GxB_Matrix_Iterator_next, libgraphblas), GrB_Info, (GxB_Iterator,), iterator)
end

"""
    GxB_Matrix_Iterator_getp(iterator)

On input, the entry iterator must be already attached to a matrix via
GxB_Matrix_Iterator_attach, and the position of the iterator must also have
been defined by a prior call to GxB_Matrix_Iterator_seek or
GxB_Matrix_Iterator_next.  Results are undefined if these conditions are not
met.
### Prototype
```c
GrB_Index GxB_Matrix_Iterator_getp (GxB_Iterator iterator);
```
"""
function GxB_Matrix_Iterator_getp(iterator)
    ccall((:GxB_Matrix_Iterator_getp, libgraphblas), GrB_Index, (GxB_Iterator,), iterator)
end

"""
    GxB_Matrix_Iterator_getIndex(iterator, row, col)

On input, the entry iterator must be already attached to a matrix via
GxB_Matrix_Iterator_attach, and the position of the iterator must also have
been defined by a prior call to GxB_Matrix_Iterator_seek or
GxB_Matrix_Iterator_next, with a return value of GrB_SUCCESS.  Results are
undefined if these conditions are not met.
### Prototype
```c
void GxB_Matrix_Iterator_getIndex ( GxB_Iterator iterator, GrB_Index *row, GrB_Index *col );
```
"""
function GxB_Matrix_Iterator_getIndex(iterator, row, col)
    ccall((:GxB_Matrix_Iterator_getIndex, libgraphblas), Cvoid, (GxB_Iterator, Ptr{GrB_Index}, Ptr{GrB_Index}), iterator, row, col)
end

"""
    GxB_Vector_Iterator_attach(iterator, v, desc)

If successful, the iterator is attached to the vector, but not to any
specific entry.  Use GxB_Vector_Iterator_seek to move the iterator to a
particular entry.
### Prototype
```c
GrB_Info GxB_Vector_Iterator_attach ( GxB_Iterator iterator, GrB_Vector v, GrB_Descriptor desc );
```
"""
function GxB_Vector_Iterator_attach(iterator, v, desc)
    ccall((:GxB_Vector_Iterator_attach, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Vector, GrB_Descriptor), iterator, v, desc)
end

# Skipping MacroDefinition: GB_GLOBAL extern

const GB_HAS_CMPLX_MACROS = 1

const GxB_IMPLEMENTATION_NAME = "SuiteSparse:GraphBLAS"

const GxB_IMPLEMENTATION_DATE = "Oct 7, 2023"

const GxB_IMPLEMENTATION_MAJOR = 9

const GxB_IMPLEMENTATION_MINOR = 0

const GxB_IMPLEMENTATION_SUB = 0

const GxB_SPEC_DATE = "Oct 7, 2023"

const GxB_SPEC_MAJOR = 2

const GxB_SPEC_MINOR = 1

const GxB_SPEC_SUB = 0

const GRB_VERSION = GxB_SPEC_MAJOR

const GRB_SUBVERSION = GxB_SPEC_MINOR

# Skipping MacroDefinition: GxB_IMPLEMENTATION_ABOUT \
#"SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2023, All Rights Reserved." \
#"\nhttp://suitesparse.com  Dept of Computer Sci. & Eng, Texas A&M University.\n"

# Skipping MacroDefinition: GxB_IMPLEMENTATION_LICENSE \
#"SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2023, All Rights Reserved." \
#"\nLicensed under the Apache License, Version 2.0 (the \"License\"); you may\n" \
#"not use SuiteSparse:GraphBLAS except in compliance with the License.  You\n" \
#"may obtain a copy of the License at\n\n" \
#"    http://www.apache.org/licenses/LICENSE-2.0\n\n" \
#"Unless required by applicable law or agreed to in writing, software\n" \
#"distributed under the License is distributed on an \"AS IS\" BASIS,\n" \
#"WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n" \
#"See the License for the specific language governing permissions and\n" \
#"limitations under the License.\n"

# Skipping MacroDefinition: GxB_SPEC_ABOUT \
#"GraphBLAS C API, by Benjamin Brock, Aydin Buluc, Raye Kimmerer,\n" \
#"Jim Kitchen, Major Kumar, Timothy Mattson, Scott McMillan, Jose' Moreira,\n" \
#"Erik Welch, and Carl Yang.  Based on 'GraphBLAS Mathematics by Jeremy\n" \
#"Kepner.  See also 'Graph Algorithms in the Language of Linear Algebra,'\n" \
#"edited by J. Kepner and J. Gilbert, SIAM, 2011.\n"

const GxB_NTHREADS = 7086

const GxB_CHUNK = 7087

const GxB_GPU_ID = 7088

const GxB_FAST_IMPORT = Cint(GrB_DEFAULT)

const GxB_MAX_NAME_LEN = 128

const GxB_HYPERSPARSE = 1

const GxB_SPARSE = 2

const GxB_BITMAP = 4

const GxB_FULL = 8

const GxB_NBITMAP_SWITCH = 8

const GxB_ANY_SPARSITY = GxB_HYPERSPARSE + GxB_SPARSE + GxB_BITMAP + GxB_FULL

const GxB_AUTO_SPARSITY = GxB_ANY_SPARSITY

const GrB_NULL = NULL

const GrB_INVALID_HANDLE = NULL

const GxB_RANGE = INT64_MAX

const GxB_STRIDE = INT64_MAX - 1

const GxB_BACKWARDS = INT64_MAX - 2

const GxB_BEGIN = 0

const GxB_END = 1

const GxB_INC = 2

const GxB_COMPRESSION_NONE = -1

const GxB_COMPRESSION_DEFAULT = 0

const GxB_COMPRESSION_LZ4 = 1000

const GxB_COMPRESSION_LZ4HC = 2000

const GxB_COMPRESSION_ZSTD = 3000

end # module
