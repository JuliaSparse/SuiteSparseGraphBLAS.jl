module LibGraphBLAS
import ..libgraphblas
to_c_type(t::Type) = t
to_c_type_pairs(va_list) = map(enumerate(to_c_type.(va_list))) do (ind, type)
    :(va_list[$ind]::$type)
end

const GxB_FC64_t = ComplexF32

const GxB_FC32_t = ComplexF32

const GrB_Index = UInt64

mutable struct GB_Type_opaque end

const GrB_Type = Ptr{GB_Type_opaque}

@enum GrB_Info::Int32 begin
    GrB_SUCCESS = 0
    GrB_NO_VALUE = 1
    GxB_EXHAUSTED = 2
    GrB_UNINITIALIZED_OBJECT = -1
    GrB_NULL_POINTER = -2
    GrB_INVALID_VALUE = -3
    GrB_INVALID_INDEX = -4
    GrB_DOMAIN_MISMATCH = -5
    GrB_DIMENSION_MISMATCH = -6
    GrB_OUTPUT_NOT_EMPTY = -7
    GrB_NOT_IMPLEMENTED = -8
    GrB_PANIC = -101
    GrB_OUT_OF_MEMORY = -102
    GrB_INSUFFICIENT_SPACE = -103
    GrB_INVALID_OBJECT = -104
    GrB_INDEX_OUT_OF_BOUNDS = -105
    GrB_EMPTY_OBJECT = -106
end

function GxB_Type_new(type, sizeof_ctype, type_name, type_defn)
    ccall((:GxB_Type_new, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Csize_t, Ptr{Cchar}, Ptr{Cchar}), type, sizeof_ctype, type_name, type_defn)
end

mutable struct GB_UnaryOp_opaque end

const GrB_UnaryOp = Ptr{GB_UnaryOp_opaque}

# typedef void ( * GxB_unary_function ) ( void * , const void * )
const GxB_unary_function = Ptr{Cvoid}

function GxB_UnaryOp_new(unaryop, _function, ztype, xtype, unop_name, unop_defn)
    ccall((:GxB_UnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp}, GxB_unary_function, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), unaryop, _function, ztype, xtype, unop_name, unop_defn)
end

mutable struct GB_BinaryOp_opaque end

const GrB_BinaryOp = Ptr{GB_BinaryOp_opaque}

# typedef void ( * GxB_binary_function ) ( void * , const void * , const void * )
const GxB_binary_function = Ptr{Cvoid}

function GxB_BinaryOp_new(op, _function, ztype, xtype, ytype, binop_name, binop_defn)
    ccall((:GxB_BinaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_binary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), op, _function, ztype, xtype, ytype, binop_name, binop_defn)
end

mutable struct GB_SelectOp_opaque end

const GxB_SelectOp = Ptr{GB_SelectOp_opaque}

# typedef bool ( * GxB_select_function ) // return true if A(i,j) is kept ( GrB_Index i , // row index of A(i,j) GrB_Index j , // column index of A(i,j) const void * x , // value of A(i,j) const void * thunk // optional input for select function )
const GxB_select_function = Ptr{Cvoid}

function GB_SelectOp_new(selectop, _function, xtype, ttype, name)
    ccall((:GB_SelectOp_new, libgraphblas), GrB_Info, (Ptr{GxB_SelectOp}, GxB_select_function, GrB_Type, GrB_Type, Ptr{Cchar}), selectop, _function, xtype, ttype, name)
end

mutable struct GB_IndexUnaryOp_opaque end

const GrB_IndexUnaryOp = Ptr{GB_IndexUnaryOp_opaque}

# typedef void ( * GxB_index_unary_function ) ( void * z , // output value z, of type ztype const void * x , // input value x of type xtype; value of v(i) or A(i,j) GrB_Index i , // row index of A(i,j) GrB_Index j , // column index of A(i,j), or zero for v(i) const void * y // input scalar y )
const GxB_index_unary_function = Ptr{Cvoid}

function GxB_IndexUnaryOp_new(op, _function, ztype, xtype, ytype, idxop_name, idxop_defn)
    ccall((:GxB_IndexUnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_IndexUnaryOp}, GxB_index_unary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), op, _function, ztype, xtype, ytype, idxop_name, idxop_defn)
end

mutable struct GB_Vector_opaque end

const GrB_Vector = Ptr{GB_Vector_opaque}

mutable struct GB_Scalar_opaque end

const GrB_Scalar = Ptr{GB_Scalar_opaque}

function GrB_Vector_setElement_Scalar(w, x, i)
    ccall((:GrB_Vector_setElement_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Scalar, GrB_Index), w, x, i)
end

function GrB_Vector_extractElement_Scalar(x, v, i)
    ccall((:GrB_Vector_extractElement_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_Vector, GrB_Index), x, v, i)
end

mutable struct GB_Matrix_opaque end

const GrB_Matrix = Ptr{GB_Matrix_opaque}

