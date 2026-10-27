module LibGraphBLAS

to_c_type(t::Type) = t
to_c_type_pairs(va_list) = map(enumerate(to_c_type.(va_list))) do (ind, type)
    :(va_list[$ind]::$type)
end

import ..libgraphblas

NULL = C_NULL
INT64_MAX = typemax(Int64)

# Clang.jl maps both C complex types to ComplexF32
const GxB_FC64_t = ComplexF64
const GxB_FC32_t = ComplexF32


"""
    GrB_Info

All GraphBLAS functions return a code that indicates if it was successful
or not.  If more information is required, the GrB_error function can be
called, which returns a string that provides more information on the last
return value from GraphBLAS.
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
    GxB_JIT_ERROR = -7001
    GxB_GPU_ERROR = -7002
    GxB_OUTPUT_IS_READONLY = -7003
end

mutable struct GB_Monoid_opaque end

const GrB_Monoid = Ptr{GB_Monoid_opaque}

mutable struct GB_BinaryOp_opaque end

const GrB_BinaryOp = Ptr{GB_BinaryOp_opaque}

mutable struct GB_Scalar_opaque end

const GrB_Scalar = Ptr{GB_Scalar_opaque}

mutable struct GB_Vector_opaque end

const GrB_Vector = Ptr{GB_Vector_opaque}

"""
GrB_Index: row or column index, or matrix dimension.  This typedef is used
for row and column indices, or matrix and vector dimensions.
"""
const GrB_Index = UInt64

"""
    GxB_Vector_build_Scalar(w, I_, scalar, nvals)


### Prototype
```c
GrB_Info GxB_Vector_build_Scalar ( GrB_Vector w, const GrB_Index *I_, const GrB_Scalar scalar, GrB_Index nvals );
```
"""
function GxB_Vector_build_Scalar(w, I_, scalar, nvals)
    ccall((:GxB_Vector_build_Scalar, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, GrB_Scalar, GrB_Index), w, I_, scalar, nvals)
end

mutable struct GB_Descriptor_opaque end

"""
11 objects in the GraphBLAS C API:
"""
const GrB_Descriptor = Ptr{GB_Descriptor_opaque}

"""
    GxB_Vector_build_Vector(w, I_vector, X_vector, dup, desc)


### Prototype
```c
GrB_Info GxB_Vector_build_Vector ( GrB_Vector w, const GrB_Vector I_vector, const GrB_Vector X_vector, const GrB_BinaryOp dup, const GrB_Descriptor desc );
```
"""
function GxB_Vector_build_Vector(w, I_vector, X_vector, dup, desc)
    ccall((:GxB_Vector_build_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Descriptor), w, I_vector, X_vector, dup, desc)
end

"""
    GxB_Vector_build_Scalar_Vector(w, I_vector, scalar, desc)


### Prototype
```c
GrB_Info GxB_Vector_build_Scalar_Vector ( GrB_Vector w, const GrB_Vector I_vector, const GrB_Scalar scalar, const GrB_Descriptor desc );
```
"""
function GxB_Vector_build_Scalar_Vector(w, I_vector, scalar, desc)
    ccall((:GxB_Vector_build_Scalar_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, I_vector, scalar, desc)
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

"""
    GxB_Vector_extractTuples_Vector(I_vector, X_vector, V, desc)


### Prototype
```c
GrB_Info GxB_Vector_extractTuples_Vector ( GrB_Vector I_vector, GrB_Vector X_vector, const GrB_Vector V, const GrB_Descriptor desc );
```
"""
function GxB_Vector_extractTuples_Vector(I_vector, X_vector, V, desc)
    ccall((:GxB_Vector_extractTuples_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_Vector, GrB_Descriptor), I_vector, X_vector, V, desc)
end

mutable struct GB_Matrix_opaque end

const GrB_Matrix = Ptr{GB_Matrix_opaque}

"""
    GxB_Matrix_build_Scalar(C, I_, J, scalar, nvals)


### Prototype
```c
GrB_Info GxB_Matrix_build_Scalar ( GrB_Matrix C, const GrB_Index *I_, const GrB_Index *J, GrB_Scalar scalar, GrB_Index nvals );
```
"""
function GxB_Matrix_build_Scalar(C, I_, J, scalar, nvals)
    ccall((:GxB_Matrix_build_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Scalar, GrB_Index), C, I_, J, scalar, nvals)
end

"""
    GxB_Matrix_build_Vector(C, I_vector, J_vector, X_vector, dup, desc)


### Prototype
```c
GrB_Info GxB_Matrix_build_Vector ( GrB_Matrix C, const GrB_Vector I_vector, const GrB_Vector J_vector, const GrB_Vector X_vector, const GrB_BinaryOp dup, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_build_Vector(C, I_vector, J_vector, X_vector, dup, desc)
    ccall((:GxB_Matrix_build_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Descriptor), C, I_vector, J_vector, X_vector, dup, desc)
end

"""
    GxB_Matrix_build_Scalar_Vector(C, I_vector, J_vector, scalar, desc)


### Prototype
```c
GrB_Info GxB_Matrix_build_Scalar_Vector ( GrB_Matrix C, const GrB_Vector I_vector, const GrB_Vector J_vector, GrB_Scalar scalar, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_build_Scalar_Vector(C, I_vector, J_vector, scalar, desc)
    ccall((:GxB_Matrix_build_Scalar_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_Vector, GrB_Scalar, GrB_Descriptor), C, I_vector, J_vector, scalar, desc)
end

"""
    GrB_Matrix_setElement_Scalar(C, x, i, j)

Set a single entry in a matrix, C(i,j) = x, typecasting from the type of x
to the type of C, as needed.

 GrB_Info GrB_Matrix_setElement_TYPE  // C (i,j) = x
 (
     GrB_Matrix C,               // matrix to modify
     <type> x,                   // scalar to assign to C(i,j)
     GrB_Index i,                // row index
     GrB_Index j                 // column index
) ;
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

"""
    GxB_Matrix_extractTuples_Vector(I_vector, J_vector, X_vector, A, desc)


### Prototype
```c
GrB_Info GxB_Matrix_extractTuples_Vector ( GrB_Vector I_vector, GrB_Vector J_vector, GrB_Vector X_vector, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_extractTuples_Vector(I_vector, J_vector, X_vector, A, desc)
    ccall((:GxB_Matrix_extractTuples_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_Vector, GrB_Matrix, GrB_Descriptor), I_vector, J_vector, X_vector, A, desc)
end

"""
    GrB_Scalar_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_get_Scalar(object, arg2, arg3)
    ccall((:GrB_Scalar_get_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Scalar_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_get_String(object, arg2, arg3)
    ccall((:GrB_Scalar_get_String, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Scalar_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_get_INT32(object, arg2, arg3)
    ccall((:GrB_Scalar_get_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_Scalar_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_get_SIZE(object, arg2, arg3)
    ccall((:GrB_Scalar_get_SIZE, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_Scalar_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_get_VOID(object, arg2, arg3)
    ccall((:GrB_Scalar_get_VOID, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

"""
    GrB_Vector_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_get_Scalar(object, arg2, arg3)
    ccall((:GrB_Vector_get_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Vector_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_get_String(object, arg2, arg3)
    ccall((:GrB_Vector_get_String, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Vector_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_get_INT32(object, arg2, arg3)
    ccall((:GrB_Vector_get_INT32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_Vector_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_get_SIZE(object, arg2, arg3)
    ccall((:GrB_Vector_get_SIZE, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_Vector_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_get_VOID(object, arg2, arg3)
    ccall((:GrB_Vector_get_VOID, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

"""
    GrB_Matrix_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_get_Scalar(object, arg2, arg3)
    ccall((:GrB_Matrix_get_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Matrix_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_get_String(object, arg2, arg3)
    ccall((:GrB_Matrix_get_String, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Matrix_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_get_INT32(object, arg2, arg3)
    ccall((:GrB_Matrix_get_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_Matrix_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_get_SIZE(object, arg2, arg3)
    ccall((:GrB_Matrix_get_SIZE, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_Matrix_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_get_VOID(object, arg2, arg3)
    ccall((:GrB_Matrix_get_VOID, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

mutable struct GB_UnaryOp_opaque end

const GrB_UnaryOp = Ptr{GB_UnaryOp_opaque}

"""
    GrB_UnaryOp_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_get_Scalar(object, arg2, arg3)
    ccall((:GrB_UnaryOp_get_Scalar, libgraphblas), GrB_Info, (GrB_UnaryOp, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_UnaryOp_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_get_String(object, arg2, arg3)
    ccall((:GrB_UnaryOp_get_String, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_UnaryOp_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_get_INT32(object, arg2, arg3)
    ccall((:GrB_UnaryOp_get_INT32, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_UnaryOp_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_get_SIZE(object, arg2, arg3)
    ccall((:GrB_UnaryOp_get_SIZE, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_UnaryOp_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_get_VOID(object, arg2, arg3)
    ccall((:GrB_UnaryOp_get_VOID, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

mutable struct GB_IndexUnaryOp_opaque end

const GrB_IndexUnaryOp = Ptr{GB_IndexUnaryOp_opaque}

"""
    GrB_IndexUnaryOp_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_get_Scalar(object, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_Scalar, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_get_String(object, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_String, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_get_INT32(object, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_INT32, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_get_SIZE(object, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_SIZE, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_get_VOID(object, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_get_VOID, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

"""
    GrB_BinaryOp_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_get_Scalar(object, arg2, arg3)
    ccall((:GrB_BinaryOp_get_Scalar, libgraphblas), GrB_Info, (GrB_BinaryOp, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_BinaryOp_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_get_String(object, arg2, arg3)
    ccall((:GrB_BinaryOp_get_String, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_BinaryOp_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_get_INT32(object, arg2, arg3)
    ccall((:GrB_BinaryOp_get_INT32, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_BinaryOp_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_get_SIZE(object, arg2, arg3)
    ccall((:GrB_BinaryOp_get_SIZE, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_BinaryOp_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_get_VOID(object, arg2, arg3)
    ccall((:GrB_BinaryOp_get_VOID, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

mutable struct GB_IndexBinaryOp_opaque end

"""
3 objects in the SuiteSparse extensions:
"""
const GxB_IndexBinaryOp = Ptr{GB_IndexBinaryOp_opaque}

"""
    GxB_IndexBinaryOp_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_get_Scalar(object, arg2, arg3)
    ccall((:GxB_IndexBinaryOp_get_Scalar, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GxB_IndexBinaryOp_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_get_String(object, arg2, arg3)
    ccall((:GxB_IndexBinaryOp_get_String, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GxB_IndexBinaryOp_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_get_INT32(object, arg2, arg3)
    ccall((:GxB_IndexBinaryOp_get_INT32, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GxB_IndexBinaryOp_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_get_SIZE(object, arg2, arg3)
    ccall((:GxB_IndexBinaryOp_get_SIZE, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GxB_IndexBinaryOp_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_get_VOID(object, arg2, arg3)
    ccall((:GxB_IndexBinaryOp_get_VOID, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

"""
    GrB_Monoid_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_get_Scalar(object, arg2, arg3)
    ccall((:GrB_Monoid_get_Scalar, libgraphblas), GrB_Info, (GrB_Monoid, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Monoid_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_get_String(object, arg2, arg3)
    ccall((:GrB_Monoid_get_String, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Monoid_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_get_INT32(object, arg2, arg3)
    ccall((:GrB_Monoid_get_INT32, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_Monoid_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_get_SIZE(object, arg2, arg3)
    ccall((:GrB_Monoid_get_SIZE, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_Monoid_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_get_VOID(object, arg2, arg3)
    ccall((:GrB_Monoid_get_VOID, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

mutable struct GB_Semiring_opaque end

const GrB_Semiring = Ptr{GB_Semiring_opaque}

"""
    GrB_Semiring_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_get_Scalar(object, arg2, arg3)
    ccall((:GrB_Semiring_get_Scalar, libgraphblas), GrB_Info, (GrB_Semiring, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Semiring_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_get_String(object, arg2, arg3)
    ccall((:GrB_Semiring_get_String, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Semiring_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_get_INT32(object, arg2, arg3)
    ccall((:GrB_Semiring_get_INT32, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_Semiring_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_get_SIZE(object, arg2, arg3)
    ccall((:GrB_Semiring_get_SIZE, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_Semiring_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_get_VOID(object, arg2, arg3)
    ccall((:GrB_Semiring_get_VOID, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

mutable struct GB_Type_opaque end

const GrB_Type = Ptr{GB_Type_opaque}

"""
    GrB_Type_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_get_Scalar(object, arg2, arg3)
    ccall((:GrB_Type_get_Scalar, libgraphblas), GrB_Info, (GrB_Type, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Type_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_get_String(object, arg2, arg3)
    ccall((:GrB_Type_get_String, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Type_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_get_INT32(object, arg2, arg3)
    ccall((:GrB_Type_get_INT32, libgraphblas), GrB_Info, (GrB_Type, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_Type_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_get_SIZE(object, arg2, arg3)
    ccall((:GrB_Type_get_SIZE, libgraphblas), GrB_Info, (GrB_Type, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_Type_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_get_VOID(object, arg2, arg3)
    ccall((:GrB_Type_get_VOID, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

"""
    GrB_Descriptor_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_get_Scalar(object, arg2, arg3)
    ccall((:GrB_Descriptor_get_Scalar, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Descriptor_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_get_String(object, arg2, arg3)
    ccall((:GrB_Descriptor_get_String, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Descriptor_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_get_INT32(object, arg2, arg3)
    ccall((:GrB_Descriptor_get_INT32, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_Descriptor_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_get_SIZE(object, arg2, arg3)
    ccall((:GrB_Descriptor_get_SIZE, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_Descriptor_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_get_VOID(object, arg2, arg3)
    ccall((:GrB_Descriptor_get_VOID, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

mutable struct GB_Global_opaque end

const GrB_Global = Ptr{GB_Global_opaque}

"""
    GrB_Global_get_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Global );
```
"""
function GrB_Global_get_Scalar(object, arg2, arg3)
    ccall((:GrB_Global_get_Scalar, libgraphblas), GrB_Info, (GrB_Global, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Global_get_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Global );
```
"""
function GrB_Global_get_String(object, arg2, arg3)
    ccall((:GrB_Global_get_String, libgraphblas), GrB_Info, (GrB_Global, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Global_get_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Global );
```
"""
function GrB_Global_get_INT32(object, arg2, arg3)
    ccall((:GrB_Global_get_INT32, libgraphblas), GrB_Info, (GrB_Global, Ptr{Int32}, Cint), object, arg2, arg3)
end

"""
    GrB_Global_get_SIZE(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Global );
```
"""
function GrB_Global_get_SIZE(object, arg2, arg3)
    ccall((:GrB_Global_get_SIZE, libgraphblas), GrB_Info, (GrB_Global, Ptr{Csize_t}, Cint), object, arg2, arg3)
end

"""
    GrB_Global_get_VOID(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Global );
```
"""
function GrB_Global_get_VOID(object, arg2, arg3)
    ccall((:GrB_Global_get_VOID, libgraphblas), GrB_Info, (GrB_Global, Ptr{Cvoid}, Cint), object, arg2, arg3)
end

mutable struct GB_Context_opaque end

const GxB_Context = Ptr{GB_Context_opaque}

"""
    GxB_Context_get_Scalar(arg1, arg2, arg3)

Note that GxB_Context_get_INT has an irregular name.  This is because it
conflicts with the signature of the prior GxB_Context_get_INT32 method,
which is now historical.
### Prototype
```c
GrB_Info GxB_Context_get_Scalar (GxB_Context, GrB_Scalar, int);
```
"""
function GxB_Context_get_Scalar(arg1, arg2, arg3)
    ccall((:GxB_Context_get_Scalar, libgraphblas), GrB_Info, (GxB_Context, GrB_Scalar, Cint), arg1, arg2, arg3)
end

"""
    GxB_Context_get_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_String (GxB_Context, char * , int);
```
"""
function GxB_Context_get_String(arg1, arg2, arg3)
    ccall((:GxB_Context_get_String, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cchar}, Cint), arg1, arg2, arg3)
end

"""
    GxB_Context_get_INT(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_INT (GxB_Context, int32_t * , int);
```
"""
function GxB_Context_get_INT(arg1, arg2, arg3)
    ccall((:GxB_Context_get_INT, libgraphblas), GrB_Info, (GxB_Context, Ptr{Int32}, Cint), arg1, arg2, arg3)
end

"""
    GxB_Context_get_SIZE(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_SIZE (GxB_Context, size_t * , int);
```
"""
function GxB_Context_get_SIZE(arg1, arg2, arg3)
    ccall((:GxB_Context_get_SIZE, libgraphblas), GrB_Info, (GxB_Context, Ptr{Csize_t}, Cint), arg1, arg2, arg3)
end

"""
    GxB_Context_get_VOID(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_VOID (GxB_Context, void * , int);
```
"""
function GxB_Context_get_VOID(arg1, arg2, arg3)
    ccall((:GxB_Context_get_VOID, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cvoid}, Cint), arg1, arg2, arg3)
end

"""
    GxB_Serialized_get_Scalar(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_Scalar (const void *, GrB_Scalar, int, size_t);
```
"""
function GxB_Serialized_get_Scalar(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_Scalar, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Scalar, Cint, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GxB_Serialized_get_String(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_String (const void *, char * , int, size_t);
```
"""
function GxB_Serialized_get_String(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_String, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{Cchar}, Cint, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GxB_Serialized_get_INT32(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_INT32 (const void *, int32_t * , int, size_t);
```
"""
function GxB_Serialized_get_INT32(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_INT32, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{Int32}, Cint, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GxB_Serialized_get_SIZE(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_SIZE (const void *, size_t * , int, size_t);
```
"""
function GxB_Serialized_get_SIZE(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_SIZE, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{Csize_t}, Cint, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GxB_Serialized_get_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Serialized_get_VOID (const void *, void * , int, size_t);
```
"""
function GxB_Serialized_get_VOID(arg1, arg2, arg3, arg4)
    ccall((:GxB_Serialized_get_VOID, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{Cvoid}, Cint, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Scalar_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_set_Scalar(object, arg2, arg3)
    ccall((:GrB_Scalar_set_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Scalar_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_set_String(object, arg2, arg3)
    ccall((:GrB_Scalar_set_String, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Scalar_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_set_INT32(object, arg2, arg3)
    ccall((:GrB_Scalar_set_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_Scalar_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_Scalar_set_VOID, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_Vector_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_set_Scalar(object, arg2, arg3)
    ccall((:GrB_Vector_set_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Vector_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_set_String(object, arg2, arg3)
    ccall((:GrB_Vector_set_String, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Vector_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_set_INT32(object, arg2, arg3)
    ccall((:GrB_Vector_set_INT32, libgraphblas), GrB_Info, (GrB_Vector, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_Vector_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_Vector_set_VOID, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_Matrix_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_set_Scalar(object, arg2, arg3)
    ccall((:GrB_Matrix_set_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Matrix_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_set_String(object, arg2, arg3)
    ccall((:GrB_Matrix_set_String, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Matrix_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_set_INT32(object, arg2, arg3)
    ccall((:GrB_Matrix_set_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_Matrix_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_Matrix_set_VOID, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_UnaryOp_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_set_Scalar(object, arg2, arg3)
    ccall((:GrB_UnaryOp_set_Scalar, libgraphblas), GrB_Info, (GrB_UnaryOp, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_UnaryOp_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_set_String(object, arg2, arg3)
    ccall((:GrB_UnaryOp_set_String, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_UnaryOp_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_set_INT32(object, arg2, arg3)
    ccall((:GrB_UnaryOp_set_INT32, libgraphblas), GrB_Info, (GrB_UnaryOp, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_UnaryOp_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_UnaryOp_set_VOID, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_IndexUnaryOp_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_set_Scalar(object, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_set_Scalar, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_set_String(object, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_set_String, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_set_INT32(object, arg2, arg3)
    ccall((:GrB_IndexUnaryOp_set_INT32, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_IndexUnaryOp_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_IndexUnaryOp_set_VOID, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_BinaryOp_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_set_Scalar(object, arg2, arg3)
    ccall((:GrB_BinaryOp_set_Scalar, libgraphblas), GrB_Info, (GrB_BinaryOp, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_BinaryOp_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_set_String(object, arg2, arg3)
    ccall((:GrB_BinaryOp_set_String, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_BinaryOp_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_set_INT32(object, arg2, arg3)
    ccall((:GrB_BinaryOp_set_INT32, libgraphblas), GrB_Info, (GrB_BinaryOp, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_BinaryOp_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_BinaryOp_set_VOID, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GxB_IndexBinaryOp_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_set_Scalar(object, arg2, arg3)
    ccall((:GxB_IndexBinaryOp_set_Scalar, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GxB_IndexBinaryOp_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_set_String(object, arg2, arg3)
    ccall((:GxB_IndexBinaryOp_set_String, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GxB_IndexBinaryOp_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_set_INT32(object, arg2, arg3)
    ccall((:GxB_IndexBinaryOp_set_INT32, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, Int32, Cint), object, arg2, arg3)
end

"""
    GxB_IndexBinaryOp_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_set_VOID(object, arg2, arg3, arg4)
    ccall((:GxB_IndexBinaryOp_set_VOID, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_Monoid_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_set_Scalar(object, arg2, arg3)
    ccall((:GrB_Monoid_set_Scalar, libgraphblas), GrB_Info, (GrB_Monoid, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Monoid_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_set_String(object, arg2, arg3)
    ccall((:GrB_Monoid_set_String, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Monoid_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_set_INT32(object, arg2, arg3)
    ccall((:GrB_Monoid_set_INT32, libgraphblas), GrB_Info, (GrB_Monoid, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_Monoid_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_Monoid_set_VOID, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_Semiring_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_set_Scalar(object, arg2, arg3)
    ccall((:GrB_Semiring_set_Scalar, libgraphblas), GrB_Info, (GrB_Semiring, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Semiring_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_set_String(object, arg2, arg3)
    ccall((:GrB_Semiring_set_String, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Semiring_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_set_INT32(object, arg2, arg3)
    ccall((:GrB_Semiring_set_INT32, libgraphblas), GrB_Info, (GrB_Semiring, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_Semiring_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_Semiring_set_VOID, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_Type_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_set_Scalar(object, arg2, arg3)
    ccall((:GrB_Type_set_Scalar, libgraphblas), GrB_Info, (GrB_Type, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Type_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_set_String(object, arg2, arg3)
    ccall((:GrB_Type_set_String, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Type_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_set_INT32(object, arg2, arg3)
    ccall((:GrB_Type_set_INT32, libgraphblas), GrB_Info, (GrB_Type, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_Type_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_Type_set_VOID, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_Descriptor_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_set_Scalar(object, arg2, arg3)
    ccall((:GrB_Descriptor_set_Scalar, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Descriptor_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_set_String(object, arg2, arg3)
    ccall((:GrB_Descriptor_set_String, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Descriptor_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_set_INT32(object, arg2, arg3)
    ccall((:GrB_Descriptor_set_INT32, libgraphblas), GrB_Info, (GrB_Descriptor, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_Descriptor_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_Descriptor_set_VOID, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GrB_Global_set_Scalar(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Global );
```
"""
function GrB_Global_set_Scalar(object, arg2, arg3)
    ccall((:GrB_Global_set_Scalar, libgraphblas), GrB_Info, (GrB_Global, GrB_Scalar, Cint), object, arg2, arg3)
end

"""
    GrB_Global_set_String(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Global );
```
"""
function GrB_Global_set_String(object, arg2, arg3)
    ccall((:GrB_Global_set_String, libgraphblas), GrB_Info, (GrB_Global, Ptr{Cchar}, Cint), object, arg2, arg3)
end

"""
    GrB_Global_set_INT32(object, arg2, arg3)


### Prototype
```c
GB_DECLARE (GrB_Global );
```
"""
function GrB_Global_set_INT32(object, arg2, arg3)
    ccall((:GrB_Global_set_INT32, libgraphblas), GrB_Info, (GrB_Global, Int32, Cint), object, arg2, arg3)
end

"""
    GrB_Global_set_VOID(object, arg2, arg3, arg4)


### Prototype
```c
GB_DECLARE (GrB_Global );
```
"""
function GrB_Global_set_VOID(object, arg2, arg3, arg4)
    ccall((:GrB_Global_set_VOID, libgraphblas), GrB_Info, (GrB_Global, Ptr{Cvoid}, Cint, Csize_t), object, arg2, arg3, arg4)
end

"""
    GxB_Context_set_Scalar(arg1, arg2, arg3)

GxB_Context_set_INT is slightly misnamed, because of the prior
GxB_Context_set_INT32.
### Prototype
```c
GrB_Info GxB_Context_set_Scalar (GxB_Context, GrB_Scalar, int);
```
"""
function GxB_Context_set_Scalar(arg1, arg2, arg3)
    ccall((:GxB_Context_set_Scalar, libgraphblas), GrB_Info, (GxB_Context, GrB_Scalar, Cint), arg1, arg2, arg3)
end

"""
    GxB_Context_set_String(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_set_String (GxB_Context, char * , int);
```
"""
function GxB_Context_set_String(arg1, arg2, arg3)
    ccall((:GxB_Context_set_String, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cchar}, Cint), arg1, arg2, arg3)
end

"""
    GxB_Context_set_INT(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_set_INT (GxB_Context, int32_t , int);
```
"""
function GxB_Context_set_INT(arg1, arg2, arg3)
    ccall((:GxB_Context_set_INT, libgraphblas), GrB_Info, (GxB_Context, Int32, Cint), arg1, arg2, arg3)
end

"""
    GxB_Context_set_VOID(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_Context_set_VOID (GxB_Context, void * , int, size_t);
```
"""
function GxB_Context_set_VOID(arg1, arg2, arg3, arg4)
    ccall((:GxB_Context_set_VOID, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cvoid}, Cint, Csize_t), arg1, arg2, arg3, arg4)
end

"""
    GrB_Type_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_wait(object, waitmode)
    ccall((:GrB_Type_wait, libgraphblas), GrB_Info, (GrB_Type, Cint), object, waitmode)
end

"""
    GrB_UnaryOp_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_wait(object, waitmode)
    ccall((:GrB_UnaryOp_wait, libgraphblas), GrB_Info, (GrB_UnaryOp, Cint), object, waitmode)
end

"""
    GrB_BinaryOp_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_wait(object, waitmode)
    ccall((:GrB_BinaryOp_wait, libgraphblas), GrB_Info, (GrB_BinaryOp, Cint), object, waitmode)
end

"""
    GrB_IndexUnaryOp_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_wait(object, waitmode)
    ccall((:GrB_IndexUnaryOp_wait, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Cint), object, waitmode)
end

"""
    GxB_IndexBinaryOp_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_wait(object, waitmode)
    ccall((:GxB_IndexBinaryOp_wait, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, Cint), object, waitmode)
end

"""
    GrB_Monoid_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_wait(object, waitmode)
    ccall((:GrB_Monoid_wait, libgraphblas), GrB_Info, (GrB_Monoid, Cint), object, waitmode)
end

"""
    GrB_Semiring_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_wait(object, waitmode)
    ccall((:GrB_Semiring_wait, libgraphblas), GrB_Info, (GrB_Semiring, Cint), object, waitmode)
end

"""
    GrB_Scalar_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_wait(object, waitmode)
    ccall((:GrB_Scalar_wait, libgraphblas), GrB_Info, (GrB_Scalar, Cint), object, waitmode)
end

"""
    GrB_Vector_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_wait(object, waitmode)
    ccall((:GrB_Vector_wait, libgraphblas), GrB_Info, (GrB_Vector, Cint), object, waitmode)
end

"""
    GrB_Matrix_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_wait(object, waitmode)
    ccall((:GrB_Matrix_wait, libgraphblas), GrB_Info, (GrB_Matrix, Cint), object, waitmode)
end

"""
    GxB_Context_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GxB_Context );
```
"""
function GxB_Context_wait(object, waitmode)
    ccall((:GxB_Context_wait, libgraphblas), GrB_Info, (GxB_Context, Cint), object, waitmode)
end

"""
    GrB_Descriptor_wait(object, waitmode)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_wait(object, waitmode)
    ccall((:GrB_Descriptor_wait, libgraphblas), GrB_Info, (GrB_Descriptor, Cint), object, waitmode)
end

"""
    GrB_Type_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_error(error, object)
    ccall((:GrB_Type_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Type), error, object)
end

"""
    GrB_UnaryOp_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_error(error, object)
    ccall((:GrB_UnaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_UnaryOp), error, object)
end

"""
    GrB_BinaryOp_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_error(error, object)
    ccall((:GrB_BinaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_BinaryOp), error, object)
end

"""
    GrB_IndexUnaryOp_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_error(error, object)
    ccall((:GrB_IndexUnaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_IndexUnaryOp), error, object)
end

"""
    GxB_IndexBinaryOp_error(error, object)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_error(error, object)
    ccall((:GxB_IndexBinaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GxB_IndexBinaryOp), error, object)
end

"""
    GrB_Monoid_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_error(error, object)
    ccall((:GrB_Monoid_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Monoid), error, object)
end

"""
    GrB_Semiring_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_error(error, object)
    ccall((:GrB_Semiring_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Semiring), error, object)
end

"""
    GrB_Scalar_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_error(error, object)
    ccall((:GrB_Scalar_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Scalar), error, object)
end

"""
    GrB_Vector_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_error(error, object)
    ccall((:GrB_Vector_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Vector), error, object)
end

"""
    GrB_Matrix_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_error(error, object)
    ccall((:GrB_Matrix_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Matrix), error, object)
end

"""
    GxB_Context_error(error, object)


### Prototype
```c
GB_DECLARE (GxB_Context );
```
"""
function GxB_Context_error(error, object)
    ccall((:GxB_Context_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GxB_Context), error, object)
end

"""
    GrB_Descriptor_error(error, object)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_error(error, object)
    ccall((:GrB_Descriptor_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Descriptor), error, object)
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
pairwise "multiplied" with C(i,j) = mult (A(i,j),B(i,j)).  The mult operator
can be based on a GxB_IndexBinaryOp.
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


### Prototype
```c
GrB_Info GxB_Vector_eWiseUnion ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_BinaryOp add, const GrB_Vector u, const GrB_Scalar alpha, const GrB_Vector v, const GrB_Scalar beta, const GrB_Descriptor desc );
```
"""
function GxB_Vector_eWiseUnion(w, mask, accum, add, u, alpha, v, beta, desc)
    ccall((:GxB_Vector_eWiseUnion, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Scalar, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, add, u, alpha, v, beta, desc)
end

"""
    GxB_Vector_extract_Vector(w, mask, accum, u, I_vector, desc)


### Prototype
```c
GrB_Info GxB_Vector_extract_Vector ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Vector I_vector, const GrB_Descriptor desc );
```
"""
function GxB_Vector_extract_Vector(w, mask, accum, u, I_vector, desc)
    ccall((:GxB_Vector_extract_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, u, I_vector, desc)
end

"""
    GrB_Vector_extract(w, mask, accum, u, I_, ni, desc)

==============================================================================
GrB_extract: extract a submatrix or subvector
==============================================================================
### Prototype
```c
GrB_Info GrB_Vector_extract ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I_, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_extract(w, mask, accum, u, I_, ni, desc)
    ccall((:GrB_Vector_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I_, ni, desc)
end

"""
    GxB_Col_extract_Vector(w, mask, accum, A, I_vector, j, desc)


### Prototype
```c
GrB_Info GxB_Col_extract_Vector ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Vector I_vector, GrB_Index j, const GrB_Descriptor desc );
```
"""
function GxB_Col_extract_Vector(w, mask, accum, A, I_vector, j, desc)
    ccall((:GxB_Col_extract_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Matrix, GrB_Vector, GrB_Index, GrB_Descriptor), w, mask, accum, A, I_vector, j, desc)
end

"""
    GrB_Col_extract(w, mask, accum, A, I_, ni, j, desc)


### Prototype
```c
GrB_Info GrB_Col_extract ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Index *I_, GrB_Index ni, GrB_Index j, const GrB_Descriptor desc );
```
"""
function GrB_Col_extract(w, mask, accum, A, I_, ni, j, desc)
    ccall((:GrB_Col_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), w, mask, accum, A, I_, ni, j, desc)
end

"""
    GxB_Matrix_extract_Vector(C, Mask, accum, A, I_vector, J_vector, desc)


### Prototype
```c
GrB_Info GxB_Matrix_extract_Vector ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Vector I_vector, const GrB_Vector J_vector, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_extract_Vector(C, Mask, accum, A, I_vector, J_vector, desc)
    ccall((:GxB_Matrix_extract_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, GrB_Vector, GrB_Vector, GrB_Descriptor), C, Mask, accum, A, I_vector, J_vector, desc)
end

"""
    GrB_Matrix_extract(C, Mask, accum, A, I_, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_extract ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Index *I_, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_extract(C, Mask, accum, A, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_extract, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I_, ni, J, nj, desc)
end

"""
    GxB_Vector_subassign(w, mask, accum, u, I_, ni, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I_, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign(w, mask, accum, u, I_, ni, desc)
    ccall((:GxB_Vector_subassign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I_, ni, desc)
end

"""
    GxB_Matrix_subassign(C, Mask, accum, A, I_, ni, J, nj, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Index *I_, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign(C, Mask, accum, A, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I_, ni, J, nj, desc)
end

"""
    GxB_Vector_subassign_Scalar_Vector(w, mask, accum, scalar, I_vector, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_Scalar_Vector ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Scalar scalar, const GrB_Vector I_vector, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_Scalar_Vector(w, mask, accum, scalar, I_vector, desc)
    ccall((:GxB_Vector_subassign_Scalar_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Scalar, GrB_Vector, GrB_Descriptor), w, mask, accum, scalar, I_vector, desc)
end

"""
    GxB_Vector_subassign_Scalar(w, mask, accum, x, I_, ni, desc)

Assigns a single scalar to a subvector, w(I)<mask> = accum(w(I),x).  The
scalar x is implicitly expanded into a vector u of size ni-by-1, with each
entry in u equal to x, and then w(I)<mask> = accum(w(I),u) is done.
### Prototype
```c
GrB_Info GxB_Vector_subassign_Scalar ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Scalar x, const GrB_Index *I_, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_Scalar(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_Vector(w, mask, accum, u, I_vector, desc)


### Prototype
```c
GrB_Info GxB_Vector_subassign_Vector ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Vector I_vector, const GrB_Descriptor desc );
```
"""
function GxB_Vector_subassign_Vector(w, mask, accum, u, I_vector, desc)
    ccall((:GxB_Vector_subassign_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, u, I_vector, desc)
end

"""
    GxB_Matrix_subassign_Scalar_Vector(C, Mask, accum, scalar, I_vector, J_vector, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_Scalar_Vector ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Scalar scalar, const GrB_Vector I_vector, const GrB_Vector J_vector, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_Scalar_Vector(C, Mask, accum, scalar, I_vector, J_vector, desc)
    ccall((:GxB_Matrix_subassign_Scalar_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Scalar, GrB_Vector, GrB_Vector, GrB_Descriptor), C, Mask, accum, scalar, I_vector, J_vector, desc)
end

"""
    GxB_Matrix_subassign_Scalar(C, Mask, accum, x, I_, ni, J, nj, desc)

Assigns a single scalar to a submatrix, C(I,J)<Mask> = accum(C(I,J),x).  The
scalar x is implicitly expanded into a matrix A of size ni-by-nj, with each
entry in A equal to x, and then C(I,J)<Mask> = accum(C(I,J),A) is done.
### Prototype
```c
GrB_Info GxB_Matrix_subassign_Scalar ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Scalar x, const GrB_Index *I_, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_Scalar(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Col_subassign(C, mask, accum, u, I_, ni, j, desc)


### Prototype
```c
GrB_Info GxB_Col_subassign ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I_, GrB_Index ni, GrB_Index j, const GrB_Descriptor desc );
```
"""
function GxB_Col_subassign(C, mask, accum, u, I_, ni, j, desc)
    ccall((:GxB_Col_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I_, ni, j, desc)
end

"""
    GxB_Col_subassign_Vector(C, mask, accum, u, I_vector, j, desc)


### Prototype
```c
GrB_Info GxB_Col_subassign_Vector ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Vector I_vector, GrB_Index j, const GrB_Descriptor desc );
```
"""
function GxB_Col_subassign_Vector(C, mask, accum, u, I_vector, j, desc)
    ccall((:GxB_Col_subassign_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Index, GrB_Descriptor), C, mask, accum, u, I_vector, j, desc)
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
    GxB_Row_subassign_Vector(C, mask, accum, u, i, J_vector, desc)


### Prototype
```c
GrB_Info GxB_Row_subassign_Vector ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, GrB_Index i, const GrB_Vector J_vector, const GrB_Descriptor desc );
```
"""
function GxB_Row_subassign_Vector(C, mask, accum, u, i, J_vector, desc)
    ccall((:GxB_Row_subassign_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, GrB_Vector, GrB_Descriptor), C, mask, accum, u, i, J_vector, desc)
end

"""
    GxB_Matrix_subassign_Vector(C, Mask, accum, A, I_vector, J_vector, desc)


### Prototype
```c
GrB_Info GxB_Matrix_subassign_Vector ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Vector I_vector, const GrB_Vector J_vector, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_subassign_Vector(C, Mask, accum, A, I_vector, J_vector, desc)
    ccall((:GxB_Matrix_subassign_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, GrB_Vector, GrB_Vector, GrB_Descriptor), C, Mask, accum, A, I_vector, J_vector, desc)
end

"""
    GxB_Vector_assign_Scalar_Vector(w, mask, accum, x, I_vector, desc)


### Prototype
```c
GrB_Info GxB_Vector_assign_Scalar_Vector ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Scalar x, const GrB_Vector I_vector, const GrB_Descriptor desc );
```
"""
function GxB_Vector_assign_Scalar_Vector(w, mask, accum, x, I_vector, desc)
    ccall((:GxB_Vector_assign_Scalar_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Scalar, GrB_Vector, GrB_Descriptor), w, mask, accum, x, I_vector, desc)
end

"""
    GrB_Vector_assign_Scalar(w, mask, accum, x, I_, ni, desc)

Assigns a single scalar to a subvector, w<mask>(I) = accum(w(I),x).  The
scalar x is implicitly expanded into a vector u of size ni-by-1, with each
entry in u equal to x, and then w<mask>(I) = accum(w(I),u) is done.
### Prototype
```c
GrB_Info GrB_Vector_assign_Scalar ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Scalar x, const GrB_Index *I_, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign_Scalar(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_assign_Vector(w, mask, accum, u, I_vector, desc)


### Prototype
```c
GrB_Info GxB_Vector_assign_Vector ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Vector I_vector, const GrB_Descriptor desc );
```
"""
function GxB_Vector_assign_Vector(w, mask, accum, u, I_vector, desc)
    ccall((:GxB_Vector_assign_Vector, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, u, I_vector, desc)
end

"""
    GrB_Vector_assign(w, mask, accum, u, I_, ni, desc)

Assign entries in a matrix or vector; C(I,J) = A.
Each of these can be used with their polymorphic name, GrB_assign.
### Prototype
```c
GrB_Info GrB_Vector_assign ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I_, GrB_Index ni, const GrB_Descriptor desc );
```
"""
function GrB_Vector_assign(w, mask, accum, u, I_, ni, desc)
    ccall((:GrB_Vector_assign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I_, ni, desc)
end

"""
    GxB_Matrix_assign_Scalar_Vector(C, Mask, accum, x, I_vector, J_vector, desc)


### Prototype
```c
GrB_Info GxB_Matrix_assign_Scalar_Vector ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Scalar x, const GrB_Vector I_vector, const GrB_Vector J_vector, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_assign_Scalar_Vector(C, Mask, accum, x, I_vector, J_vector, desc)
    ccall((:GxB_Matrix_assign_Scalar_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Scalar, GrB_Vector, GrB_Vector, GrB_Descriptor), C, Mask, accum, x, I_vector, J_vector, desc)
end

"""
    GrB_Matrix_assign_Scalar(C, Mask, accum, x, I_, ni, J, nj, desc)

Assigns a single scalar to a submatrix, C<Mask>(I,J) = accum(C(I,J),x).  The
scalar x is implicitly expanded into a matrix A of size ni-by-nj, with each
entry in A equal to x, and then C<Mask>(I,J) = accum(C(I,J),A) is done.
### Prototype
```c
GrB_Info GrB_Matrix_assign_Scalar ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Scalar x, const GrB_Index *I_, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign_Scalar(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Col_assign(C, mask, accum, u, I_, ni, j, desc)


### Prototype
```c
GrB_Info GrB_Col_assign ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Index *I_, GrB_Index ni, GrB_Index j, const GrB_Descriptor desc );
```
"""
function GrB_Col_assign(C, mask, accum, u, I_, ni, j, desc)
    ccall((:GrB_Col_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I_, ni, j, desc)
end

"""
    GxB_Col_assign_Vector(C, mask, accum, u, I_vector, j, desc)


### Prototype
```c
GrB_Info GxB_Col_assign_Vector ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, const GrB_Vector I_vector, GrB_Index j, const GrB_Descriptor desc );
```
"""
function GxB_Col_assign_Vector(C, mask, accum, u, I_vector, j, desc)
    ccall((:GxB_Col_assign_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Index, GrB_Descriptor), C, mask, accum, u, I_vector, j, desc)
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
    GxB_Row_assign_Vector(C, mask, accum, u, i, J_vector, desc)


### Prototype
```c
GrB_Info GxB_Row_assign_Vector ( GrB_Matrix C, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Vector u, GrB_Index i, const GrB_Vector J_vector, const GrB_Descriptor desc );
```
"""
function GxB_Row_assign_Vector(C, mask, accum, u, i, J_vector, desc)
    ccall((:GxB_Row_assign_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, GrB_Vector, GrB_Descriptor), C, mask, accum, u, i, J_vector, desc)
end

"""
    GxB_Matrix_assign_Vector(C, Mask, accum, A, I_vector, J_vector, desc)


### Prototype
```c
GrB_Info GxB_Matrix_assign_Vector ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Vector I_vector, const GrB_Vector J_vector, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_assign_Vector(C, Mask, accum, A, I_vector, J_vector, desc)
    ccall((:GxB_Matrix_assign_Vector, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, GrB_Vector, GrB_Vector, GrB_Descriptor), C, Mask, accum, A, I_vector, J_vector, desc)
end

"""
    GrB_Matrix_assign(C, Mask, accum, A, I_, ni, J, nj, desc)


### Prototype
```c
GrB_Info GrB_Matrix_assign ( GrB_Matrix C, const GrB_Matrix Mask, const GrB_BinaryOp accum, const GrB_Matrix A, const GrB_Index *I_, GrB_Index ni, const GrB_Index *J, GrB_Index nj, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_assign(C, Mask, accum, A, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I_, ni, J, nj, desc)
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

"""
    GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)

Reduce the entries in a matrix to a vector, a column vector t such that
t(i) = sum (A (i,:)), and where "sum" is a commutative and associative
monoid with an identity value.  A can be transposed, which reduces down the
columns instead of the rows.
### Prototype
```c
GrB_Info GrB_Matrix_reduce_Monoid ( GrB_Vector w, const GrB_Vector mask, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), w, mask, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_BinaryOp(arg1, arg2, arg3, arg4, arg5, arg6)

The following methods are not recommended; use a GrB_Monoid instead.  The
GrB_BinaryOp op must correspond to a known built-in monoid.
### Prototype
```c
GrB_Info GrB_Matrix_reduce_BinaryOp (GrB_Vector, const GrB_Vector, const GrB_BinaryOp, const GrB_BinaryOp, const GrB_Matrix, const GrB_Descriptor);
```
"""
function GrB_Matrix_reduce_BinaryOp(arg1, arg2, arg3, arg4, arg5, arg6)
    ccall((:GrB_Matrix_reduce_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6)
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

==============================================================================
GrB_kronecker:  Kronecker product
==============================================================================
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
    GxB_Type_fprint(type, name, pr, f)


### Prototype
```c
GrB_Info GxB_Type_fprint ( GrB_Type type, const char *name, int pr, FILE *f );
```
"""
function GxB_Type_fprint(type, name, pr, f)
    ccall((:GxB_Type_fprint, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), type, name, pr, f)
end

"""
    GxB_UnaryOp_fprint(unaryop, name, pr, f)


### Prototype
```c
GrB_Info GxB_UnaryOp_fprint ( GrB_UnaryOp unaryop, const char *name, int pr, FILE *f );
```
"""
function GxB_UnaryOp_fprint(unaryop, name, pr, f)
    ccall((:GxB_UnaryOp_fprint, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), unaryop, name, pr, f)
end

"""
    GxB_BinaryOp_fprint(binaryop, name, pr, f)


### Prototype
```c
GrB_Info GxB_BinaryOp_fprint ( GrB_BinaryOp binaryop, const char *name, int pr, FILE *f );
```
"""
function GxB_BinaryOp_fprint(binaryop, name, pr, f)
    ccall((:GxB_BinaryOp_fprint, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), binaryop, name, pr, f)
end

"""
    GxB_IndexUnaryOp_fprint(op, name, pr, f)


### Prototype
```c
GrB_Info GxB_IndexUnaryOp_fprint ( GrB_IndexUnaryOp op, const char *name, int pr, FILE *f );
```
"""
function GxB_IndexUnaryOp_fprint(op, name, pr, f)
    ccall((:GxB_IndexUnaryOp_fprint, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

"""
    GxB_IndexBinaryOp_fprint(op, name, pr, f)


### Prototype
```c
GrB_Info GxB_IndexBinaryOp_fprint ( GxB_IndexBinaryOp op, const char *name, int pr, FILE *f );
```
"""
function GxB_IndexBinaryOp_fprint(op, name, pr, f)
    ccall((:GxB_IndexBinaryOp_fprint, libgraphblas), GrB_Info, (GxB_IndexBinaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

"""
    GxB_Monoid_fprint(monoid, name, pr, f)


### Prototype
```c
GrB_Info GxB_Monoid_fprint ( GrB_Monoid monoid, const char *name, int pr, FILE *f );
```
"""
function GxB_Monoid_fprint(monoid, name, pr, f)
    ccall((:GxB_Monoid_fprint, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), monoid, name, pr, f)
end

"""
    GxB_Semiring_fprint(semiring, name, pr, f)


### Prototype
```c
GrB_Info GxB_Semiring_fprint ( GrB_Semiring semiring, const char *name, int pr, FILE *f );
```
"""
function GxB_Semiring_fprint(semiring, name, pr, f)
    ccall((:GxB_Semiring_fprint, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), semiring, name, pr, f)
end

"""
    GxB_Scalar_fprint(s, name, pr, f)


### Prototype
```c
GrB_Info GxB_Scalar_fprint ( GrB_Scalar s, const char *name, int pr, FILE *f );
```
"""
function GxB_Scalar_fprint(s, name, pr, f)
    ccall((:GxB_Scalar_fprint, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), s, name, pr, f)
end

"""
    GxB_Vector_fprint(v, name, pr, f)


### Prototype
```c
GrB_Info GxB_Vector_fprint ( GrB_Vector v, const char *name, int pr, FILE *f );
```
"""
function GxB_Vector_fprint(v, name, pr, f)
    ccall((:GxB_Vector_fprint, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), v, name, pr, f)
end

"""
    GxB_Matrix_fprint(A, name, pr, f)


### Prototype
```c
GrB_Info GxB_Matrix_fprint ( GrB_Matrix A, const char *name, int pr, FILE *f );
```
"""
function GxB_Matrix_fprint(A, name, pr, f)
    ccall((:GxB_Matrix_fprint, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), A, name, pr, f)
end

"""
    GxB_Descriptor_fprint(descriptor, name, pr, f)


### Prototype
```c
GrB_Info GxB_Descriptor_fprint ( GrB_Descriptor descriptor, const char *name, int pr, FILE *f );
```
"""
function GxB_Descriptor_fprint(descriptor, name, pr, f)
    ccall((:GxB_Descriptor_fprint, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), descriptor, name, pr, f)
end

"""
    GxB_Context_fprint(Context, name, pr, f)


### Prototype
```c
GrB_Info GxB_Context_fprint ( GxB_Context Context, const char *name, int pr, FILE *f );
```
"""
function GxB_Context_fprint(Context, name, pr, f)
    ccall((:GxB_Context_fprint, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), Context, name, pr, f)
end

"""
    GxB_Vector_sort(w, p, op, u, desc)


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
    GrB_Type_free(object)


### Prototype
```c
GB_DECLARE (GrB_Type );
```
"""
function GrB_Type_free(object)
    ccall((:GrB_Type_free, libgraphblas), GrB_Info, (Ptr{GrB_Type},), object)
end

"""
    GrB_UnaryOp_free(object)


### Prototype
```c
GB_DECLARE (GrB_UnaryOp );
```
"""
function GrB_UnaryOp_free(object)
    ccall((:GrB_UnaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp},), object)
end

"""
    GrB_BinaryOp_free(object)


### Prototype
```c
GB_DECLARE (GrB_BinaryOp );
```
"""
function GrB_BinaryOp_free(object)
    ccall((:GrB_BinaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp},), object)
end

"""
    GrB_IndexUnaryOp_free(object)


### Prototype
```c
GB_DECLARE (GrB_IndexUnaryOp );
```
"""
function GrB_IndexUnaryOp_free(object)
    ccall((:GrB_IndexUnaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_IndexUnaryOp},), object)
end

"""
    GxB_IndexBinaryOp_free(object)


### Prototype
```c
GB_DECLARE (GxB_IndexBinaryOp);
```
"""
function GxB_IndexBinaryOp_free(object)
    ccall((:GxB_IndexBinaryOp_free, libgraphblas), GrB_Info, (Ptr{GxB_IndexBinaryOp},), object)
end

"""
    GrB_Monoid_free(object)


### Prototype
```c
GB_DECLARE (GrB_Monoid );
```
"""
function GrB_Monoid_free(object)
    ccall((:GrB_Monoid_free, libgraphblas), GrB_Info, (Ptr{GrB_Monoid},), object)
end

"""
    GrB_Semiring_free(object)


### Prototype
```c
GB_DECLARE (GrB_Semiring );
```
"""
function GrB_Semiring_free(object)
    ccall((:GrB_Semiring_free, libgraphblas), GrB_Info, (Ptr{GrB_Semiring},), object)
end

"""
    GrB_Scalar_free(object)


### Prototype
```c
GB_DECLARE (GrB_Scalar );
```
"""
function GrB_Scalar_free(object)
    ccall((:GrB_Scalar_free, libgraphblas), GrB_Info, (Ptr{GrB_Scalar},), object)
end

"""
    GrB_Vector_free(object)


### Prototype
```c
GB_DECLARE (GrB_Vector );
```
"""
function GrB_Vector_free(object)
    ccall((:GrB_Vector_free, libgraphblas), GrB_Info, (Ptr{GrB_Vector},), object)
end

"""
    GrB_Matrix_free(object)


### Prototype
```c
GB_DECLARE (GrB_Matrix );
```
"""
function GrB_Matrix_free(object)
    ccall((:GrB_Matrix_free, libgraphblas), GrB_Info, (Ptr{GrB_Matrix},), object)
end

"""
    GrB_Descriptor_free(object)


### Prototype
```c
GB_DECLARE (GrB_Descriptor );
```
"""
function GrB_Descriptor_free(object)
    ccall((:GrB_Descriptor_free, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), object)
end

"""
    GxB_Context_free(object)


### Prototype
```c
GB_DECLARE (GxB_Context );
```
"""
function GxB_Context_free(object)
    ccall((:GxB_Context_free, libgraphblas), GrB_Info, (Ptr{GxB_Context},), object)
end

struct GxB_Container_struct
    nrows::UInt64
    ncols::UInt64
    nrows_nonempty::Int64
    ncols_nonempty::Int64
    nvals::UInt64
    u64_future::NTuple{11, UInt64}
    format::Int32
    orientation::Int32
    header_arena::Int32
    u32_future::NTuple{13, UInt32}
    p::GrB_Vector
    h::GrB_Vector
    b::GrB_Vector
    i::GrB_Vector
    x::GrB_Vector
    vector_future::NTuple{11, GrB_Vector}
    Y::GrB_Matrix
    matrix_future::NTuple{15, GrB_Matrix}
    iso::Bool
    jumbled::Bool
    bool_future::NTuple{30, Bool}
    void_future::NTuple{16, Ptr{Cvoid}}
end

const GxB_Container = Ptr{GxB_Container_struct}

"""
    GxB_Container_free(object)


### Prototype
```c
GB_DECLARE (GxB_Container );
```
"""
function GxB_Container_free(object)
    ccall((:GxB_Container_free, libgraphblas), GrB_Info, (Ptr{GxB_Container},), object)
end

"""
    GB_Iterator_opaque

The contents of an iterator must not be directly accessed by the user
application.  Only the functions and macros provided here may access
"iterator->" contents.  The iterator is defined here only so that macros
can be used to speed up the use of the iterator methods.  User applications
must not use "iterator->" directly; results are undefined otherwise.
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
    Ap32::Ptr{UInt32}
    Ap64::Ptr{UInt64}
    Ah32::Ptr{UInt32}
    Ah64::Ptr{UInt64}
    Ai32::Ptr{UInt32}
    Ai64::Ptr{UInt64}
    Ab::Ptr{Int8}
    Ax::Ptr{Cvoid}
    type_size::Csize_t
    A_sparsity::Int32
    iso::Bool
    by_col::Bool
    reserved_bool::NTuple{2, Bool}
    header_arena::Int32
    reserved::NTuple{8, UInt64}
end

const GxB_Iterator = Ptr{GB_Iterator_opaque}

"""
    GxB_Iterator_free(object)


### Prototype
```c
GB_DECLARE (GxB_Iterator );
```
"""
function GxB_Iterator_free(object)
    ccall((:GxB_Iterator_free, libgraphblas), GrB_Info, (Ptr{GxB_Iterator},), object)
end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Global_Option_set(arg1, va_list...)
        :(@ccall(libgraphblas.GxB_Global_Option_set(arg1::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Vector_Option_set(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Vector_Option_set(arg1::GrB_Vector, arg2::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Matrix_Option_set(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Matrix_Option_set(arg1::GrB_Matrix, arg2::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Desc_set(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Desc_set(arg1::GrB_Descriptor, arg2::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Context_set(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Context_set(arg1::GxB_Context, arg2::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Global_Option_get(arg1, va_list...)
        :(@ccall(libgraphblas.GxB_Global_Option_get(arg1::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Vector_Option_get(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Vector_Option_get(arg1::GrB_Vector, arg2::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Matrix_Option_get(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Matrix_Option_get(arg1::GrB_Matrix, arg2::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Desc_get(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Desc_get(arg1::GrB_Descriptor, arg2::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Context_get(arg1, arg2, va_list...)
        :(@ccall(libgraphblas.GxB_Context_get(arg1::GxB_Context, arg2::Cint; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

mutable struct GB_SelectOp_opaque end

"""
2 historical objects
"""
const GxB_SelectOp = Ptr{GB_SelectOp_opaque}

"""
    GxB_Vector_select(arg1, arg2, arg3, arg4, arg5, arg6, arg7)

GxB_select: use GrB_select instead
### Prototype
```c
GrB_Info GxB_Vector_select (GrB_Vector, const GrB_Vector, const GrB_BinaryOp, const GxB_SelectOp, const GrB_Vector, const GrB_Scalar, const GrB_Descriptor);
```
"""
function GxB_Vector_select(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:GxB_Vector_select, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_SelectOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

"""
    GxB_Matrix_select(arg1, arg2, arg3, arg4, arg5, arg6, arg7)


### Prototype
```c
GrB_Info GxB_Matrix_select (GrB_Matrix, const GrB_Matrix, const GrB_BinaryOp, const GxB_SelectOp, const GrB_Matrix, const GrB_Scalar, const GrB_Descriptor);
```
"""
function GxB_Matrix_select(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:GxB_Matrix_select, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_SelectOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
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

const GxB_Scalar = Ptr{GB_Scalar_opaque}

@enum GrB_Desc_Field::UInt32 begin
    GrB_OUTP = 0
    GrB_MASK = 1
    GrB_INP0 = 2
    GrB_INP1 = 3
    GxB_AxB_METHOD = 7090
    GxB_SORT = 7091
    GxB_COMPRESSION = 7092
    GxB_IMPORT = 7093
    GxB_ROWINDEX_LIST = 7094
    GxB_COLINDEX_LIST = 7095
    GxB_VALUE_LIST = 7096
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
    GxB_USE_INDICES = 7060
    GxB_IS_STRIDE = 7061
end

# typedef void ( * GxB_unary_function ) ( void * , const void * )
"""
The pointers are void * but they are always of pointers to objects of type
ztype and xtype, respectively.  The function must typecast its arguments as
needed from void* to ztype* and xtype*.
"""
const GxB_unary_function = Ptr{Cvoid}

# typedef void ( * GxB_binary_function ) ( void * , const void * , const void * )
"""
The pointers are void * but they are always of pointers to objects of type
ztype, xtype, and ytype, respectively.  See Demo/usercomplex.c for examples.
"""
const GxB_binary_function = Ptr{Cvoid}

# typedef void ( * GxB_index_binary_function ) ( void * , const void * , GrB_Index , GrB_Index , const void * , GrB_Index , GrB_Index , const void * )
const GxB_index_binary_function = Ptr{Cvoid}

# typedef void ( * GxB_index_unary_function ) ( void * z , // output value z, of type ztype const void * x , // input value x of type xtype; value of v(i) or A(i,j) GrB_Index i , // row index of A(i,j) GrB_Index j , // column index of A(i,j), or zero for v(i) const void * y // input scalar y )
"""
The indexop has the form z = f(aij, i, j, y) where aij is the numerical
value of the A(i,j) entry, i and j are its row and column index, and y
is a scalar.  For vectors, it has the form z = f(vi, i, 0, y).
"""
const GxB_index_unary_function = Ptr{Cvoid}

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
    GrB_EL_TYPE_CODE = 102
    GrB_EL_TYPE_STRING = 106
    GrB_INP0_TYPE_CODE = 103
    GrB_INP1_TYPE_CODE = 104
    GrB_OUTP_TYPE_CODE = 105
    GrB_INP0_TYPE_STRING = 107
    GrB_INP1_TYPE_STRING = 108
    GrB_OUTP_TYPE_STRING = 109
    GrB_SIZE = 110
    GxB_JIT_C_NAME = 7041
    GxB_JIT_C_DEFINITION = 7042
    GxB_MONOID_IDENTITY = 7043
    GxB_MONOID_TERMINAL = 7044
    GxB_MONOID_OPERATOR = 7045
    GxB_SEMIRING_MONOID = 7046
    GxB_SEMIRING_MULTIPLY = 7047
    GxB_THETA_TYPE_CODE = 7050
    GxB_THETA_TYPE_STRING = 7051
    GxB_THETA = 7052
    GxB_ROWINDEX_INTEGER_HINT = 7053
    GxB_COLINDEX_INTEGER_HINT = 7054
    GxB_OFFSET_INTEGER_HINT = 7056
    GxB_HYPER_SWITCH = 7000
    GxB_HYPER_HASH = 7048
    GxB_BITMAP_SWITCH = 7001
    GxB_FORMAT = 7002
    GxB_ISO = 7079
    GxB_SPARSITY_CONTROL = 7036
    GxB_ROWINDEX_INTEGER_BITS = 7057
    GxB_COLINDEX_INTEGER_BITS = 7058
    GxB_OFFSET_INTEGER_BITS = 7059
    GxB_SPARSITY_STATUS = 7034
    GxB_IS_HYPER = 7035
    GxB_IS_READONLY = 7078
    GxB_WILL_WAIT = 7076
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
    GxB_ARENA_MALLOC = 65536
    GxB_ARENA_CALLOC = 131072
    GxB_ARENA_REALLOC = 196608
    GxB_ARENA_FREE = 262144
    GxB_GLOBAL_NTHREADS = 7086
    GxB_GLOBAL_CHUNK = 7087
    GxB_GLOBAL_NGPUS = 7102
    GxB_GLOBAL_GPU_IDS = 7101
    GxB_NGPUS_MAX = 7103
    GxB_BURBLE = 7019
    GxB_PRINTF = 7020
    GxB_FLUSH = 7021
    GxB_MEMORY_POOL = 7022
    GxB_PRINT_1BASED = 7023
    GxB_INCLUDE_READONLY_STATISTICS = 7077
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
    GxB_JIT_CUDA_PREFACE = 7100
    GxB_PRINT_FUNCTION = 7104
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
    GxB_CONTEXT_NGPUS = 7102
    GxB_CONTEXT_GPU_IDS = 7101
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
    GrB_WaitMode

==============================================================================
GrB_wait: finish computations
==============================================================================
"""
@enum GrB_WaitMode::UInt32 begin
    GrB_COMPLETE = 0
    GrB_MATERIALIZE = 1
end

@enum GxB_Print_Level::UInt32 begin
    GxB_SILENT = 0
    GxB_SUMMARY = 1
    GxB_SHORT = 2
    GxB_COMPLETE = 3
    GxB_SHORT_VERBOSE = 4
    GxB_COMPLETE_VERBOSE = 5
end

# typedef int64_t ( * GxB_print_function ) ( // output: char * string , // value is printed to the string // input: size_t string_len , // size of the string array in bytes const void * value , // value to print int verbose // if >0, print verbosely; else tersely )
const GxB_print_function = Ptr{Cvoid}

"""
    GrB_Format

The GrB C API specification supports 3 formats:
"""
@enum GrB_Format::UInt32 begin
    GrB_CSR_FORMAT = 0
    GrB_CSC_FORMAT = 1
    GrB_COO_FORMAT = 2
end

@enum GxB_Format_Value::Int32 begin
    GxB_BY_ROW = 0
    GxB_BY_COL = 1
    GxB_NO_FORMAT = -1
end

"""
    GrB_init(mode)

==============================================================================
GrB_init / GrB_finalize
==============================================================================
### Prototype
```c
GrB_Info GrB_init ( int mode );
```
"""
function GrB_init(mode)
    ccall((:GrB_init, libgraphblas), GrB_Info, (Cint,), mode)
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
    GxB_init(mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)


### Prototype
```c
GrB_Info GxB_init ( int mode, void * (* user_malloc_function ) (size_t), void * (* user_calloc_function ) (size_t, size_t), void * (* user_realloc_function ) (void *, size_t), void (* user_free_function ) (void *) );
```
"""
function GxB_init(mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)
    ccall((:GxB_init, libgraphblas), GrB_Info, (Cint, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}), mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)
end

"""
    GxB_initialized(flag)

GrB_init and GxB_init return GrB_INVALID_VALUE if GraphBLAS is already
initialized.  GrB_finalize returns GrB_INVALID_VALUE if GraphBLAS has not
been initialized, and sets the state of GraphBLAS to not-initialized.
### Prototype
```c
GrB_Info GxB_initialized ( int *flag );
```
"""
function GxB_initialized(flag)
    ccall((:GxB_initialized, libgraphblas), GrB_Info, (Ptr{Cint},), flag)
end

"""
    GxB_finalized(flag)


### Prototype
```c
GrB_Info GxB_finalized ( int *flag );
```
"""
function GxB_finalized(flag)
    ccall((:GxB_finalized, libgraphblas), GrB_Info, (Ptr{Cint},), flag)
end

"""
    GxB_arena_init(arena, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)


### Prototype
```c
GrB_Info GxB_arena_init ( int arena, void * (* user_malloc_function ) (size_t), void * (* user_calloc_function ) (size_t, size_t), void * (* user_realloc_function ) (void *, size_t), void (* user_free_function ) (void *) );
```
"""
function GxB_arena_init(arena, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)
    ccall((:GxB_arena_init, libgraphblas), GrB_Info, (Cint, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}), arena, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)
end

"""
    GxB_arena_initialized(flag, arena)


### Prototype
```c
GrB_Info GxB_arena_initialized ( int *flag, int arena );
```
"""
function GxB_arena_initialized(flag, arena)
    ccall((:GxB_arena_initialized, libgraphblas), GrB_Info, (Ptr{Cint}, Cint), flag, arena)
end

"""
    GxB_Matrix_set_arenas(Ahandle, new_header_arena, new_data_arena)

GxB_[Matrix,Vector,Scalar]_set_arenas: change the header and data arena:
### Prototype
```c
GrB_Info GxB_Matrix_set_arenas ( GrB_Matrix *Ahandle, const int new_header_arena, const int new_data_arena );
```
"""
function GxB_Matrix_set_arenas(Ahandle, new_header_arena, new_data_arena)
    ccall((:GxB_Matrix_set_arenas, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Cint, Cint), Ahandle, new_header_arena, new_data_arena)
end

"""
    GxB_Vector_set_arenas(Vhandle, new_header_arena, new_data_arena)


### Prototype
```c
GrB_Info GxB_Vector_set_arenas ( GrB_Vector *Vhandle, const int new_header_arena, const int new_data_arena );
```
"""
function GxB_Vector_set_arenas(Vhandle, new_header_arena, new_data_arena)
    ccall((:GxB_Vector_set_arenas, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Cint, Cint), Vhandle, new_header_arena, new_data_arena)
end

"""
    GxB_Scalar_set_arenas(Shandle, new_header_arena, new_data_arena)


### Prototype
```c
GrB_Info GxB_Scalar_set_arenas ( GrB_Scalar *Shandle, const int new_header_arena, const int new_data_arena );
```
"""
function GxB_Scalar_set_arenas(Shandle, new_header_arena, new_data_arena)
    ccall((:GxB_Scalar_set_arenas, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, Cint, Cint), Shandle, new_header_arena, new_data_arena)
end

"""
    GrB_Descriptor_new(descriptor)

==============================================================================
GrB_Descriptor: the GraphBLAS descriptor
==============================================================================
### Prototype
```c
GrB_Info GrB_Descriptor_new ( GrB_Descriptor *descriptor );
```
"""
function GrB_Descriptor_new(descriptor)
    ccall((:GrB_Descriptor_new, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), descriptor)
end

"""
    GxB_Descriptor_new_arena(descriptor, header_arena)


### Prototype
```c
GrB_Info GxB_Descriptor_new_arena ( GrB_Descriptor *descriptor, const int header_arena );
```
"""
function GxB_Descriptor_new_arena(descriptor, header_arena)
    ccall((:GxB_Descriptor_new_arena, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor}, Cint), descriptor, header_arena)
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
    GxB_Type_new_arena(type, sizeof_type, type_name, type_defn, header_arena)


### Prototype
```c
GrB_Info GxB_Type_new_arena ( GrB_Type *type, size_t sizeof_type, const char *type_name, const char *type_defn, const int header_arena );
```
"""
function GxB_Type_new_arena(type, sizeof_type, type_name, type_defn, header_arena)
    ccall((:GxB_Type_new_arena, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Csize_t, Ptr{Cchar}, Ptr{Cchar}, Cint), type, sizeof_type, type_name, type_defn, header_arena)
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
    GxB_UnaryOp_new_arena(op_handle, _function, ztype, xtype, unop_name, unop_defn, header_arena)


### Prototype
```c
GrB_Info GxB_UnaryOp_new_arena ( GrB_UnaryOp *op_handle, GxB_unary_function function, GrB_Type ztype, GrB_Type xtype, const char *unop_name, const char *unop_defn, const int header_arena );
```
"""
function GxB_UnaryOp_new_arena(op_handle, _function, ztype, xtype, unop_name, unop_defn, header_arena)
    ccall((:GxB_UnaryOp_new_arena, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp}, GxB_unary_function, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}, Cint), op_handle, _function, ztype, xtype, unop_name, unop_defn, header_arena)
end

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
    GxB_BinaryOp_new_arena(op_handle, _function, ztype, xtype, ytype, binop_name, binop_defn, header_arena)


### Prototype
```c
GrB_Info GxB_BinaryOp_new_arena ( GrB_BinaryOp *op_handle, GxB_binary_function function, GrB_Type ztype, GrB_Type xtype, GrB_Type ytype, const char *binop_name, const char *binop_defn, const int header_arena );
```
"""
function GxB_BinaryOp_new_arena(op_handle, _function, ztype, xtype, ytype, binop_name, binop_defn, header_arena)
    ccall((:GxB_BinaryOp_new_arena, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_binary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}, Cint), op_handle, _function, ztype, xtype, ytype, binop_name, binop_defn, header_arena)
end

"""
    GxB_IndexBinaryOp_new(op, _function, ztype, xtype, ytype, theta_type, idxbinop_name, idxbinop_defn)

GxB_IndexBinaryOp_new creates a new user-defined index binary op
### Prototype
```c
GrB_Info GxB_IndexBinaryOp_new ( GxB_IndexBinaryOp *op, GxB_index_binary_function function, GrB_Type ztype, GrB_Type xtype, GrB_Type ytype, GrB_Type theta_type, const char *idxbinop_name, const char *idxbinop_defn );
```
"""
function GxB_IndexBinaryOp_new(op, _function, ztype, xtype, ytype, theta_type, idxbinop_name, idxbinop_defn)
    ccall((:GxB_IndexBinaryOp_new, libgraphblas), GrB_Info, (Ptr{GxB_IndexBinaryOp}, GxB_index_binary_function, GrB_Type, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), op, _function, ztype, xtype, ytype, theta_type, idxbinop_name, idxbinop_defn)
end

"""
    GxB_IndexBinaryOp_new_arena(op_handle, _function, ztype, xtype, ytype, theta_type, idxop_name, idxop_defn, header_arena)


### Prototype
```c
GrB_Info GxB_IndexBinaryOp_new_arena ( GxB_IndexBinaryOp *op_handle, GxB_index_binary_function function, GrB_Type ztype, GrB_Type xtype, GrB_Type ytype, GrB_Type theta_type, const char *idxop_name, const char *idxop_defn, const int header_arena );
```
"""
function GxB_IndexBinaryOp_new_arena(op_handle, _function, ztype, xtype, ytype, theta_type, idxop_name, idxop_defn, header_arena)
    ccall((:GxB_IndexBinaryOp_new_arena, libgraphblas), GrB_Info, (Ptr{GxB_IndexBinaryOp}, GxB_index_binary_function, GrB_Type, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}, Cint), op_handle, _function, ztype, xtype, ytype, theta_type, idxop_name, idxop_defn, header_arena)
end

"""
    GxB_BinaryOp_new_IndexOp(binop, idxbinop, theta)

GxB_BinaryOp_new_IndexOp: create a new binary op from an index binary op
### Prototype
```c
GrB_Info GxB_BinaryOp_new_IndexOp ( GrB_BinaryOp *binop, GxB_IndexBinaryOp idxbinop, GrB_Scalar theta );
```
"""
function GxB_BinaryOp_new_IndexOp(binop, idxbinop, theta)
    ccall((:GxB_BinaryOp_new_IndexOp, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_IndexBinaryOp, GrB_Scalar), binop, idxbinop, theta)
end

"""
    GxB_BinaryOp_new_IndexOp_arena(binop_handle, idxbinop, theta, header_arena)

GxB_BinaryOp_new_IndexOp_arena: create new binary op from an index binary op
### Prototype
```c
GrB_Info GxB_BinaryOp_new_IndexOp_arena ( GrB_BinaryOp *binop_handle, GxB_IndexBinaryOp idxbinop, GrB_Scalar theta, const int header_arena );
```
"""
function GxB_BinaryOp_new_IndexOp_arena(binop_handle, idxbinop, theta, header_arena)
    ccall((:GxB_BinaryOp_new_IndexOp_arena, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_IndexBinaryOp, GrB_Scalar, Cint), binop_handle, idxbinop, theta, header_arena)
end

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
    GxB_IndexUnaryOp_new_arena(op_handle, _function, ztype, xtype, ytype, idxop_name, idxop_defn, header_arena)


### Prototype
```c
GrB_Info GxB_IndexUnaryOp_new_arena ( GrB_IndexUnaryOp *op_handle, GxB_index_unary_function function, GrB_Type ztype, GrB_Type xtype, GrB_Type ytype, const char *idxop_name, const char *idxop_defn, const int header_arena );
```
"""
function GxB_IndexUnaryOp_new_arena(op_handle, _function, ztype, xtype, ytype, idxop_name, idxop_defn, header_arena)
    ccall((:GxB_IndexUnaryOp_new_arena, libgraphblas), GrB_Info, (Ptr{GrB_IndexUnaryOp}, GxB_index_unary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}, Cint), op_handle, _function, ztype, xtype, ytype, idxop_name, idxop_defn, header_arena)
end

"""
    GrB_Monoid_new_BOOL(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_BOOL(monoid, op, identity)
    ccall((:GrB_Monoid_new_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool), monoid, op, identity)
end

"""
    GrB_Monoid_new_INT8(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_INT8(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8), monoid, op, identity)
end

"""
    GrB_Monoid_new_INT16(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_INT16(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16), monoid, op, identity)
end

"""
    GrB_Monoid_new_INT32(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_INT32(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32), monoid, op, identity)
end

"""
    GrB_Monoid_new_INT64(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_INT64(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64), monoid, op, identity)
end

"""
    GrB_Monoid_new_UINT8(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_UINT8(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8), monoid, op, identity)
end

"""
    GrB_Monoid_new_UINT16(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_UINT16(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16), monoid, op, identity)
end

"""
    GrB_Monoid_new_UINT32(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_UINT32(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32), monoid, op, identity)
end

"""
    GrB_Monoid_new_UINT64(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_UINT64(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64), monoid, op, identity)
end

"""
    GrB_Monoid_new_FP32(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_FP32(monoid, op, identity)
    ccall((:GrB_Monoid_new_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat), monoid, op, identity)
end

"""
    GrB_Monoid_new_FP64(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_FP64(monoid, op, identity)
    ccall((:GrB_Monoid_new_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble), monoid, op, identity)
end

"""
    GxB_Monoid_new_FC32(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Monoid_new_FC32(monoid, op, identity)
    ccall((:GxB_Monoid_new_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t), monoid, op, identity)
end

"""
    GxB_Monoid_new_FC64(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Monoid_new_FC64(monoid, op, identity)
    ccall((:GxB_Monoid_new_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t), monoid, op, identity)
end

"""
    GrB_Monoid_new_UDT(monoid, op, identity)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Monoid_new_UDT(monoid, op, identity)
    ccall((:GrB_Monoid_new_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}), monoid, op, identity)
end

"""
    GxB_Monoid_new_arena_BOOL(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_BOOL(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_INT8(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_INT8(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_INT16(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_INT16(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_INT32(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_INT32(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_INT64(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_INT64(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_UINT8(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_UINT8(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_UINT16(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_UINT16(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_UINT32(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_UINT32(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_UINT64(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_UINT64(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_FP32(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_FP32(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_FP64(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_FP64(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_FC32(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_FC32(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_FC64(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_FC64(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_new_arena_UDT(monoid, op, identity, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_new_arena_UDT(monoid, op, identity, header_arena)
    ccall((:GxB_Monoid_new_arena_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}, Cint), monoid, op, identity, header_arena)
end

"""
    GxB_Monoid_terminal_new_BOOL(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_BOOL(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool, Bool), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_INT8(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_INT8(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8, Int8), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_INT16(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_INT16(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16, Int16), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_INT32(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_INT32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32, Int32), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_INT64(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_INT64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64, Int64), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UINT8(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_UINT8(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8, UInt8), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UINT16(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_UINT16(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16, UInt16), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UINT32(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_UINT32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32, UInt32), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UINT64(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_UINT64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64, UInt64), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_FP32(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_FP32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat, Cfloat), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_FP64(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_FP64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble, Cdouble), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_FC32(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_FC32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t, GxB_FC32_t), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_FC64(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_FC64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t, GxB_FC64_t), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_UDT(monoid, op, identity, terminal)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_UDT(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}, Ptr{Cvoid}), monoid, op, identity, terminal)
end

"""
    GxB_Monoid_terminal_new_arena_BOOL(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_BOOL(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool, Bool, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_INT8(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_INT8(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8, Int8, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_INT16(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_INT16(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16, Int16, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_INT32(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_INT32(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32, Int32, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_INT64(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_INT64(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64, Int64, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_UINT8(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_UINT8(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8, UInt8, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_UINT16(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_UINT16(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16, UInt16, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_UINT32(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_UINT32(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32, UInt32, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_UINT64(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_UINT64(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64, UInt64, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_FP32(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_FP32(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat, Cfloat, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_FP64(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_FP64(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble, Cdouble, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_FC32(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_FC32(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t, GxB_FC32_t, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_FC64(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_FC64(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t, GxB_FC64_t, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GxB_Monoid_terminal_new_arena_UDT(monoid, op, identity, terminal, header_arena)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Monoid_terminal_new_arena_UDT(monoid, op, identity, terminal, header_arena)
    ccall((:GxB_Monoid_terminal_new_arena_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}, Ptr{Cvoid}, Cint), monoid, op, identity, terminal, header_arena)
end

"""
    GrB_Semiring_new(semiring, add, multiply)

The multiply op can be any GrB_BinaryOp, including those based on a
GxB_IndexBinaryOp.
### Prototype
```c
GrB_Info GrB_Semiring_new ( GrB_Semiring *semiring, GrB_Monoid add, GrB_BinaryOp multiply );
```
"""
function GrB_Semiring_new(semiring, add, multiply)
    ccall((:GrB_Semiring_new, libgraphblas), GrB_Info, (Ptr{GrB_Semiring}, GrB_Monoid, GrB_BinaryOp), semiring, add, multiply)
end

"""
    GxB_Semiring_new_arena(semiring, add, multiply, header_arena)


### Prototype
```c
GrB_Info GxB_Semiring_new_arena ( GrB_Semiring *semiring, GrB_Monoid add, GrB_BinaryOp multiply, const int header_arena );
```
"""
function GxB_Semiring_new_arena(semiring, add, multiply, header_arena)
    ccall((:GxB_Semiring_new_arena, libgraphblas), GrB_Info, (Ptr{GrB_Semiring}, GrB_Monoid, GrB_BinaryOp, Cint), semiring, add, multiply, header_arena)
end

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
    GxB_Scalar_new_arena(s, type, header_arena, data_arena)


### Prototype
```c
GrB_Info GxB_Scalar_new_arena ( GrB_Scalar *s, GrB_Type type, const int header_arena, const int data_arena );
```
"""
function GxB_Scalar_new_arena(s, type, header_arena, data_arena)
    ccall((:GxB_Scalar_new_arena, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Type, Cint, Cint), s, type, header_arena, data_arena)
end

"""
    GxB_Scalar_dup_arena(s, t, header_arena, data_arena)


### Prototype
```c
GrB_Info GxB_Scalar_dup_arena ( GrB_Scalar *s, const GrB_Scalar t, const int header_arena, const int data_arena );
```
"""
function GxB_Scalar_dup_arena(s, t, header_arena, data_arena)
    ccall((:GxB_Scalar_dup_arena, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Scalar, Cint, Cint), s, t, header_arena, data_arena)
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
    GxB_Scalar_type(type, s)


### Prototype
```c
GrB_Info GxB_Scalar_type ( GrB_Type *type, const GrB_Scalar s );
```
"""
function GxB_Scalar_type(type, s)
    ccall((:GxB_Scalar_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Scalar), type, s)
end

"""
    GrB_Scalar_setElement_BOOL(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_BOOL(s, x)
    ccall((:GrB_Scalar_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Scalar, Bool), s, x)
end

"""
    GrB_Scalar_setElement_INT8(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_INT8(s, x)
    ccall((:GrB_Scalar_setElement_INT8, libgraphblas), GrB_Info, (GrB_Scalar, Int8), s, x)
end

"""
    GrB_Scalar_setElement_INT16(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_INT16(s, x)
    ccall((:GrB_Scalar_setElement_INT16, libgraphblas), GrB_Info, (GrB_Scalar, Int16), s, x)
end

"""
    GrB_Scalar_setElement_INT32(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_INT32(s, x)
    ccall((:GrB_Scalar_setElement_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Int32), s, x)
end

"""
    GrB_Scalar_setElement_INT64(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_INT64(s, x)
    ccall((:GrB_Scalar_setElement_INT64, libgraphblas), GrB_Info, (GrB_Scalar, Int64), s, x)
end

"""
    GrB_Scalar_setElement_UINT8(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_UINT8(s, x)
    ccall((:GrB_Scalar_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Scalar, UInt8), s, x)
end

"""
    GrB_Scalar_setElement_UINT16(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_UINT16(s, x)
    ccall((:GrB_Scalar_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Scalar, UInt16), s, x)
end

"""
    GrB_Scalar_setElement_UINT32(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_UINT32(s, x)
    ccall((:GrB_Scalar_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Scalar, UInt32), s, x)
end

"""
    GrB_Scalar_setElement_UINT64(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_UINT64(s, x)
    ccall((:GrB_Scalar_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Scalar, UInt64), s, x)
end

"""
    GrB_Scalar_setElement_FP32(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_FP32(s, x)
    ccall((:GrB_Scalar_setElement_FP32, libgraphblas), GrB_Info, (GrB_Scalar, Cfloat), s, x)
end

"""
    GrB_Scalar_setElement_FP64(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_FP64(s, x)
    ccall((:GrB_Scalar_setElement_FP64, libgraphblas), GrB_Info, (GrB_Scalar, Cdouble), s, x)
end

"""
    GxB_Scalar_setElement_FC32(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Scalar_setElement_FC32(s, x)
    ccall((:GxB_Scalar_setElement_FC32, libgraphblas), GrB_Info, (GrB_Scalar, GxB_FC32_t), s, x)
end

"""
    GxB_Scalar_setElement_FC64(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Scalar_setElement_FC64(s, x)
    ccall((:GxB_Scalar_setElement_FC64, libgraphblas), GrB_Info, (GrB_Scalar, GxB_FC64_t), s, x)
end

"""
    GrB_Scalar_setElement_UDT(s, x)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Scalar_setElement_UDT(s, x)
    ccall((:GrB_Scalar_setElement_UDT, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}), s, x)
end

"""
    GrB_Scalar_extractElement_BOOL(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_BOOL(x, s)
    ccall((:GrB_Scalar_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_INT8(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_INT8(x, s)
    ccall((:GrB_Scalar_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_INT16(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_INT16(x, s)
    ccall((:GrB_Scalar_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_INT32(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_INT32(x, s)
    ccall((:GrB_Scalar_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_INT64(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_INT64(x, s)
    ccall((:GrB_Scalar_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UINT8(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_UINT8(x, s)
    ccall((:GrB_Scalar_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UINT16(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_UINT16(x, s)
    ccall((:GrB_Scalar_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UINT32(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_UINT32(x, s)
    ccall((:GrB_Scalar_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UINT64(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_UINT64(x, s)
    ccall((:GrB_Scalar_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_FP32(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_FP32(x, s)
    ccall((:GrB_Scalar_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_FP64(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_FP64(x, s)
    ccall((:GrB_Scalar_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_FC32(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Scalar_extractElement_FC32(x, s)
    ccall((:GxB_Scalar_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_Scalar), x, s)
end

"""
    GxB_Scalar_extractElement_FC64(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Scalar_extractElement_FC64(x, s)
    ccall((:GxB_Scalar_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_Scalar), x, s)
end

"""
    GrB_Scalar_extractElement_UDT(x, s)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Scalar_extractElement_UDT(x, s)
    ccall((:GrB_Scalar_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Scalar), x, s)
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
    GxB_Vector_new_arena(v, type, n, header_arena, data_arena)


### Prototype
```c
GrB_Info GxB_Vector_new_arena ( GrB_Vector *v, GrB_Type type, GrB_Index n, const int header_arena, const int data_arena );
```
"""
function GxB_Vector_new_arena(v, type, n, header_arena, data_arena)
    ccall((:GxB_Vector_new_arena, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Cint, Cint), v, type, n, header_arena, data_arena)
end

"""
    GxB_Vector_dup_arena(w, u, header_arena, data_arena)


### Prototype
```c
GrB_Info GxB_Vector_dup_arena ( GrB_Vector *w, const GrB_Vector u, const int header_arena, const int data_arena );
```
"""
function GxB_Vector_dup_arena(w, u, header_arena, data_arena)
    ccall((:GxB_Vector_dup_arena, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Vector, Cint, Cint), w, u, header_arena, data_arena)
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
    GxB_Vector_type(type, v)


### Prototype
```c
GrB_Info GxB_Vector_type ( GrB_Type *type, const GrB_Vector v );
```
"""
function GxB_Vector_type(type, v)
    ccall((:GxB_Vector_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Vector), type, v)
end

"""
    GrB_Vector_build_BOOL(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_BOOL(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_BOOL, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Bool}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_INT8(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_INT8(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_INT8, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int8}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_INT16(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_INT16(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_INT16, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int16}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_INT32(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_INT32(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_INT32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int32}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_INT64(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_INT64(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_INT64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int64}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_UINT8(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_UINT8(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT8, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt8}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_UINT16(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_UINT16(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT16, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt16}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_UINT32(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_UINT32(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt32}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_UINT64(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_UINT64(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt64}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_FP32(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_FP32(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_FP32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cfloat}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_FP64(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_FP64(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_FP64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cdouble}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GxB_Vector_build_FC32(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Vector_build_FC32(w, I_, X, nvals, dup)
    ccall((:GxB_Vector_build_FC32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GxB_Vector_build_FC64(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Vector_build_FC64(w, I_, X, nvals, dup)
    ccall((:GxB_Vector_build_FC64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_build_UDT(w, I_, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_build_UDT(w, I_, X, nvals, dup)
    ccall((:GrB_Vector_build_UDT, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_BinaryOp), w, I_, X, nvals, dup)
end

"""
    GrB_Vector_setElement_BOOL(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_BOOL(w, x, i)
    ccall((:GrB_Vector_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Vector, Bool, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_INT8(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_INT8(w, x, i)
    ccall((:GrB_Vector_setElement_INT8, libgraphblas), GrB_Info, (GrB_Vector, Int8, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_INT16(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_INT16(w, x, i)
    ccall((:GrB_Vector_setElement_INT16, libgraphblas), GrB_Info, (GrB_Vector, Int16, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_INT32(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_INT32(w, x, i)
    ccall((:GrB_Vector_setElement_INT32, libgraphblas), GrB_Info, (GrB_Vector, Int32, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_INT64(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_INT64(w, x, i)
    ccall((:GrB_Vector_setElement_INT64, libgraphblas), GrB_Info, (GrB_Vector, Int64, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UINT8(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_UINT8(w, x, i)
    ccall((:GrB_Vector_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Vector, UInt8, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UINT16(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_UINT16(w, x, i)
    ccall((:GrB_Vector_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Vector, UInt16, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UINT32(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_UINT32(w, x, i)
    ccall((:GrB_Vector_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Vector, UInt32, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UINT64(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_UINT64(w, x, i)
    ccall((:GrB_Vector_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Vector, UInt64, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_FP32(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_FP32(w, x, i)
    ccall((:GrB_Vector_setElement_FP32, libgraphblas), GrB_Info, (GrB_Vector, Cfloat, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_FP64(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_FP64(w, x, i)
    ccall((:GrB_Vector_setElement_FP64, libgraphblas), GrB_Info, (GrB_Vector, Cdouble, GrB_Index), w, x, i)
end

"""
    GxB_Vector_setElement_FC32(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Vector_setElement_FC32(w, x, i)
    ccall((:GxB_Vector_setElement_FC32, libgraphblas), GrB_Info, (GrB_Vector, GxB_FC32_t, GrB_Index), w, x, i)
end

"""
    GxB_Vector_setElement_FC64(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Vector_setElement_FC64(w, x, i)
    ccall((:GxB_Vector_setElement_FC64, libgraphblas), GrB_Info, (GrB_Vector, GxB_FC64_t, GrB_Index), w, x, i)
end

"""
    GrB_Vector_setElement_UDT(w, x, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_setElement_UDT(w, x, i)
    ccall((:GrB_Vector_setElement_UDT, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cvoid}, GrB_Index), w, x, i)
end

"""
    GrB_Vector_extractElement_BOOL(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_BOOL(x, v, i)
    ccall((:GrB_Vector_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_INT8(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_INT8(x, v, i)
    ccall((:GrB_Vector_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_INT16(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_INT16(x, v, i)
    ccall((:GrB_Vector_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_INT32(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_INT32(x, v, i)
    ccall((:GrB_Vector_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_INT64(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_INT64(x, v, i)
    ccall((:GrB_Vector_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UINT8(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_UINT8(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UINT16(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_UINT16(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UINT32(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_UINT32(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UINT64(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_UINT64(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_FP32(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_FP32(x, v, i)
    ccall((:GrB_Vector_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_FP64(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_FP64(x, v, i)
    ccall((:GrB_Vector_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GxB_Vector_extractElement_FC32(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Vector_extractElement_FC32(x, v, i)
    ccall((:GxB_Vector_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GxB_Vector_extractElement_FC64(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Vector_extractElement_FC64(x, v, i)
    ccall((:GxB_Vector_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GrB_Vector_extractElement_UDT(x, v, i)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractElement_UDT(x, v, i)
    ccall((:GrB_Vector_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Vector, GrB_Index), x, v, i)
end

"""
    GxB_Vector_isStoredElement(v, i)


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
    GrB_Vector_extractTuples_BOOL(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_BOOL(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_INT8(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_INT8(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int8}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_INT16(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_INT16(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int16}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_INT32(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_INT32(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int32}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_INT64(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_INT64(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int64}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_UINT8(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_UINT8(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt8}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_UINT16(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_UINT16(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt16}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_UINT32(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_UINT32(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt32}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_UINT64(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_UINT64(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt64}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_FP32(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_FP32(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cfloat}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_FP64(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_FP64(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cdouble}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GxB_Vector_extractTuples_FC32(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Vector_extractTuples_FC32(I_, X, nvals, V)
    ccall((:GxB_Vector_extractTuples_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GxB_FC32_t}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GxB_Vector_extractTuples_FC64(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Vector_extractTuples_FC64(I_, X, nvals, V)
    ccall((:GxB_Vector_extractTuples_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GxB_FC64_t}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
end

"""
    GrB_Vector_extractTuples_UDT(I_, X, nvals, V)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_extractTuples_UDT(I_, X, nvals, V)
    ccall((:GrB_Vector_extractTuples_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Vector), I_, X, nvals, V)
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
    GxB_Matrix_new_arena(A, type, nrows, ncols, header_arena, data_arena)


### Prototype
```c
GrB_Info GxB_Matrix_new_arena ( GrB_Matrix *A, GrB_Type type, GrB_Index nrows, GrB_Index ncols, const int header_arena, const int data_arena );
```
"""
function GxB_Matrix_new_arena(A, type, nrows, ncols, header_arena, data_arena)
    ccall((:GxB_Matrix_new_arena, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Cint, Cint), A, type, nrows, ncols, header_arena, data_arena)
end

"""
    GxB_Matrix_dup_arena(C, A, header_arena, data_arena)


### Prototype
```c
GrB_Info GxB_Matrix_dup_arena ( GrB_Matrix *C, const GrB_Matrix A, const int header_arena, const int data_arena );
```
"""
function GxB_Matrix_dup_arena(C, A, header_arena, data_arena)
    ccall((:GxB_Matrix_dup_arena, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Matrix, Cint, Cint), C, A, header_arena, data_arena)
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
    GxB_Matrix_type(type, A)


### Prototype
```c
GrB_Info GxB_Matrix_type ( GrB_Type *type, const GrB_Matrix A );
```
"""
function GxB_Matrix_type(type, A)
    ccall((:GxB_Matrix_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Matrix), type, A)
end

"""
    GrB_Matrix_build_BOOL(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_BOOL(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_INT8(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_INT8(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT8, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_INT16(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_INT16(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT16, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_INT32(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_INT32(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_INT64(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_INT64(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UINT8(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_UINT8(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UINT16(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_UINT16(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UINT32(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_UINT32(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UINT64(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_UINT64(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_FP32(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_FP32(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_FP32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_FP64(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_FP64(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_FP64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GxB_Matrix_build_FC32(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_build_FC32(C, I_, J, X, nvals, dup)
    ccall((:GxB_Matrix_build_FC32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GxB_Matrix_build_FC64(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_build_FC64(C, I_, J, X, nvals, dup)
    ccall((:GxB_Matrix_build_FC64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_build_UDT(C, I_, J, X, nvals, dup)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_build_UDT(C, I_, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UDT, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_BinaryOp), C, I_, J, X, nvals, dup)
end

"""
    GrB_Matrix_setElement_BOOL(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_BOOL(C, x, i, j)
    ccall((:GrB_Matrix_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, Bool, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_INT8(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_INT8(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT8, libgraphblas), GrB_Info, (GrB_Matrix, Int8, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_INT16(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_INT16(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT16, libgraphblas), GrB_Info, (GrB_Matrix, Int16, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_INT32(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_INT32(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Int32, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_INT64(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_INT64(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT64, libgraphblas), GrB_Info, (GrB_Matrix, Int64, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UINT8(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_UINT8(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, UInt8, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UINT16(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_UINT16(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, UInt16, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UINT32(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_UINT32(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, UInt32, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UINT64(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_UINT64(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, UInt64, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_FP32(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_FP32(C, x, i, j)
    ccall((:GrB_Matrix_setElement_FP32, libgraphblas), GrB_Info, (GrB_Matrix, Cfloat, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_FP64(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_FP64(C, x, i, j)
    ccall((:GrB_Matrix_setElement_FP64, libgraphblas), GrB_Info, (GrB_Matrix, Cdouble, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GxB_Matrix_setElement_FC32(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Matrix_setElement_FC32(C, x, i, j)
    ccall((:GxB_Matrix_setElement_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GxB_FC32_t, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GxB_Matrix_setElement_FC64(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Matrix_setElement_FC64(C, x, i, j)
    ccall((:GxB_Matrix_setElement_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GxB_FC64_t, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_setElement_UDT(C, x, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_setElement_UDT(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UDT, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cvoid}, GrB_Index, GrB_Index), C, x, i, j)
end

"""
    GrB_Matrix_extractElement_BOOL(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_BOOL(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_INT8(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_INT8(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_INT16(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_INT16(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_INT32(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_INT32(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_INT64(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_INT64(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UINT8(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_UINT8(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UINT16(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_UINT16(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UINT32(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_UINT32(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UINT64(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_UINT64(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_FP32(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_FP32(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_FP64(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_FP64(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GxB_Matrix_extractElement_FC32(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_extractElement_FC32(x, A, i, j)
    ccall((:GxB_Matrix_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GxB_Matrix_extractElement_FC64(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_extractElement_FC64(x, A, i, j)
    ccall((:GxB_Matrix_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GrB_Matrix_extractElement_UDT(x, A, i, j)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractElement_UDT(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

"""
    GxB_Matrix_isStoredElement(A, i, j)


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
    GrB_Matrix_extractTuples_BOOL(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_BOOL(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_INT8(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_INT8(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_INT16(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_INT16(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_INT32(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_INT32(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_INT64(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_INT64(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UINT8(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_UINT8(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UINT16(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_UINT16(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UINT32(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_UINT32(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UINT64(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_UINT64(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_FP32(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_FP32(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_FP64(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_FP64(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GxB_Matrix_extractTuples_FC32(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_extractTuples_FC32(I_, J, X, nvals, A)
    ccall((:GxB_Matrix_extractTuples_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GxB_Matrix_extractTuples_FC64(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_extractTuples_FC64(I_, J, X, nvals, A)
    ccall((:GxB_Matrix_extractTuples_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GrB_Matrix_extractTuples_UDT(I_, J, X, nvals, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_extractTuples_UDT(I_, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Matrix), I_, J, X, nvals, A)
end

"""
    GxB_Matrix_concat(C, Tiles, m, n, desc)


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


### Prototype
```c
GrB_Info GxB_Matrix_split ( GrB_Matrix *Tiles, const GrB_Index m, const GrB_Index n, const GrB_Index *Tile_nrows, const GrB_Index *Tile_ncols, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_split(Tiles, m, n, Tile_nrows, Tile_ncols, A, desc)
    ccall((:GxB_Matrix_split, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Matrix, GrB_Descriptor), Tiles, m, n, Tile_nrows, Tile_ncols, A, desc)
end

"""
    GxB_Matrix_split_arena(Tiles, m, n, Tile_nrows, Tile_ncols, A, header_arena, data_arena, desc)


### Prototype
```c
GrB_Info GxB_Matrix_split_arena ( GrB_Matrix *Tiles, const GrB_Index m, const GrB_Index n, const GrB_Index *Tile_nrows, const GrB_Index *Tile_ncols, const GrB_Matrix A, const int header_arena, const int data_arena, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_split_arena(Tiles, m, n, Tile_nrows, Tile_ncols, A, header_arena, data_arena, desc)
    ccall((:GxB_Matrix_split_arena, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Matrix, Cint, Cint, GrB_Descriptor), Tiles, m, n, Tile_nrows, Tile_ncols, A, header_arena, data_arena, desc)
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
    GxB_Matrix_diag_arena(C, v, k, header_arena, data_arena)


### Prototype
```c
GrB_Info GxB_Matrix_diag_arena ( GrB_Matrix *C, const GrB_Vector v, int64_t k, const int header_arena, const int data_arena );
```
"""
function GxB_Matrix_diag_arena(C, v, k, header_arena, data_arena)
    ccall((:GxB_Matrix_diag_arena, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Vector, Int64, Cint, Cint), C, v, k, header_arena, data_arena)
end

"""
    GxB_Matrix_diag(C, v, k, desc)


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


### Prototype
```c
GrB_Info GxB_Vector_diag ( GrB_Vector v, const GrB_Matrix A, int64_t k, const GrB_Descriptor desc );
```
"""
function GxB_Vector_diag(v, A, k, desc)
    ccall((:GxB_Vector_diag, libgraphblas), GrB_Info, (GrB_Vector, GrB_Matrix, Int64, GrB_Descriptor), v, A, k, desc)
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
    GxB_Context_new_arena(Context_handle, header_arena)


### Prototype
```c
GrB_Info GxB_Context_new_arena ( GxB_Context *Context_handle, const int header_arena );
```
"""
function GxB_Context_new_arena(Context_handle, header_arena)
    ccall((:GxB_Context_new_arena, libgraphblas), GrB_Info, (Ptr{GxB_Context}, Cint), Context_handle, header_arena)
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
    GrB_mxm(C, Mask, accum, semiring, A, B, desc)

No accum operator in any method can be based on a GxB_IndexBinaryOp.
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
    GxB_Vector_subassign_BOOL(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_BOOL(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_INT8(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_INT8(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_INT16(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_INT16(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_INT32(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_INT32(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_INT64(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_INT64(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_UINT8(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_UINT8(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_UINT16(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_UINT16(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_UINT32(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_UINT32(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_UINT64(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_UINT64(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_FP32(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_FP32(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_FP64(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_FP64(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_FC32(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_FC32(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_FC64(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_FC64(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_subassign_UDT(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Vector_subassign_UDT(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_subassign_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Matrix_subassign_BOOL(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_BOOL(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_INT8(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_INT8(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_INT16(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_INT16(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_INT32(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_INT32(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_INT64(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_INT64(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UINT8(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_UINT8(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UINT16(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_UINT16(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UINT32(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_UINT32(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UINT64(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_UINT64(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_FP32(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_FP32(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_FP64(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_FP64(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_FC32(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_FC32(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_FC64(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_FC64(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_subassign_UDT(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GxB_, void *);
```
"""
function GxB_Matrix_subassign_UDT(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Vector_assign_BOOL(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_BOOL(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_INT8(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_INT8(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_INT16(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_INT16(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_INT32(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_INT32(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_INT64(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_INT64(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_UINT8(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_UINT8(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_UINT16(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_UINT16(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_UINT32(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_UINT32(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_UINT64(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_UINT64(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_FP32(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_FP32(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_FP64(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_FP64(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_assign_FC32(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Vector_assign_FC32(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_assign_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GxB_Vector_assign_FC64(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Vector_assign_FC64(w, mask, accum, x, I_, ni, desc)
    ccall((:GxB_Vector_assign_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Vector_assign_UDT(w, mask, accum, x, I_, ni, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Vector_assign_UDT(w, mask, accum, x, I_, ni, desc)
    ccall((:GrB_Vector_assign_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I_, ni, desc)
end

"""
    GrB_Matrix_assign_BOOL(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_BOOL(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_INT8(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_INT8(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_INT16(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_INT16(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_INT32(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_INT32(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_INT64(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_INT64(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UINT8(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_UINT8(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UINT16(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_UINT16(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UINT32(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_UINT32(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UINT64(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_UINT64(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_FP32(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_FP32(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_FP64(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_FP64(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_assign_FC32(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Matrix_assign_FC32(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_assign_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GxB_Matrix_assign_FC64(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GxB_Matrix_assign_FC64(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GxB_Matrix_assign_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
end

"""
    GrB_Matrix_assign_UDT(C, Mask, accum, x, I_, ni, J, nj, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void *);
```
"""
function GrB_Matrix_assign_UDT(C, Mask, accum, x, I_, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I_, ni, J, nj, desc)
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
    GrB_Vector_apply_BinaryOp1st_BOOL(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_BOOL(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Bool, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_INT8(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_INT8(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int8, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_INT16(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_INT16(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int16, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_INT32(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_INT32(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int32, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_INT64(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_INT64(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int64, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UINT8(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_UINT8(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt8, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UINT16(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_UINT16(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt16, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UINT32(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_UINT32(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt32, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UINT64(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_UINT64(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt64, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_FP32(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_FP32(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Cfloat, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_FP64(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp1st_FP64(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Cdouble, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GxB_Vector_apply_BinaryOp1st_FC32(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Vector_apply_BinaryOp1st_FC32(w, mask, accum, op, x, u, desc)
    ccall((:GxB_Vector_apply_BinaryOp1st_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_FC32_t, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GxB_Vector_apply_BinaryOp1st_FC64(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Vector_apply_BinaryOp1st_FC64(w, mask, accum, op, x, u, desc)
    ccall((:GxB_Vector_apply_BinaryOp1st_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_FC64_t, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

"""
    GrB_Vector_apply_BinaryOp1st_UDT(w, mask, accum, op, x, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
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
    GrB_Vector_apply_BinaryOp2nd_BOOL(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_BOOL(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_INT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_INT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_INT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_INT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_INT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_INT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_INT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_INT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UINT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_UINT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UINT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_UINT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UINT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_UINT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UINT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_UINT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_FP32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_FP32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_FP64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_BinaryOp2nd_FP64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_apply_BinaryOp2nd_FC32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Vector_apply_BinaryOp2nd_FC32(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_BinaryOp2nd_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_apply_BinaryOp2nd_FC64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Vector_apply_BinaryOp2nd_FC64(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_BinaryOp2nd_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_BinaryOp2nd_UDT(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
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
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_BOOL(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_INT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_INT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_INT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_INT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_INT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_INT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_INT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_INT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UINT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_UINT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UINT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_UINT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UINT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_UINT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UINT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_UINT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_FP32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_FP32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_FP64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_apply_IndexOp_FP64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_apply_IndexOp_FC32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Vector_apply_IndexOp_FC32(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_IndexOp_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_apply_IndexOp_FC64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Vector_apply_IndexOp_FC64(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_IndexOp_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_apply_IndexOp_UDT(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
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
    GrB_Matrix_apply_BinaryOp1st_BOOL(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_BOOL(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Bool, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_INT8(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_INT8(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int8, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_INT16(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_INT16(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int16, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_INT32(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_INT32(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int32, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_INT64(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_INT64(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int64, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UINT8(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_UINT8(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt8, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UINT16(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_UINT16(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt16, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UINT32(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_UINT32(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt32, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UINT64(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_UINT64(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt64, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_FP32(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_FP32(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Cfloat, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_FP64(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp1st_FP64(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Cdouble, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GxB_Matrix_apply_BinaryOp1st_FC32(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Matrix_apply_BinaryOp1st_FC32(C, Mask, accum, op, x, A, desc)
    ccall((:GxB_Matrix_apply_BinaryOp1st_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_FC32_t, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GxB_Matrix_apply_BinaryOp1st_FC64(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Matrix_apply_BinaryOp1st_FC64(C, Mask, accum, op, x, A, desc)
    ccall((:GxB_Matrix_apply_BinaryOp1st_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_FC64_t, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

"""
    GrB_Matrix_apply_BinaryOp1st_UDT(C, Mask, accum, op, x, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
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
    GrB_Matrix_apply_BinaryOp2nd_BOOL(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_BOOL(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_INT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_INT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_INT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_INT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_INT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_INT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_INT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_INT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UINT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_UINT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UINT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_UINT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UINT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_UINT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UINT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_UINT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_FP32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_FP32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_FP64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_BinaryOp2nd_FP64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_apply_BinaryOp2nd_FC32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Matrix_apply_BinaryOp2nd_FC32(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_BinaryOp2nd_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_apply_BinaryOp2nd_FC64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Matrix_apply_BinaryOp2nd_FC64(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_BinaryOp2nd_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_BinaryOp2nd_UDT(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
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
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_BOOL(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_INT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_INT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_INT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_INT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_INT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_INT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_INT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_INT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UINT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_UINT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UINT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_UINT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UINT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_UINT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UINT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_UINT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_FP32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_FP32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_FP64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_FP64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_apply_IndexOp_FC32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Matrix_apply_IndexOp_FC32(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_IndexOp_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_apply_IndexOp_FC64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Matrix_apply_IndexOp_FC64(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_IndexOp_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_apply_IndexOp_UDT(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_apply_IndexOp_UDT(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Ptr{Cvoid}, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Vector_select_BOOL(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_BOOL(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_INT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_INT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_INT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_INT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_INT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_INT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_INT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_INT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UINT8(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_UINT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UINT16(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_UINT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UINT32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_UINT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UINT64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_UINT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_FP32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_FP32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_FP64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_FP64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_select_FC32(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Vector_select_FC32(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_select_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GxB_Vector_select_FC64(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Vector_select_FC64(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_select_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Vector_select_UDT(w, mask, accum, op, u, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Vector_select_UDT(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Ptr{Cvoid}, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

"""
    GrB_Matrix_select_BOOL(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_BOOL(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_INT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_INT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_INT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_INT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_INT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_INT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_INT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_INT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UINT8(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_UINT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UINT16(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_UINT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UINT32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_UINT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UINT64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_UINT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_FP32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_FP32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_FP64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_FP64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_select_FC32(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Matrix_select_FC32(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_select_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GxB_Matrix_select_FC64(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GxB_Matrix_select_FC64(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_select_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Matrix_select_UDT(C, Mask, accum, op, A, y, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, const void *);
```
"""
function GrB_Matrix_select_UDT(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Ptr{Cvoid}, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

"""
    GrB_Vector_reduce_Monoid_Scalar(c, accum, monoid, u, desc)

Reduce entries in a vector to a scalar, c = accum (c, reduce_to_scalar(u))
### Prototype
```c
GrB_Info GrB_Vector_reduce_Monoid_Scalar ( GrB_Scalar c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GrB_Vector_reduce_Monoid_Scalar(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_Monoid_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_BOOL(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_BOOL(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_INT8(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_INT8(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_INT16(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_INT16(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_INT32(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_INT32(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_INT64(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_INT64(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UINT8(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_UINT8(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UINT16(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_UINT16(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UINT32(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_UINT32(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UINT64(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_UINT64(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_FP32(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_FP32(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_FP64(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_FP64(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GxB_Vector_reduce_FC32(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Vector_reduce_FC32(c, accum, monoid, u, desc)
    ccall((:GxB_Vector_reduce_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GxB_Vector_reduce_FC64(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Vector_reduce_FC64(c, accum, monoid, u, desc)
    ccall((:GxB_Vector_reduce_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Vector_reduce_UDT(c, accum, monoid, u, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Vector_reduce_UDT(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

"""
    GrB_Matrix_reduce_Monoid_Scalar(c, accum, monoid, A, desc)

Reduce entries in a matrix to a scalar, c = accum (c, reduce_to_scalar(A))
### Prototype
```c
GrB_Info GrB_Matrix_reduce_Monoid_Scalar ( GrB_Scalar c, const GrB_BinaryOp accum, const GrB_Monoid monoid, const GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GrB_Matrix_reduce_Monoid_Scalar(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_Monoid_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_BOOL(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_BOOL(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_INT8(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_INT8(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_INT16(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_INT16(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_INT32(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_INT32(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_INT64(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_INT64(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UINT8(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_UINT8(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UINT16(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_UINT16(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UINT32(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_UINT32(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UINT64(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_UINT64(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_FP32(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_FP32(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_FP64(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_FP64(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GxB_Matrix_reduce_FC32(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_reduce_FC32(c, accum, monoid, A, desc)
    ccall((:GxB_Matrix_reduce_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GxB_Matrix_reduce_FC64(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_reduce_FC64(c, accum, monoid, A, desc)
    ccall((:GxB_Matrix_reduce_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Matrix_reduce_UDT(c, accum, monoid, A, desc)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_reduce_UDT(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

"""
    GrB_Vector_reduce_BinaryOp_Scalar(arg1, arg2, arg3, arg4, arg5)


### Prototype
```c
GrB_Info GrB_Vector_reduce_BinaryOp_Scalar (GrB_Scalar, const GrB_BinaryOp, const GrB_BinaryOp, const GrB_Vector, const GrB_Descriptor);
```
"""
function GrB_Vector_reduce_BinaryOp_Scalar(arg1, arg2, arg3, arg4, arg5)
    ccall((:GrB_Vector_reduce_BinaryOp_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5)
end

"""
    GrB_Matrix_reduce_BinaryOp_Scalar(arg1, arg2, arg3, arg4, arg5)


### Prototype
```c
GrB_Info GrB_Matrix_reduce_BinaryOp_Scalar (GrB_Scalar, const GrB_BinaryOp, const GrB_BinaryOp, const GrB_Matrix, const GrB_Descriptor);
```
"""
function GrB_Matrix_reduce_BinaryOp_Scalar(arg1, arg2, arg3, arg4, arg5)
    ccall((:GrB_Matrix_reduce_BinaryOp_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5)
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
    GxB_Container_new(Container)


### Prototype
```c
GrB_Info GxB_Container_new (GxB_Container *Container);
```
"""
function GxB_Container_new(Container)
    ccall((:GxB_Container_new, libgraphblas), GrB_Info, (Ptr{GxB_Container},), Container)
end

"""
    GxB_Container_new_arena(Container, header_arena, data_arena)


### Prototype
```c
GrB_Info GxB_Container_new_arena ( GxB_Container *Container, const int header_arena, const int data_arena );
```
"""
function GxB_Container_new_arena(Container, header_arena, data_arena)
    ccall((:GxB_Container_new_arena, libgraphblas), GrB_Info, (Ptr{GxB_Container}, Cint, Cint), Container, header_arena, data_arena)
end

"""
    GxB_load_Matrix_from_Container(A, Container, desc)


### Prototype
```c
GrB_Info GxB_load_Matrix_from_Container ( GrB_Matrix A, GxB_Container Container, const GrB_Descriptor desc );
```
"""
function GxB_load_Matrix_from_Container(A, Container, desc)
    ccall((:GxB_load_Matrix_from_Container, libgraphblas), GrB_Info, (GrB_Matrix, GxB_Container, GrB_Descriptor), A, Container, desc)
end

"""
    GxB_load_Vector_from_Container(V, Container, desc)


### Prototype
```c
GrB_Info GxB_load_Vector_from_Container ( GrB_Vector V, GxB_Container Container, const GrB_Descriptor desc );
```
"""
function GxB_load_Vector_from_Container(V, Container, desc)
    ccall((:GxB_load_Vector_from_Container, libgraphblas), GrB_Info, (GrB_Vector, GxB_Container, GrB_Descriptor), V, Container, desc)
end

"""
    GxB_unload_Matrix_into_Container(A, Container, desc)


### Prototype
```c
GrB_Info GxB_unload_Matrix_into_Container ( GrB_Matrix A, GxB_Container Container, const GrB_Descriptor desc );
```
"""
function GxB_unload_Matrix_into_Container(A, Container, desc)
    ccall((:GxB_unload_Matrix_into_Container, libgraphblas), GrB_Info, (GrB_Matrix, GxB_Container, GrB_Descriptor), A, Container, desc)
end

"""
    GxB_unload_Vector_into_Container(V, Container, desc)


### Prototype
```c
GrB_Info GxB_unload_Vector_into_Container ( GrB_Vector V, GxB_Container Container, const GrB_Descriptor desc );
```
"""
function GxB_unload_Vector_into_Container(V, Container, desc)
    ccall((:GxB_unload_Vector_into_Container, libgraphblas), GrB_Info, (GrB_Vector, GxB_Container, GrB_Descriptor), V, Container, desc)
end

"""
    GxB_Vector_load(V, X, type, n, X_memsize, handling, desc)


### Prototype
```c
GrB_Info GxB_Vector_load ( GrB_Vector V, void **X, GrB_Type type, uint64_t n, uint64_t X_memsize, int handling, const GrB_Descriptor desc );
```
"""
function GxB_Vector_load(V, X, type, n, X_memsize, handling, desc)
    ccall((:GxB_Vector_load, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Cvoid}}, GrB_Type, UInt64, UInt64, Cint, GrB_Descriptor), V, X, type, n, X_memsize, handling, desc)
end

"""
    GxB_Vector_unload(V, X, type, n, X_memsize, handling, desc)


### Prototype
```c
GrB_Info GxB_Vector_unload ( GrB_Vector V, void **X, GrB_Type *type, uint64_t *n, uint64_t *X_memsize, int *handling, const GrB_Descriptor desc );
```
"""
function GxB_Vector_unload(V, X, type, n, X_memsize, handling, desc)
    ccall((:GxB_Vector_unload, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Cvoid}}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Cint}, GrB_Descriptor), V, X, type, n, X_memsize, handling, desc)
end

"""
    GrB_Matrix_import_BOOL(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_BOOL(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_INT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_INT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_INT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_INT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_INT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_INT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_INT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_INT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UINT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_UINT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UINT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_UINT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UINT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_UINT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UINT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_UINT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_FP32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_FP32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_FP64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_FP64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GxB_Matrix_import_FC32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_import_FC32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GxB_Matrix_import_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GxB_Matrix_import_FC64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_import_FC64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GxB_Matrix_import_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_import_UDT(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_import_UDT(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_Index, GrB_Index, Cint), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

"""
    GrB_Matrix_export_BOOL(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_BOOL(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_INT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_INT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_INT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_INT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_INT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_INT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_INT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_INT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UINT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_UINT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UINT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_UINT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UINT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_UINT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UINT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_UINT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_FP32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_FP32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_FP64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_FP64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GxB_Matrix_export_FC32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_export_FC32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GxB_Matrix_export_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GxB_Matrix_export_FC64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GxB_Matrix_export_FC64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GxB_Matrix_export_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_export_UDT(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GB_DECLARE_14 (GrB_, void);
```
"""
function GrB_Matrix_export_UDT(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_exportSize(Ap_len, Ai_len, Ax_len, format, A)


### Prototype
```c
GrB_Info GrB_Matrix_exportSize ( GrB_Index *Ap_len, GrB_Index *Ai_len, GrB_Index *Ax_len, int format, GrB_Matrix A );
```
"""
function GrB_Matrix_exportSize(Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_exportSize, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Cint, GrB_Matrix), Ap_len, Ai_len, Ax_len, format, A)
end

"""
    GrB_Matrix_exportHint(format, A)


### Prototype
```c
GrB_Info GrB_Matrix_exportHint ( int *format, GrB_Matrix A );
```
"""
function GrB_Matrix_exportHint(format, A)
    ccall((:GrB_Matrix_exportHint, libgraphblas), GrB_Info, (Ptr{Cint}, GrB_Matrix), format, A)
end

"""
    GxB_Matrix_serialize(blob_handle, blob_size, A, desc)


### Prototype
```c
GrB_Info GxB_Matrix_serialize ( void **blob_handle, GrB_Index *blob_size, GrB_Matrix A, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_serialize(blob_handle, blob_size, A, desc)
    ccall((:GxB_Matrix_serialize, libgraphblas), GrB_Info, (Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, GrB_Matrix, GrB_Descriptor), blob_handle, blob_size, A, desc)
end

"""
    GxB_Matrix_serialize_arena(blob_handle, blob_size, A, data_arena, desc)


### Prototype
```c
GrB_Info GxB_Matrix_serialize_arena ( void **blob_handle, GrB_Index *blob_size, GrB_Matrix A, const int data_arena, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_serialize_arena(blob_handle, blob_size, A, data_arena, desc)
    ccall((:GxB_Matrix_serialize_arena, libgraphblas), GrB_Info, (Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, GrB_Matrix, Cint, GrB_Descriptor), blob_handle, blob_size, A, data_arena, desc)
end

"""
    GrB_Matrix_serialize(blob, blob_size, A)


### Prototype
```c
GrB_Info GrB_Matrix_serialize ( void *blob, GrB_Index *blob_size, GrB_Matrix A );
```
"""
function GrB_Matrix_serialize(blob, blob_size, A)
    ccall((:GrB_Matrix_serialize, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Matrix), blob, blob_size, A)
end

"""
    GxB_Vector_serialize(blob_handle, blob_size, u, desc)


### Prototype
```c
GrB_Info GxB_Vector_serialize ( void **blob_handle, GrB_Index *blob_size, GrB_Vector u, const GrB_Descriptor desc );
```
"""
function GxB_Vector_serialize(blob_handle, blob_size, u, desc)
    ccall((:GxB_Vector_serialize, libgraphblas), GrB_Info, (Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, GrB_Vector, GrB_Descriptor), blob_handle, blob_size, u, desc)
end

"""
    GxB_Vector_serialize_arena(blob_handle, blob_size, u, data_arena, desc)


### Prototype
```c
GrB_Info GxB_Vector_serialize_arena ( void **blob_handle, GrB_Index *blob_size, GrB_Vector u, const int data_arena, const GrB_Descriptor desc );
```
"""
function GxB_Vector_serialize_arena(blob_handle, blob_size, u, data_arena, desc)
    ccall((:GxB_Vector_serialize_arena, libgraphblas), GrB_Info, (Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, GrB_Vector, Cint, GrB_Descriptor), blob_handle, blob_size, u, data_arena, desc)
end

"""
    GrB_Matrix_serializeSize(blob_size, A)


### Prototype
```c
GrB_Info GrB_Matrix_serializeSize ( GrB_Index *blob_size, GrB_Matrix A );
```
"""
function GrB_Matrix_serializeSize(blob_size, A)
    ccall((:GrB_Matrix_serializeSize, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), blob_size, A)
end

"""
    GxB_Matrix_deserialize(C, type, blob, blob_size, desc)


### Prototype
```c
GrB_Info GxB_Matrix_deserialize ( GrB_Matrix *C, GrB_Type type, const void *blob, GrB_Index blob_size, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_deserialize(C, type, blob, blob_size, desc)
    ccall((:GxB_Matrix_deserialize, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Ptr{Cvoid}, GrB_Index, GrB_Descriptor), C, type, blob, blob_size, desc)
end

"""
    GxB_Matrix_deserialize_arena(C, type, blob, blob_memsize, header_arena, data_arena, desc)


### Prototype
```c
GrB_Info GxB_Matrix_deserialize_arena ( GrB_Matrix *C, GrB_Type type, const void *blob, uint64_t blob_memsize, const int header_arena, const int data_arena, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_deserialize_arena(C, type, blob, blob_memsize, header_arena, data_arena, desc)
    ccall((:GxB_Matrix_deserialize_arena, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Ptr{Cvoid}, UInt64, Cint, Cint, GrB_Descriptor), C, type, blob, blob_memsize, header_arena, data_arena, desc)
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
    GxB_Vector_deserialize_arena(w, type, blob, blob_size, header_arena, data_arena, desc)


### Prototype
```c
GrB_Info GxB_Vector_deserialize_arena ( GrB_Vector *w, GrB_Type type, const void *blob, GrB_Index blob_size, const int header_arena, const int data_arena, const GrB_Descriptor desc );
```
"""
function GxB_Vector_deserialize_arena(w, type, blob, blob_size, header_arena, data_arena, desc)
    ccall((:GxB_Vector_deserialize_arena, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, Ptr{Cvoid}, GrB_Index, Cint, Cint, GrB_Descriptor), w, type, blob, blob_size, header_arena, data_arena, desc)
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
    GxB_Matrix_reshapeDup_arena(C, A, by_col, nrows_new, ncols_new, header_arena, data_arena, desc)


### Prototype
```c
GrB_Info GxB_Matrix_reshapeDup_arena ( GrB_Matrix *C, GrB_Matrix A, bool by_col, uint64_t nrows_new, uint64_t ncols_new, const int header_arena, const int data_arena, const GrB_Descriptor desc );
```
"""
function GxB_Matrix_reshapeDup_arena(C, A, by_col, nrows_new, ncols_new, header_arena, data_arena, desc)
    ccall((:GxB_Matrix_reshapeDup_arena, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Matrix, Bool, UInt64, UInt64, Cint, Cint, GrB_Descriptor), C, A, by_col, nrows_new, ncols_new, header_arena, data_arena, desc)
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
    GxB_Iterator_new_arena(iterator, header_arena)


### Prototype
```c
GrB_Info GxB_Iterator_new_arena ( GxB_Iterator *iterator, const int header_arena );
```
"""
function GxB_Iterator_new_arena(iterator, header_arena)
    ccall((:GxB_Iterator_new_arena, libgraphblas), GrB_Info, (Ptr{GxB_Iterator}, Cint), iterator, header_arena)
end

"""
    GB_Iterator_attach(iterator, A, format, desc)

------------------------------------------------------------------------------
GB_Iterator_attach: attach a row/col/entry iterator to a matrix
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GB(Iterator_attach) ( GxB_Iterator iterator, GrB_Matrix A, int format, GrB_Descriptor desc );
```
"""
function GB_Iterator_attach(iterator, A, format, desc)
    ccall((:GB_Iterator_attach, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Matrix, Cint, GrB_Descriptor), iterator, A, format, desc)
end

"""
    GB_Iterator_rc_seek(iterator, j, jth_vector)

------------------------------------------------------------------------------
GB_Iterator_rc_seek: seek a row/col iterator to a particular vector
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GB(Iterator_rc_seek) ( GxB_Iterator iterator, GrB_Index j, bool jth_vector );
```
"""
function GB_Iterator_rc_seek(iterator, j, jth_vector)
    ccall((:GB_Iterator_rc_seek, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Index, Bool), iterator, j, jth_vector)
end

"""
    GB_Iterator_rc_bitmap_next(iterator)

------------------------------------------------------------------------------
GB_Iterator_rc_bitmap_next: move a row/col iterator to next entry in bitmap
------------------------------------------------------------------------------
### Prototype
```c
GrB_Info GB(Iterator_rc_bitmap_next)(GxB_Iterator iterator);
```
"""
function GB_Iterator_rc_bitmap_next(iterator)
    ccall((:GB_Iterator_rc_bitmap_next, libgraphblas), GrB_Info, (GxB_Iterator,), iterator)
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

"""
    GB_Vector_Iterator_bitmap_seek(iterator)

Returns GrB_SUCCESS if the iterator is at an entry that exists in the
vector, or GxB_EXHAUSTED if the iterator is exhausted.
### Prototype
```c
GrB_Info GB(Vector_Iterator_bitmap_seek)(GxB_Iterator iterator);
```
"""
function GB_Vector_Iterator_bitmap_seek(iterator)
    ccall((:GB_Vector_Iterator_bitmap_seek, libgraphblas), GrB_Info, (GxB_Iterator,), iterator)
end

"""
    GxB_atfork_prepare()

These methods are suitable for passing to pthread_atfork
(see https://man7.org/linux/man-pages/man3/pthread_atfork.3.html ), or for
non-POSIX systems such as Windows, they can be directly called.
### Prototype
```c
void GxB_atfork_prepare (void);
```
"""
function GxB_atfork_prepare()
    ccall((:GxB_atfork_prepare, libgraphblas), Cvoid, ())
end

"""
    GxB_atfork_parent()


### Prototype
```c
void GxB_atfork_parent (void);
```
"""
function GxB_atfork_parent()
    ccall((:GxB_atfork_parent, libgraphblas), Cvoid, ())
end

"""
    GxB_atfork_child()


### Prototype
```c
void GxB_atfork_child (void);
```
"""
function GxB_atfork_child()
    ccall((:GxB_atfork_child, libgraphblas), Cvoid, ())
end

const GrB_Field = Cint

"""
    GrB_getVersion(arg1, arg2)

GrB_getVersion: use GrB_get instead
### Prototype
```c
GrB_Info GrB_getVersion (unsigned int *, unsigned int *);
```
"""
function GrB_getVersion(arg1, arg2)
    ccall((:GrB_getVersion, libgraphblas), GrB_Info, (Ptr{Cuint}, Ptr{Cuint}), arg1, arg2)
end

"""
    GxB_Matrix_iso(arg1, arg2)

GxB_*_iso: use GrB_get instead
### Prototype
```c
GrB_Info GxB_Matrix_iso (bool *, const GrB_Matrix);
```
"""
function GxB_Matrix_iso(arg1, arg2)
    ccall((:GxB_Matrix_iso, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Matrix), arg1, arg2)
end

"""
    GxB_Vector_iso(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Vector_iso (bool *, const GrB_Vector);
```
"""
function GxB_Vector_iso(arg1, arg2)
    ccall((:GxB_Vector_iso, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Vector), arg1, arg2)
end

"""
    GrB_Descriptor_set(arg1, arg2, arg3)

GxB_Desc*get/set and GrB_Descriptor_set: use GrB_get/set instead.
### Prototype
```c
GrB_Info GrB_Descriptor_set (GrB_Descriptor, int, int);
```
"""
function GrB_Descriptor_set(arg1, arg2, arg3)
    ccall((:GrB_Descriptor_set, libgraphblas), GrB_Info, (GrB_Descriptor, Cint, Cint), arg1, arg2, arg3)
end

"""
    GxB_Descriptor_get(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Descriptor_get (int32_t *, GrB_Descriptor, int);
```
"""
function GxB_Descriptor_get(arg1, arg2, arg3)
    ccall((:GxB_Descriptor_get, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Descriptor, Cint), arg1, arg2, arg3)
end

"""
    GxB_Desc_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Desc_set_INT32 (GrB_Descriptor, int, int32_t);
```
"""
function GxB_Desc_set_INT32(arg1, arg2, arg3)
    ccall((:GxB_Desc_set_INT32, libgraphblas), GrB_Info, (GrB_Descriptor, Cint, Int32), arg1, arg2, arg3)
end

"""
    GxB_Desc_set_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Desc_set_FP64 (GrB_Descriptor, int, double);
```
"""
function GxB_Desc_set_FP64(arg1, arg2, arg3)
    ccall((:GxB_Desc_set_FP64, libgraphblas), GrB_Info, (GrB_Descriptor, Cint, Cdouble), arg1, arg2, arg3)
end

"""
    GxB_Desc_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Desc_get_INT32 (GrB_Descriptor, int, int32_t *);
```
"""
function GxB_Desc_get_INT32(arg1, arg2, arg3)
    ccall((:GxB_Desc_get_INT32, libgraphblas), GrB_Info, (GrB_Descriptor, Cint, Ptr{Int32}), arg1, arg2, arg3)
end

"""
    GxB_Desc_get_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Desc_get_FP64 (GrB_Descriptor, int, double *);
```
"""
function GxB_Desc_get_FP64(arg1, arg2, arg3)
    ccall((:GxB_Desc_get_FP64, libgraphblas), GrB_Info, (GrB_Descriptor, Cint, Ptr{Cdouble}), arg1, arg2, arg3)
end

"""
    GxB_Type_name(arg1, arg2)

GxB_Type_* queries: use GrB_get instead
### Prototype
```c
GrB_Info GxB_Type_name (char *, const GrB_Type);
```
"""
function GxB_Type_name(arg1, arg2)
    ccall((:GxB_Type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Type), arg1, arg2)
end

"""
    GxB_Type_size(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Type_size (size_t *, const GrB_Type);
```
"""
function GxB_Type_size(arg1, arg2)
    ccall((:GxB_Type_size, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Type), arg1, arg2)
end

"""
    GxB_UnaryOp_ztype(arg1, arg2)

GxB_UnaryOp_* queries: use GrB_get_instead
### Prototype
```c
GrB_Info GxB_UnaryOp_ztype (GrB_Type *, GrB_UnaryOp);
```
"""
function GxB_UnaryOp_ztype(arg1, arg2)
    ccall((:GxB_UnaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), arg1, arg2)
end

"""
    GxB_UnaryOp_ztype_name(arg1, arg2)


### Prototype
```c
GrB_Info GxB_UnaryOp_ztype_name (char *, const GrB_UnaryOp);
```
"""
function GxB_UnaryOp_ztype_name(arg1, arg2)
    ccall((:GxB_UnaryOp_ztype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_UnaryOp), arg1, arg2)
end

"""
    GxB_UnaryOp_xtype(arg1, arg2)


### Prototype
```c
GrB_Info GxB_UnaryOp_xtype (GrB_Type *, GrB_UnaryOp);
```
"""
function GxB_UnaryOp_xtype(arg1, arg2)
    ccall((:GxB_UnaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), arg1, arg2)
end

"""
    GxB_UnaryOp_xtype_name(arg1, arg2)


### Prototype
```c
GrB_Info GxB_UnaryOp_xtype_name (char *, const GrB_UnaryOp);
```
"""
function GxB_UnaryOp_xtype_name(arg1, arg2)
    ccall((:GxB_UnaryOp_xtype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_UnaryOp), arg1, arg2)
end

"""
    GxB_BinaryOp_ztype(arg1, arg2)

GxB_BinaryOp_* queries: use GrB_get_instead
### Prototype
```c
GrB_Info GxB_BinaryOp_ztype (GrB_Type *, GrB_BinaryOp);
```
"""
function GxB_BinaryOp_ztype(arg1, arg2)
    ccall((:GxB_BinaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), arg1, arg2)
end

"""
    GxB_BinaryOp_ztype_name(arg1, arg2)


### Prototype
```c
GrB_Info GxB_BinaryOp_ztype_name (char *, const GrB_BinaryOp);
```
"""
function GxB_BinaryOp_ztype_name(arg1, arg2)
    ccall((:GxB_BinaryOp_ztype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_BinaryOp), arg1, arg2)
end

"""
    GxB_BinaryOp_xtype(arg1, arg2)


### Prototype
```c
GrB_Info GxB_BinaryOp_xtype (GrB_Type *, GrB_BinaryOp);
```
"""
function GxB_BinaryOp_xtype(arg1, arg2)
    ccall((:GxB_BinaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), arg1, arg2)
end

"""
    GxB_BinaryOp_xtype_name(arg1, arg2)


### Prototype
```c
GrB_Info GxB_BinaryOp_xtype_name (char *, const GrB_BinaryOp);
```
"""
function GxB_BinaryOp_xtype_name(arg1, arg2)
    ccall((:GxB_BinaryOp_xtype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_BinaryOp), arg1, arg2)
end

"""
    GxB_BinaryOp_ytype(arg1, arg2)


### Prototype
```c
GrB_Info GxB_BinaryOp_ytype (GrB_Type *, GrB_BinaryOp);
```
"""
function GxB_BinaryOp_ytype(arg1, arg2)
    ccall((:GxB_BinaryOp_ytype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), arg1, arg2)
end

"""
    GxB_BinaryOp_ytype_name(arg1, arg2)


### Prototype
```c
GrB_Info GxB_BinaryOp_ytype_name (char *, const GrB_BinaryOp);
```
"""
function GxB_BinaryOp_ytype_name(arg1, arg2)
    ccall((:GxB_BinaryOp_ytype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_BinaryOp), arg1, arg2)
end

"""
    GxB_IndexUnaryOp_ztype_name(arg1, arg2)

GxB_IndexUnaryOp_* queries: use GrB_get instead
### Prototype
```c
GrB_Info GxB_IndexUnaryOp_ztype_name (char *, const GrB_IndexUnaryOp);
```
"""
function GxB_IndexUnaryOp_ztype_name(arg1, arg2)
    ccall((:GxB_IndexUnaryOp_ztype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_IndexUnaryOp), arg1, arg2)
end

"""
    GxB_IndexUnaryOp_xtype_name(arg1, arg2)


### Prototype
```c
GrB_Info GxB_IndexUnaryOp_xtype_name (char *, const GrB_IndexUnaryOp);
```
"""
function GxB_IndexUnaryOp_xtype_name(arg1, arg2)
    ccall((:GxB_IndexUnaryOp_xtype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_IndexUnaryOp), arg1, arg2)
end

"""
    GxB_IndexUnaryOp_ytype_name(arg1, arg2)


### Prototype
```c
GrB_Info GxB_IndexUnaryOp_ytype_name (char *, const GrB_IndexUnaryOp);
```
"""
function GxB_IndexUnaryOp_ytype_name(arg1, arg2)
    ccall((:GxB_IndexUnaryOp_ytype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_IndexUnaryOp), arg1, arg2)
end

"""
    GxB_Monoid_operator(arg1, arg2)

GxB_Monoid_* queries: use GrB_get instead
### Prototype
```c
GrB_Info GxB_Monoid_operator (GrB_BinaryOp *, GrB_Monoid);
```
"""
function GxB_Monoid_operator(arg1, arg2)
    ccall((:GxB_Monoid_operator, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GrB_Monoid), arg1, arg2)
end

"""
    GxB_Monoid_identity(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Monoid_identity (void *, GrB_Monoid);
```
"""
function GxB_Monoid_identity(arg1, arg2)
    ccall((:GxB_Monoid_identity, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Monoid), arg1, arg2)
end

"""
    GxB_Monoid_terminal(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Monoid_terminal (bool *, void *, GrB_Monoid);
```
"""
function GxB_Monoid_terminal(arg1, arg2, arg3)
    ccall((:GxB_Monoid_terminal, libgraphblas), GrB_Info, (Ptr{Bool}, Ptr{Cvoid}, GrB_Monoid), arg1, arg2, arg3)
end

"""
    GxB_Semiring_add(arg1, arg2)

GxB_Semiring_* queries: use GrB_get instead
### Prototype
```c
GrB_Info GxB_Semiring_add (GrB_Monoid *, GrB_Semiring);
```
"""
function GxB_Semiring_add(arg1, arg2)
    ccall((:GxB_Semiring_add, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_Semiring), arg1, arg2)
end

"""
    GxB_Semiring_multiply(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Semiring_multiply (GrB_BinaryOp *, GrB_Semiring);
```
"""
function GxB_Semiring_multiply(arg1, arg2)
    ccall((:GxB_Semiring_multiply, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GrB_Semiring), arg1, arg2)
end

"""
    GxB_Scalar_type_name(arg1, arg2)

GxB_Scalar_* queries: use GrB_get instead
### Prototype
```c
GrB_Info GxB_Scalar_type_name (char *, const GrB_Scalar);
```
"""
function GxB_Scalar_type_name(arg1, arg2)
    ccall((:GxB_Scalar_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_new(arg1, arg2)

GxB_Scalar_* methods: use GrB_Scalar_* instead (as-is)
### Prototype
```c
GrB_Info GxB_Scalar_new (GrB_Scalar *, GrB_Type);
```
"""
function GxB_Scalar_new(arg1, arg2)
    ccall((:GxB_Scalar_new, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Type), arg1, arg2)
end

"""
    GxB_Scalar_dup(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_dup (GrB_Scalar *, const GrB_Scalar);
```
"""
function GxB_Scalar_dup(arg1, arg2)
    ccall((:GxB_Scalar_dup, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_clear(arg1)


### Prototype
```c
GrB_Info GxB_Scalar_clear (GrB_Scalar );
```
"""
function GxB_Scalar_clear(arg1)
    ccall((:GxB_Scalar_clear, libgraphblas), GrB_Info, (GrB_Scalar,), arg1)
end

"""
    GxB_Scalar_nvals(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_nvals (uint64_t *, const GrB_Scalar);
```
"""
function GxB_Scalar_nvals(arg1, arg2)
    ccall((:GxB_Scalar_nvals, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_free(arg1)


### Prototype
```c
GrB_Info GxB_Scalar_free (GrB_Scalar *);
```
"""
function GxB_Scalar_free(arg1)
    ccall((:GxB_Scalar_free, libgraphblas), GrB_Info, (Ptr{GrB_Scalar},), arg1)
end

"""
    GxB_Scalar_setElement_BOOL(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_BOOL (GrB_Scalar, bool);
```
"""
function GxB_Scalar_setElement_BOOL(arg1, arg2)
    ccall((:GxB_Scalar_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Scalar, Bool), arg1, arg2)
end

"""
    GxB_Scalar_setElement_INT8(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_INT8 (GrB_Scalar, int8_t);
```
"""
function GxB_Scalar_setElement_INT8(arg1, arg2)
    ccall((:GxB_Scalar_setElement_INT8, libgraphblas), GrB_Info, (GrB_Scalar, Int8), arg1, arg2)
end

"""
    GxB_Scalar_setElement_INT16(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_INT16 (GrB_Scalar, int16_t);
```
"""
function GxB_Scalar_setElement_INT16(arg1, arg2)
    ccall((:GxB_Scalar_setElement_INT16, libgraphblas), GrB_Info, (GrB_Scalar, Int16), arg1, arg2)
end

"""
    GxB_Scalar_setElement_INT32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_INT32 (GrB_Scalar, int32_t);
```
"""
function GxB_Scalar_setElement_INT32(arg1, arg2)
    ccall((:GxB_Scalar_setElement_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Int32), arg1, arg2)
end

"""
    GxB_Scalar_setElement_INT64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_INT64 (GrB_Scalar, int64_t);
```
"""
function GxB_Scalar_setElement_INT64(arg1, arg2)
    ccall((:GxB_Scalar_setElement_INT64, libgraphblas), GrB_Info, (GrB_Scalar, Int64), arg1, arg2)
end

"""
    GxB_Scalar_setElement_UINT8(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UINT8 (GrB_Scalar, uint8_t);
```
"""
function GxB_Scalar_setElement_UINT8(arg1, arg2)
    ccall((:GxB_Scalar_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Scalar, UInt8), arg1, arg2)
end

"""
    GxB_Scalar_setElement_UINT16(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UINT16 (GrB_Scalar, uint16_t);
```
"""
function GxB_Scalar_setElement_UINT16(arg1, arg2)
    ccall((:GxB_Scalar_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Scalar, UInt16), arg1, arg2)
end

"""
    GxB_Scalar_setElement_UINT32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UINT32 (GrB_Scalar, uint32_t);
```
"""
function GxB_Scalar_setElement_UINT32(arg1, arg2)
    ccall((:GxB_Scalar_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Scalar, UInt32), arg1, arg2)
end

"""
    GxB_Scalar_setElement_UINT64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UINT64 (GrB_Scalar, uint64_t);
```
"""
function GxB_Scalar_setElement_UINT64(arg1, arg2)
    ccall((:GxB_Scalar_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Scalar, UInt64), arg1, arg2)
end

"""
    GxB_Scalar_setElement_FP32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_FP32 (GrB_Scalar, float);
```
"""
function GxB_Scalar_setElement_FP32(arg1, arg2)
    ccall((:GxB_Scalar_setElement_FP32, libgraphblas), GrB_Info, (GrB_Scalar, Cfloat), arg1, arg2)
end

"""
    GxB_Scalar_setElement_FP64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_FP64 (GrB_Scalar, double);
```
"""
function GxB_Scalar_setElement_FP64(arg1, arg2)
    ccall((:GxB_Scalar_setElement_FP64, libgraphblas), GrB_Info, (GrB_Scalar, Cdouble), arg1, arg2)
end

"""
    GxB_Scalar_setElement_UDT(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_setElement_UDT (GrB_Scalar, void *);
```
"""
function GxB_Scalar_setElement_UDT(arg1, arg2)
    ccall((:GxB_Scalar_setElement_UDT, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_BOOL(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_BOOL (bool *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_BOOL(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_INT8(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_INT8 (int8_t *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_INT8(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_INT16(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_INT16 (int16_t *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_INT16(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_INT32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_INT32 (int32_t *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_INT32(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_INT64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_INT64 (int64_t *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_INT64(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_UINT8(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UINT8 (uint8_t *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_UINT8(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_UINT16(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UINT16 (uint16_t *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_UINT16(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_UINT32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UINT32 (uint32_t *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_UINT32(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_UINT64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UINT64 (uint64_t *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_UINT64(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_FP32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_FP32 (float *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_FP32(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_FP64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_FP64 (double *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_FP64(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_extractElement_UDT(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_extractElement_UDT (void *, const GrB_Scalar);
```
"""
function GxB_Scalar_extractElement_UDT(arg1, arg2)
    ccall((:GxB_Scalar_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Scalar_wait(arg1)


### Prototype
```c
GrB_Info GxB_Scalar_wait (GrB_Scalar *);
```
"""
function GxB_Scalar_wait(arg1)
    ccall((:GxB_Scalar_wait, libgraphblas), GrB_Info, (Ptr{GrB_Scalar},), arg1)
end

"""
    GxB_Scalar_error(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Scalar_error (const char **, const GrB_Scalar);
```
"""
function GxB_Scalar_error(arg1, arg2)
    ccall((:GxB_Scalar_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Scalar), arg1, arg2)
end

"""
    GxB_Vector_type_name(arg1, arg2)

GxB_Vector_* queries: use GrB_get instead
### Prototype
```c
GrB_Info GxB_Vector_type_name (char *, const GrB_Vector);
```
"""
function GxB_Vector_type_name(arg1, arg2)
    ccall((:GxB_Vector_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Vector), arg1, arg2)
end

"""
    GxB_Matrix_type_name(arg1, arg2)

GxB_Matrix_* queries: use GrB_get instead
### Prototype
```c
GrB_Info GxB_Matrix_type_name (char *, const GrB_Matrix);
```
"""
function GxB_Matrix_type_name(arg1, arg2)
    ccall((:GxB_Matrix_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Matrix), arg1, arg2)
end

"""
    GxB_Matrix_Option_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Matrix_Option_set_INT32 (GrB_Matrix, int, int32_t);
```
"""
function GxB_Matrix_Option_set_INT32(arg1, arg2, arg3)
    ccall((:GxB_Matrix_Option_set_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Cint, Int32), arg1, arg2, arg3)
end

"""
    GxB_Matrix_Option_set_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Matrix_Option_set_FP64 (GrB_Matrix, int, double);
```
"""
function GxB_Matrix_Option_set_FP64(arg1, arg2, arg3)
    ccall((:GxB_Matrix_Option_set_FP64, libgraphblas), GrB_Info, (GrB_Matrix, Cint, Cdouble), arg1, arg2, arg3)
end

"""
    GxB_Matrix_Option_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Matrix_Option_get_INT32 (GrB_Matrix, int, int32_t *);
```
"""
function GxB_Matrix_Option_get_INT32(arg1, arg2, arg3)
    ccall((:GxB_Matrix_Option_get_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Cint, Ptr{Int32}), arg1, arg2, arg3)
end

"""
    GxB_Matrix_Option_get_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Matrix_Option_get_FP64 (GrB_Matrix, int, double *);
```
"""
function GxB_Matrix_Option_get_FP64(arg1, arg2, arg3)
    ccall((:GxB_Matrix_Option_get_FP64, libgraphblas), GrB_Info, (GrB_Matrix, Cint, Ptr{Cdouble}), arg1, arg2, arg3)
end

"""
    GxB_Vector_Option_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Vector_Option_set_INT32 (GrB_Vector, int, int32_t);
```
"""
function GxB_Vector_Option_set_INT32(arg1, arg2, arg3)
    ccall((:GxB_Vector_Option_set_INT32, libgraphblas), GrB_Info, (GrB_Vector, Cint, Int32), arg1, arg2, arg3)
end

"""
    GxB_Vector_Option_set_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Vector_Option_set_FP64 (GrB_Vector, int, double);
```
"""
function GxB_Vector_Option_set_FP64(arg1, arg2, arg3)
    ccall((:GxB_Vector_Option_set_FP64, libgraphblas), GrB_Info, (GrB_Vector, Cint, Cdouble), arg1, arg2, arg3)
end

"""
    GxB_Vector_Option_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Vector_Option_get_INT32 (GrB_Vector, int, int32_t *);
```
"""
function GxB_Vector_Option_get_INT32(arg1, arg2, arg3)
    ccall((:GxB_Vector_Option_get_INT32, libgraphblas), GrB_Info, (GrB_Vector, Cint, Ptr{Int32}), arg1, arg2, arg3)
end

"""
    GxB_Vector_Option_get_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Vector_Option_get_FP64 (GrB_Vector, int, double *);
```
"""
function GxB_Vector_Option_get_FP64(arg1, arg2, arg3)
    ccall((:GxB_Vector_Option_get_FP64, libgraphblas), GrB_Info, (GrB_Vector, Cint, Ptr{Cdouble}), arg1, arg2, arg3)
end

"""
    GxB_Global_Option_set_INT32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_INT32 (int, int32_t);
```
"""
function GxB_Global_Option_set_INT32(arg1, arg2)
    ccall((:GxB_Global_Option_set_INT32, libgraphblas), GrB_Info, (Cint, Int32), arg1, arg2)
end

"""
    GxB_Global_Option_set_FP64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_FP64 (int, double);
```
"""
function GxB_Global_Option_set_FP64(arg1, arg2)
    ccall((:GxB_Global_Option_set_FP64, libgraphblas), GrB_Info, (Cint, Cdouble), arg1, arg2)
end

"""
    GxB_Global_Option_set_FP64_ARRAY(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_FP64_ARRAY (int, double *);
```
"""
function GxB_Global_Option_set_FP64_ARRAY(arg1, arg2)
    ccall((:GxB_Global_Option_set_FP64_ARRAY, libgraphblas), GrB_Info, (Cint, Ptr{Cdouble}), arg1, arg2)
end

"""
    GxB_Global_Option_set_INT64_ARRAY(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_INT64_ARRAY (int, int64_t *);
```
"""
function GxB_Global_Option_set_INT64_ARRAY(arg1, arg2)
    ccall((:GxB_Global_Option_set_INT64_ARRAY, libgraphblas), GrB_Info, (Cint, Ptr{Int64}), arg1, arg2)
end

"""
    GxB_Global_Option_set_CHAR(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_CHAR (int, const char *);
```
"""
function GxB_Global_Option_set_CHAR(arg1, arg2)
    ccall((:GxB_Global_Option_set_CHAR, libgraphblas), GrB_Info, (Cint, Ptr{Cchar}), arg1, arg2)
end

"""
    GxB_Global_Option_set_FUNCTION(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_set_FUNCTION (int, void *);
```
"""
function GxB_Global_Option_set_FUNCTION(arg1, arg2)
    ccall((:GxB_Global_Option_set_FUNCTION, libgraphblas), GrB_Info, (Cint, Ptr{Cvoid}), arg1, arg2)
end

"""
    GxB_Global_Option_get_INT32(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_INT32 (int, int32_t *);
```
"""
function GxB_Global_Option_get_INT32(arg1, arg2)
    ccall((:GxB_Global_Option_get_INT32, libgraphblas), GrB_Info, (Cint, Ptr{Int32}), arg1, arg2)
end

"""
    GxB_Global_Option_get_FP64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_FP64 (int, double *);
```
"""
function GxB_Global_Option_get_FP64(arg1, arg2)
    ccall((:GxB_Global_Option_get_FP64, libgraphblas), GrB_Info, (Cint, Ptr{Cdouble}), arg1, arg2)
end

"""
    GxB_Global_Option_get_INT64(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_INT64 (int, int64_t *);
```
"""
function GxB_Global_Option_get_INT64(arg1, arg2)
    ccall((:GxB_Global_Option_get_INT64, libgraphblas), GrB_Info, (Cint, Ptr{Int64}), arg1, arg2)
end

"""
    GxB_Global_Option_get_CHAR(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_CHAR (int, const char **);
```
"""
function GxB_Global_Option_get_CHAR(arg1, arg2)
    ccall((:GxB_Global_Option_get_CHAR, libgraphblas), GrB_Info, (Cint, Ptr{Ptr{Cchar}}), arg1, arg2)
end

"""
    GxB_Global_Option_get_FUNCTION(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Global_Option_get_FUNCTION (int, void **);
```
"""
function GxB_Global_Option_get_FUNCTION(arg1, arg2)
    ccall((:GxB_Global_Option_get_FUNCTION, libgraphblas), GrB_Info, (Cint, Ptr{Ptr{Cvoid}}), arg1, arg2)
end

"""
    GxB_Context_set_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_set_INT32 (GxB_Context, int, int32_t);
```
"""
function GxB_Context_set_INT32(arg1, arg2, arg3)
    ccall((:GxB_Context_set_INT32, libgraphblas), GrB_Info, (GxB_Context, Cint, Int32), arg1, arg2, arg3)
end

"""
    GxB_Context_set_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_set_FP64 (GxB_Context, int, double);
```
"""
function GxB_Context_set_FP64(arg1, arg2, arg3)
    ccall((:GxB_Context_set_FP64, libgraphblas), GrB_Info, (GxB_Context, Cint, Cdouble), arg1, arg2, arg3)
end

"""
    GxB_Context_get_INT32(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_INT32 (GxB_Context, int, int32_t *);
```
"""
function GxB_Context_get_INT32(arg1, arg2, arg3)
    ccall((:GxB_Context_get_INT32, libgraphblas), GrB_Info, (GxB_Context, Cint, Ptr{Int32}), arg1, arg2, arg3)
end

"""
    GxB_Context_get_FP64(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_Context_get_FP64 (GxB_Context, int, double *);
```
"""
function GxB_Context_get_FP64(arg1, arg2, arg3)
    ccall((:GxB_Context_get_FP64, libgraphblas), GrB_Info, (GxB_Context, Cint, Ptr{Cdouble}), arg1, arg2, arg3)
end

"""
    GxB_Vector_apply_BinaryOp1st(arg1, arg2, arg3, arg4, arg5, arg6, arg7)

GxB_*_apply_BinaryOp*: GrB_*_apply_BinaryOp*_Scalar instead (as-is)
### Prototype
```c
GrB_Info GxB_Vector_apply_BinaryOp1st (GrB_Vector, const GrB_Vector, const GrB_BinaryOp, const GrB_BinaryOp, const GrB_Scalar, const GrB_Vector, const GrB_Descriptor);
```
"""
function GxB_Vector_apply_BinaryOp1st(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:GxB_Vector_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Vector, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

"""
    GxB_Vector_apply_BinaryOp2nd(arg1, arg2, arg3, arg4, arg5, arg6, arg7)


### Prototype
```c
GrB_Info GxB_Vector_apply_BinaryOp2nd (GrB_Vector, const GrB_Vector, const GrB_BinaryOp, const GrB_BinaryOp, const GrB_Vector, const GrB_Scalar, const GrB_Descriptor);
```
"""
function GxB_Vector_apply_BinaryOp2nd(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:GxB_Vector_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

"""
    GxB_Matrix_apply_BinaryOp1st(arg1, arg2, arg3, arg4, arg5, arg6, arg7)


### Prototype
```c
GrB_Info GxB_Matrix_apply_BinaryOp1st (GrB_Matrix, const GrB_Matrix, const GrB_BinaryOp, const GrB_BinaryOp, const GrB_Scalar, const GrB_Matrix, const GrB_Descriptor);
```
"""
function GxB_Matrix_apply_BinaryOp1st(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:GxB_Matrix_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Matrix, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

"""
    GxB_Matrix_apply_BinaryOp2nd(arg1, arg2, arg3, arg4, arg5, arg6, arg7)


### Prototype
```c
GrB_Info GxB_Matrix_apply_BinaryOp2nd (GrB_Matrix, const GrB_Matrix, const GrB_BinaryOp, const GrB_BinaryOp, const GrB_Matrix, const GrB_Scalar, const GrB_Descriptor);
```
"""
function GxB_Matrix_apply_BinaryOp2nd(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:GxB_Matrix_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

"""
    GxB_kron(arg1, arg2, arg3, arg4, arg5, arg6, arg7)

GxB_kron: use GrB_Matrix_kronecker_BinaryOp instead (as-is)
### Prototype
```c
GrB_Info GxB_kron (GrB_Matrix, const GrB_Matrix, const GrB_BinaryOp, const GrB_BinaryOp, const GrB_Matrix, const GrB_Matrix, const GrB_Descriptor);
```
"""
function GxB_kron(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:GxB_kron, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

"""
    GxB_Matrix_resize(arg1, arg2, arg3)

GxB_*_resize: use GrB_*_resize instead (as-is)
### Prototype
```c
GrB_Info GxB_Matrix_resize (GrB_Matrix, uint64_t, uint64_t);
```
"""
function GxB_Matrix_resize(arg1, arg2, arg3)
    ccall((:GxB_Matrix_resize, libgraphblas), GrB_Info, (GrB_Matrix, UInt64, UInt64), arg1, arg2, arg3)
end

"""
    GxB_Vector_resize(arg1, arg2)


### Prototype
```c
GrB_Info GxB_Vector_resize (GrB_Vector, uint64_t);
```
"""
function GxB_Vector_resize(arg1, arg2)
    ccall((:GxB_Vector_resize, libgraphblas), GrB_Info, (GrB_Vector, UInt64), arg1, arg2)
end

"""
    GxB_Matrix_import_CSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)

GxB_*_import/export_[FORMAT]: use Container methods instead
### Prototype
```c
GrB_Info GxB_Matrix_import_CSR (GrB_Matrix *, GrB_Type, uint64_t, uint64_t, uint64_t **, uint64_t **, void **, uint64_t, uint64_t, uint64_t, bool, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_import_CSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
    ccall((:GxB_Matrix_import_CSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, UInt64, UInt64, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, UInt64, Bool, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
end

"""
    GxB_Matrix_import_BitmapR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)


### Prototype
```c
GrB_Info GxB_Matrix_import_BitmapR (GrB_Matrix *, GrB_Type, uint64_t, uint64_t, int8_t **, void **, uint64_t, uint64_t, bool, uint64_t, const GrB_Descriptor);
```
"""
function GxB_Matrix_import_BitmapR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    ccall((:GxB_Matrix_import_BitmapR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, UInt64, UInt64, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, Bool, UInt64, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
end

"""
    GxB_Matrix_import_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)


### Prototype
```c
GrB_Info GxB_Matrix_import_CSC (GrB_Matrix *, GrB_Type, uint64_t, uint64_t, uint64_t **, uint64_t **, void **, uint64_t, uint64_t, uint64_t, bool, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_import_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
    ccall((:GxB_Matrix_import_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, UInt64, UInt64, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, UInt64, Bool, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
end

"""
    GxB_Matrix_import_HyperCSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)


### Prototype
```c
GrB_Info GxB_Matrix_import_HyperCSR (GrB_Matrix *, GrB_Type, uint64_t, uint64_t, uint64_t **, uint64_t **, uint64_t **, void **, uint64_t, uint64_t, uint64_t, uint64_t, bool, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_import_HyperCSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)
    ccall((:GxB_Matrix_import_HyperCSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, UInt64, UInt64, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, UInt64, UInt64, Bool, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)
end

"""
    GxB_Matrix_import_HyperCSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)


### Prototype
```c
GrB_Info GxB_Matrix_import_HyperCSC (GrB_Matrix *, GrB_Type, uint64_t, uint64_t, uint64_t **, uint64_t **, uint64_t **, void **, uint64_t, uint64_t, uint64_t, uint64_t, bool, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_import_HyperCSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)
    ccall((:GxB_Matrix_import_HyperCSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, UInt64, UInt64, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, UInt64, UInt64, Bool, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)
end

"""
    GxB_Matrix_import_BitmapC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)


### Prototype
```c
GrB_Info GxB_Matrix_import_BitmapC (GrB_Matrix *, GrB_Type, uint64_t, uint64_t, int8_t **, void **, uint64_t, uint64_t, bool, uint64_t, const GrB_Descriptor);
```
"""
function GxB_Matrix_import_BitmapC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    ccall((:GxB_Matrix_import_BitmapC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, UInt64, UInt64, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, Bool, UInt64, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
end

"""
    GxB_Matrix_import_FullR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Matrix_import_FullR (GrB_Matrix *, GrB_Type, uint64_t, uint64_t, void **, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_import_FullR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Matrix_import_FullR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, UInt64, UInt64, Ptr{Ptr{Cvoid}}, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Matrix_import_FullC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Matrix_import_FullC (GrB_Matrix *, GrB_Type, uint64_t, uint64_t, void **, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_import_FullC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Matrix_import_FullC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, UInt64, UInt64, Ptr{Ptr{Cvoid}}, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Vector_import_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)


### Prototype
```c
GrB_Info GxB_Vector_import_CSC (GrB_Vector *, GrB_Type, uint64_t, uint64_t **, void **, uint64_t, uint64_t, bool, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Vector_import_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    ccall((:GxB_Vector_import_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, UInt64, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, Bool, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
end

"""
    GxB_Vector_import_Bitmap(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)


### Prototype
```c
GrB_Info GxB_Vector_import_Bitmap (GrB_Vector *, GrB_Type, uint64_t, int8_t **, void **, uint64_t, uint64_t, bool, uint64_t, const GrB_Descriptor);
```
"""
function GxB_Vector_import_Bitmap(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    ccall((:GxB_Vector_import_Bitmap, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, UInt64, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, Bool, UInt64, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end

"""
    GxB_Vector_import_Full(arg1, arg2, arg3, arg4, arg5, arg6, arg7)


### Prototype
```c
GrB_Info GxB_Vector_import_Full (GrB_Vector *, GrB_Type, uint64_t, void **, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Vector_import_Full(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:GxB_Vector_import_Full, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, UInt64, Ptr{Ptr{Cvoid}}, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

"""
    GxB_Matrix_export_CSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)


### Prototype
```c
GrB_Info GxB_Matrix_export_CSR (GrB_Matrix *, GrB_Type *, uint64_t *, uint64_t *, uint64_t **, uint64_t **, void **, uint64_t *, uint64_t *, uint64_t *, bool *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_export_CSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
    ccall((:GxB_Matrix_export_CSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
end

"""
    GxB_Matrix_export_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)


### Prototype
```c
GrB_Info GxB_Matrix_export_CSC (GrB_Matrix *, GrB_Type *, uint64_t *, uint64_t *, uint64_t **, uint64_t **, void **, uint64_t *, uint64_t *, uint64_t *, bool *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_export_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
    ccall((:GxB_Matrix_export_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
end

"""
    GxB_Matrix_export_HyperCSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)


### Prototype
```c
GrB_Info GxB_Matrix_export_HyperCSR (GrB_Matrix *, GrB_Type *, uint64_t *, uint64_t *, uint64_t **, uint64_t **, uint64_t **, void **, uint64_t *, uint64_t *, uint64_t *, uint64_t *, bool *, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_export_HyperCSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)
    ccall((:GxB_Matrix_export_HyperCSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)
end

"""
    GxB_Matrix_export_HyperCSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)


### Prototype
```c
GrB_Info GxB_Matrix_export_HyperCSC (GrB_Matrix *, GrB_Type *, uint64_t *, uint64_t *, uint64_t **, uint64_t **, uint64_t **, void **, uint64_t *, uint64_t *, uint64_t *, uint64_t *, bool *, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_export_HyperCSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)
    ccall((:GxB_Matrix_export_HyperCSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16)
end

"""
    GxB_Matrix_export_BitmapR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)


### Prototype
```c
GrB_Info GxB_Matrix_export_BitmapR (GrB_Matrix *, GrB_Type *, uint64_t *, uint64_t *, int8_t **, void **, uint64_t *, uint64_t *, bool *, uint64_t *, const GrB_Descriptor);
```
"""
function GxB_Matrix_export_BitmapR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    ccall((:GxB_Matrix_export_BitmapR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
end

"""
    GxB_Matrix_export_BitmapC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)


### Prototype
```c
GrB_Info GxB_Matrix_export_BitmapC (GrB_Matrix *, GrB_Type *, uint64_t *, uint64_t *, int8_t **, void **, uint64_t *, uint64_t *, bool *, uint64_t *, const GrB_Descriptor);
```
"""
function GxB_Matrix_export_BitmapC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    ccall((:GxB_Matrix_export_BitmapC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
end

"""
    GxB_Matrix_export_FullR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Matrix_export_FullR (GrB_Matrix *, GrB_Type *, uint64_t *, uint64_t *, void **, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_export_FullR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Matrix_export_FullR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Matrix_export_FullC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Matrix_export_FullC (GrB_Matrix *, GrB_Type *, uint64_t *, uint64_t *, void **, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_export_FullC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Matrix_export_FullC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Vector_export_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)


### Prototype
```c
GrB_Info GxB_Vector_export_CSC (GrB_Vector *, GrB_Type *, uint64_t *, uint64_t **, void **, uint64_t *, uint64_t *, bool *, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Vector_export_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
    ccall((:GxB_Vector_export_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11)
end

"""
    GxB_Vector_export_Bitmap(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)


### Prototype
```c
GrB_Info GxB_Vector_export_Bitmap (GrB_Vector *, GrB_Type *, uint64_t *, int8_t **, void **, uint64_t *, uint64_t *, bool *, uint64_t *, const GrB_Descriptor);
```
"""
function GxB_Vector_export_Bitmap(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    ccall((:GxB_Vector_export_Bitmap, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end

"""
    GxB_Vector_export_Full(arg1, arg2, arg3, arg4, arg5, arg6, arg7)


### Prototype
```c
GrB_Info GxB_Vector_export_Full (GrB_Vector *, GrB_Type *, uint64_t *, void **, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Vector_export_Full(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    ccall((:GxB_Vector_export_Full, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{UInt64}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7)
end

"""
    GxB_SelectOp_xtype(arg1, arg2)

GxB_SelectOp_: use GrB_IndexUnaryOp instead
### Prototype
```c
GrB_Info GxB_SelectOp_xtype (GrB_Type *, GxB_SelectOp);
```
"""
function GxB_SelectOp_xtype(arg1, arg2)
    ccall((:GxB_SelectOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), arg1, arg2)
end

"""
    GxB_SelectOp_ttype(arg1, arg2)


### Prototype
```c
GrB_Info GxB_SelectOp_ttype (GrB_Type *, GxB_SelectOp);
```
"""
function GxB_SelectOp_ttype(arg1, arg2)
    ccall((:GxB_SelectOp_ttype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), arg1, arg2)
end

"""
    GxB_SelectOp_fprint(arg1, arg2, arg3, arg4)


### Prototype
```c
GrB_Info GxB_SelectOp_fprint (GxB_SelectOp, const char *, int, FILE *);
```
"""
function GxB_SelectOp_fprint(arg1, arg2, arg3, arg4)
    ccall((:GxB_SelectOp_fprint, libgraphblas), GrB_Info, (GxB_SelectOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), arg1, arg2, arg3, arg4)
end

"""
    GxB_deserialize_type_name(arg1, arg2, arg3)

GxB_deserialize_* queries: use GrB_get instead
### Prototype
```c
GrB_Info GxB_deserialize_type_name (char *, const void *, uint64_t);
```
"""
function GxB_deserialize_type_name(arg1, arg2, arg3)
    ccall((:GxB_deserialize_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, Ptr{Cvoid}, UInt64), arg1, arg2, arg3)
end

"""
    GxB_Matrix_pack_CSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)

pack/unpack: use the GxB_Container methods instead
### Prototype
```c
GrB_Info GxB_Matrix_pack_CSR (GrB_Matrix, uint64_t **, uint64_t **, void **, uint64_t, uint64_t, uint64_t, bool, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_pack_CSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    ccall((:GxB_Matrix_pack_CSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, UInt64, Bool, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end

"""
    GxB_Matrix_pack_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)


### Prototype
```c
GrB_Info GxB_Matrix_pack_CSC (GrB_Matrix, uint64_t **, uint64_t **, void **, uint64_t, uint64_t, uint64_t, bool, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_pack_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    ccall((:GxB_Matrix_pack_CSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, UInt64, Bool, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end

"""
    GxB_Matrix_pack_HyperCSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)


### Prototype
```c
GrB_Info GxB_Matrix_pack_HyperCSR (GrB_Matrix, uint64_t **, uint64_t **, uint64_t **, void **, uint64_t, uint64_t, uint64_t, uint64_t, bool, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_pack_HyperCSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
    ccall((:GxB_Matrix_pack_HyperCSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, UInt64, UInt64, Bool, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
end

"""
    GxB_Matrix_pack_HyperCSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)


### Prototype
```c
GrB_Info GxB_Matrix_pack_HyperCSC (GrB_Matrix, uint64_t **, uint64_t **, uint64_t **, void **, uint64_t, uint64_t, uint64_t, uint64_t, bool, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_pack_HyperCSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
    ccall((:GxB_Matrix_pack_HyperCSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, UInt64, UInt64, Bool, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
end

"""
    GxB_Matrix_pack_BitmapR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Matrix_pack_BitmapR (GrB_Matrix, int8_t **, void **, uint64_t, uint64_t, bool, uint64_t, const GrB_Descriptor);
```
"""
function GxB_Matrix_pack_BitmapR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Matrix_pack_BitmapR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, Bool, UInt64, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Matrix_pack_BitmapC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Matrix_pack_BitmapC (GrB_Matrix, int8_t **, void **, uint64_t, uint64_t, bool, uint64_t, const GrB_Descriptor);
```
"""
function GxB_Matrix_pack_BitmapC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Matrix_pack_BitmapC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, Bool, UInt64, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Matrix_pack_FullR(arg1, arg2, arg3, arg4, arg5)


### Prototype
```c
GrB_Info GxB_Matrix_pack_FullR (GrB_Matrix, void **, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_pack_FullR(arg1, arg2, arg3, arg4, arg5)
    ccall((:GxB_Matrix_pack_FullR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5)
end

"""
    GxB_Matrix_pack_FullC(arg1, arg2, arg3, arg4, arg5)


### Prototype
```c
GrB_Info GxB_Matrix_pack_FullC (GrB_Matrix, void **, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Matrix_pack_FullC(arg1, arg2, arg3, arg4, arg5)
    ccall((:GxB_Matrix_pack_FullC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5)
end

"""
    GxB_Vector_pack_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)


### Prototype
```c
GrB_Info GxB_Vector_pack_CSC (GrB_Vector, uint64_t **, void **, uint64_t, uint64_t, bool, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Vector_pack_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    ccall((:GxB_Vector_pack_CSC, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, Bool, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end

"""
    GxB_Vector_pack_Bitmap(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Vector_pack_Bitmap (GrB_Vector, int8_t **, void **, uint64_t, uint64_t, bool, uint64_t, const GrB_Descriptor);
```
"""
function GxB_Vector_pack_Bitmap(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Vector_pack_Bitmap, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, UInt64, UInt64, Bool, UInt64, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Vector_pack_Full(arg1, arg2, arg3, arg4, arg5)


### Prototype
```c
GrB_Info GxB_Vector_pack_Full (GrB_Vector, void **, uint64_t, bool, const GrB_Descriptor);
```
"""
function GxB_Vector_pack_Full(arg1, arg2, arg3, arg4, arg5)
    ccall((:GxB_Vector_pack_Full, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Cvoid}}, UInt64, Bool, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5)
end

"""
    GxB_Matrix_unpack_CSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_CSR (GrB_Matrix, uint64_t **, uint64_t **, void **, uint64_t *, uint64_t *, uint64_t *, bool *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_unpack_CSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    ccall((:GxB_Matrix_unpack_CSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end

"""
    GxB_Matrix_unpack_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_CSC (GrB_Matrix, uint64_t **, uint64_t **, void **, uint64_t *, uint64_t *, uint64_t *, bool *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_unpack_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
    ccall((:GxB_Matrix_unpack_CSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10)
end

"""
    GxB_Matrix_unpack_HyperCSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_HyperCSR (GrB_Matrix, uint64_t **, uint64_t **, uint64_t **, void **, uint64_t *, uint64_t *, uint64_t *, uint64_t *, bool *, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_unpack_HyperCSR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
    ccall((:GxB_Matrix_unpack_HyperCSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
end

"""
    GxB_Matrix_unpack_HyperCSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_HyperCSC (GrB_Matrix, uint64_t **, uint64_t **, uint64_t **, void **, uint64_t *, uint64_t *, uint64_t *, uint64_t *, bool *, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_unpack_HyperCSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
    ccall((:GxB_Matrix_unpack_HyperCSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13)
end

"""
    GxB_Matrix_unpack_BitmapR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_BitmapR (GrB_Matrix, int8_t **, void **, uint64_t *, uint64_t *, bool *, uint64_t *, const GrB_Descriptor);
```
"""
function GxB_Matrix_unpack_BitmapR(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Matrix_unpack_BitmapR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Matrix_unpack_BitmapC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_BitmapC (GrB_Matrix, int8_t **, void **, uint64_t *, uint64_t *, bool *, uint64_t *, const GrB_Descriptor);
```
"""
function GxB_Matrix_unpack_BitmapC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Matrix_unpack_BitmapC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Matrix_unpack_FullR(arg1, arg2, arg3, arg4, arg5)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_FullR (GrB_Matrix, void **, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_unpack_FullR(arg1, arg2, arg3, arg4, arg5)
    ccall((:GxB_Matrix_unpack_FullR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5)
end

"""
    GxB_Matrix_unpack_FullC(arg1, arg2, arg3, arg4, arg5)


### Prototype
```c
GrB_Info GxB_Matrix_unpack_FullC (GrB_Matrix, void **, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Matrix_unpack_FullC(arg1, arg2, arg3, arg4, arg5)
    ccall((:GxB_Matrix_unpack_FullC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5)
end

"""
    GxB_Vector_unpack_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)


### Prototype
```c
GrB_Info GxB_Vector_unpack_CSC (GrB_Vector, uint64_t **, void **, uint64_t *, uint64_t *, bool *, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Vector_unpack_CSC(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    ccall((:GxB_Vector_unpack_CSC, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{UInt64}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
end

"""
    GxB_Vector_unpack_Bitmap(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)


### Prototype
```c
GrB_Info GxB_Vector_unpack_Bitmap (GrB_Vector, int8_t **, void **, uint64_t *, uint64_t *, bool *, uint64_t *, const GrB_Descriptor);
```
"""
function GxB_Vector_unpack_Bitmap(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    ccall((:GxB_Vector_unpack_Bitmap, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{UInt64}, Ptr{Bool}, Ptr{UInt64}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
end

"""
    GxB_Vector_unpack_Full(arg1, arg2, arg3, arg4, arg5)


### Prototype
```c
GrB_Info GxB_Vector_unpack_Full (GrB_Vector, void **, uint64_t *, bool *, const GrB_Descriptor);
```
"""
function GxB_Vector_unpack_Full(arg1, arg2, arg3, arg4, arg5)
    ccall((:GxB_Vector_unpack_Full, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Cvoid}}, Ptr{UInt64}, Ptr{Bool}, GrB_Descriptor), arg1, arg2, arg3, arg4, arg5)
end

"""
    GxB_unpack_HyperHash(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_unpack_HyperHash (GrB_Matrix, GrB_Matrix *, const GrB_Descriptor);
```
"""
function GxB_unpack_HyperHash(arg1, arg2, arg3)
    ccall((:GxB_unpack_HyperHash, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Matrix}, GrB_Descriptor), arg1, arg2, arg3)
end

"""
    GxB_pack_HyperHash(arg1, arg2, arg3)


### Prototype
```c
GrB_Info GxB_pack_HyperHash (GrB_Matrix, GrB_Matrix *, const GrB_Descriptor);
```
"""
function GxB_pack_HyperHash(arg1, arg2, arg3)
    ccall((:GxB_pack_HyperHash, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Matrix}, GrB_Descriptor), arg1, arg2, arg3)
end

# Skipping MacroDefinition: GB_GLOBAL extern

const GB_HAS_CMPLX_MACROS = 0

const GxB_IMPLEMENTATION_NAME = "SuiteSparse:GraphBLAS"

const GxB_IMPLEMENTATION_DATE = "Aug 12, 2026"

const GxB_IMPLEMENTATION_MAJOR = 10

const GxB_IMPLEMENTATION_MINOR = 5

const GxB_IMPLEMENTATION_SUB = 0

const GxB_SPEC_DATE = "Dec 22, 2023"

const GxB_SPEC_MAJOR = 2

const GxB_SPEC_MINOR = 1

const GxB_SPEC_SUB = 0

# Skipping MacroDefinition: GxB_IMPLEMENTATION_ABOUT \
#"SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2026, All Rights Reserved." \
#"\nhttp://suitesparse.com  Dept of Computer Sci. & Eng, Texas A&M University.\n"

# Skipping MacroDefinition: GxB_IMPLEMENTATION_LICENSE \
#"SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2026, All Rights Reserved." \
#"\nLicensed under the Apache License, Version 2.0 (the \"License\"); you may\n" \
#"not use SuiteSparse:GraphBLAS except in compliance with the License.  You\n" \
#"may obtain a copy of the License at\n\n" \
#"    http://www.apache.org/licenses/LICENSE-2.0\n\n" \
#"Unless required by applicable law or agreed to in writing, software\n" \
#"distributed under the License is distributed on an \"AS IS\" BASIS,\n" \
#"WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n" \
#"See the License for the specific language governing permissions and\n" \
#"limitations under the License.\n"

const GRB_VERSION = 2

const GRB_SUBVERSION = 1

# Skipping MacroDefinition: GxB_SPEC_ABOUT \
#"GraphBLAS C API, by Benjamin Brock, Aydin Buluc, Raye Kimmerer,\n" \
#"Jim Kitchen, Manoj Kumar, Timothy Mattson, Scott McMillan, Jose' Moreira,\n" \
#"Michel Pelletier, Erik Welch, and Carl Yang.  Based on 'GraphBLAS\n" \
#"Mathematics by Jeremy Kepner.  See also 'Graph Algorithms in the Language\n" \
#"of Linear Algebra,' edited by J. Kepner and J. Gilbert, SIAM, 2011.\n"

const GrB_NULL = NULL

const GrB_INVALID_HANDLE = NULL

const GxB_NTHREADS = 7086

const GxB_CHUNK = 7087

const GxB_GPU_IDS = 7101

const GxB_NGPUS = 7102

const GxB_ARENA_DATA = 7105

const GxB_ARENA_HEADER = 7106

const GxB_FAST_IMPORT = Cint(GrB_DEFAULT)

const GxB_USE_VALUES = Cint(GrB_DEFAULT)

const GxB_MAX_NAME_LEN = 128

const GxB_HYPERSPARSE = 1

const GxB_SPARSE = 2

const GxB_BITMAP = 4

const GxB_FULL = 8

const GxB_NBITMAP_SWITCH = 8

const GxB_ANY_SPARSITY = GxB_HYPERSPARSE + GxB_SPARSE + GxB_BITMAP + GxB_FULL

const GxB_AUTO_SPARSITY = GxB_ANY_SPARSITY

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

const GxB_NARENAS = 8

# Skipping MacroDefinition: GB_DECLARE ( prefix , suffix , type ) GrB_Info prefix ## Monoid_new ## suffix /* create a new monoid */ \
#( GrB_Monoid * monoid , /* handle of monoid to create */ GrB_BinaryOp op , /* binary operator of the monoid */ type identity /* identity value of the monoid */ \
#) ;

end # module