function GrB_Matrix_setElement_Scalar(C, x, i, j)
    ccall((:GrB_Matrix_setElement_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Scalar, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_extractElement_Scalar(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Global_Option_set(field, va_list...)
        :(@ccall(libgraphblas.GxB_Global_Option_set(field::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

@enum GxB_Option_Field::UInt32 begin
    GxB_HYPER_SWITCH = 0
    GxB_BITMAP_SWITCH = 34
    GxB_FORMAT = 1
    GxB_MODE = 2
    GxB_LIBRARY_NAME = 8
    GxB_LIBRARY_VERSION = 9
    GxB_LIBRARY_DATE = 10
    GxB_LIBRARY_ABOUT = 11
    GxB_LIBRARY_URL = 12
    GxB_LIBRARY_LICENSE = 13
    GxB_LIBRARY_COMPILE_DATE = 14
    GxB_LIBRARY_COMPILE_TIME = 15
    GxB_API_VERSION = 16
    GxB_API_DATE = 17
    GxB_API_ABOUT = 18
    GxB_API_URL = 19
    GxB_COMPILER_VERSION = 23
    GxB_COMPILER_NAME = 24
    GxB_GLOBAL_NTHREADS = 5
    GxB_GLOBAL_CHUNK = 7
    GxB_BURBLE = 99
    GxB_PRINTF = 101
    GxB_FLUSH = 102
    GxB_MEMORY_POOL = 103
    GxB_PRINT_1BASED = 104
    GxB_SPARSITY_STATUS = 33
    GxB_IS_HYPER = 6
    GxB_SPARSITY_CONTROL = 32
    GxB_GLOBAL_GPU_CONTROL = 21
    GxB_GLOBAL_GPU_CHUNK = 22
end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Vector_Option_set(A, field, va_list...)
        :(@ccall(libgraphblas.GxB_Vector_Option_set(A::GrB_Vector, field::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Matrix_Option_set(A, field, va_list...)
        :(@ccall(libgraphblas.GxB_Matrix_Option_set(A::GrB_Matrix, field::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

mutable struct GB_Descriptor_opaque end

const GrB_Descriptor = Ptr{GB_Descriptor_opaque}

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Desc_set(desc, field, va_list...)
        :(@ccall(libgraphblas.GxB_Desc_set(desc::GrB_Descriptor, field::GrB_Desc_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Global_Option_get(field, va_list...)
        :(@ccall(libgraphblas.GxB_Global_Option_get(field::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Vector_Option_get(A, field, va_list...)
        :(@ccall(libgraphblas.GxB_Vector_Option_get(A::GrB_Vector, field::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Matrix_Option_get(A, field, va_list...)
        :(@ccall(libgraphblas.GxB_Matrix_Option_get(A::GrB_Matrix, field::GxB_Option_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

# automatic type deduction for variadic arguments may not be what you want, please use with caution
@generated function GxB_Desc_get(desc, field, va_list...)
        :(@ccall(libgraphblas.GxB_Desc_get(desc::GrB_Descriptor, field::GrB_Desc_Field; $(to_c_type_pairs(va_list)...))::GrB_Info))
    end

function GrB_Type_free(type)
    ccall((:GrB_Type_free, libgraphblas), GrB_Info, (Ptr{GrB_Type},), type)
end

function GrB_UnaryOp_free(unaryop)
    ccall((:GrB_UnaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp},), unaryop)
end

function GrB_BinaryOp_free(binaryop)
    ccall((:GrB_BinaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp},), binaryop)
end

function GxB_SelectOp_free(selectop)
    ccall((:GxB_SelectOp_free, libgraphblas), GrB_Info, (Ptr{GxB_SelectOp},), selectop)
end

function GrB_IndexUnaryOp_free(op)
    ccall((:GrB_IndexUnaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_IndexUnaryOp},), op)
end

mutable struct GB_Monoid_opaque end

const GrB_Monoid = Ptr{GB_Monoid_opaque}

function GrB_Monoid_free(monoid)
    ccall((:GrB_Monoid_free, libgraphblas), GrB_Info, (Ptr{GrB_Monoid},), monoid)
end

mutable struct GB_Semiring_opaque end

const GrB_Semiring = Ptr{GB_Semiring_opaque}

function GrB_Semiring_free(semiring)
    ccall((:GrB_Semiring_free, libgraphblas), GrB_Info, (Ptr{GrB_Semiring},), semiring)
end

function GrB_Scalar_free(s)
    ccall((:GrB_Scalar_free, libgraphblas), GrB_Info, (Ptr{GrB_Scalar},), s)
end

function GrB_Vector_free(v)
    ccall((:GrB_Vector_free, libgraphblas), GrB_Info, (Ptr{GrB_Vector},), v)
end

function GrB_Matrix_free(A)
    ccall((:GrB_Matrix_free, libgraphblas), GrB_Info, (Ptr{GrB_Matrix},), A)
end

function GrB_Descriptor_free(descriptor)
    ccall((:GrB_Descriptor_free, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), descriptor)
end

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

function GxB_Iterator_free(iterator)
    ccall((:GxB_Iterator_free, libgraphblas), GrB_Info, (Ptr{GxB_Iterator},), iterator)
end

@enum GrB_WaitMode::UInt32 begin
    GrB_COMPLETE = 0
    GrB_MATERIALIZE = 1
end

function GrB_Type_wait(type, waitmode)
    ccall((:GrB_Type_wait, libgraphblas), GrB_Info, (GrB_Type, GrB_WaitMode), type, waitmode)
end

function GrB_UnaryOp_wait(op, waitmode)
    ccall((:GrB_UnaryOp_wait, libgraphblas), GrB_Info, (GrB_UnaryOp, GrB_WaitMode), op, waitmode)
end

function GrB_BinaryOp_wait(op, waitmode)
    ccall((:GrB_BinaryOp_wait, libgraphblas), GrB_Info, (GrB_BinaryOp, GrB_WaitMode), op, waitmode)
end

function GxB_SelectOp_wait(op, waitmode)
    ccall((:GxB_SelectOp_wait, libgraphblas), GrB_Info, (GxB_SelectOp, GrB_WaitMode), op, waitmode)
end

function GrB_IndexUnaryOp_wait(op, waitmode)
    ccall((:GrB_IndexUnaryOp_wait, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, GrB_WaitMode), op, waitmode)
end

function GrB_Monoid_wait(monoid, waitmode)
    ccall((:GrB_Monoid_wait, libgraphblas), GrB_Info, (GrB_Monoid, GrB_WaitMode), monoid, waitmode)
end

function GrB_Semiring_wait(semiring, waitmode)
    ccall((:GrB_Semiring_wait, libgraphblas), GrB_Info, (GrB_Semiring, GrB_WaitMode), semiring, waitmode)
end

function GrB_Scalar_wait(s, waitmode)
    ccall((:GrB_Scalar_wait, libgraphblas), GrB_Info, (GrB_Scalar, GrB_WaitMode), s, waitmode)
end

function GrB_Vector_wait(v, waitmode)
    ccall((:GrB_Vector_wait, libgraphblas), GrB_Info, (GrB_Vector, GrB_WaitMode), v, waitmode)
end

function GrB_Matrix_wait(A, waitmode)
    ccall((:GrB_Matrix_wait, libgraphblas), GrB_Info, (GrB_Matrix, GrB_WaitMode), A, waitmode)
end

function GrB_Descriptor_wait(desc, waitmode)
    ccall((:GrB_Descriptor_wait, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_WaitMode), desc, waitmode)
end

function GrB_Type_error(error, type)
    ccall((:GrB_Type_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Type), error, type)
end

function GrB_UnaryOp_error(error, op)
    ccall((:GrB_UnaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_UnaryOp), error, op)
end

function GrB_BinaryOp_error(error, op)
    ccall((:GrB_BinaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_BinaryOp), error, op)
end

function GxB_SelectOp_error(error, op)
    ccall((:GxB_SelectOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GxB_SelectOp), error, op)
end

function GrB_IndexUnaryOp_error(error, op)
    ccall((:GrB_IndexUnaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_IndexUnaryOp), error, op)
end

function GrB_Monoid_error(error, monoid)
    ccall((:GrB_Monoid_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Monoid), error, monoid)
end

function GrB_Semiring_error(error, semiring)
    ccall((:GrB_Semiring_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Semiring), error, semiring)
end

function GrB_Scalar_error(error, s)
    ccall((:GrB_Scalar_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Scalar), error, s)
end

function GrB_Vector_error(error, v)
    ccall((:GrB_Vector_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Vector), error, v)
end

function GrB_Matrix_error(error, A)
    ccall((:GrB_Matrix_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Matrix), error, A)
end

function GrB_Descriptor_error(error, d)
    ccall((:GrB_Descriptor_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Descriptor), error, d)
end

function GrB_Matrix_eWiseMult_Semiring(C, Mask, accum, semiring, A, B, desc)
    ccall((:GrB_Matrix_eWiseMult_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

function GrB_Matrix_eWiseMult_Monoid(C, Mask, accum, monoid, A, B, desc)
    ccall((:GrB_Matrix_eWiseMult_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, monoid, A, B, desc)
end

function GrB_Matrix_eWiseMult_BinaryOp(C, Mask, accum, mult, A, B, desc)
    ccall((:GrB_Matrix_eWiseMult_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, mult, A, B, desc)
end

function GrB_Vector_eWiseMult_Semiring(w, mask, accum, semiring, u, v, desc)
    ccall((:GrB_Vector_eWiseMult_Semiring, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, u, v, desc)
end

function GrB_Vector_eWiseMult_Monoid(w, mask, accum, monoid, u, v, desc)
    ccall((:GrB_Vector_eWiseMult_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, monoid, u, v, desc)
end

function GrB_Vector_eWiseMult_BinaryOp(w, mask, accum, mult, u, v, desc)
    ccall((:GrB_Vector_eWiseMult_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, mult, u, v, desc)
end

function GrB_Matrix_eWiseAdd_Semiring(C, Mask, accum, semiring, A, B, desc)
    ccall((:GrB_Matrix_eWiseAdd_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

function GrB_Matrix_eWiseAdd_Monoid(C, Mask, accum, monoid, A, B, desc)
    ccall((:GrB_Matrix_eWiseAdd_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, monoid, A, B, desc)
end

function GrB_Matrix_eWiseAdd_BinaryOp(C, Mask, accum, add, A, B, desc)
    ccall((:GrB_Matrix_eWiseAdd_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, add, A, B, desc)
end

function GrB_Vector_eWiseAdd_Semiring(w, mask, accum, semiring, u, v, desc)
    ccall((:GrB_Vector_eWiseAdd_Semiring, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, u, v, desc)
end

function GrB_Vector_eWiseAdd_Monoid(w, mask, accum, monoid, u, v, desc)
    ccall((:GrB_Vector_eWiseAdd_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, monoid, u, v, desc)
end

function GrB_Vector_eWiseAdd_BinaryOp(w, mask, accum, add, u, v, desc)
    ccall((:GrB_Vector_eWiseAdd_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, add, u, v, desc)
end

function GxB_Matrix_eWiseUnion(C, Mask, accum, add, A, alpha, B, beta, desc)
    ccall((:GxB_Matrix_eWiseUnion, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Scalar, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, add, A, alpha, B, beta, desc)
end

function GxB_Vector_eWiseUnion(w, mask, accum, add, u, alpha, v, beta, desc)
    ccall((:GxB_Vector_eWiseUnion, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Scalar, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, add, u, alpha, v, beta, desc)
end

function GrB_Vector_extract(w, mask, accum, u, I, ni, desc)
    ccall((:GrB_Vector_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

function GrB_Col_extract(w, mask, accum, A, I, ni, j, desc)
    ccall((:GrB_Col_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), w, mask, accum, A, I, ni, j, desc)
end

function GrB_Matrix_extract(C, Mask, accum, A, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_extract, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

function GxB_Vector_subassign_Scalar(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign(w, mask, accum, u, I, ni, desc)
    ccall((:GxB_Vector_subassign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

function GxB_Matrix_subassign_Scalar(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Col_subassign(C, mask, accum, u, I, ni, j, desc)
    ccall((:GxB_Col_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I, ni, j, desc)
end

function GxB_Row_subassign(C, mask, accum, u, i, J, nj, desc)
    ccall((:GxB_Row_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, mask, accum, u, i, J, nj, desc)
end

function GxB_Matrix_subassign(C, Mask, accum, A, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

function GrB_Vector_assign_Scalar(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign(w, mask, accum, u, I, ni, desc)
    ccall((:GrB_Vector_assign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

function GrB_Matrix_assign_Scalar(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Scalar, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Col_assign(C, mask, accum, u, I, ni, j, desc)
    ccall((:GrB_Col_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I, ni, j, desc)
end

function GrB_Row_assign(C, mask, accum, u, i, J, nj, desc)
    ccall((:GrB_Row_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, mask, accum, u, i, J, nj, desc)
end

function GrB_Matrix_assign(C, Mask, accum, A, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

function GrB_Vector_apply(w, mask, accum, op, u, desc)
    ccall((:GrB_Vector_apply, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_UnaryOp, GrB_Vector, GrB_Descriptor), w, mask, accum, op, u, desc)
end

function GrB_Matrix_apply(C, Mask, accum, op, A, desc)
    ccall((:GrB_Matrix_apply, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_UnaryOp, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, A, desc)
end

function GrB_Vector_select_Scalar(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Matrix_select_Scalar(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GxB_Vector_select(w, mask, accum, op, u, Thunk, desc)
    ccall((:GxB_Vector_select, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_SelectOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, Thunk, desc)
end

function GxB_Matrix_select(C, Mask, accum, op, A, Thunk, desc)
    ccall((:GxB_Matrix_select, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_SelectOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, Thunk, desc)
end

function GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), w, mask, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_BinaryOp(w, mask, accum, op, A, desc)
    ccall((:GrB_Matrix_reduce_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), w, mask, accum, op, A, desc)
end

function GrB_Matrix_kronecker_Semiring(C, M, accum, semiring, A, B, desc)
    ccall((:GrB_Matrix_kronecker_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, semiring, A, B, desc)
end

function GrB_Matrix_kronecker_Monoid(C, M, accum, monoid, A, B, desc)
    ccall((:GrB_Matrix_kronecker_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, monoid, A, B, desc)
end

function GrB_Matrix_kronecker_BinaryOp(C, M, accum, op, A, B, desc)
    ccall((:GrB_Matrix_kronecker_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, op, A, B, desc)
end

function GrB_Vector_resize(w, nrows_new)
    ccall((:GrB_Vector_resize, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), w, nrows_new)
end

function GrB_Matrix_resize(C, nrows_new, ncols_new)
    ccall((:GrB_Matrix_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, nrows_new, ncols_new)
end

@enum GxB_Print_Level::UInt32 begin
    GxB_SILENT = 0
    GxB_SUMMARY = 1
    GxB_SHORT = 2
    GxB_COMPLETE = 3
    GxB_SHORT_VERBOSE = 4
    GxB_COMPLETE_VERBOSE = 5
end

function GxB_Type_fprint(type, name, pr, f)
    ccall((:GxB_Type_fprint, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), type, name, pr, f)
end

function GxB_UnaryOp_fprint(unaryop, name, pr, f)
    ccall((:GxB_UnaryOp_fprint, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), unaryop, name, pr, f)
end

function GxB_BinaryOp_fprint(binaryop, name, pr, f)
    ccall((:GxB_BinaryOp_fprint, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), binaryop, name, pr, f)
end

function GxB_IndexUnaryOp_fprint(op, name, pr, f)
    ccall((:GxB_IndexUnaryOp_fprint, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), op, name, pr, f)
end

function GxB_SelectOp_fprint(selectop, name, pr, f)
    ccall((:GxB_SelectOp_fprint, libgraphblas), GrB_Info, (GxB_SelectOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), selectop, name, pr, f)
end

function GxB_Monoid_fprint(monoid, name, pr, f)
    ccall((:GxB_Monoid_fprint, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), monoid, name, pr, f)
end

function GxB_Semiring_fprint(semiring, name, pr, f)
    ccall((:GxB_Semiring_fprint, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), semiring, name, pr, f)
end

function GxB_Scalar_fprint(s, name, pr, f)
    ccall((:GxB_Scalar_fprint, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), s, name, pr, f)
end

function GxB_Vector_fprint(v, name, pr, f)
    ccall((:GxB_Vector_fprint, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), v, name, pr, f)
end

function GxB_Matrix_fprint(A, name, pr, f)
    ccall((:GxB_Matrix_fprint, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), A, name, pr, f)
end

function GxB_Descriptor_fprint(descriptor, name, pr, f)
    ccall((:GxB_Descriptor_fprint, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), descriptor, name, pr, f)
end

function GxB_Vector_sort(w, p, op, u, desc)
    ccall((:GxB_Vector_sort, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Descriptor), w, p, op, u, desc)
end

function GxB_Matrix_sort(C, P, op, A, desc)
    ccall((:GxB_Matrix_sort, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), C, P, op, A, desc)
end

function GB_Iterator_rc_bitmap_next(iterator)
    ccall((:GB_Iterator_rc_bitmap_next, libgraphblas), GrB_Info, (GxB_Iterator,), iterator)
end

@enum GxB_Format_Value::Int32 begin
    GxB_BY_ROW = 0
    GxB_BY_COL = 1
    GxB_NO_FORMAT = -1
end

function GB_Iterator_attach(iterator, A, format, desc)
    ccall((:GB_Iterator_attach, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Matrix, GxB_Format_Value, GrB_Descriptor), iterator, A, format, desc)
end

function GB_Iterator_rc_seek(iterator, j, jth_vector)
    ccall((:GB_Iterator_rc_seek, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Index, Bool), iterator, j, jth_vector)
end

function GB_Vector_Iterator_bitmap_seek(iterator, unused)
    ccall((:GB_Vector_Iterator_bitmap_seek, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Index), iterator, unused)
end

@enum GrB_Mode::UInt32 begin
    GrB_NONBLOCKING = 0
    GrB_BLOCKING = 1
    GxB_NONBLOCKING_GPU = 2
    GxB_BLOCKING_GPU = 3
end

function GrB_init(mode)
    ccall((:GrB_init, libgraphblas), GrB_Info, (GrB_Mode,), mode)
end

function GxB_init(mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)
    ccall((:GxB_init, libgraphblas), GrB_Info, (GrB_Mode, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}), mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function)
end

function GrB_finalize()
    ccall((:GrB_finalize, libgraphblas), GrB_Info, ())
end

function GrB_getVersion(version, subversion)
    ccall((:GrB_getVersion, libgraphblas), GrB_Info, (Ptr{Cuint}, Ptr{Cuint}), version, subversion)
end

@enum GrB_Desc_Field::UInt32 begin
    GrB_OUTP = 0
    GrB_MASK = 1
    GrB_INP0 = 2
    GrB_INP1 = 3
    GxB_DESCRIPTOR_NTHREADS = 5
    GxB_DESCRIPTOR_CHUNK = 7
    GxB_DESCRIPTOR_GPU_CONTROL = 21
    GxB_DESCRIPTOR_GPU_CHUNK = 22
    GxB_AxB_METHOD = 1000
    GxB_SORT = 35
    GxB_COMPRESSION = 36
    GxB_IMPORT = 37
end

@enum GrB_Desc_Value::UInt32 begin
    GxB_DEFAULT = 0
    GrB_REPLACE = 1
    GrB_COMP = 2
    GrB_STRUCTURE = 4
    GrB_TRAN = 3
    GxB_GPU_ALWAYS = 2001
    GxB_GPU_NEVER = 2002
    GxB_AxB_GUSTAVSON = 1001
    GxB_AxB_DOT = 1003
    GxB_AxB_HASH = 1004
    GxB_AxB_SAXPY = 1005
    GxB_SECURE_IMPORT = 502
end

function GrB_Descriptor_new(descriptor)
    ccall((:GrB_Descriptor_new, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), descriptor)
end

function GrB_Descriptor_set(desc, field, val)
    ccall((:GrB_Descriptor_set, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Desc_Field, GrB_Desc_Value), desc, field, val)
end

function GxB_Descriptor_get(val, desc, field)
    ccall((:GxB_Descriptor_get, libgraphblas), GrB_Info, (Ptr{GrB_Desc_Value}, GrB_Descriptor, GrB_Desc_Field), val, desc, field)
end

function GB_Type_new(type, sizeof_ctype, type_name)
    ccall((:GB_Type_new, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Csize_t, Ptr{Cchar}), type, sizeof_ctype, type_name)
end

function GxB_Type_name(type_name, type)
    ccall((:GxB_Type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Type), type_name, type)
end

function GxB_Type_size(size, type)
    ccall((:GxB_Type_size, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Type), size, type)
end

function GxB_Type_from_name(type, type_name)
    ccall((:GxB_Type_from_name, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Ptr{Cchar}), type, type_name)
end

function GB_UnaryOp_new(unaryop, _function, ztype, xtype, unop_name)
    ccall((:GB_UnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp}, GxB_unary_function, GrB_Type, GrB_Type, Ptr{Cchar}), unaryop, _function, ztype, xtype, unop_name)
end

function GxB_UnaryOp_ztype(ztype, unaryop)
    ccall((:GxB_UnaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), ztype, unaryop)
end

function GxB_UnaryOp_ztype_name(type_name, unaryop)
    ccall((:GxB_UnaryOp_ztype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_UnaryOp), type_name, unaryop)
end

function GxB_UnaryOp_xtype(xtype, unaryop)
    ccall((:GxB_UnaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), xtype, unaryop)
end

function GxB_UnaryOp_xtype_name(type_name, unaryop)
    ccall((:GxB_UnaryOp_xtype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_UnaryOp), type_name, unaryop)
end

function GB_BinaryOp_new(binaryop, _function, ztype, xtype, ytype, binop_name)
    ccall((:GB_BinaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_binary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}), binaryop, _function, ztype, xtype, ytype, binop_name)
end

function GxB_BinaryOp_ztype(ztype, binaryop)
    ccall((:GxB_BinaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), ztype, binaryop)
end

function GxB_BinaryOp_ztype_name(type_name, binaryop)
    ccall((:GxB_BinaryOp_ztype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_BinaryOp), type_name, binaryop)
end

function GxB_BinaryOp_xtype(xtype, binaryop)
    ccall((:GxB_BinaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), xtype, binaryop)
end

function GxB_BinaryOp_xtype_name(type_name, binaryop)
    ccall((:GxB_BinaryOp_xtype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_BinaryOp), type_name, binaryop)
end

function GxB_BinaryOp_ytype(ytype, binaryop)
    ccall((:GxB_BinaryOp_ytype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), ytype, binaryop)
end

function GxB_BinaryOp_ytype_name(type_name, binaryop)
    ccall((:GxB_BinaryOp_ytype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_BinaryOp), type_name, binaryop)
end

function GxB_SelectOp_xtype(xtype, selectop)
    ccall((:GxB_SelectOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), xtype, selectop)
end

function GxB_SelectOp_ttype(ttype, selectop)
    ccall((:GxB_SelectOp_ttype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), ttype, selectop)
end

function GxB_IndexUnaryOp_ztype_name(type_name, op)
    ccall((:GxB_IndexUnaryOp_ztype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_IndexUnaryOp), type_name, op)
end

function GxB_IndexUnaryOp_xtype_name(type_name, op)
    ccall((:GxB_IndexUnaryOp_xtype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_IndexUnaryOp), type_name, op)
end

function GxB_IndexUnaryOp_ytype_name(type_name, op)
    ccall((:GxB_IndexUnaryOp_ytype_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_IndexUnaryOp), type_name, op)
end

function GrB_Monoid_new_BOOL(monoid, op, identity)
    ccall((:GrB_Monoid_new_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool), monoid, op, identity)
end

function GrB_Monoid_new_INT8(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8), monoid, op, identity)
end

function GrB_Monoid_new_UINT8(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8), monoid, op, identity)
end

function GrB_Monoid_new_INT16(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16), monoid, op, identity)
end

function GrB_Monoid_new_UINT16(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16), monoid, op, identity)
end

function GrB_Monoid_new_INT32(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32), monoid, op, identity)
end

function GrB_Monoid_new_UINT32(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32), monoid, op, identity)
end

function GrB_Monoid_new_INT64(monoid, op, identity)
    ccall((:GrB_Monoid_new_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64), monoid, op, identity)
end

function GrB_Monoid_new_UINT64(monoid, op, identity)
    ccall((:GrB_Monoid_new_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64), monoid, op, identity)
end

function GrB_Monoid_new_FP32(monoid, op, identity)
    ccall((:GrB_Monoid_new_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat), monoid, op, identity)
end

function GrB_Monoid_new_FP64(monoid, op, identity)
    ccall((:GrB_Monoid_new_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble), monoid, op, identity)
end

function GxB_Monoid_new_FC32(monoid, op, identity)
    ccall((:GxB_Monoid_new_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t), monoid, op, identity)
end

function GxB_Monoid_new_FC64(monoid, op, identity)
    ccall((:GxB_Monoid_new_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t), monoid, op, identity)
end

function GrB_Monoid_new_UDT(monoid, op, identity)
    ccall((:GrB_Monoid_new_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}), monoid, op, identity)
end

function GxB_Monoid_terminal_new_BOOL(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool, Bool), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_INT8(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8, Int8), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_UINT8(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8, UInt8), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_INT16(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16, Int16), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_UINT16(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16, UInt16), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_INT32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32, Int32), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_UINT32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32, UInt32), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_INT64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64, Int64), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_UINT64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64, UInt64), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_FP32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat, Cfloat), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_FP64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble, Cdouble), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_FC32(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t, GxB_FC32_t), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_FC64(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t, GxB_FC64_t), monoid, op, identity, terminal)
end

function GxB_Monoid_terminal_new_UDT(monoid, op, identity, terminal)
    ccall((:GxB_Monoid_terminal_new_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}, Ptr{Cvoid}), monoid, op, identity, terminal)
end

function GxB_Monoid_operator(op, monoid)
    ccall((:GxB_Monoid_operator, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GrB_Monoid), op, monoid)
end

function GxB_Monoid_identity(identity, monoid)
    ccall((:GxB_Monoid_identity, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Monoid), identity, monoid)
end

function GxB_Monoid_terminal(has_terminal, terminal, monoid)
    ccall((:GxB_Monoid_terminal, libgraphblas), GrB_Info, (Ptr{Bool}, Ptr{Cvoid}, GrB_Monoid), has_terminal, terminal, monoid)
end

function GrB_Semiring_new(semiring, add, multiply)
    ccall((:GrB_Semiring_new, libgraphblas), GrB_Info, (Ptr{GrB_Semiring}, GrB_Monoid, GrB_BinaryOp), semiring, add, multiply)
end

function GxB_Semiring_add(add, semiring)
    ccall((:GxB_Semiring_add, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_Semiring), add, semiring)
end

function GxB_Semiring_multiply(multiply, semiring)
    ccall((:GxB_Semiring_multiply, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GrB_Semiring), multiply, semiring)
end

const GxB_Scalar = Ptr{GB_Scalar_opaque}

function GrB_Scalar_new(s, type)
    ccall((:GrB_Scalar_new, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Type), s, type)
end

function GrB_Scalar_dup(s, t)
    ccall((:GrB_Scalar_dup, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Scalar), s, t)
end

function GrB_Scalar_clear(s)
    ccall((:GrB_Scalar_clear, libgraphblas), GrB_Info, (GrB_Scalar,), s)
end

function GrB_Scalar_nvals(nvals, s)
    ccall((:GrB_Scalar_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Scalar), nvals, s)
end

function GxB_Scalar_type(type, s)
    ccall((:GxB_Scalar_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Scalar), type, s)
end

function GxB_Scalar_type_name(type_name, s)
    ccall((:GxB_Scalar_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Scalar), type_name, s)
end

function GxB_Scalar_memoryUsage(size, s)
    ccall((:GxB_Scalar_memoryUsage, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Scalar), size, s)
end

function GxB_Scalar_new(s, type)
    ccall((:GxB_Scalar_new, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Type), s, type)
end

function GxB_Scalar_dup(s, t)
    ccall((:GxB_Scalar_dup, libgraphblas), GrB_Info, (Ptr{GrB_Scalar}, GrB_Scalar), s, t)
end

function GxB_Scalar_clear(s)
    ccall((:GxB_Scalar_clear, libgraphblas), GrB_Info, (GrB_Scalar,), s)
end

function GxB_Scalar_nvals(nvals, s)
    ccall((:GxB_Scalar_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Scalar), nvals, s)
end

function GxB_Scalar_free(s)
    ccall((:GxB_Scalar_free, libgraphblas), GrB_Info, (Ptr{GrB_Scalar},), s)
end

function GrB_Scalar_setElement_BOOL(s, x)
    ccall((:GrB_Scalar_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Scalar, Bool), s, x)
end

function GrB_Scalar_setElement_INT8(s, x)
    ccall((:GrB_Scalar_setElement_INT8, libgraphblas), GrB_Info, (GrB_Scalar, Int8), s, x)
end

function GrB_Scalar_setElement_UINT8(s, x)
    ccall((:GrB_Scalar_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Scalar, UInt8), s, x)
end

function GrB_Scalar_setElement_INT16(s, x)
    ccall((:GrB_Scalar_setElement_INT16, libgraphblas), GrB_Info, (GrB_Scalar, Int16), s, x)
end

function GrB_Scalar_setElement_UINT16(s, x)
    ccall((:GrB_Scalar_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Scalar, UInt16), s, x)
end

function GrB_Scalar_setElement_INT32(s, x)
    ccall((:GrB_Scalar_setElement_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Int32), s, x)
end

function GrB_Scalar_setElement_UINT32(s, x)
    ccall((:GrB_Scalar_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Scalar, UInt32), s, x)
end

function GrB_Scalar_setElement_INT64(s, x)
    ccall((:GrB_Scalar_setElement_INT64, libgraphblas), GrB_Info, (GrB_Scalar, Int64), s, x)
end

function GrB_Scalar_setElement_UINT64(s, x)
    ccall((:GrB_Scalar_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Scalar, UInt64), s, x)
end

function GrB_Scalar_setElement_FP32(s, x)
    ccall((:GrB_Scalar_setElement_FP32, libgraphblas), GrB_Info, (GrB_Scalar, Cfloat), s, x)
end

function GrB_Scalar_setElement_FP64(s, x)
    ccall((:GrB_Scalar_setElement_FP64, libgraphblas), GrB_Info, (GrB_Scalar, Cdouble), s, x)
end

function GxB_Scalar_setElement_FC32(s, x)
    ccall((:GxB_Scalar_setElement_FC32, libgraphblas), GrB_Info, (GrB_Scalar, GxB_FC32_t), s, x)
end

function GxB_Scalar_setElement_FC64(s, x)
    ccall((:GxB_Scalar_setElement_FC64, libgraphblas), GrB_Info, (GrB_Scalar, GxB_FC64_t), s, x)
end

function GrB_Scalar_setElement_UDT(s, x)
    ccall((:GrB_Scalar_setElement_UDT, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}), s, x)
end

function GxB_Scalar_setElement_BOOL(s, x)
    ccall((:GxB_Scalar_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Scalar, Bool), s, x)
end

function GxB_Scalar_setElement_INT8(s, x)
    ccall((:GxB_Scalar_setElement_INT8, libgraphblas), GrB_Info, (GrB_Scalar, Int8), s, x)
end

function GxB_Scalar_setElement_INT16(s, x)
    ccall((:GxB_Scalar_setElement_INT16, libgraphblas), GrB_Info, (GrB_Scalar, Int16), s, x)
end

function GxB_Scalar_setElement_INT32(s, x)
    ccall((:GxB_Scalar_setElement_INT32, libgraphblas), GrB_Info, (GrB_Scalar, Int32), s, x)
end

function GxB_Scalar_setElement_INT64(s, x)
    ccall((:GxB_Scalar_setElement_INT64, libgraphblas), GrB_Info, (GrB_Scalar, Int64), s, x)
end

function GxB_Scalar_setElement_UINT8(s, x)
    ccall((:GxB_Scalar_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Scalar, UInt8), s, x)
end

function GxB_Scalar_setElement_UINT16(s, x)
    ccall((:GxB_Scalar_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Scalar, UInt16), s, x)
end

function GxB_Scalar_setElement_UINT32(s, x)
    ccall((:GxB_Scalar_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Scalar, UInt32), s, x)
end

function GxB_Scalar_setElement_UINT64(s, x)
    ccall((:GxB_Scalar_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Scalar, UInt64), s, x)
end

function GxB_Scalar_setElement_FP32(s, x)
    ccall((:GxB_Scalar_setElement_FP32, libgraphblas), GrB_Info, (GrB_Scalar, Cfloat), s, x)
end

function GxB_Scalar_setElement_FP64(s, x)
    ccall((:GxB_Scalar_setElement_FP64, libgraphblas), GrB_Info, (GrB_Scalar, Cdouble), s, x)
end

function GxB_Scalar_setElement_UDT(s, x)
    ccall((:GxB_Scalar_setElement_UDT, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cvoid}), s, x)
end

function GrB_Scalar_extractElement_BOOL(x, s)
    ccall((:GrB_Scalar_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_INT8(x, s)
    ccall((:GrB_Scalar_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_UINT8(x, s)
    ccall((:GrB_Scalar_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_INT16(x, s)
    ccall((:GrB_Scalar_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_UINT16(x, s)
    ccall((:GrB_Scalar_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_INT32(x, s)
    ccall((:GrB_Scalar_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_UINT32(x, s)
    ccall((:GrB_Scalar_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_INT64(x, s)
    ccall((:GrB_Scalar_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_UINT64(x, s)
    ccall((:GrB_Scalar_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_FP32(x, s)
    ccall((:GrB_Scalar_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_FP64(x, s)
    ccall((:GrB_Scalar_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_FC32(x, s)
    ccall((:GxB_Scalar_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_FC64(x, s)
    ccall((:GxB_Scalar_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_Scalar), x, s)
end

function GrB_Scalar_extractElement_UDT(x, s)
    ccall((:GrB_Scalar_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_BOOL(x, s)
    ccall((:GxB_Scalar_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_INT8(x, s)
    ccall((:GxB_Scalar_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_INT16(x, s)
    ccall((:GxB_Scalar_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_INT32(x, s)
    ccall((:GxB_Scalar_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_INT64(x, s)
    ccall((:GxB_Scalar_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UINT8(x, s)
    ccall((:GxB_Scalar_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UINT16(x, s)
    ccall((:GxB_Scalar_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UINT32(x, s)
    ccall((:GxB_Scalar_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UINT64(x, s)
    ccall((:GxB_Scalar_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_FP32(x, s)
    ccall((:GxB_Scalar_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_FP64(x, s)
    ccall((:GxB_Scalar_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UDT(x, s)
    ccall((:GxB_Scalar_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Scalar), x, s)
end

function GrB_Vector_new(v, type, n)
    ccall((:GrB_Vector_new, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index), v, type, n)
end

function GrB_Vector_dup(w, u)
    ccall((:GrB_Vector_dup, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Vector), w, u)
end

function GrB_Vector_clear(v)
    ccall((:GrB_Vector_clear, libgraphblas), GrB_Info, (GrB_Vector,), v)
end

function GrB_Vector_size(n, v)
    ccall((:GrB_Vector_size, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Vector), n, v)
end

function GrB_Vector_nvals(nvals, v)
    ccall((:GrB_Vector_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Vector), nvals, v)
end

function GxB_Vector_type(type, v)
    ccall((:GxB_Vector_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Vector), type, v)
end

function GxB_Vector_type_name(type_name, v)
    ccall((:GxB_Vector_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Vector), type_name, v)
end

function GxB_Vector_memoryUsage(size, v)
    ccall((:GxB_Vector_memoryUsage, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Vector), size, v)
end

function GxB_Vector_iso(iso, v)
    ccall((:GxB_Vector_iso, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Vector), iso, v)
end

function GrB_Vector_build_BOOL(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_BOOL, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Bool}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_INT8(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_INT8, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int8}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_UINT8(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT8, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt8}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_INT16(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_INT16, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int16}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_UINT16(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT16, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt16}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_INT32(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_INT32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int32}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_UINT32(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt32}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_INT64(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_INT64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Int64}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_UINT64(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UINT64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{UInt64}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_FP32(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_FP32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cfloat}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_FP64(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_FP64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cdouble}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GxB_Vector_build_FC32(w, I, X, nvals, dup)
    ccall((:GxB_Vector_build_FC32, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GxB_Vector_build_FC64(w, I, X, nvals, dup)
    ccall((:GxB_Vector_build_FC64, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GrB_Vector_build_UDT(w, I, X, nvals, dup)
    ccall((:GrB_Vector_build_UDT, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GxB_Vector_build_Scalar(w, I, scalar, nvals)
    ccall((:GxB_Vector_build_Scalar, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, GrB_Scalar, GrB_Index), w, I, scalar, nvals)
end

function GrB_Vector_setElement_BOOL(w, x, i)
    ccall((:GrB_Vector_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Vector, Bool, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_INT8(w, x, i)
    ccall((:GrB_Vector_setElement_INT8, libgraphblas), GrB_Info, (GrB_Vector, Int8, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_UINT8(w, x, i)
    ccall((:GrB_Vector_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Vector, UInt8, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_INT16(w, x, i)
    ccall((:GrB_Vector_setElement_INT16, libgraphblas), GrB_Info, (GrB_Vector, Int16, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_UINT16(w, x, i)
    ccall((:GrB_Vector_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Vector, UInt16, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_INT32(w, x, i)
    ccall((:GrB_Vector_setElement_INT32, libgraphblas), GrB_Info, (GrB_Vector, Int32, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_UINT32(w, x, i)
    ccall((:GrB_Vector_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Vector, UInt32, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_INT64(w, x, i)
    ccall((:GrB_Vector_setElement_INT64, libgraphblas), GrB_Info, (GrB_Vector, Int64, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_UINT64(w, x, i)
    ccall((:GrB_Vector_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Vector, UInt64, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_FP32(w, x, i)
    ccall((:GrB_Vector_setElement_FP32, libgraphblas), GrB_Info, (GrB_Vector, Cfloat, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_FP64(w, x, i)
    ccall((:GrB_Vector_setElement_FP64, libgraphblas), GrB_Info, (GrB_Vector, Cdouble, GrB_Index), w, x, i)
end

function GxB_Vector_setElement_FC32(w, x, i)
    ccall((:GxB_Vector_setElement_FC32, libgraphblas), GrB_Info, (GrB_Vector, GxB_FC32_t, GrB_Index), w, x, i)
end

function GxB_Vector_setElement_FC64(w, x, i)
    ccall((:GxB_Vector_setElement_FC64, libgraphblas), GrB_Info, (GrB_Vector, GxB_FC64_t, GrB_Index), w, x, i)
end

function GrB_Vector_setElement_UDT(w, x, i)
    ccall((:GrB_Vector_setElement_UDT, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cvoid}, GrB_Index), w, x, i)
end

function GrB_Vector_extractElement_BOOL(x, v, i)
    ccall((:GrB_Vector_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_INT8(x, v, i)
    ccall((:GrB_Vector_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_UINT8(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_INT16(x, v, i)
    ccall((:GrB_Vector_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_UINT16(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_INT32(x, v, i)
    ccall((:GrB_Vector_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_UINT32(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_INT64(x, v, i)
    ccall((:GrB_Vector_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_UINT64(x, v, i)
    ccall((:GrB_Vector_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_FP32(x, v, i)
    ccall((:GrB_Vector_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_FP64(x, v, i)
    ccall((:GrB_Vector_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Vector, GrB_Index), x, v, i)
end

function GxB_Vector_extractElement_FC32(x, v, i)
    ccall((:GxB_Vector_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_Vector, GrB_Index), x, v, i)
end

function GxB_Vector_extractElement_FC64(x, v, i)
    ccall((:GxB_Vector_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_extractElement_UDT(x, v, i)
    ccall((:GrB_Vector_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Vector, GrB_Index), x, v, i)
end

function GxB_Vector_isStoredElement(v, i)
    ccall((:GxB_Vector_isStoredElement, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), v, i)
end

function GrB_Vector_removeElement(v, i)
    ccall((:GrB_Vector_removeElement, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), v, i)
end

function GrB_Vector_extractTuples_BOOL(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_INT8(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int8}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_UINT8(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt8}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_INT16(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int16}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_UINT16(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt16}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_INT32(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int32}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_UINT32(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt32}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_INT64(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Int64}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_UINT64(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{UInt64}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_FP32(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cfloat}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_FP64(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cdouble}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GxB_Vector_extractTuples_FC32(I, X, nvals, v)
    ccall((:GxB_Vector_extractTuples_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GxB_FC32_t}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GxB_Vector_extractTuples_FC64(I, X, nvals, v)
    ccall((:GxB_Vector_extractTuples_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GxB_FC64_t}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Vector_extractTuples_UDT(I, X, nvals, v)
    ccall((:GrB_Vector_extractTuples_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

function GrB_Matrix_new(A, type, nrows, ncols)
    ccall((:GrB_Matrix_new, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index), A, type, nrows, ncols)
end

function GrB_Matrix_dup(C, A)
    ccall((:GrB_Matrix_dup, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Matrix), C, A)
end

function GrB_Matrix_clear(A)
    ccall((:GrB_Matrix_clear, libgraphblas), GrB_Info, (GrB_Matrix,), A)
end

function GrB_Matrix_nrows(nrows, A)
    ccall((:GrB_Matrix_nrows, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), nrows, A)
end

function GrB_Matrix_ncols(ncols, A)
    ccall((:GrB_Matrix_ncols, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), ncols, A)
end

function GrB_Matrix_nvals(nvals, A)
    ccall((:GrB_Matrix_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), nvals, A)
end

function GxB_Matrix_type(type, A)
    ccall((:GxB_Matrix_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Matrix), type, A)
end

function GxB_Matrix_type_name(type_name, A)
    ccall((:GxB_Matrix_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Matrix), type_name, A)
end

function GxB_Matrix_memoryUsage(size, A)
    ccall((:GxB_Matrix_memoryUsage, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Matrix), size, A)
end

function GxB_Matrix_iso(iso, A)
    ccall((:GxB_Matrix_iso, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Matrix), iso, A)
end

function GrB_Matrix_build_BOOL(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_INT8(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT8, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_UINT8(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_INT16(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT16, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_UINT16(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_INT32(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_UINT32(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_INT64(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_INT64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_UINT64(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_FP32(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_FP32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_FP64(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_FP64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GxB_Matrix_build_FC32(C, I, J, X, nvals, dup)
    ccall((:GxB_Matrix_build_FC32, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GxB_Matrix_build_FC64(C, I, J, X, nvals, dup)
    ccall((:GxB_Matrix_build_FC64, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GrB_Matrix_build_UDT(C, I, J, X, nvals, dup)
    ccall((:GrB_Matrix_build_UDT, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GxB_Matrix_build_Scalar(C, I, J, scalar, nvals)
    ccall((:GxB_Matrix_build_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Scalar, GrB_Index), C, I, J, scalar, nvals)
end

function GrB_Matrix_setElement_BOOL(C, x, i, j)
    ccall((:GrB_Matrix_setElement_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, Bool, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_INT8(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT8, libgraphblas), GrB_Info, (GrB_Matrix, Int8, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_UINT8(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, UInt8, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_INT16(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT16, libgraphblas), GrB_Info, (GrB_Matrix, Int16, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_UINT16(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, UInt16, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_INT32(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT32, libgraphblas), GrB_Info, (GrB_Matrix, Int32, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_UINT32(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, UInt32, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_INT64(C, x, i, j)
    ccall((:GrB_Matrix_setElement_INT64, libgraphblas), GrB_Info, (GrB_Matrix, Int64, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_UINT64(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, UInt64, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_FP32(C, x, i, j)
    ccall((:GrB_Matrix_setElement_FP32, libgraphblas), GrB_Info, (GrB_Matrix, Cfloat, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_FP64(C, x, i, j)
    ccall((:GrB_Matrix_setElement_FP64, libgraphblas), GrB_Info, (GrB_Matrix, Cdouble, GrB_Index, GrB_Index), C, x, i, j)
end

function GxB_Matrix_setElement_FC32(C, x, i, j)
    ccall((:GxB_Matrix_setElement_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GxB_FC32_t, GrB_Index, GrB_Index), C, x, i, j)
end

function GxB_Matrix_setElement_FC64(C, x, i, j)
    ccall((:GxB_Matrix_setElement_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GxB_FC64_t, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_setElement_UDT(C, x, i, j)
    ccall((:GrB_Matrix_setElement_UDT, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cvoid}, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_extractElement_BOOL(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_INT8(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_UINT8(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_INT16(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_UINT16(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_INT32(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_UINT32(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_INT64(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_UINT64(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_FP32(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_FP64(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GxB_Matrix_extractElement_FC32(x, A, i, j)
    ccall((:GxB_Matrix_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GxB_Matrix_extractElement_FC64(x, A, i, j)
    ccall((:GxB_Matrix_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_extractElement_UDT(x, A, i, j)
    ccall((:GrB_Matrix_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GxB_Matrix_isStoredElement(A, i, j)
    ccall((:GxB_Matrix_isStoredElement, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), A, i, j)
end

function GrB_Matrix_removeElement(C, i, j)
    ccall((:GrB_Matrix_removeElement, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, i, j)
end

function GrB_Matrix_extractTuples_BOOL(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_INT8(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_UINT8(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_INT16(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_UINT16(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_INT32(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_UINT32(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_INT64(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_UINT64(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_FP32(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_FP64(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GxB_Matrix_extractTuples_FC32(I, J, X, nvals, A)
    ccall((:GxB_Matrix_extractTuples_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GxB_Matrix_extractTuples_FC64(I, J, X, nvals, A)
    ccall((:GxB_Matrix_extractTuples_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GrB_Matrix_extractTuples_UDT(I, J, X, nvals, A)
    ccall((:GrB_Matrix_extractTuples_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GxB_Matrix_concat(C, Tiles, m, n, desc)
    ccall((:GxB_Matrix_concat, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Matrix}, GrB_Index, GrB_Index, GrB_Descriptor), C, Tiles, m, n, desc)
end

function GxB_Matrix_split(Tiles, m, n, Tile_nrows, Tile_ncols, A, desc)
    ccall((:GxB_Matrix_split, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Matrix, GrB_Descriptor), Tiles, m, n, Tile_nrows, Tile_ncols, A, desc)
end

function GrB_Matrix_diag(C, v, k)
    ccall((:GrB_Matrix_diag, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Vector, Int64), C, v, k)
end

function GxB_Matrix_diag(C, v, k, desc)
    ccall((:GxB_Matrix_diag, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, Int64, GrB_Descriptor), C, v, k, desc)
end

function GxB_Vector_diag(v, A, k, desc)
    ccall((:GxB_Vector_diag, libgraphblas), GrB_Info, (GrB_Vector, GrB_Matrix, Int64, GrB_Descriptor), v, A, k, desc)
end

function GxB_Scalar_wait(s)
    ccall((:GxB_Scalar_wait, libgraphblas), GrB_Info, (Ptr{GrB_Scalar},), s)
end

function GxB_Scalar_error(error, s)
    ccall((:GxB_Scalar_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Scalar), error, s)
end

function GrB_mxm(C, Mask, accum, semiring, A, B, desc)
    ccall((:GrB_mxm, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

function GrB_vxm(w, mask, accum, semiring, u, A, desc)
    ccall((:GrB_vxm, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Matrix, GrB_Descriptor), w, mask, accum, semiring, u, A, desc)
end

function GrB_mxv(w, mask, accum, semiring, A, u, desc)
    ccall((:GrB_mxv, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, A, u, desc)
end

function GxB_Vector_subassign_BOOL(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_INT8(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_UINT8(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_INT16(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_UINT16(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_INT32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_UINT32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_INT64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_UINT64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_FP32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_FP64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_FC32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_FC64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_subassign_UDT(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_subassign_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Matrix_subassign_BOOL(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_INT8(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_UINT8(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_INT16(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_UINT16(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_INT32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_UINT32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_INT64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_UINT64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_FP32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_FP64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_FC32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_FC64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_subassign_UDT(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Vector_assign_BOOL(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_INT8(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_UINT8(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_INT16(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_UINT16(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_INT32(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_UINT32(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_INT64(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_UINT64(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_FP32(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_FP64(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_assign_FC32(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_assign_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Vector_assign_FC64(w, mask, accum, x, I, ni, desc)
    ccall((:GxB_Vector_assign_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Vector_assign_UDT(w, mask, accum, x, I, ni, desc)
    ccall((:GrB_Vector_assign_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Matrix_assign_BOOL(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_INT8(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_UINT8(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_INT16(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_UINT16(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_INT32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_UINT32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_INT64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_UINT64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_FP32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_FP64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_assign_FC32(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_assign_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GxB_Matrix_assign_FC64(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_assign_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Matrix_assign_UDT(C, Mask, accum, x, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Vector_apply_BinaryOp1st_Scalar(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GxB_Vector_apply_BinaryOp1st(w, mask, accum, op, x, u, desc)
    ccall((:GxB_Vector_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_BOOL(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Bool, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_INT8(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int8, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_INT16(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int16, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_INT32(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int32, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_INT64(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int64, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_UINT8(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt8, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_UINT16(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt16, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_UINT32(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt32, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_UINT64(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt64, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_FP32(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Cfloat, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_FP64(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Cdouble, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GxB_Vector_apply_BinaryOp1st_FC32(w, mask, accum, op, x, u, desc)
    ccall((:GxB_Vector_apply_BinaryOp1st_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_FC32_t, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GxB_Vector_apply_BinaryOp1st_FC64(w, mask, accum, op, x, u, desc)
    ccall((:GxB_Vector_apply_BinaryOp1st_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_FC64_t, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_UDT(w, mask, accum, op, x, u, desc)
    ccall((:GrB_Vector_apply_BinaryOp1st_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Ptr{Cvoid}, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp2nd_Scalar(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GxB_Vector_apply_BinaryOp2nd(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_BOOL(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_INT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_INT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_INT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_INT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_UINT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_UINT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_UINT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_UINT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_FP32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_FP64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GxB_Vector_apply_BinaryOp2nd_FC32(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_BinaryOp2nd_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GxB_Vector_apply_BinaryOp2nd_FC64(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_BinaryOp2nd_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_UDT(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_BinaryOp2nd_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Ptr{Cvoid}, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_Scalar(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GrB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_BOOL(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_INT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_INT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_INT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_INT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_UINT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_UINT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_UINT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_UINT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_FP32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_FP64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GxB_Vector_apply_IndexOp_FC32(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_IndexOp_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GxB_Vector_apply_IndexOp_FC64(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_IndexOp_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_IndexOp_UDT(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_apply_IndexOp_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Ptr{Cvoid}, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Matrix_apply_BinaryOp1st_Scalar(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GxB_Matrix_apply_BinaryOp1st(C, Mask, accum, op, x, A, desc)
    ccall((:GxB_Matrix_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Scalar, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_BOOL(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Bool, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_INT8(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int8, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_INT16(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int16, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_INT32(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int32, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_INT64(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int64, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_UINT8(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt8, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_UINT16(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt16, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_UINT32(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt32, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_UINT64(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt64, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_FP32(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Cfloat, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_FP64(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Cdouble, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GxB_Matrix_apply_BinaryOp1st_FC32(C, Mask, accum, op, x, A, desc)
    ccall((:GxB_Matrix_apply_BinaryOp1st_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_FC32_t, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GxB_Matrix_apply_BinaryOp1st_FC64(C, Mask, accum, op, x, A, desc)
    ccall((:GxB_Matrix_apply_BinaryOp1st_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_FC64_t, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_UDT(C, Mask, accum, op, x, A, desc)
    ccall((:GrB_Matrix_apply_BinaryOp1st_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Ptr{Cvoid}, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_Scalar(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GxB_Matrix_apply_BinaryOp2nd(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_BOOL(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_INT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_INT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_INT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_INT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_UINT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_UINT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_UINT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_UINT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_FP32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_FP64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GxB_Matrix_apply_BinaryOp2nd_FC32(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_BinaryOp2nd_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GxB_Matrix_apply_BinaryOp2nd_FC64(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_BinaryOp2nd_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_UDT(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_BinaryOp2nd_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Ptr{Cvoid}, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_Scalar(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GrB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_BOOL(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_INT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_INT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_INT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_INT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_UINT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_UINT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_UINT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_UINT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_FP32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_FP64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GxB_Matrix_apply_IndexOp_FC32(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_IndexOp_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GxB_Matrix_apply_IndexOp_FC64(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_IndexOp_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_IndexOp_UDT(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_apply_IndexOp_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Ptr{Cvoid}, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Vector_select_BOOL(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_INT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_INT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_INT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_INT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_UINT8(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_UINT16(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_UINT32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_UINT64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_FP32(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_FP64(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GxB_Vector_select_FC32(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_select_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GxB_Vector_select_FC64(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_select_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_select_UDT(w, mask, accum, op, u, y, desc)
    ccall((:GrB_Vector_select_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Vector, Ptr{Cvoid}, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Matrix_select_BOOL(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_INT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_INT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_INT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_INT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_UINT8(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_UINT16(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_UINT32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_UINT64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_FP32(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_FP64(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GxB_Matrix_select_FC32(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_select_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GxB_Matrix_select_FC64(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_select_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_select_UDT(C, Mask, accum, op, A, y, desc)
    ccall((:GrB_Matrix_select_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_IndexUnaryOp, GrB_Matrix, Ptr{Cvoid}, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Vector_reduce_BOOL(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_INT8(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_UINT8(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_INT16(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_UINT16(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_INT32(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_UINT32(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_INT64(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_UINT64(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_FP32(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_FP64(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GxB_Vector_reduce_FC32(c, accum, monoid, u, desc)
    ccall((:GxB_Vector_reduce_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GxB_Vector_reduce_FC64(c, accum, monoid, u, desc)
    ccall((:GxB_Vector_reduce_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_UDT(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_Monoid_Scalar(c, accum, monoid, u, desc)
    ccall((:GrB_Vector_reduce_Monoid_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

function GrB_Vector_reduce_BinaryOp_Scalar(c, accum, op, u, desc)
    ccall((:GrB_Vector_reduce_BinaryOp_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Descriptor), c, accum, op, u, desc)
end

function GrB_Matrix_reduce_BOOL(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_INT8(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_UINT8(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_INT16(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_UINT16(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_INT32(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_UINT32(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_INT64(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_UINT64(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_FP32(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_FP64(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GxB_Matrix_reduce_FC32(c, accum, monoid, A, desc)
    ccall((:GxB_Matrix_reduce_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GxB_Matrix_reduce_FC64(c, accum, monoid, A, desc)
    ccall((:GxB_Matrix_reduce_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_UDT(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_Monoid_Scalar(c, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_Monoid_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_BinaryOp_Scalar(S, accum, op, A, desc)
    ccall((:GrB_Matrix_reduce_BinaryOp_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), S, accum, op, A, desc)
end

function GrB_transpose(C, Mask, accum, A, desc)
    ccall((:GrB_transpose, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), C, Mask, accum, A, desc)
end

function GxB_kron(C, Mask, accum, op, A, B, desc)
    ccall((:GxB_kron, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, A, B, desc)
end

function GxB_Matrix_resize(C, nrows_new, ncols_new)
    ccall((:GxB_Matrix_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, nrows_new, ncols_new)
end

function GxB_Vector_resize(w, nrows_new)
    ccall((:GxB_Vector_resize, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), w, nrows_new)
end

function GxB_Matrix_import_CSR(A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_import_CSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
end

function GxB_Matrix_pack_CSR(A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_pack_CSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
end

function GxB_Matrix_import_CSC(A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_import_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
end

function GxB_Matrix_pack_CSC(A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_pack_CSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
end

function GxB_Matrix_import_HyperCSR(A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_import_HyperCSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
end

function GxB_Matrix_pack_HyperCSR(A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_pack_HyperCSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
end

function GxB_Matrix_import_HyperCSC(A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_import_HyperCSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
end

function GxB_Matrix_pack_HyperCSC(A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_pack_HyperCSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
end

function GxB_Matrix_import_BitmapR(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_import_BitmapR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

function GxB_Matrix_pack_BitmapR(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_pack_BitmapR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

function GxB_Matrix_import_BitmapC(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_import_BitmapC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

function GxB_Matrix_pack_BitmapC(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_pack_BitmapC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

function GxB_Matrix_import_FullR(A, type, nrows, ncols, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_import_FullR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, iso, desc)
end

function GxB_Matrix_pack_FullR(A, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_pack_FullR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, Ax, Ax_size, iso, desc)
end

function GxB_Matrix_import_FullC(A, type, nrows, ncols, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_import_FullC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, iso, desc)
end

function GxB_Matrix_pack_FullC(A, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_pack_FullC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, Ax, Ax_size, iso, desc)
end

function GxB_Vector_import_CSC(v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
    ccall((:GxB_Vector_import_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
end

function GxB_Vector_pack_CSC(v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
    ccall((:GxB_Vector_pack_CSC, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
end

function GxB_Vector_import_Bitmap(v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)
    ccall((:GxB_Vector_import_Bitmap, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)
end

function GxB_Vector_pack_Bitmap(v, vb, vx, vb_size, vx_size, iso, nvals, desc)
    ccall((:GxB_Vector_pack_Bitmap, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), v, vb, vx, vb_size, vx_size, iso, nvals, desc)
end

function GxB_Vector_import_Full(v, type, n, vx, vx_size, iso, desc)
    ccall((:GxB_Vector_import_Full, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), v, type, n, vx, vx_size, iso, desc)
end

function GxB_Vector_pack_Full(v, vx, vx_size, iso, desc)
    ccall((:GxB_Vector_pack_Full, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), v, vx, vx_size, iso, desc)
end

function GxB_Matrix_export_CSR(A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_export_CSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
end

function GxB_Matrix_unpack_CSR(A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_unpack_CSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, iso, jumbled, desc)
end

function GxB_Matrix_export_CSC(A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_export_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
end

function GxB_Matrix_unpack_CSC(A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
    ccall((:GxB_Matrix_unpack_CSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, iso, jumbled, desc)
end

function GxB_Matrix_export_HyperCSR(A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_export_HyperCSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
end

function GxB_Matrix_unpack_HyperCSR(A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_unpack_HyperCSR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, iso, nvec, jumbled, desc)
end

function GxB_Matrix_export_HyperCSC(A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_export_HyperCSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
end

function GxB_Matrix_unpack_HyperCSC(A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
    ccall((:GxB_Matrix_unpack_HyperCSC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, iso, nvec, jumbled, desc)
end

function GxB_Matrix_export_BitmapR(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_export_BitmapR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

function GxB_Matrix_unpack_BitmapR(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_unpack_BitmapR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

function GxB_Matrix_export_BitmapC(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_export_BitmapC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

function GxB_Matrix_unpack_BitmapC(A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
    ccall((:GxB_Matrix_unpack_BitmapC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, Ab, Ax, Ab_size, Ax_size, iso, nvals, desc)
end

function GxB_Matrix_export_FullR(A, type, nrows, ncols, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_export_FullR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, iso, desc)
end

function GxB_Matrix_unpack_FullR(A, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_unpack_FullR, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, Ax, Ax_size, iso, desc)
end

function GxB_Matrix_export_FullC(A, type, nrows, ncols, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_export_FullC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, iso, desc)
end

function GxB_Matrix_unpack_FullC(A, Ax, Ax_size, iso, desc)
    ccall((:GxB_Matrix_unpack_FullC, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, Ax, Ax_size, iso, desc)
end

function GxB_Vector_export_CSC(v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
    ccall((:GxB_Vector_export_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, type, n, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
end

function GxB_Vector_unpack_CSC(v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
    ccall((:GxB_Vector_unpack_CSC, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, vi, vx, vi_size, vx_size, iso, nvals, jumbled, desc)
end

function GxB_Vector_export_Bitmap(v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)
    ccall((:GxB_Vector_export_Bitmap, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), v, type, n, vb, vx, vb_size, vx_size, iso, nvals, desc)
end

function GxB_Vector_unpack_Bitmap(v, vb, vx, vb_size, vx_size, iso, nvals, desc)
    ccall((:GxB_Vector_unpack_Bitmap, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), v, vb, vx, vb_size, vx_size, iso, nvals, desc)
end

function GxB_Vector_export_Full(v, type, n, vx, vx_size, iso, desc)
    ccall((:GxB_Vector_export_Full, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, type, n, vx, vx_size, iso, desc)
end

function GxB_Vector_unpack_Full(v, vx, vx_size, iso, desc)
    ccall((:GxB_Vector_unpack_Full, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, vx, vx_size, iso, desc)
end

@enum GrB_Format::UInt32 begin
    GrB_CSR_FORMAT = 0
    GrB_CSC_FORMAT = 1
    GrB_COO_FORMAT = 2
end

function GrB_Matrix_import_BOOL(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_INT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_INT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_INT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_INT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_UINT8(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_UINT16(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_UINT32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_UINT64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_FP32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_FP64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GxB_Matrix_import_FC32(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GxB_Matrix_import_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GxB_Matrix_import_FC64(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GxB_Matrix_import_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_import_UDT(A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
    ccall((:GrB_Matrix_import_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_Index, GrB_Index, GrB_Format), A, type, nrows, ncols, Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format)
end

function GrB_Matrix_export_BOOL(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_INT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int8}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_INT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int16}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_INT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int32}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_INT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Int64}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_UINT8(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt8}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_UINT16(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt16}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_UINT32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt32}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_UINT64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{UInt64}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_FP32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cfloat}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_FP64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cdouble}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GxB_Matrix_export_FC32(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GxB_Matrix_export_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC32_t}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GxB_Matrix_export_FC64(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GxB_Matrix_export_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GxB_FC64_t}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_export_UDT(Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_export_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap, Ai, Ax, Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_exportSize(Ap_len, Ai_len, Ax_len, format, A)
    ccall((:GrB_Matrix_exportSize, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Format, GrB_Matrix), Ap_len, Ai_len, Ax_len, format, A)
end

function GrB_Matrix_exportHint(format, A)
    ccall((:GrB_Matrix_exportHint, libgraphblas), GrB_Info, (Ptr{GrB_Format}, GrB_Matrix), format, A)
end

function GxB_Matrix_serialize(blob_handle, blob_size_handle, A, desc)
    ccall((:GxB_Matrix_serialize, libgraphblas), GrB_Info, (Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, GrB_Matrix, GrB_Descriptor), blob_handle, blob_size_handle, A, desc)
end

function GrB_Matrix_serialize(blob, blob_size_handle, A)
    ccall((:GrB_Matrix_serialize, libgraphblas), GrB_Info, (Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Matrix), blob, blob_size_handle, A)
end

function GxB_Vector_serialize(blob_handle, blob_size_handle, u, desc)
    ccall((:GxB_Vector_serialize, libgraphblas), GrB_Info, (Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, GrB_Vector, GrB_Descriptor), blob_handle, blob_size_handle, u, desc)
end

function GrB_Matrix_serializeSize(blob_size_handle, A)
    ccall((:GrB_Matrix_serializeSize, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), blob_size_handle, A)
end

function GxB_Matrix_deserialize(C, type, blob, blob_size, desc)
    ccall((:GxB_Matrix_deserialize, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Ptr{Cvoid}, GrB_Index, GrB_Descriptor), C, type, blob, blob_size, desc)
end

function GrB_Matrix_deserialize(C, type, blob, blob_size)
    ccall((:GrB_Matrix_deserialize, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Ptr{Cvoid}, GrB_Index), C, type, blob, blob_size)
end

function GxB_Vector_deserialize(w, type, blob, blob_size, desc)
    ccall((:GxB_Vector_deserialize, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, Ptr{Cvoid}, GrB_Index, GrB_Descriptor), w, type, blob, blob_size, desc)
end

function GxB_deserialize_type_name(type_name, blob, blob_size)
    ccall((:GxB_deserialize_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, Ptr{Cvoid}, GrB_Index), type_name, blob, blob_size)
end

function GxB_Iterator_new(iterator)
    ccall((:GxB_Iterator_new, libgraphblas), GrB_Info, (Ptr{GxB_Iterator},), iterator)
end

function GxB_Matrix_Iterator_attach(iterator, A, desc)
    ccall((:GxB_Matrix_Iterator_attach, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Matrix, GrB_Descriptor), iterator, A, desc)
end

function GxB_Matrix_Iterator_getpmax(iterator)
    ccall((:GxB_Matrix_Iterator_getpmax, libgraphblas), GrB_Index, (GxB_Iterator,), iterator)
end

function GxB_Matrix_Iterator_seek(iterator, p)
    ccall((:GxB_Matrix_Iterator_seek, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Index), iterator, p)
end

function GxB_Matrix_Iterator_next(iterator)
    ccall((:GxB_Matrix_Iterator_next, libgraphblas), GrB_Info, (GxB_Iterator,), iterator)
end

function GxB_Matrix_Iterator_getp(iterator)
    ccall((:GxB_Matrix_Iterator_getp, libgraphblas), GrB_Index, (GxB_Iterator,), iterator)
end

function GxB_Matrix_Iterator_getIndex(iterator, row, col)
    ccall((:GxB_Matrix_Iterator_getIndex, libgraphblas), Cvoid, (GxB_Iterator, Ptr{GrB_Index}, Ptr{GrB_Index}), iterator, row, col)
end

function GxB_Vector_Iterator_attach(iterator, v, desc)
    ccall((:GxB_Vector_Iterator_attach, libgraphblas), GrB_Info, (GxB_Iterator, GrB_Vector, GrB_Descriptor), iterator, v, desc)
end

@enum RMM_MODE::UInt32 begin
    rmm_wrap_host = 0
    rmm_wrap_host_pinned = 1
    rmm_wrap_device = 2
    rmm_wrap_managed = 3
end

function rmm_wrap_finalize()
    ccall((:rmm_wrap_finalize, libgraphblas), Cvoid, ())
end

function rmm_wrap_initialize(mode, init_pool_size, max_pool_size)
    ccall((:rmm_wrap_initialize, libgraphblas), Cint, (RMM_MODE, Csize_t, Csize_t), mode, init_pool_size, max_pool_size)
end

function rmm_wrap_allocate(size)
    ccall((:rmm_wrap_allocate, libgraphblas), Ptr{Cvoid}, (Ptr{Csize_t},), size)
end

function rmm_wrap_deallocate(p, size)
    ccall((:rmm_wrap_deallocate, libgraphblas), Cvoid, (Ptr{Cvoid}, Csize_t), p, size)
end

function rmm_wrap_malloc(size)
    ccall((:rmm_wrap_malloc, libgraphblas), Ptr{Cvoid}, (Csize_t,), size)
end

function rmm_wrap_calloc(n, size)
    ccall((:rmm_wrap_calloc, libgraphblas), Ptr{Cvoid}, (Csize_t, Csize_t), n, size)
end

function rmm_wrap_realloc(p, newsize)
    ccall((:rmm_wrap_realloc, libgraphblas), Ptr{Cvoid}, (Ptr{Cvoid}, Csize_t), p, newsize)
end

function rmm_wrap_free(p)
    ccall((:rmm_wrap_free, libgraphblas), Cvoid, (Ptr{Cvoid},), p)
end

# Skipping MacroDefinition: GB_PUBLIC extern

# const GxB_STDC_VERSION = __STDC_VERSION__

# const GB_restrict = restrict

const GxB_IMPLEMENTATION_NAME = "SuiteSparse:GraphBLAS"

const GxB_IMPLEMENTATION_DATE = "May 20, 2022"

const GxB_IMPLEMENTATION_MAJOR = 7

const GxB_IMPLEMENTATION_MINOR = 1

const GxB_IMPLEMENTATION_SUB = 0

const GxB_SPEC_DATE = "Nov 15, 2021"

const GxB_SPEC_MAJOR = 2

const GxB_SPEC_MINOR = 0

const GxB_SPEC_SUB = 0

const GRB_VERSION = GxB_SPEC_MAJOR

const GRB_SUBVERSION = GxB_SPEC_MINOR

# const GxB_IMPLEMENTATION = GxB_VERSION(GxB_IMPLEMENTATION_MAJOR, GxB_IMPLEMENTATION_MINOR, GxB_IMPLEMENTATION_SUB)

# Skipping MacroDefinition: GxB_IMPLEMENTATION_ABOUT \
#"SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2022, All Rights Reserved." \
#"\nhttp://suitesparse.com  Dept of Computer Sci. & Eng, Texas A&M University.\n"

# Skipping MacroDefinition: GxB_IMPLEMENTATION_LICENSE \
#"SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2022, All Rights Reserved." \
#"\nLicensed under the Apache License, Version 2.0 (the \"License\"); you may\n" \
#"not use SuiteSparse:GraphBLAS except in compliance with the License.  You\n" \
#"may obtain a copy of the License at\n\n" \
#"    http://www.apache.org/licenses/LICENSE-2.0\n\n" \
#"Unless required by applicable law or agreed to in writing, software\n" \
#"distributed under the License is distributed on an \"AS IS\" BASIS,\n" \
#"WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n" \
#"See the License for the specific language governing permissions and\n" \
#"limitations under the License.\n"

# const GxB_SPEC_VERSION = GxB_VERSION(GxB_SPEC_MAJOR, GxB_SPEC_MINOR, GxB_SPEC_SUB)

# Skipping MacroDefinition: GxB_SPEC_ABOUT \
#"GraphBLAS C API, by Aydin Buluc, Timothy Mattson, Scott McMillan,\n" \
#"Jose' Moreira, Carl Yang, and Benjamin Brock.  Based on 'GraphBLAS\n" \
#"Mathematics by Jeremy Kepner.  See also 'Graph Algorithms in the Language\n" \
#"of Linear Algebra,' edited by J. Kepner and J. Gilbert, SIAM, 2011.\n"

# const GrB_INDEX_MAX = (GrB_Index(Culonglong(1) << 60))(-1)

# const GxB_INDEX_MAX = GrB_Index(Culonglong(1) << 60)

const GxB_NTHREADS = 5

const GxB_CHUNK = 7

const GxB_GPU_CONTROL = 21

const GxB_GPU_CHUNK = 22

const GxB_FAST_IMPORT = GxB_DEFAULT

const GxB_MAX_NAME_LEN = 128

const GxB_HYPER = 0

const GxB_HYPERSPARSE = 1

const GxB_SPARSE = 2

const GxB_BITMAP = 4

const GxB_FULL = 8

const GxB_NBITMAP_SWITCH = 8

const GxB_ANY_SPARSITY = GxB_HYPERSPARSE + GxB_SPARSE + GxB_BITMAP + GxB_FULL

const GxB_AUTO_SPARSITY = GxB_ANY_SPARSITY

const GrB_NULL = C_NULL

const GrB_INVALID_HANDLE = C_NULL

const GxB_RANGE = typemax(Int64)

const GxB_STRIDE = typemax(Int64) - 1

const GxB_BACKWARDS = typemax(Int64) - 2

const GxB_BEGIN = 0

const GxB_END = 1

const GxB_INC = 2

const GxB_COMPRESSION_NONE = -1

const GxB_COMPRESSION_DEFAULT = 0

const GxB_COMPRESSION_LZ4 = 1000

const GxB_COMPRESSION_LZ4HC = 2000

const GxB_COMPRESSION_INTEL = 1000000

# Skipping MacroDefinition: GB_Iterator_rc_knext ( iterator ) \
#( /* move to the next vector, and check if iterator is exhausted */ ( ++ ( iterator -> k ) >= iterator -> anvec ) ? ( /* iterator is at the end of the matrix */ iterator -> pstart = 0 , iterator -> pend = 0 , iterator -> p = 0 , iterator -> k = iterator -> anvec , GxB_EXHAUSTED ) : ( /* find first entry in vector, and pstart/pend for this vector */ ( iterator -> A_sparsity <= GxB_SPARSE ) ? ( /* matrix is sparse or hypersparse */ iterator -> pstart = iterator -> Ap [ iterator -> k ] , iterator -> pend = iterator -> Ap [ iterator -> k + 1 ] , iterator -> p = iterator -> pstart , ( ( iterator -> p >= iterator -> pend ) ? GrB_NO_VALUE : GrB_SUCCESS ) ) : ( /* matrix is bitmap or full */ iterator -> pstart += iterator -> avlen , iterator -> pend += iterator -> avlen , iterator -> p = iterator -> pstart , ( iterator -> A_sparsity <= GxB_BITMAP ) ? ( /* matrix is bitmap */ GB_Iterator_rc_bitmap_next ( iterator ) ) : ( /* matrix is full */ ( ( iterator -> p >= iterator -> pend ) ? GrB_NO_VALUE : GrB_SUCCESS ) ) ) ) \
#)

# Skipping MacroDefinition: GB_Iterator_rc_inext ( iterator ) \
#( /* move to the next entry in the vector */ ( ++ ( iterator -> p ) >= iterator -> pend ) ? ( /* no more entries in the current vector */ GrB_NO_VALUE ) : ( ( iterator -> A_sparsity == GxB_BITMAP ) ? ( /* the matrix is in bitmap form */ GB_Iterator_rc_bitmap_next ( iterator ) ) : ( GrB_SUCCESS ) ) \
#)

# Skipping MacroDefinition: GB_Iterator_rc_getj ( iterator ) \
#( ( iterator -> k >= iterator -> anvec ) ? ( /* iterator is past the end of the matrix */ iterator -> avdim ) : ( ( iterator -> A_sparsity == GxB_HYPERSPARSE ) ? ( /* return the name of kth vector: j = Ah [k] if it appears */ iterator -> Ah [ iterator -> k ] ) : ( /* return the kth vector: j = k */ iterator -> k ) ) \
#)

# Skipping MacroDefinition: GB_Iterator_rc_geti ( iterator ) \
#( ( iterator -> Ai != NULL ) ? ( iterator -> Ai [ iterator -> p ] ) : ( ( iterator -> p - iterator -> pstart ) ) \
#)

# Skipping MacroDefinition: GxB_rowIterator_attach ( iterator , A , desc ) \
#( GB_Iterator_attach ( iterator , A , GxB_BY_ROW , desc ) \
#)

# Skipping MacroDefinition: GxB_rowIterator_kount ( iterator ) \
#( ( iterator ) -> anvec \
#)

# Skipping MacroDefinition: GxB_rowIterator_seekRow ( iterator , row ) \
#( GB_Iterator_rc_seek ( iterator , row , false ) \
#)

# Skipping MacroDefinition: GxB_rowIterator_kseek ( iterator , k ) \
#( GB_Iterator_rc_seek ( iterator , k , true ) \
#)

# Skipping MacroDefinition: GxB_rowIterator_nextRow ( iterator ) \
#( GB_Iterator_rc_knext ( iterator ) \
#)

# Skipping MacroDefinition: GxB_rowIterator_nextCol ( iterator ) \
#( GB_Iterator_rc_inext ( ( iterator ) ) \
#)

# Skipping MacroDefinition: GxB_rowIterator_getRowIndex ( iterator ) \
#( GB_Iterator_rc_getj ( ( iterator ) ) \
#)

# Skipping MacroDefinition: GxB_rowIterator_getColIndex ( iterator ) \
#( GB_Iterator_rc_geti ( ( iterator ) ) \
#)

# Skipping MacroDefinition: GxB_colIterator_attach ( iterator , A , desc ) \
#( GB_Iterator_attach ( iterator , A , GxB_BY_COL , desc ) \
#)

# Skipping MacroDefinition: GxB_colIterator_kount ( iterator ) \
#( ( iterator ) -> anvec \
#)

# Skipping MacroDefinition: GxB_colIterator_seekCol ( iterator , col ) \
#( GB_Iterator_rc_seek ( iterator , col , false ) \
#)

# Skipping MacroDefinition: GxB_colIterator_kseek ( iterator , k ) \
#( GB_Iterator_rc_seek ( iterator , k , true ) \
#)

# Skipping MacroDefinition: GxB_colIterator_nextCol ( iterator ) \
#( GB_Iterator_rc_knext ( ( iterator ) ) \
#)

# Skipping MacroDefinition: GxB_colIterator_nextRow ( iterator ) \
#( GB_Iterator_rc_inext ( ( iterator ) ) \
#)

# Skipping MacroDefinition: GxB_colIterator_getColIndex ( iterator ) \
#( GB_Iterator_rc_getj ( ( iterator ) ) \
#)

# Skipping MacroDefinition: GxB_colIterator_getRowIndex ( iterator ) \
#( GB_Iterator_rc_geti ( ( iterator ) ) \
#)

# Skipping MacroDefinition: GxB_Vector_Iterator_getpmax ( iterator ) \
#( ( iterator -> pmax ) \
#)

# Skipping MacroDefinition: GB_Vector_Iterator_seek ( iterator , q ) \
#( ( q >= iterator -> pmax ) ? ( /* the iterator is exhausted */ iterator -> p = iterator -> pmax , GxB_EXHAUSTED ) : ( /* seek to an arbitrary position in the vector */ iterator -> p = q , ( iterator -> A_sparsity == GxB_BITMAP ) ? ( GB_Vector_Iterator_bitmap_seek ( iterator , 0 ) ) : ( GrB_SUCCESS ) ) \
#)

# Skipping MacroDefinition: GxB_Vector_Iterator_seek ( iterator , p ) \
#( GB_Vector_Iterator_seek ( iterator , p ) \
#)

# Skipping MacroDefinition: GB_Vector_Iterator_next ( iterator ) \
#( /* move to the next entry */ ( ++ ( iterator -> p ) >= iterator -> pmax ) ? ( /* the iterator is exhausted */ iterator -> p = iterator -> pmax , GxB_EXHAUSTED ) : ( ( iterator -> A_sparsity == GxB_BITMAP ) ? ( /* bitmap: seek to the next entry present in the bitmap */ GB_Vector_Iterator_bitmap_seek ( iterator , 0 ) ) : ( /* other formats: already at the next entry */ GrB_SUCCESS ) ) \
#)

# Skipping MacroDefinition: GxB_Vector_Iterator_next ( iterator ) \
#( GB_Vector_Iterator_next ( iterator ) \
#)

# Skipping MacroDefinition: GxB_Vector_Iterator_getp ( iterator ) \
#( ( iterator -> p ) \
#)

# Skipping MacroDefinition: GxB_Vector_Iterator_getIndex ( iterator ) \
#( ( ( iterator -> Ai != NULL ) ? iterator -> Ai [ iterator -> p ] : iterator -> p ) \
#)

end # module
