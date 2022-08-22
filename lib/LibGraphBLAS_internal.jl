module LibGraphBLAS_Internal
import ..libgraphblas
to_c_type(t::Type) = t
to_c_type_pairs(va_list) = map(enumerate(to_c_type.(va_list))) do (ind, type)
    :(va_list[$ind]::$type)
end

struct GB_blob16
    stuff::NTuple{2, UInt64}
end

const GrB_Index = UInt64

# typedef int ( * GB_printf_function_t ) ( const char * restrict format , ... )
const GB_printf_function_t = Ptr{Cvoid}

function GB_Global_printf_get()
    ccall((:GB_Global_printf_get, libgraphblas), GB_printf_function_t, ())
end

# typedef int ( * GB_flush_function_t ) ( void )
const GB_flush_function_t = Ptr{Cvoid}

function GB_Global_flush_get()
    ccall((:GB_Global_flush_get, libgraphblas), GB_flush_function_t, ())
end

function GB_Global_burble_get()
    ccall((:GB_Global_burble_get, libgraphblas), Bool, ())
end

@enum GB_Type_code::UInt32 begin
    GB_ignore_code = 0
    GB_BOOL_code = 1
    GB_INT8_code = 2
    GB_UINT8_code = 3
    GB_INT16_code = 4
    GB_UINT16_code = 5
    GB_INT32_code = 6
    GB_UINT32_code = 7
    GB_INT64_code = 8
    GB_UINT64_code = 9
    GB_FP32_code = 10
    GB_FP64_code = 11
    GB_FC32_code = 12
    GB_FC64_code = 13
    GB_UDT_code = 14
end

struct GB_Type_opaque
    magic::Int64
    header_size::Csize_t
    size::Csize_t
    code::GB_Type_code
    name::NTuple{128, Cchar}
    defn::Ptr{Cchar}
end

const GrB_Type = Ptr{GB_Type_opaque}

const GB_void = Cuchar

# typedef void ( * GxB_unary_function ) ( void * , const void * )
const GxB_unary_function = Ptr{Cvoid}

# typedef void ( * GxB_index_unary_function ) ( void * z , // output value z, of type ztype const void * x , // input value x of type xtype; value of v(i) or A(i,j) GrB_Index i , // row index of A(i,j) GrB_Index j , // column index of A(i,j), or zero for v(i) const void * y // input scalar y )
const GxB_index_unary_function = Ptr{Cvoid}

# typedef void ( * GxB_binary_function ) ( void * , const void * , const void * )
const GxB_binary_function = Ptr{Cvoid}

# typedef bool ( * GxB_select_function ) // return true if A(i,j) is kept ( GrB_Index i , // row index of A(i,j) GrB_Index j , // column index of A(i,j) const void * x , // value of A(i,j) const void * thunk // optional input for select function )
const GxB_select_function = Ptr{Cvoid}

@enum GB_Opcode::UInt32 begin
    GB_NOP_code = 0
    GB_ONE_unop_code = 1
    GB_IDENTITY_unop_code = 2
    GB_AINV_unop_code = 3
    GB_ABS_unop_code = 4
    GB_MINV_unop_code = 5
    GB_LNOT_unop_code = 6
    GB_BNOT_unop_code = 7
    GB_SQRT_unop_code = 8
    GB_LOG_unop_code = 9
    GB_EXP_unop_code = 10
    GB_SIN_unop_code = 11
    GB_COS_unop_code = 12
    GB_TAN_unop_code = 13
    GB_ASIN_unop_code = 14
    GB_ACOS_unop_code = 15
    GB_ATAN_unop_code = 16
    GB_SINH_unop_code = 17
    GB_COSH_unop_code = 18
    GB_TANH_unop_code = 19
    GB_ASINH_unop_code = 20
    GB_ACOSH_unop_code = 21
    GB_ATANH_unop_code = 22
    GB_SIGNUM_unop_code = 23
    GB_CEIL_unop_code = 24
    GB_FLOOR_unop_code = 25
    GB_ROUND_unop_code = 26
    GB_TRUNC_unop_code = 27
    GB_EXP2_unop_code = 28
    GB_EXPM1_unop_code = 29
    GB_LOG10_unop_code = 30
    GB_LOG1P_unop_code = 31
    GB_LOG2_unop_code = 32
    GB_LGAMMA_unop_code = 33
    GB_TGAMMA_unop_code = 34
    GB_ERF_unop_code = 35
    GB_ERFC_unop_code = 36
    GB_CBRT_unop_code = 37
    GB_FREXPX_unop_code = 38
    GB_FREXPE_unop_code = 39
    GB_CONJ_unop_code = 40
    GB_CREAL_unop_code = 41
    GB_CIMAG_unop_code = 42
    GB_CARG_unop_code = 43
    GB_ISINF_unop_code = 44
    GB_ISNAN_unop_code = 45
    GB_ISFINITE_unop_code = 46
    GB_POSITIONI_unop_code = 47
    GB_POSITIONI1_unop_code = 48
    GB_POSITIONJ_unop_code = 49
    GB_POSITIONJ1_unop_code = 50
    GB_USER_unop_code = 51
    GB_ROWINDEX_idxunop_code = 52
    GB_COLINDEX_idxunop_code = 53
    GB_DIAGINDEX_idxunop_code = 54
    GB_FLIPDIAGINDEX_idxunop_code = 55
    GB_TRIL_idxunop_code = 56
    GB_TRIU_idxunop_code = 57
    GB_DIAG_idxunop_code = 58
    GB_OFFDIAG_idxunop_code = 59
    GB_COLLE_idxunop_code = 60
    GB_COLGT_idxunop_code = 61
    GB_ROWLE_idxunop_code = 62
    GB_ROWGT_idxunop_code = 63
    GB_VALUENE_idxunop_code = 64
    GB_VALUEEQ_idxunop_code = 65
    GB_VALUEGT_idxunop_code = 66
    GB_VALUEGE_idxunop_code = 67
    GB_VALUELT_idxunop_code = 68
    GB_VALUELE_idxunop_code = 69
    GB_USER_idxunop_code = 70
    GB_FIRST_binop_code = 71
    GB_SECOND_binop_code = 72
    GB_ANY_binop_code = 73
    GB_PAIR_binop_code = 74
    GB_MIN_binop_code = 75
    GB_MAX_binop_code = 76
    GB_PLUS_binop_code = 77
    GB_MINUS_binop_code = 78
    GB_RMINUS_binop_code = 79
    GB_TIMES_binop_code = 80
    GB_DIV_binop_code = 81
    GB_RDIV_binop_code = 82
    GB_POW_binop_code = 83
    GB_ISEQ_binop_code = 84
    GB_ISNE_binop_code = 85
    GB_ISGT_binop_code = 86
    GB_ISLT_binop_code = 87
    GB_ISGE_binop_code = 88
    GB_ISLE_binop_code = 89
    GB_LOR_binop_code = 90
    GB_LAND_binop_code = 91
    GB_LXOR_binop_code = 92
    GB_BOR_binop_code = 93
    GB_BAND_binop_code = 94
    GB_BXOR_binop_code = 95
    GB_BXNOR_binop_code = 96
    GB_BGET_binop_code = 97
    GB_BSET_binop_code = 98
    GB_BCLR_binop_code = 99
    GB_BSHIFT_binop_code = 100
    GB_EQ_binop_code = 101
    GB_NE_binop_code = 102
    GB_GT_binop_code = 103
    GB_LT_binop_code = 104
    GB_GE_binop_code = 105
    GB_LE_binop_code = 106
    GB_ATAN2_binop_code = 107
    GB_HYPOT_binop_code = 108
    GB_FMOD_binop_code = 109
    GB_REMAINDER_binop_code = 110
    GB_COPYSIGN_binop_code = 111
    GB_LDEXP_binop_code = 112
    GB_CMPLX_binop_code = 113
    GB_FIRSTI_binop_code = 114
    GB_FIRSTI1_binop_code = 115
    GB_FIRSTJ_binop_code = 116
    GB_FIRSTJ1_binop_code = 117
    GB_SECONDI_binop_code = 118
    GB_SECONDI1_binop_code = 119
    GB_SECONDJ_binop_code = 120
    GB_SECONDJ1_binop_code = 121
    GB_USER_binop_code = 122
    GB_TRIL_selop_code = 123
    GB_TRIU_selop_code = 124
    GB_DIAG_selop_code = 125
    GB_OFFDIAG_selop_code = 126
    GB_NONZOMBIE_selop_code = 127
    GB_NONZERO_selop_code = 128
    GB_EQ_ZERO_selop_code = 129
    GB_GT_ZERO_selop_code = 130
    GB_GE_ZERO_selop_code = 131
    GB_LT_ZERO_selop_code = 132
    GB_LE_ZERO_selop_code = 133
    GB_NE_THUNK_selop_code = 134
    GB_EQ_THUNK_selop_code = 135
    GB_GT_THUNK_selop_code = 136
    GB_GE_THUNK_selop_code = 137
    GB_LT_THUNK_selop_code = 138
    GB_LE_THUNK_selop_code = 139
    GB_USER_selop_code = 140
end

struct GB_BinaryOp_opaque
    magic::Int64
    header_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    selop_function::GxB_select_function
    name::NTuple{128, Cchar}
    opcode::GB_Opcode
    defn::Ptr{Cchar}
end

const GrB_BinaryOp = Ptr{GB_BinaryOp_opaque}

struct GB_Pending_struct
    header_size::Csize_t
    n::Int64
    nmax::Int64
    sorted::Bool
    i::Ptr{Int64}
    i_size::Csize_t
    j::Ptr{Int64}
    j_size::Csize_t
    x::Ptr{GB_void}
    x_size::Csize_t
    type::GrB_Type
    size::Csize_t
    op::GrB_BinaryOp
end

const GB_Pending = Ptr{GB_Pending_struct}

struct GB_Matrix_opaque
    magic::Int64
    header_size::Csize_t
    logger::Ptr{Cchar}
    logger_size::Csize_t
    type::GrB_Type
    plen::Int64
    vlen::Int64
    vdim::Int64
    nvec::Int64
    nvec_nonempty::Int64
    h::Ptr{Int64}
    p::Ptr{Int64}
    i::Ptr{Int64}
    x::Ptr{Cvoid}
    b::Ptr{Int8}
    nvals::Int64
    p_size::Csize_t
    h_size::Csize_t
    b_size::Csize_t
    i_size::Csize_t
    x_size::Csize_t
    Pending::GB_Pending
    nzombies::UInt64
    hyper_switch::Cfloat
    bitmap_switch::Cfloat
    sparsity_control::Cint
    p_shallow::Bool
    h_shallow::Bool
    b_shallow::Bool
    i_shallow::Bool
    x_shallow::Bool
    static_header::Bool
    is_csc::Bool
    jumbled::Bool
    iso::Bool
end

const GrB_Matrix = Ptr{GB_Matrix_opaque}

function GB_is_dense(A)
    ccall((:GB_is_dense, libgraphblas), Bool, (GrB_Matrix,), A)
end

function GB_Global_abort_function()
    ccall((:GB_Global_abort_function, libgraphblas), Cvoid, ())
end

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

function GB_Type_check(type, name, pr, f)
    ccall((:GB_Type_check, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), type, name, pr, f)
end

function GB_BinaryOp_check(op, name, pr, f)
    ccall((:GB_BinaryOp_check, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

struct GB_IndexUnaryOp_opaque
    magic::Int64
    header_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    selop_function::GxB_select_function
    name::NTuple{128, Cchar}
    opcode::GB_Opcode
    defn::Ptr{Cchar}
end

const GrB_IndexUnaryOp = Ptr{GB_IndexUnaryOp_opaque}

function GB_IndexUnaryOp_check(op, name, pr, f)
    ccall((:GB_IndexUnaryOp_check, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

struct GB_UnaryOp_opaque
    magic::Int64
    header_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    selop_function::GxB_select_function
    name::NTuple{128, Cchar}
    opcode::GB_Opcode
    defn::Ptr{Cchar}
end

const GrB_UnaryOp = Ptr{GB_UnaryOp_opaque}

function GB_UnaryOp_check(op, name, pr, f)
    ccall((:GB_UnaryOp_check, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

struct GB_SelectOp_opaque
    magic::Int64
    header_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    selop_function::GxB_select_function
    name::NTuple{128, Cchar}
    opcode::GB_Opcode
    defn::Ptr{Cchar}
end

const GxB_SelectOp = Ptr{GB_SelectOp_opaque}

function GB_SelectOp_check(op, name, pr, f)
    ccall((:GB_SelectOp_check, libgraphblas), GrB_Info, (GxB_SelectOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

struct GB_Operator_opaque
    magic::Int64
    header_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    selop_function::GxB_select_function
    name::NTuple{128, Cchar}
    opcode::GB_Opcode
    defn::Ptr{Cchar}
end

const GB_Operator = Ptr{GB_Operator_opaque}

function GB_Operator_check(op, name, pr, f)
    ccall((:GB_Operator_check, libgraphblas), GrB_Info, (GB_Operator, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

struct GB_Monoid_opaque
    magic::Int64
    header_size::Csize_t
    op::GrB_BinaryOp
    identity::Ptr{Cvoid}
    terminal::Ptr{Cvoid}
    identity_size::Csize_t
    terminal_size::Csize_t
end

const GrB_Monoid = Ptr{GB_Monoid_opaque}

function GB_Monoid_check(monoid, name, pr, f)
    ccall((:GB_Monoid_check, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), monoid, name, pr, f)
end

struct GB_Semiring_opaque
    magic::Int64
    header_size::Csize_t
    add::GrB_Monoid
    multiply::GrB_BinaryOp
end

const GrB_Semiring = Ptr{GB_Semiring_opaque}

function GB_Semiring_check(semiring, name, pr, f)
    ccall((:GB_Semiring_check, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), semiring, name, pr, f)
end

function GB_Matrix_check(A, name, pr, f)
    ccall((:GB_Matrix_check, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), A, name, pr, f)
end

struct GB_Vector_opaque
    magic::Int64
    header_size::Csize_t
    logger::Ptr{Cchar}
    logger_size::Csize_t
    type::GrB_Type
    plen::Int64
    vlen::Int64
    vdim::Int64
    nvec::Int64
    nvec_nonempty::Int64
    h::Ptr{Int64}
    p::Ptr{Int64}
    i::Ptr{Int64}
    x::Ptr{Cvoid}
    b::Ptr{Int8}
    nvals::Int64
    p_size::Csize_t
    h_size::Csize_t
    b_size::Csize_t
    i_size::Csize_t
    x_size::Csize_t
    Pending::GB_Pending
    nzombies::UInt64
    hyper_switch::Cfloat
    bitmap_switch::Cfloat
    sparsity_control::Cint
    p_shallow::Bool
    h_shallow::Bool
    b_shallow::Bool
    i_shallow::Bool
    x_shallow::Bool
    static_header::Bool
    is_csc::Bool
    jumbled::Bool
    iso::Bool
end

const GrB_Vector = Ptr{GB_Vector_opaque}

function GB_Vector_check(v, name, pr, f)
    ccall((:GB_Vector_check, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), v, name, pr, f)
end

struct GB_Scalar_opaque
    magic::Int64
    header_size::Csize_t
    logger::Ptr{Cchar}
    logger_size::Csize_t
    type::GrB_Type
    plen::Int64
    vlen::Int64
    vdim::Int64
    nvec::Int64
    nvec_nonempty::Int64
    h::Ptr{Int64}
    p::Ptr{Int64}
    i::Ptr{Int64}
    x::Ptr{Cvoid}
    b::Ptr{Int8}
    nvals::Int64
    p_size::Csize_t
    h_size::Csize_t
    b_size::Csize_t
    i_size::Csize_t
    x_size::Csize_t
    Pending::GB_Pending
    nzombies::UInt64
    hyper_switch::Cfloat
    bitmap_switch::Cfloat
    sparsity_control::Cint
    p_shallow::Bool
    h_shallow::Bool
    b_shallow::Bool
    i_shallow::Bool
    x_shallow::Bool
    static_header::Bool
    is_csc::Bool
    jumbled::Bool
    iso::Bool
end

const GrB_Scalar = Ptr{GB_Scalar_opaque}

function GB_Scalar_check(v, name, pr, f)
    ccall((:GB_Scalar_check, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), v, name, pr, f)
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

struct GB_Descriptor_opaque
    magic::Int64
    header_size::Csize_t
    logger::Ptr{Cchar}
    logger_size::Csize_t
    chunk::Cdouble
    out::GrB_Desc_Value
    mask::GrB_Desc_Value
    in0::GrB_Desc_Value
    in1::GrB_Desc_Value
    axb::GrB_Desc_Value
    nthreads_max::Cint
    compression::Cint
    do_sort::Bool
    _import::Cint
end

const GrB_Descriptor = Ptr{GB_Descriptor_opaque}

function GB_Descriptor_check(D, name, pr, f)
    ccall((:GB_Descriptor_check, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), D, name, pr, f)
end

function GB_clear_static_header(C)
    ccall((:GB_clear_static_header, libgraphblas), GrB_Matrix, (GrB_Matrix,), C)
end

function GB_cast_to_int8_t(x)
    ccall((:GB_cast_to_int8_t, libgraphblas), Int8, (Cdouble,), x)
end

function GB_cast_to_int16_t(x)
    ccall((:GB_cast_to_int16_t, libgraphblas), Int16, (Cdouble,), x)
end

function GB_cast_to_int32_t(x)
    ccall((:GB_cast_to_int32_t, libgraphblas), Int32, (Cdouble,), x)
end

function GB_cast_to_int64_t(x)
    ccall((:GB_cast_to_int64_t, libgraphblas), Int64, (Cdouble,), x)
end

function GB_cast_to_uint8_t(x)
    ccall((:GB_cast_to_uint8_t, libgraphblas), UInt8, (Cdouble,), x)
end

function GB_cast_to_uint16_t(x)
    ccall((:GB_cast_to_uint16_t, libgraphblas), UInt16, (Cdouble,), x)
end

function GB_cast_to_uint32_t(x)
    ccall((:GB_cast_to_uint32_t, libgraphblas), UInt32, (Cdouble,), x)
end

function GB_cast_to_uint64_t(x)
    ccall((:GB_cast_to_uint64_t, libgraphblas), UInt64, (Cdouble,), x)
end

const GxB_FC32_t = ComplexF32

const GxB_FC64_t = ComplexF64

function GB_FC32_div(x, y)
    ccall((:GB_FC32_div, libgraphblas), GxB_FC32_t, (GxB_FC32_t, GxB_FC32_t), x, y)
end

function GB_FC64_div(x, y)
    ccall((:GB_FC64_div, libgraphblas), GxB_FC64_t, (GxB_FC64_t, GxB_FC64_t), x, y)
end

function GB_nnz(A)
    ccall((:GB_nnz, libgraphblas), Int64, (GrB_Matrix,), A)
end

function GB_Pending_n(A)
    ccall((:GB_Pending_n, libgraphblas), Int64, (GrB_Matrix,), A)
end

struct GB_Context_struct
    Werk::NTuple{16384, GB_void}
    chunk::Cdouble
    where::Ptr{Cchar}
    logger_handle::Ptr{Ptr{Cchar}}
    logger_size_handle::Ptr{Csize_t}
    nthreads_max::Cint
    pwerk::Cint
end

const GB_Context = Ptr{GB_Context_struct}

function GB_Global_nthreads_max_get()
    ccall((:GB_Global_nthreads_max_get, libgraphblas), Cint, ())
end

function GB_Global_chunk_get()
    ccall((:GB_Global_chunk_get, libgraphblas), Cdouble, ())
end

function GB_Global_GrB_init_called_get()
    ccall((:GB_Global_GrB_init_called_get, libgraphblas), Bool, ())
end

function GB_dealloc_memory(p, size_allocated)
    ccall((:GB_dealloc_memory, libgraphblas), Cvoid, (Ptr{Ptr{Cvoid}}, Csize_t), p, size_allocated)
end

function GB_calloc_memory(nitems, size_of_item, size_allocated, Context)
    ccall((:GB_calloc_memory, libgraphblas), Ptr{Cvoid}, (Csize_t, Csize_t, Ptr{Csize_t}, GB_Context), nitems, size_of_item, size_allocated, Context)
end

function GB_status_code(info)
    ccall((:GB_status_code, libgraphblas), Ptr{Cchar}, (GrB_Info,), info)
end

function GB_malloc_memory(nitems, size_of_item, size_allocated)
    ccall((:GB_malloc_memory, libgraphblas), Ptr{Cvoid}, (Csize_t, Csize_t, Ptr{Csize_t}), nitems, size_of_item, size_allocated)
end

function GB_realloc_memory(nitems_new, size_of_item, p, size_allocated, ok, Context)
    ccall((:GB_realloc_memory, libgraphblas), Ptr{Cvoid}, (Csize_t, Csize_t, Ptr{Cvoid}, Ptr{Csize_t}, Ptr{Bool}, GB_Context), nitems_new, size_of_item, p, size_allocated, ok, Context)
end

function GB_xalloc_memory(use_calloc, iso, n, type_size, size, Context)
    ccall((:GB_xalloc_memory, libgraphblas), Ptr{Cvoid}, (Bool, Bool, Int64, Csize_t, Ptr{Csize_t}, GB_Context), use_calloc, iso, n, type_size, size, Context)
end

function GB_werk_push(size_allocated, on_stack, nitems, size_of_item, Context)
    ccall((:GB_werk_push, libgraphblas), Ptr{Cvoid}, (Ptr{Csize_t}, Ptr{Bool}, Csize_t, Csize_t, GB_Context), size_allocated, on_stack, nitems, size_of_item, Context)
end

function GB_werk_pop(p, size_allocated, on_stack, nitems, size_of_item, Context)
    ccall((:GB_werk_pop, libgraphblas), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Csize_t}, Bool, Csize_t, Csize_t, GB_Context), p, size_allocated, on_stack, nitems, size_of_item, Context)
end

struct GB_task_struct
    kfirst::Int64
    klast::Int64
    pC::Int64
    pC_end::Int64
    pM::Int64
    pM_end::Int64
    pA::Int64
    pA_end::Int64
    pB::Int64
    pB_end::Int64
    len::Int64
end

function GB_clear(A, Context)
    ccall((:GB_clear, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_Descriptor_get(desc, C_replace, Mask_comp, Mask_struct, In0_transpose, In1_transpose, AxB_method, do_sort, Context)
    ccall((:GB_Descriptor_get, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Bool}, Ptr{Bool}, Ptr{Bool}, Ptr{Bool}, Ptr{Bool}, Ptr{GrB_Desc_Value}, Ptr{Cint}, GB_Context), desc, C_replace, Mask_comp, Mask_struct, In0_transpose, In1_transpose, AxB_method, do_sort, Context)
end

function GB_wait(A, name, Context)
    ccall((:GB_wait, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, GB_Context), A, name, Context)
end

function GB_convert_bitmap_to_sparse(A, Context)
    ccall((:GB_convert_bitmap_to_sparse, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_convert_full_to_sparse(A, Context)
    ccall((:GB_convert_full_to_sparse, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_sparsity_control(sparsity_control, vdim)
    ccall((:GB_sparsity_control, libgraphblas), Cint, (Cint, Int64), sparsity_control, vdim)
end

function GB_convert_any_to_full(A)
    ccall((:GB_convert_any_to_full, libgraphblas), Cvoid, (GrB_Matrix,), A)
end

@enum CacheType::UInt32 begin
    CPU_FEATURE_CACHE_NULL = 0
    CPU_FEATURE_CACHE_DATA = 1
    CPU_FEATURE_CACHE_INSTRUCTION = 2
    CPU_FEATURE_CACHE_UNIFIED = 3
    CPU_FEATURE_CACHE_TLB = 4
    CPU_FEATURE_CACHE_DTLB = 5
    CPU_FEATURE_CACHE_STLB = 6
    CPU_FEATURE_CACHE_PREFETCH = 7
end

struct CacheLevelInfo
    level::Cint
    cache_type::CacheType
    cache_size::Cint
    ways::Cint
    line_size::Cint
    tlb_entries::Cint
    partitioning::Cint
end

struct CacheInfo
    size::Cint
    levels::NTuple{10, CacheLevelInfo}
end

struct X86Features
    fpu::Cint
    tsc::Cint
    cx8::Cint
    clfsh::Cint
    mmx::Cint
    aes::Cint
    erms::Cint
    f16c::Cint
    fma4::Cint
    fma3::Cint
    vaes::Cint
    vpclmulqdq::Cint
    bmi1::Cint
    hle::Cint
    bmi2::Cint
    rtm::Cint
    rdseed::Cint
    clflushopt::Cint
    clwb::Cint
    sse::Cint
    sse2::Cint
    sse3::Cint
    ssse3::Cint
    sse4_1::Cint
    sse4_2::Cint
    sse4a::Cint
    avx::Cint
    avx2::Cint
    avx512f::Cint
    avx512cd::Cint
    avx512er::Cint
    avx512pf::Cint
    avx512bw::Cint
    avx512dq::Cint
    avx512vl::Cint
    avx512ifma::Cint
    avx512vbmi::Cint
    avx512vbmi2::Cint
    avx512vnni::Cint
    avx512bitalg::Cint
    avx512vpopcntdq::Cint
    avx512_4vnniw::Cint
    avx512_4vbmi2::Cint
    avx512_second_fma::Cint
    avx512_4fmaps::Cint
    avx512_bf16::Cint
    avx512_vp2intersect::Cint
    amx_bf16::Cint
    amx_tile::Cint
    amx_int8::Cint
    pclmulqdq::Cint
    smx::Cint
    sgx::Cint
    cx16::Cint
    sha::Cint
    popcnt::Cint
    movbe::Cint
    rdrnd::Cint
    dca::Cint
    ss::Cint
    adx::Cint
end

struct X86Info
    features::X86Features
    family::Cint
    model::Cint
    stepping::Cint
    vendor::NTuple{13, Cchar}
end

function GetX86Info()
    ccall((:GetX86Info, libgraphblas), X86Info, ())
end

function GetX86CacheInfo()
    ccall((:GetX86CacheInfo, libgraphblas), CacheInfo, ())
end

@enum X86Microarchitecture::UInt32 begin
    X86_UNKNOWN = 0
    INTEL_80486 = 1
    INTEL_P5 = 2
    INTEL_LAKEMONT = 3
    INTEL_CORE = 4
    INTEL_PNR = 5
    INTEL_NHM = 6
    INTEL_ATOM_BNL = 7
    INTEL_WSM = 8
    INTEL_SNB = 9
    INTEL_IVB = 10
    INTEL_ATOM_SMT = 11
    INTEL_HSW = 12
    INTEL_BDW = 13
    INTEL_SKL = 14
    INTEL_ATOM_GMT = 15
    INTEL_KBL = 16
    INTEL_CFL = 17
    INTEL_WHL = 18
    INTEL_CNL = 19
    INTEL_ICL = 20
    INTEL_TGL = 21
    INTEL_SPR = 22
    INTEL_ADL = 23
    INTEL_RCL = 24
    INTEL_KNIGHTS_M = 25
    INTEL_KNIGHTS_L = 26
    INTEL_KNIGHTS_F = 27
    INTEL_KNIGHTS_C = 28
    INTEL_NETBURST = 29
    AMD_HAMMER = 30
    AMD_K10 = 31
    AMD_K11 = 32
    AMD_K12 = 33
    AMD_BOBCAT = 34
    AMD_PILEDRIVER = 35
    AMD_STREAMROLLER = 36
    AMD_EXCAVATOR = 37
    AMD_BULLDOZER = 38
    AMD_JAGUAR = 39
    AMD_PUMA = 40
    AMD_ZEN = 41
    AMD_ZEN_PLUS = 42
    AMD_ZEN2 = 43
    AMD_ZEN3 = 44
    X86_MICROARCHITECTURE_LAST_ = 45
end

function GetX86Microarchitecture(info)
    ccall((:GetX86Microarchitecture, libgraphblas), X86Microarchitecture, (Ptr{X86Info},), info)
end

function FillX86BrandString(brand_string)
    ccall((:FillX86BrandString, libgraphblas), Cvoid, (Ptr{Cchar},), brand_string)
end

@enum X86FeaturesEnum::UInt32 begin
    X86_FPU = 0
    X86_TSC = 1
    X86_CX8 = 2
    X86_CLFSH = 3
    X86_MMX = 4
    X86_AES = 5
    X86_ERMS = 6
    X86_F16C = 7
    X86_FMA4 = 8
    X86_FMA3 = 9
    X86_VAES = 10
    X86_VPCLMULQDQ = 11
    X86_BMI1 = 12
    X86_HLE = 13
    X86_BMI2 = 14
    X86_RTM = 15
    X86_RDSEED = 16
    X86_CLFLUSHOPT = 17
    X86_CLWB = 18
    X86_SSE = 19
    X86_SSE2 = 20
    X86_SSE3 = 21
    X86_SSSE3 = 22
    X86_SSE4_1 = 23
    X86_SSE4_2 = 24
    X86_SSE4A = 25
    X86_AVX = 26
    X86_AVX2 = 27
    X86_AVX512F = 28
    X86_AVX512CD = 29
    X86_AVX512ER = 30
    X86_AVX512PF = 31
    X86_AVX512BW = 32
    X86_AVX512DQ = 33
    X86_AVX512VL = 34
    X86_AVX512IFMA = 35
    X86_AVX512VBMI = 36
    X86_AVX512VBMI2 = 37
    X86_AVX512VNNI = 38
    X86_AVX512BITALG = 39
    X86_AVX512VPOPCNTDQ = 40
    X86_AVX512_4VNNIW = 41
    X86_AVX512_4VBMI2 = 42
    X86_AVX512_SECOND_FMA = 43
    X86_AVX512_4FMAPS = 44
    X86_AVX512_BF16 = 45
    X86_AVX512_VP2INTERSECT = 46
    X86_AMX_BF16 = 47
    X86_AMX_TILE = 48
    X86_AMX_INT8 = 49
    X86_PCLMULQDQ = 50
    X86_SMX = 51
    X86_SGX = 52
    X86_CX16 = 53
    X86_SHA = 54
    X86_POPCNT = 55
    X86_MOVBE = 56
    X86_RDRND = 57
    X86_DCA = 58
    X86_SS = 59
    X86_ADX = 60
    X86_LAST_ = 61
end

function GetX86FeaturesEnumValue(features, value)
    ccall((:GetX86FeaturesEnumValue, libgraphblas), Cint, (Ptr{X86Features}, X86FeaturesEnum), features, value)
end

function GetX86FeaturesEnumName(arg1)
    ccall((:GetX86FeaturesEnumName, libgraphblas), Ptr{Cchar}, (X86FeaturesEnum,), arg1)
end

function GetX86MicroarchitectureName(arg1)
    ccall((:GetX86MicroarchitectureName, libgraphblas), Ptr{Cchar}, (X86Microarchitecture,), arg1)
end

function GB_Global_cpu_features_query()
    ccall((:GB_Global_cpu_features_query, libgraphblas), Cvoid, ())
end

function GB_Global_cpu_features_avx2()
    ccall((:GB_Global_cpu_features_avx2, libgraphblas), Bool, ())
end

function GB_Global_cpu_features_avx512f()
    ccall((:GB_Global_cpu_features_avx512f, libgraphblas), Bool, ())
end

@enum GrB_Mode::UInt32 begin
    GrB_NONBLOCKING = 0
    GrB_BLOCKING = 1
    GxB_NONBLOCKING_GPU = 2
    GxB_BLOCKING_GPU = 3
end

function GB_Global_mode_set(mode)
    ccall((:GB_Global_mode_set, libgraphblas), Cvoid, (GrB_Mode,), mode)
end

function GB_Global_mode_get()
    ccall((:GB_Global_mode_get, libgraphblas), GrB_Mode, ())
end

function GB_Global_sort_set(sort)
    ccall((:GB_Global_sort_set, libgraphblas), Cvoid, (Cint,), sort)
end

function GB_Global_sort_get()
    ccall((:GB_Global_sort_get, libgraphblas), Cint, ())
end

function GB_Global_GrB_init_called_set(GrB_init_called)
    ccall((:GB_Global_GrB_init_called_set, libgraphblas), Cvoid, (Bool,), GrB_init_called)
end

function GB_Global_nthreads_max_set(nthreads_max)
    ccall((:GB_Global_nthreads_max_set, libgraphblas), Cvoid, (Cint,), nthreads_max)
end

function GB_Global_omp_get_max_threads()
    ccall((:GB_Global_omp_get_max_threads, libgraphblas), Cint, ())
end

function GB_Global_chunk_set(chunk)
    ccall((:GB_Global_chunk_set, libgraphblas), Cvoid, (Cdouble,), chunk)
end

function GB_Global_hyper_switch_set(hyper_switch)
    ccall((:GB_Global_hyper_switch_set, libgraphblas), Cvoid, (Cfloat,), hyper_switch)
end

function GB_Global_hyper_switch_get()
    ccall((:GB_Global_hyper_switch_get, libgraphblas), Cfloat, ())
end

function GB_Global_bitmap_switch_set(k, b)
    ccall((:GB_Global_bitmap_switch_set, libgraphblas), Cvoid, (Cint, Cfloat), k, b)
end

function GB_Global_bitmap_switch_get(k)
    ccall((:GB_Global_bitmap_switch_get, libgraphblas), Cfloat, (Cint,), k)
end

function GB_Global_bitmap_switch_matrix_get(vlen, vdim)
    ccall((:GB_Global_bitmap_switch_matrix_get, libgraphblas), Cfloat, (Int64, Int64), vlen, vdim)
end

function GB_Global_bitmap_switch_default()
    ccall((:GB_Global_bitmap_switch_default, libgraphblas), Cvoid, ())
end

function GB_Global_is_csc_set(is_csc)
    ccall((:GB_Global_is_csc_set, libgraphblas), Cvoid, (Bool,), is_csc)
end

function GB_Global_is_csc_get()
    ccall((:GB_Global_is_csc_get, libgraphblas), Bool, ())
end

function GB_Global_abort_function_set(abort_function)
    ccall((:GB_Global_abort_function_set, libgraphblas), Cvoid, (Ptr{Cvoid},), abort_function)
end

function GB_Global_malloc_function_set(malloc_function)
    ccall((:GB_Global_malloc_function_set, libgraphblas), Cvoid, (Ptr{Cvoid},), malloc_function)
end

function GB_Global_malloc_function(size)
    ccall((:GB_Global_malloc_function, libgraphblas), Ptr{Cvoid}, (Csize_t,), size)
end

function GB_Global_realloc_function_set(realloc_function)
    ccall((:GB_Global_realloc_function_set, libgraphblas), Cvoid, (Ptr{Cvoid},), realloc_function)
end

function GB_Global_realloc_function(p, size)
    ccall((:GB_Global_realloc_function, libgraphblas), Ptr{Cvoid}, (Ptr{Cvoid}, Csize_t), p, size)
end

function GB_Global_have_realloc_function()
    ccall((:GB_Global_have_realloc_function, libgraphblas), Bool, ())
end

function GB_Global_free_function_set(free_function)
    ccall((:GB_Global_free_function_set, libgraphblas), Cvoid, (Ptr{Cvoid},), free_function)
end

function GB_Global_free_function(p)
    ccall((:GB_Global_free_function, libgraphblas), Cvoid, (Ptr{Cvoid},), p)
end

function GB_Global_malloc_is_thread_safe_set(malloc_is_thread_safe)
    ccall((:GB_Global_malloc_is_thread_safe_set, libgraphblas), Cvoid, (Bool,), malloc_is_thread_safe)
end

function GB_Global_malloc_is_thread_safe_get()
    ccall((:GB_Global_malloc_is_thread_safe_get, libgraphblas), Bool, ())
end

function GB_Global_malloc_tracking_set(malloc_tracking)
    ccall((:GB_Global_malloc_tracking_set, libgraphblas), Cvoid, (Bool,), malloc_tracking)
end

function GB_Global_malloc_tracking_get()
    ccall((:GB_Global_malloc_tracking_get, libgraphblas), Bool, ())
end

function GB_Global_nmalloc_clear()
    ccall((:GB_Global_nmalloc_clear, libgraphblas), Cvoid, ())
end

function GB_Global_nmalloc_get()
    ccall((:GB_Global_nmalloc_get, libgraphblas), Int64, ())
end

function GB_Global_malloc_debug_set(malloc_debug)
    ccall((:GB_Global_malloc_debug_set, libgraphblas), Cvoid, (Bool,), malloc_debug)
end

function GB_Global_malloc_debug_get()
    ccall((:GB_Global_malloc_debug_get, libgraphblas), Bool, ())
end

function GB_Global_malloc_debug_count_set(malloc_debug_count)
    ccall((:GB_Global_malloc_debug_count_set, libgraphblas), Cvoid, (Int64,), malloc_debug_count)
end

function GB_Global_malloc_debug_count_decrement()
    ccall((:GB_Global_malloc_debug_count_decrement, libgraphblas), Bool, ())
end

function GB_Global_hack_set(k, hack)
    ccall((:GB_Global_hack_set, libgraphblas), Cvoid, (Cint, Int64), k, hack)
end

function GB_Global_hack_get(k)
    ccall((:GB_Global_hack_get, libgraphblas), Int64, (Cint,), k)
end

function GB_Global_burble_set(burble)
    ccall((:GB_Global_burble_set, libgraphblas), Cvoid, (Bool,), burble)
end

function GB_Global_print_one_based_set(onebased)
    ccall((:GB_Global_print_one_based_set, libgraphblas), Cvoid, (Bool,), onebased)
end

function GB_Global_print_one_based_get()
    ccall((:GB_Global_print_one_based_get, libgraphblas), Bool, ())
end

function GB_Global_print_mem_shallow_set(mem_shallow)
    ccall((:GB_Global_print_mem_shallow_set, libgraphblas), Cvoid, (Bool,), mem_shallow)
end

function GB_Global_print_mem_shallow_get()
    ccall((:GB_Global_print_mem_shallow_get, libgraphblas), Bool, ())
end

function GB_Global_gpu_control_set(value)
    ccall((:GB_Global_gpu_control_set, libgraphblas), Cvoid, (GrB_Desc_Value,), value)
end

function GB_Global_gpu_control_get()
    ccall((:GB_Global_gpu_control_get, libgraphblas), GrB_Desc_Value, ())
end

function GB_Global_gpu_chunk_set(gpu_chunk)
    ccall((:GB_Global_gpu_chunk_set, libgraphblas), Cvoid, (Cdouble,), gpu_chunk)
end

function GB_Global_gpu_chunk_get()
    ccall((:GB_Global_gpu_chunk_get, libgraphblas), Cdouble, ())
end

function GB_Global_gpu_count_set(enable_cuda)
    ccall((:GB_Global_gpu_count_set, libgraphblas), Bool, (Bool,), enable_cuda)
end

function GB_Global_gpu_count_get()
    ccall((:GB_Global_gpu_count_get, libgraphblas), Cint, ())
end

function GB_Global_gpu_memorysize_get(device)
    ccall((:GB_Global_gpu_memorysize_get, libgraphblas), Csize_t, (Cint,), device)
end

function GB_Global_gpu_sm_get(device)
    ccall((:GB_Global_gpu_sm_get, libgraphblas), Cint, (Cint,), device)
end

function GB_Global_gpu_device_pool_size_set(device, size)
    ccall((:GB_Global_gpu_device_pool_size_set, libgraphblas), Bool, (Cint, Csize_t), device, size)
end

function GB_Global_gpu_device_max_pool_size_set(device, size)
    ccall((:GB_Global_gpu_device_max_pool_size_set, libgraphblas), Bool, (Cint, Csize_t), device, size)
end

function GB_Global_gpu_device_memory_resource_set(device, resource)
    ccall((:GB_Global_gpu_device_memory_resource_set, libgraphblas), Bool, (Cint, Ptr{Cvoid}), device, resource)
end

function GB_Global_gpu_device_memory_resource_get(device)
    ccall((:GB_Global_gpu_device_memory_resource_get, libgraphblas), Ptr{Cvoid}, (Cint,), device)
end

function GB_Global_gpu_device_properties_get(device)
    ccall((:GB_Global_gpu_device_properties_get, libgraphblas), Bool, (Cint,), device)
end

function GB_Global_timing_clear_all()
    ccall((:GB_Global_timing_clear_all, libgraphblas), Cvoid, ())
end

function GB_Global_timing_clear(k)
    ccall((:GB_Global_timing_clear, libgraphblas), Cvoid, (Cint,), k)
end

function GB_Global_timing_set(k, t)
    ccall((:GB_Global_timing_set, libgraphblas), Cvoid, (Cint, Cdouble), k, t)
end

function GB_Global_timing_add(k, t)
    ccall((:GB_Global_timing_add, libgraphblas), Cvoid, (Cint, Cdouble), k, t)
end

function GB_Global_timing_get(k)
    ccall((:GB_Global_timing_get, libgraphblas), Cdouble, (Cint,), k)
end

function GB_Global_memtable_n()
    ccall((:GB_Global_memtable_n, libgraphblas), Cint, ())
end

function GB_Global_memtable_dump()
    ccall((:GB_Global_memtable_dump, libgraphblas), Cvoid, ())
end

function GB_Global_memtable_clear()
    ccall((:GB_Global_memtable_clear, libgraphblas), Cvoid, ())
end

function GB_Global_memtable_add(p, size)
    ccall((:GB_Global_memtable_add, libgraphblas), Cvoid, (Ptr{Cvoid}, Csize_t), p, size)
end

function GB_Global_memtable_size(p)
    ccall((:GB_Global_memtable_size, libgraphblas), Csize_t, (Ptr{Cvoid},), p)
end

function GB_Global_memtable_remove(p)
    ccall((:GB_Global_memtable_remove, libgraphblas), Cvoid, (Ptr{Cvoid},), p)
end

function GB_Global_memtable_find(p)
    ccall((:GB_Global_memtable_find, libgraphblas), Bool, (Ptr{Cvoid},), p)
end

function GB_Global_free_pool_init(clear)
    ccall((:GB_Global_free_pool_init, libgraphblas), Cvoid, (Bool,), clear)
end

function GB_Global_free_pool_get(k)
    ccall((:GB_Global_free_pool_get, libgraphblas), Ptr{Cvoid}, (Cint,), k)
end

function GB_Global_free_pool_put(p, k)
    ccall((:GB_Global_free_pool_put, libgraphblas), Bool, (Ptr{Cvoid}, Cint), p, k)
end

function GB_Global_free_pool_dump(pr)
    ccall((:GB_Global_free_pool_dump, libgraphblas), Cvoid, (Cint,), pr)
end

function GB_Global_free_pool_limit_get(k)
    ccall((:GB_Global_free_pool_limit_get, libgraphblas), Int64, (Cint,), k)
end

function GB_Global_free_pool_limit_set(k, nblocks)
    ccall((:GB_Global_free_pool_limit_set, libgraphblas), Cvoid, (Cint, Int64), k, nblocks)
end

function GB_Global_free_pool_nblocks_total()
    ccall((:GB_Global_free_pool_nblocks_total, libgraphblas), Int64, ())
end

function GB_Global_printf_set(p)
    ccall((:GB_Global_printf_set, libgraphblas), Cvoid, (GB_printf_function_t,), p)
end

function GB_Global_flush_set(p)
    ccall((:GB_Global_flush_set, libgraphblas), Cvoid, (GB_flush_function_t,), p)
end

function GB_Global_get_wtime()
    ccall((:GB_Global_get_wtime, libgraphblas), Cdouble, ())
end

function GB_burble_assign(C_replace, Ikind, Jkind, M, Mask_comp, Mask_struct, accum, A, assign_kind)
    ccall((:GB_burble_assign, libgraphblas), Cvoid, (Bool, Cint, Cint, GrB_Matrix, Bool, Bool, GrB_BinaryOp, GrB_Matrix, Cint), C_replace, Ikind, Jkind, M, Mask_comp, Mask_struct, accum, A, assign_kind)
end

function GB_positional_unop_ijflip(op)
    ccall((:GB_positional_unop_ijflip, libgraphblas), GrB_UnaryOp, (GrB_UnaryOp,), op)
end

function GB_positional_binop_ijflip(op)
    ccall((:GB_positional_binop_ijflip, libgraphblas), GrB_BinaryOp, (GrB_BinaryOp,), op)
end

function GB_positional_idxunop_ijflip(ithunk, op)
    ccall((:GB_positional_idxunop_ijflip, libgraphblas), GrB_IndexUnaryOp, (Ptr{Int64}, GrB_IndexUnaryOp), ithunk, op)
end

function GB_positional_offset(opcode, Thunk)
    ccall((:GB_positional_offset, libgraphblas), Int64, (GB_Opcode, GrB_Scalar), opcode, Thunk)
end

# typedef void ( * GB_cast_function ) ( void * , const void * , size_t )
const GB_cast_function = Ptr{Cvoid}

function GB_cast_factory(code1, code2)
    ccall((:GB_cast_factory, libgraphblas), GB_cast_function, (GB_Type_code, GB_Type_code), code1, code2)
end

function GB_copy_user_user(z, x, s)
    ccall((:GB_copy_user_user, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_bool(z, x, s)
    ccall((:GB__cast_bool_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_int8_t(z, x, s)
    ccall((:GB__cast_bool_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_int16_t(z, x, s)
    ccall((:GB__cast_bool_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_int32_t(z, x, s)
    ccall((:GB__cast_bool_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_int64_t(z, x, s)
    ccall((:GB__cast_bool_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_uint8_t(z, x, s)
    ccall((:GB__cast_bool_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_uint16_t(z, x, s)
    ccall((:GB__cast_bool_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_uint32_t(z, x, s)
    ccall((:GB__cast_bool_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_uint64_t(z, x, s)
    ccall((:GB__cast_bool_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_float(z, x, s)
    ccall((:GB__cast_bool_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_double(z, x, s)
    ccall((:GB__cast_bool_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_bool_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_bool_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_bool_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_bool(z, x, s)
    ccall((:GB__cast_int8_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_int8_t(z, x, s)
    ccall((:GB__cast_int8_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_int16_t(z, x, s)
    ccall((:GB__cast_int8_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_int32_t(z, x, s)
    ccall((:GB__cast_int8_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_int64_t(z, x, s)
    ccall((:GB__cast_int8_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_uint8_t(z, x, s)
    ccall((:GB__cast_int8_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_uint16_t(z, x, s)
    ccall((:GB__cast_int8_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_uint32_t(z, x, s)
    ccall((:GB__cast_int8_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_uint64_t(z, x, s)
    ccall((:GB__cast_int8_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_float(z, x, s)
    ccall((:GB__cast_int8_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_double(z, x, s)
    ccall((:GB__cast_int8_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_int8_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int8_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_int8_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_bool(z, x, s)
    ccall((:GB__cast_int16_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_int8_t(z, x, s)
    ccall((:GB__cast_int16_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_int16_t(z, x, s)
    ccall((:GB__cast_int16_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_int32_t(z, x, s)
    ccall((:GB__cast_int16_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_int64_t(z, x, s)
    ccall((:GB__cast_int16_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_uint8_t(z, x, s)
    ccall((:GB__cast_int16_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_uint16_t(z, x, s)
    ccall((:GB__cast_int16_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_uint32_t(z, x, s)
    ccall((:GB__cast_int16_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_uint64_t(z, x, s)
    ccall((:GB__cast_int16_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_float(z, x, s)
    ccall((:GB__cast_int16_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_double(z, x, s)
    ccall((:GB__cast_int16_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_int16_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int16_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_int16_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_bool(z, x, s)
    ccall((:GB__cast_int32_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_int8_t(z, x, s)
    ccall((:GB__cast_int32_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_int16_t(z, x, s)
    ccall((:GB__cast_int32_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_int32_t(z, x, s)
    ccall((:GB__cast_int32_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_int64_t(z, x, s)
    ccall((:GB__cast_int32_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_uint8_t(z, x, s)
    ccall((:GB__cast_int32_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_uint16_t(z, x, s)
    ccall((:GB__cast_int32_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_uint32_t(z, x, s)
    ccall((:GB__cast_int32_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_uint64_t(z, x, s)
    ccall((:GB__cast_int32_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_float(z, x, s)
    ccall((:GB__cast_int32_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_double(z, x, s)
    ccall((:GB__cast_int32_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_int32_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int32_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_int32_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_bool(z, x, s)
    ccall((:GB__cast_int64_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_int8_t(z, x, s)
    ccall((:GB__cast_int64_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_int16_t(z, x, s)
    ccall((:GB__cast_int64_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_int32_t(z, x, s)
    ccall((:GB__cast_int64_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_int64_t(z, x, s)
    ccall((:GB__cast_int64_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_uint8_t(z, x, s)
    ccall((:GB__cast_int64_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_uint16_t(z, x, s)
    ccall((:GB__cast_int64_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_uint32_t(z, x, s)
    ccall((:GB__cast_int64_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_uint64_t(z, x, s)
    ccall((:GB__cast_int64_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_float(z, x, s)
    ccall((:GB__cast_int64_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_double(z, x, s)
    ccall((:GB__cast_int64_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_int64_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_int64_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_int64_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_bool(z, x, s)
    ccall((:GB__cast_uint8_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_int8_t(z, x, s)
    ccall((:GB__cast_uint8_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_int16_t(z, x, s)
    ccall((:GB__cast_uint8_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_int32_t(z, x, s)
    ccall((:GB__cast_uint8_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_int64_t(z, x, s)
    ccall((:GB__cast_uint8_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_uint8_t(z, x, s)
    ccall((:GB__cast_uint8_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_uint16_t(z, x, s)
    ccall((:GB__cast_uint8_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_uint32_t(z, x, s)
    ccall((:GB__cast_uint8_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_uint64_t(z, x, s)
    ccall((:GB__cast_uint8_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_float(z, x, s)
    ccall((:GB__cast_uint8_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_double(z, x, s)
    ccall((:GB__cast_uint8_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_uint8_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint8_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_uint8_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_bool(z, x, s)
    ccall((:GB__cast_uint16_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_int8_t(z, x, s)
    ccall((:GB__cast_uint16_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_int16_t(z, x, s)
    ccall((:GB__cast_uint16_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_int32_t(z, x, s)
    ccall((:GB__cast_uint16_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_int64_t(z, x, s)
    ccall((:GB__cast_uint16_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_uint8_t(z, x, s)
    ccall((:GB__cast_uint16_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_uint16_t(z, x, s)
    ccall((:GB__cast_uint16_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_uint32_t(z, x, s)
    ccall((:GB__cast_uint16_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_uint64_t(z, x, s)
    ccall((:GB__cast_uint16_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_float(z, x, s)
    ccall((:GB__cast_uint16_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_double(z, x, s)
    ccall((:GB__cast_uint16_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_uint16_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint16_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_uint16_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_bool(z, x, s)
    ccall((:GB__cast_uint32_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_int8_t(z, x, s)
    ccall((:GB__cast_uint32_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_int16_t(z, x, s)
    ccall((:GB__cast_uint32_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_int32_t(z, x, s)
    ccall((:GB__cast_uint32_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_int64_t(z, x, s)
    ccall((:GB__cast_uint32_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_uint8_t(z, x, s)
    ccall((:GB__cast_uint32_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_uint16_t(z, x, s)
    ccall((:GB__cast_uint32_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_uint32_t(z, x, s)
    ccall((:GB__cast_uint32_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_uint64_t(z, x, s)
    ccall((:GB__cast_uint32_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_float(z, x, s)
    ccall((:GB__cast_uint32_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_double(z, x, s)
    ccall((:GB__cast_uint32_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_uint32_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint32_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_uint32_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_bool(z, x, s)
    ccall((:GB__cast_uint64_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_int8_t(z, x, s)
    ccall((:GB__cast_uint64_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_int16_t(z, x, s)
    ccall((:GB__cast_uint64_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_int32_t(z, x, s)
    ccall((:GB__cast_uint64_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_int64_t(z, x, s)
    ccall((:GB__cast_uint64_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_uint8_t(z, x, s)
    ccall((:GB__cast_uint64_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_uint16_t(z, x, s)
    ccall((:GB__cast_uint64_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_uint32_t(z, x, s)
    ccall((:GB__cast_uint64_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_uint64_t(z, x, s)
    ccall((:GB__cast_uint64_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_float(z, x, s)
    ccall((:GB__cast_uint64_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_double(z, x, s)
    ccall((:GB__cast_uint64_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_uint64_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_uint64_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_uint64_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_bool(z, x, s)
    ccall((:GB__cast_float_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_int8_t(z, x, s)
    ccall((:GB__cast_float_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_int16_t(z, x, s)
    ccall((:GB__cast_float_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_int32_t(z, x, s)
    ccall((:GB__cast_float_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_int64_t(z, x, s)
    ccall((:GB__cast_float_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_uint8_t(z, x, s)
    ccall((:GB__cast_float_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_uint16_t(z, x, s)
    ccall((:GB__cast_float_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_uint32_t(z, x, s)
    ccall((:GB__cast_float_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_uint64_t(z, x, s)
    ccall((:GB__cast_float_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_float(z, x, s)
    ccall((:GB__cast_float_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_double(z, x, s)
    ccall((:GB__cast_float_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_float_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_float_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_float_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_bool(z, x, s)
    ccall((:GB__cast_double_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_int8_t(z, x, s)
    ccall((:GB__cast_double_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_int16_t(z, x, s)
    ccall((:GB__cast_double_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_int32_t(z, x, s)
    ccall((:GB__cast_double_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_int64_t(z, x, s)
    ccall((:GB__cast_double_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_uint8_t(z, x, s)
    ccall((:GB__cast_double_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_uint16_t(z, x, s)
    ccall((:GB__cast_double_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_uint32_t(z, x, s)
    ccall((:GB__cast_double_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_uint64_t(z, x, s)
    ccall((:GB__cast_double_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_float(z, x, s)
    ccall((:GB__cast_double_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_double(z, x, s)
    ccall((:GB__cast_double_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_double_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_double_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_double_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_bool(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_int8_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_int16_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_int32_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_int64_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_uint8_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_uint16_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_uint32_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_uint64_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_float(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_double(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC32_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_GxB_FC32_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_bool(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_bool, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_int8_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_int8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_int16_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_int16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_int32_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_int32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_int64_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_int64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_uint8_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_uint8_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_uint16_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_uint16_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_uint32_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_uint32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_uint64_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_uint64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_float(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_float, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_double(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_double, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_GxB_FC32_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_GxB_FC32_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB__cast_GxB_FC64_t_GxB_FC64_t(z, x, s)
    ccall((:GB__cast_GxB_FC64_t_GxB_FC64_t, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t), z, x, s)
end

function GB_mcast(Mx, pM, msize)
    ccall((:GB_mcast, libgraphblas), Bool, (Ptr{GB_void}, Int64, Csize_t), Mx, pM, msize)
end

function GB_idiv_int8(x, y)
    ccall((:GB_idiv_int8, libgraphblas), Int8, (Int8, Int8), x, y)
end

function GB_idiv_int16(x, y)
    ccall((:GB_idiv_int16, libgraphblas), Int16, (Int16, Int16), x, y)
end

function GB_idiv_int32(x, y)
    ccall((:GB_idiv_int32, libgraphblas), Int32, (Int32, Int32), x, y)
end

function GB_idiv_int64(x, y)
    ccall((:GB_idiv_int64, libgraphblas), Int64, (Int64, Int64), x, y)
end

function GB_idiv_uint8(x, y)
    ccall((:GB_idiv_uint8, libgraphblas), UInt8, (UInt8, UInt8), x, y)
end

function GB_idiv_uint16(x, y)
    ccall((:GB_idiv_uint16, libgraphblas), UInt16, (UInt16, UInt16), x, y)
end

function GB_idiv_uint32(x, y)
    ccall((:GB_idiv_uint32, libgraphblas), UInt32, (UInt32, UInt32), x, y)
end

function GB_idiv_uint64(x, y)
    ccall((:GB_idiv_uint64, libgraphblas), UInt64, (UInt64, UInt64), x, y)
end

function GB_divcomplex(xr, xi, yr, yi, zr, zi)
    ccall((:GB_divcomplex, libgraphblas), Cint, (Cdouble, Cdouble, Cdouble, Cdouble, Ptr{Cdouble}, Ptr{Cdouble}), xr, xi, yr, yi, zr, zi)
end

function GB_powf(x, y)
    ccall((:GB_powf, libgraphblas), Cfloat, (Cfloat, Cfloat), x, y)
end

function GB_pow(x, y)
    ccall((:GB_pow, libgraphblas), Cdouble, (Cdouble, Cdouble), x, y)
end

function GB_cpowf(x, y)
    ccall((:GB_cpowf, libgraphblas), GxB_FC32_t, (GxB_FC32_t, GxB_FC32_t), x, y)
end

function GB_cpow(x, y)
    ccall((:GB_cpow, libgraphblas), GxB_FC64_t, (GxB_FC64_t, GxB_FC64_t), x, y)
end

function GB_pow_int8(x, y)
    ccall((:GB_pow_int8, libgraphblas), Int8, (Int8, Int8), x, y)
end

function GB_pow_int16(x, y)
    ccall((:GB_pow_int16, libgraphblas), Int16, (Int16, Int16), x, y)
end

function GB_pow_int32(x, y)
    ccall((:GB_pow_int32, libgraphblas), Int32, (Int32, Int32), x, y)
end

function GB_pow_int64(x, y)
    ccall((:GB_pow_int64, libgraphblas), Int64, (Int64, Int64), x, y)
end

function GB_pow_uint8(x, y)
    ccall((:GB_pow_uint8, libgraphblas), UInt8, (UInt8, UInt8), x, y)
end

function GB_pow_uint16(x, y)
    ccall((:GB_pow_uint16, libgraphblas), UInt16, (UInt16, UInt16), x, y)
end

function GB_pow_uint32(x, y)
    ccall((:GB_pow_uint32, libgraphblas), UInt32, (UInt32, UInt32), x, y)
end

function GB_pow_uint64(x, y)
    ccall((:GB_pow_uint64, libgraphblas), UInt64, (UInt64, UInt64), x, y)
end

function GB_frexpxf(x)
    ccall((:GB_frexpxf, libgraphblas), Cfloat, (Cfloat,), x)
end

function GB_frexpef(x)
    ccall((:GB_frexpef, libgraphblas), Cfloat, (Cfloat,), x)
end

function GB_frexpx(x)
    ccall((:GB_frexpx, libgraphblas), Cdouble, (Cdouble,), x)
end

function GB_frexpe(x)
    ccall((:GB_frexpe, libgraphblas), Cdouble, (Cdouble,), x)
end

function GB_signumf(x)
    ccall((:GB_signumf, libgraphblas), Cfloat, (Cfloat,), x)
end

function GB_signum(x)
    ccall((:GB_signum, libgraphblas), Cdouble, (Cdouble,), x)
end

function GB_csignumf(x)
    ccall((:GB_csignumf, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_csignum(x)
    ccall((:GB_csignum, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_cceilf(x)
    ccall((:GB_cceilf, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_cceil(x)
    ccall((:GB_cceil, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_cfloorf(x)
    ccall((:GB_cfloorf, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_cfloor(x)
    ccall((:GB_cfloor, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_croundf(x)
    ccall((:GB_croundf, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_cround(x)
    ccall((:GB_cround, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_ctruncf(x)
    ccall((:GB_ctruncf, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_ctrunc(x)
    ccall((:GB_ctrunc, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_cexp2f(x)
    ccall((:GB_cexp2f, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_cexp2(x)
    ccall((:GB_cexp2, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_cexpm1(x)
    ccall((:GB_cexpm1, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_cexpm1f(x)
    ccall((:GB_cexpm1f, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_clog1p(x)
    ccall((:GB_clog1p, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_clog1pf(x)
    ccall((:GB_clog1pf, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_clog10f(x)
    ccall((:GB_clog10f, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_clog10(x)
    ccall((:GB_clog10, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_clog2f(x)
    ccall((:GB_clog2f, libgraphblas), GxB_FC32_t, (GxB_FC32_t,), x)
end

function GB_clog2(x)
    ccall((:GB_clog2, libgraphblas), GxB_FC64_t, (GxB_FC64_t,), x)
end

function GB_cisinff(x)
    ccall((:GB_cisinff, libgraphblas), Bool, (GxB_FC32_t,), x)
end

function GB_cisinf(x)
    ccall((:GB_cisinf, libgraphblas), Bool, (GxB_FC64_t,), x)
end

function GB_cisnanf(x)
    ccall((:GB_cisnanf, libgraphblas), Bool, (GxB_FC32_t,), x)
end

function GB_cisnan(x)
    ccall((:GB_cisnan, libgraphblas), Bool, (GxB_FC64_t,), x)
end

function GB_cisfinitef(x)
    ccall((:GB_cisfinitef, libgraphblas), Bool, (GxB_FC32_t,), x)
end

function GB_cisfinite(x)
    ccall((:GB_cisfinite, libgraphblas), Bool, (GxB_FC64_t,), x)
end

function GB_bitshift_uint8(x, k)
    ccall((:GB_bitshift_uint8, libgraphblas), UInt8, (UInt8, Int8), x, k)
end

function GB_bitshift_uint16(x, k)
    ccall((:GB_bitshift_uint16, libgraphblas), UInt16, (UInt16, Int8), x, k)
end

function GB_bitshift_uint32(x, k)
    ccall((:GB_bitshift_uint32, libgraphblas), UInt32, (UInt32, Int8), x, k)
end

function GB_bitshift_uint64(x, k)
    ccall((:GB_bitshift_uint64, libgraphblas), UInt64, (UInt64, Int8), x, k)
end

function GB_bitshift_int8(x, k)
    ccall((:GB_bitshift_int8, libgraphblas), Int8, (Int8, Int8), x, k)
end

function GB_bitshift_int16(x, k)
    ccall((:GB_bitshift_int16, libgraphblas), Int16, (Int16, Int8), x, k)
end

function GB_bitshift_int32(x, k)
    ccall((:GB_bitshift_int32, libgraphblas), Int32, (Int32, Int8), x, k)
end

function GB_bitshift_int64(x, k)
    ccall((:GB_bitshift_int64, libgraphblas), Int64, (Int64, Int8), x, k)
end

function GB_lookup(A_is_hyper, Ah, Ap, avlen, pleft, pright, j, pstart, pend)
    ccall((:GB_lookup, libgraphblas), Bool, (Bool, Ptr{Int64}, Ptr{Int64}, Int64, Ptr{Int64}, Int64, Int64, Ptr{Int64}, Ptr{Int64}), A_is_hyper, Ah, Ap, avlen, pleft, pright, j, pstart, pend)
end

function GB_entry_check(type, x, pr, f)
    ccall((:GB_entry_check, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cvoid}, Cint, Ptr{Libc.FILE}), type, x, pr, f)
end

function GB_code_check(code, x, pr, f)
    ccall((:GB_code_check, libgraphblas), GrB_Info, (GB_Type_code, Ptr{Cvoid}, Cint, Ptr{Libc.FILE}), code, x, pr, f)
end

function GB_matvec_check(A, name, pr, f, kind)
    ccall((:GB_matvec_check, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, Cint, Ptr{Libc.FILE}, Ptr{Cchar}), A, name, pr, f, kind)
end

function GB_nnz_full(A)
    ccall((:GB_nnz_full, libgraphblas), Int64, (GrB_Matrix,), A)
end

function GB_nnz_held(A)
    ccall((:GB_nnz_held, libgraphblas), Int64, (GrB_Matrix,), A)
end

function GB_nnz_max(A)
    ccall((:GB_nnz_max, libgraphblas), Int64, (GrB_Matrix,), A)
end

function GB_nthreads(work, chunk, nthreads_max)
    ccall((:GB_nthreads, libgraphblas), Cint, (Cdouble, Cdouble, Cint), work, chunk, nthreads_max)
end

function GB_memoryUsage(nallocs, mem_deep, mem_shallow, A)
    ccall((:GB_memoryUsage, libgraphblas), GrB_Info, (Ptr{Int64}, Ptr{Csize_t}, Ptr{Csize_t}, GrB_Matrix), nallocs, mem_deep, mem_shallow, A)
end

function GB_free_memory(p, size_allocated)
    ccall((:GB_free_memory, libgraphblas), Cvoid, (Ptr{Ptr{Cvoid}}, Csize_t), p, size_allocated)
end

function GB_free_pool_finalize()
    ccall((:GB_free_pool_finalize, libgraphblas), Cvoid, ())
end

function GB_memcpy(dest, src, n, nthreads)
    ccall((:GB_memcpy, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t, Cint), dest, src, n, nthreads)
end

function GB_memset(dest, c, n, nthreads)
    ccall((:GB_memset, libgraphblas), Cvoid, (Ptr{Cvoid}, Cint, Csize_t, Cint), dest, c, n, nthreads)
end

@enum GB_iso_code::UInt32 begin
    GB_NON_ISO = 0
    GB_ISO_1 = 1
    GB_ISO_S = 2
    GB_ISO_A = 3
    GB_ISO_OP1_A = 4
    GB_ISO_OP2_SA = 5
    GB_ISO_OP2_AS = 6
end

function GB_iso_unop_code(A, op, binop_bind1st)
    ccall((:GB_iso_unop_code, libgraphblas), GB_iso_code, (GrB_Matrix, GB_Operator, Bool), A, op, binop_bind1st)
end

function GB_iso_unop(Cx, ctype, C_code_iso, op, A, scalar)
    ccall((:GB_iso_unop, libgraphblas), Cvoid, (Ptr{GB_void}, GrB_Type, GB_iso_code, GB_Operator, GrB_Matrix, GrB_Scalar), Cx, ctype, C_code_iso, op, A, scalar)
end

function GB_convert_any_to_non_iso(A, initialize, Contest)
    ccall((:GB_convert_any_to_non_iso, libgraphblas), GrB_Info, (GrB_Matrix, Bool, GB_Context), A, initialize, Contest)
end

function GB_convert_any_to_iso(A, scalar, Context)
    ccall((:GB_convert_any_to_iso, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GB_void}, GB_Context), A, scalar, Context)
end

function GB_iso_expand(X, n, scalar, size, Context)
    ccall((:GB_iso_expand, libgraphblas), Cvoid, (Ptr{Cvoid}, Int64, Ptr{Cvoid}, Csize_t, GB_Context), X, n, scalar, size, Context)
end

function GB_iso_check(A, Context)
    ccall((:GB_iso_check, libgraphblas), Bool, (GrB_Matrix, GB_Context), A, Context)
end

function GB_nvals(nvals, A, Context)
    ccall((:GB_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix, GB_Context), nvals, A, Context)
end

function GB_aliased(A, B)
    ccall((:GB_aliased, libgraphblas), Bool, (GrB_Matrix, GrB_Matrix), A, B)
end

function GB_is_shallow(A)
    ccall((:GB_is_shallow, libgraphblas), Bool, (GrB_Matrix,), A)
end

function GB_init(mode, malloc_function, realloc_function, free_function, Context)
    ccall((:GB_init, libgraphblas), GrB_Info, (GrB_Mode, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, GB_Context), mode, malloc_function, realloc_function, free_function, Context)
end

@enum GB_Ap_code::UInt32 begin
    GB_Ap_calloc = 0
    GB_Ap_malloc = 1
    GB_Ap_null = 2
end

function GB_Matrix_new(A, type, nrows, ncols, Context)
    ccall((:GB_Matrix_new, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, GB_Context), A, type, nrows, ncols, Context)
end

function GB_new(Ahandle, type, vlen, vdim, Ap_option, is_csc, sparsity, hyper_switch, plen, Context)
    ccall((:GB_new, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Int64, Int64, GB_Ap_code, Bool, Cint, Cfloat, Int64, GB_Context), Ahandle, type, vlen, vdim, Ap_option, is_csc, sparsity, hyper_switch, plen, Context)
end

function GB_new_bix(Ahandle, type, vlen, vdim, Ap_option, is_csc, sparsity, bitmap_calloc, hyper_switch, plen, nzmax, numeric, iso, Context)
    ccall((:GB_new_bix, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Int64, Int64, GB_Ap_code, Bool, Cint, Bool, Cfloat, Int64, Int64, Bool, Bool, GB_Context), Ahandle, type, vlen, vdim, Ap_option, is_csc, sparsity, bitmap_calloc, hyper_switch, plen, nzmax, numeric, iso, Context)
end

function GB_bix_alloc(A, nzmax, sparsity, bitmap_calloc, numeric, iso, Context)
    ccall((:GB_bix_alloc, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, Cint, Bool, Bool, Bool, GB_Context), A, nzmax, sparsity, bitmap_calloc, numeric, iso, Context)
end

function GB_ix_realloc(A, nzmax_new, Context)
    ccall((:GB_ix_realloc, libgraphblas), GrB_Info, (GrB_Matrix, Int64, GB_Context), A, nzmax_new, Context)
end

function GB_bix_free(A)
    ccall((:GB_bix_free, libgraphblas), Cvoid, (GrB_Matrix,), A)
end

function GB_ph_free(A)
    ccall((:GB_ph_free, libgraphblas), Cvoid, (GrB_Matrix,), A)
end

function GB_phbix_free(A)
    ccall((:GB_phbix_free, libgraphblas), Cvoid, (GrB_Matrix,), A)
end

function GB_Matrix_free(Ahandle)
    ccall((:GB_Matrix_free, libgraphblas), Cvoid, (Ptr{GrB_Matrix},), Ahandle)
end

function GB_resize(A, nrows_new, ncols_new, Context)
    ccall((:GB_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index, GB_Context), A, nrows_new, ncols_new, Context)
end

function GB_dup(Chandle, A, Context)
    ccall((:GB_dup, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Matrix, GB_Context), Chandle, A, Context)
end

function GB_dup_worker(Chandle, C_iso, A, numeric, ctype, Context)
    ccall((:GB_dup_worker, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Bool, GrB_Matrix, Bool, GrB_Type, GB_Context), Chandle, C_iso, A, numeric, ctype, Context)
end

function GB_code_compatible(acode, bcode)
    ccall((:GB_code_compatible, libgraphblas), Bool, (GB_Type_code, GB_Type_code), acode, bcode)
end

function GB_Type_compatible(atype, btype)
    ccall((:GB_Type_compatible, libgraphblas), Bool, (GrB_Type, GrB_Type), atype, btype)
end

function GB_compatible(ctype, C, M, Mask_struct, accum, ttype, Context)
    ccall((:GB_compatible, libgraphblas), GrB_Info, (GrB_Type, GrB_Matrix, GrB_Matrix, Bool, GrB_BinaryOp, GrB_Type, GB_Context), ctype, C, M, Mask_struct, accum, ttype, Context)
end

function GB_Mask_compatible(M, Mask_struct, C, nrows, ncols, Context)
    ccall((:GB_Mask_compatible, libgraphblas), GrB_Info, (GrB_Matrix, Bool, GrB_Matrix, GrB_Index, GrB_Index, GB_Context), M, Mask_struct, C, nrows, ncols, Context)
end

function GB_BinaryOp_compatible(op, ctype, atype, btype, bcode, Context)
    ccall((:GB_BinaryOp_compatible, libgraphblas), GrB_Info, (GrB_BinaryOp, GrB_Type, GrB_Type, GrB_Type, GB_Type_code, GB_Context), op, ctype, atype, btype, bcode, Context)
end

function GB_ewise_slice(p_TaskList, p_TaskList_size, p_ntasks, p_nthreads, Cnvec, Ch, C_to_M, C_to_A, C_to_B, Ch_is_Mh, M, A, B, Context)
    ccall((:GB_ewise_slice, libgraphblas), GrB_Info, (Ptr{Ptr{GB_task_struct}}, Ptr{Csize_t}, Ptr{Cint}, Ptr{Cint}, Int64, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Bool, GrB_Matrix, GrB_Matrix, GrB_Matrix, GB_Context), p_TaskList, p_TaskList_size, p_ntasks, p_nthreads, Cnvec, Ch, C_to_M, C_to_A, C_to_B, Ch_is_Mh, M, A, B, Context)
end

function GB_slice_vector(p_i, p_pM, p_pA, p_pB, pM_start, pM_end, Mi, pA_start, pA_end, Ai, pB_start, pB_end, Bi, vlen, target_work)
    ccall((:GB_slice_vector, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Int64, Int64, Ptr{Int64}, Int64, Int64, Ptr{Int64}, Int64, Int64, Ptr{Int64}, Int64, Cdouble), p_i, p_pM, p_pA, p_pB, pM_start, pM_end, Mi, pA_start, pA_end, Ai, pB_start, pB_end, Bi, vlen, target_work)
end

function GB_task_cumsum(Cp, Cnvec, Cnvec_nonempty, TaskList, ntasks, nthreads, Context)
    ccall((:GB_task_cumsum, libgraphblas), Cvoid, (Ptr{Int64}, Int64, Ptr{Int64}, Ptr{GB_task_struct}, Cint, Cint, GB_Context), Cp, Cnvec, Cnvec_nonempty, TaskList, ntasks, nthreads, Context)
end

function GB_transplant(C, ctype, Ahandle, Context)
    ccall((:GB_transplant, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Type, Ptr{GrB_Matrix}, GB_Context), C, ctype, Ahandle, Context)
end

function GB_transplant_conform(C, ctype, Thandle, Context)
    ccall((:GB_transplant_conform, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Type, Ptr{GrB_Matrix}, GB_Context), C, ctype, Thandle, Context)
end

function GB_matvec_type(type, A, Context)
    ccall((:GB_matvec_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Matrix, GB_Context), type, A, Context)
end

function GB_matvec_type_name(type_name, A, Context)
    ccall((:GB_matvec_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Matrix, GB_Context), type_name, A, Context)
end

function GB_code_size(code, usize)
    ccall((:GB_code_size, libgraphblas), Csize_t, (GB_Type_code, Csize_t), code, usize)
end

function GB_code_type(code, type)
    ccall((:GB_code_type, libgraphblas), GrB_Type, (GB_Type_code, GrB_Type), code, type)
end

function GB_code_string(code)
    ccall((:GB_code_string, libgraphblas), Ptr{Cchar}, (GB_Type_code,), code)
end

function GB_pslice(Slice, Ap, n, ntasks, perfectly_balanced)
    ccall((:GB_pslice, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Int64, Cint, Bool), Slice, Ap, n, ntasks, perfectly_balanced)
end

function GB_eslice(Slice, e, ntasks)
    ccall((:GB_eslice, libgraphblas), Cvoid, (Ptr{Int64}, Int64, Cint), Slice, e, ntasks)
end

function GB_int64_multiply(c, a, b)
    ccall((:GB_int64_multiply, libgraphblas), Bool, (Ptr{GrB_Index}, Int64, Int64), c, a, b)
end

function GB_size_t_multiply(c, a, b)
    ccall((:GB_size_t_multiply, libgraphblas), Bool, (Ptr{Csize_t}, Csize_t, Csize_t), c, a, b)
end

function GB_extract_vector_list(J, A, Context)
    ccall((:GB_extract_vector_list, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Matrix, GB_Context), J, A, Context)
end

function GB_extractTuples(I_out, J_out, X, p_nvals, xcode, A, Context)
    ccall((:GB_extractTuples, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GB_Type_code, GrB_Matrix, GB_Context), I_out, J_out, X, p_nvals, xcode, A, Context)
end

function GB_cumsum(count, n, kresult, nthreads, Context)
    ccall((:GB_cumsum, libgraphblas), Cvoid, (Ptr{Int64}, Int64, Ptr{Int64}, Cint, GB_Context), count, n, kresult, nthreads, Context)
end

function GB_setElement(C, accum, scalar, row, col, scalar_code, Context)
    ccall((:GB_setElement, libgraphblas), GrB_Info, (GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, GrB_Index, GrB_Index, GB_Type_code, GB_Context), C, accum, scalar, row, col, scalar_code, Context)
end

function GB_Vector_removeElement(V, i, Context)
    ccall((:GB_Vector_removeElement, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index, GB_Context), V, i, Context)
end

function GB_Matrix_removeElement(C, row, col, Context)
    ccall((:GB_Matrix_removeElement, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index, GB_Context), C, row, col, Context)
end

function GB_Op_free(op_handle)
    ccall((:GB_Op_free, libgraphblas), GrB_Info, (Ptr{GB_Operator},), op_handle)
end

function GB_op_is_second(op, type)
    ccall((:GB_op_is_second, libgraphblas), Bool, (GrB_BinaryOp, GrB_Type), op, type)
end

function GB_op_name_and_defn(operator_name, operator_defn, input_name, input_defn, typecast_name, typecast_name_len)
    ccall((:GB_op_name_and_defn, libgraphblas), Cvoid, (Ptr{Cchar}, Ptr{Ptr{Cchar}}, Ptr{Cchar}, Ptr{Cchar}, Ptr{Cchar}, Csize_t), operator_name, operator_defn, input_name, input_defn, typecast_name, typecast_name_len)
end

function GB_unop_one(xcode)
    ccall((:GB_unop_one, libgraphblas), GrB_UnaryOp, (GB_Type_code,), xcode)
end

function GB_nvec_nonempty(A, Context)
    ccall((:GB_nvec_nonempty, libgraphblas), Int64, (GrB_Matrix, GB_Context), A, Context)
end

function GB_hyper_realloc(A, plen_new, Context)
    ccall((:GB_hyper_realloc, libgraphblas), GrB_Info, (GrB_Matrix, Int64, GB_Context), A, plen_new, Context)
end

function GB_conform_hyper(A, Context)
    ccall((:GB_conform_hyper, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_hyper_prune(p_Ap, p_Ap_size, p_Ah, p_Ah_size, p_nvec, Ap_old, Ah_old, nvec_old, Context)
    ccall((:GB_hyper_prune, libgraphblas), GrB_Info, (Ptr{Ptr{Int64}}, Ptr{Csize_t}, Ptr{Ptr{Int64}}, Ptr{Csize_t}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Int64, GB_Context), p_Ap, p_Ap_size, p_Ah, p_Ah_size, p_nvec, Ap_old, Ah_old, nvec_old, Context)
end

function GB_hypermatrix_prune(A, Context)
    ccall((:GB_hypermatrix_prune, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_cast_scalar(z, zcode, x, xcode, size)
    ccall((:GB_cast_scalar, libgraphblas), Cvoid, (Ptr{Cvoid}, GB_Type_code, Ptr{Cvoid}, GB_Type_code, Csize_t), z, zcode, x, xcode, size)
end

function GB_cast_one(z, zcode)
    ccall((:GB_cast_one, libgraphblas), Cvoid, (Ptr{Cvoid}, GB_Type_code), z, zcode)
end

function GB_cast_array(Cx, code1, Ax, code2, Ab, anz, nthreads)
    ccall((:GB_cast_array, libgraphblas), Cvoid, (Ptr{GB_void}, GB_Type_code, Ptr{GB_void}, GB_Type_code, Ptr{Int8}, Int64, Cint), Cx, code1, Ax, code2, Ab, anz, nthreads)
end

function GB_cast_matrix(C, A, Context)
    ccall((:GB_cast_matrix, libgraphblas), Cvoid, (GrB_Matrix, GrB_Matrix, GB_Context), C, A, Context)
end

function GB_block(A, Context)
    ccall((:GB_block, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_unjumble(A, Context)
    ccall((:GB_unjumble, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_sparsity(A)
    ccall((:GB_sparsity, libgraphblas), Cint, (GrB_Matrix,), A)
end

function GB_convert_hyper_to_sparse(A, Context)
    ccall((:GB_convert_hyper_to_sparse, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_convert_sparse_to_hyper(A, Context)
    ccall((:GB_convert_sparse_to_hyper, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_convert_hyper_to_sparse_test(hyper_switch, k, vdim)
    ccall((:GB_convert_hyper_to_sparse_test, libgraphblas), Bool, (Cfloat, Int64, Int64), hyper_switch, k, vdim)
end

function GB_convert_sparse_to_hyper_test(hyper_switch, k, vdim)
    ccall((:GB_convert_sparse_to_hyper_test, libgraphblas), Bool, (Cfloat, Int64, Int64), hyper_switch, k, vdim)
end

function GB_convert_bitmap_to_sparse_test(bitmap_switch, anz, vlen, vdim)
    ccall((:GB_convert_bitmap_to_sparse_test, libgraphblas), Bool, (Cfloat, Int64, Int64, Int64), bitmap_switch, anz, vlen, vdim)
end

function GB_convert_sparse_to_bitmap_test(bitmap_switch, anz, vlen, vdim)
    ccall((:GB_convert_sparse_to_bitmap_test, libgraphblas), Bool, (Cfloat, Int64, Int64, Int64), bitmap_switch, anz, vlen, vdim)
end

function GB_convert_full_to_bitmap(A, Context)
    ccall((:GB_convert_full_to_bitmap, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_convert_sparse_to_bitmap(A, Context)
    ccall((:GB_convert_sparse_to_bitmap, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_convert_bitmap_worker(Ap, Ai, Aj, Ax_new, anvec_nonempty, A, Context)
    ccall((:GB_convert_bitmap_worker, libgraphblas), GrB_Info, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{GB_void}, Ptr{Int64}, GrB_Matrix, GB_Context), Ap, Ai, Aj, Ax_new, anvec_nonempty, A, Context)
end

function GB_convert_any_to_bitmap(A, Context)
    ccall((:GB_convert_any_to_bitmap, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_convert_any_to_hyper(A, Context)
    ccall((:GB_convert_any_to_hyper, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_convert_any_to_sparse(A, Context)
    ccall((:GB_convert_any_to_sparse, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_convert_to_nonfull(A, Context)
    ccall((:GB_convert_to_nonfull, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_as_if_full(A)
    ccall((:GB_as_if_full, libgraphblas), Bool, (GrB_Matrix,), A)
end

function GB_conform(A, Context)
    ccall((:GB_conform, libgraphblas), GrB_Info, (GrB_Matrix, GB_Context), A, Context)
end

function GB_sparsity_char(sparsity)
    ccall((:GB_sparsity_char, libgraphblas), Ptr{Cchar}, (Cint,), sparsity)
end

function GB_sparsity_char_matrix(A)
    ccall((:GB_sparsity_char_matrix, libgraphblas), Ptr{Cchar}, (GrB_Matrix,), A)
end

function GB_hyper_shallow(C, A)
    ccall((:GB_hyper_shallow, libgraphblas), GrB_Matrix, (GrB_Matrix, GrB_Matrix), C, A)
end

function GB__func_ONE_BOOL(z, x)
    ccall((:GB__func_ONE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}), z, x)
end

function GB__func_IDENTITY_BOOL(z, x)
    ccall((:GB__func_IDENTITY_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}), z, x)
end

function GB__func_AINV_BOOL(z, x)
    ccall((:GB__func_AINV_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}), z, x)
end

function GB__func_MINV_BOOL(z, x)
    ccall((:GB__func_MINV_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}), z, x)
end

function GB__func_ABS_BOOL(z, x)
    ccall((:GB__func_ABS_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}), z, x)
end

function GB__func_LNOT_BOOL(z, x)
    ccall((:GB__func_LNOT_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}), z, x)
end

function GB__func_FIRST_BOOL(z, x, y)
    ccall((:GB__func_FIRST_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_SECOND_BOOL(z, x, y)
    ccall((:GB__func_SECOND_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_PAIR_BOOL(z, x, y)
    ccall((:GB__func_PAIR_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_ANY_BOOL(z, x, y)
    ccall((:GB__func_ANY_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_PLUS_BOOL(z, x, y)
    ccall((:GB__func_PLUS_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_MINUS_BOOL(z, x, y)
    ccall((:GB__func_MINUS_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_RMINUS_BOOL(z, x, y)
    ccall((:GB__func_RMINUS_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_TIMES_BOOL(z, x, y)
    ccall((:GB__func_TIMES_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_DIV_BOOL(z, x, y)
    ccall((:GB__func_DIV_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_RDIV_BOOL(z, x, y)
    ccall((:GB__func_RDIV_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_POW_BOOL(z, x, y)
    ccall((:GB__func_POW_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_MIN_BOOL(z, x, y)
    ccall((:GB__func_MIN_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_MAX_BOOL(z, x, y)
    ccall((:GB__func_MAX_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_ISEQ_BOOL(z, x, y)
    ccall((:GB__func_ISEQ_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_ISNE_BOOL(z, x, y)
    ccall((:GB__func_ISNE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_ISGT_BOOL(z, x, y)
    ccall((:GB__func_ISGT_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_ISLT_BOOL(z, x, y)
    ccall((:GB__func_ISLT_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_ISGE_BOOL(z, x, y)
    ccall((:GB__func_ISGE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_ISLE_BOOL(z, x, y)
    ccall((:GB__func_ISLE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_LOR_BOOL(z, x, y)
    ccall((:GB__func_LOR_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_LAND_BOOL(z, x, y)
    ccall((:GB__func_LAND_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_LXOR_BOOL(z, x, y)
    ccall((:GB__func_LXOR_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_EQ_BOOL(z, x, y)
    ccall((:GB__func_EQ_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_NE_BOOL(z, x, y)
    ccall((:GB__func_NE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_GT_BOOL(z, x, y)
    ccall((:GB__func_GT_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_LT_BOOL(z, x, y)
    ccall((:GB__func_LT_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_GE_BOOL(z, x, y)
    ccall((:GB__func_GE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_LE_BOOL(z, x, y)
    ccall((:GB__func_LE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, Ptr{Bool}), z, x, y)
end

function GB__func_VALUEEQ_BOOL(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_BOOL(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_BOOL(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_BOOL(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_BOOL(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_BOOL(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_INT8(z, x)
    ccall((:GB__func_ONE_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}), z, x)
end

function GB__func_IDENTITY_INT8(z, x)
    ccall((:GB__func_IDENTITY_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}), z, x)
end

function GB__func_AINV_INT8(z, x)
    ccall((:GB__func_AINV_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}), z, x)
end

function GB__func_MINV_INT8(z, x)
    ccall((:GB__func_MINV_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}), z, x)
end

function GB__func_ABS_INT8(z, x)
    ccall((:GB__func_ABS_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}), z, x)
end

function GB__func_LNOT_INT8(z, x)
    ccall((:GB__func_LNOT_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}), z, x)
end

function GB__func_BNOT_INT8(z, x)
    ccall((:GB__func_BNOT_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}), z, x)
end

function GB__func_FIRST_INT8(z, x, y)
    ccall((:GB__func_FIRST_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_SECOND_INT8(z, x, y)
    ccall((:GB__func_SECOND_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_PAIR_INT8(z, x, y)
    ccall((:GB__func_PAIR_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_ANY_INT8(z, x, y)
    ccall((:GB__func_ANY_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_PLUS_INT8(z, x, y)
    ccall((:GB__func_PLUS_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_MINUS_INT8(z, x, y)
    ccall((:GB__func_MINUS_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_RMINUS_INT8(z, x, y)
    ccall((:GB__func_RMINUS_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_TIMES_INT8(z, x, y)
    ccall((:GB__func_TIMES_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_DIV_INT8(z, x, y)
    ccall((:GB__func_DIV_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_RDIV_INT8(z, x, y)
    ccall((:GB__func_RDIV_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_POW_INT8(z, x, y)
    ccall((:GB__func_POW_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_MIN_INT8(z, x, y)
    ccall((:GB__func_MIN_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_MAX_INT8(z, x, y)
    ccall((:GB__func_MAX_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_BOR_INT8(z, x, y)
    ccall((:GB__func_BOR_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_BAND_INT8(z, x, y)
    ccall((:GB__func_BAND_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_BXOR_INT8(z, x, y)
    ccall((:GB__func_BXOR_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_BXNOR_INT8(z, x, y)
    ccall((:GB__func_BXNOR_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_BGET_INT8(z, x, y)
    ccall((:GB__func_BGET_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_BSET_INT8(z, x, y)
    ccall((:GB__func_BSET_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_BCLR_INT8(z, x, y)
    ccall((:GB__func_BCLR_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_BSHIFT_INT8(z, x, y)
    ccall((:GB__func_BSHIFT_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_ISEQ_INT8(z, x, y)
    ccall((:GB__func_ISEQ_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_ISNE_INT8(z, x, y)
    ccall((:GB__func_ISNE_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_ISGT_INT8(z, x, y)
    ccall((:GB__func_ISGT_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_ISLT_INT8(z, x, y)
    ccall((:GB__func_ISLT_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_ISGE_INT8(z, x, y)
    ccall((:GB__func_ISGE_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_ISLE_INT8(z, x, y)
    ccall((:GB__func_ISLE_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_LOR_INT8(z, x, y)
    ccall((:GB__func_LOR_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_LAND_INT8(z, x, y)
    ccall((:GB__func_LAND_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_LXOR_INT8(z, x, y)
    ccall((:GB__func_LXOR_INT8, libgraphblas), Cvoid, (Ptr{Int8}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_EQ_INT8(z, x, y)
    ccall((:GB__func_EQ_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_NE_INT8(z, x, y)
    ccall((:GB__func_NE_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_GT_INT8(z, x, y)
    ccall((:GB__func_GT_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_LT_INT8(z, x, y)
    ccall((:GB__func_LT_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_GE_INT8(z, x, y)
    ccall((:GB__func_GE_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_LE_INT8(z, x, y)
    ccall((:GB__func_LE_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, Ptr{Int8}), z, x, y)
end

function GB__func_VALUEEQ_INT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_INT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_INT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_INT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_INT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_INT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_INT16(z, x)
    ccall((:GB__func_ONE_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}), z, x)
end

function GB__func_IDENTITY_INT16(z, x)
    ccall((:GB__func_IDENTITY_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}), z, x)
end

function GB__func_AINV_INT16(z, x)
    ccall((:GB__func_AINV_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}), z, x)
end

function GB__func_MINV_INT16(z, x)
    ccall((:GB__func_MINV_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}), z, x)
end

function GB__func_ABS_INT16(z, x)
    ccall((:GB__func_ABS_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}), z, x)
end

function GB__func_LNOT_INT16(z, x)
    ccall((:GB__func_LNOT_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}), z, x)
end

function GB__func_BNOT_INT16(z, x)
    ccall((:GB__func_BNOT_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}), z, x)
end

function GB__func_FIRST_INT16(z, x, y)
    ccall((:GB__func_FIRST_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_SECOND_INT16(z, x, y)
    ccall((:GB__func_SECOND_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_PAIR_INT16(z, x, y)
    ccall((:GB__func_PAIR_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_ANY_INT16(z, x, y)
    ccall((:GB__func_ANY_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_PLUS_INT16(z, x, y)
    ccall((:GB__func_PLUS_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_MINUS_INT16(z, x, y)
    ccall((:GB__func_MINUS_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_RMINUS_INT16(z, x, y)
    ccall((:GB__func_RMINUS_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_TIMES_INT16(z, x, y)
    ccall((:GB__func_TIMES_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_DIV_INT16(z, x, y)
    ccall((:GB__func_DIV_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_RDIV_INT16(z, x, y)
    ccall((:GB__func_RDIV_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_POW_INT16(z, x, y)
    ccall((:GB__func_POW_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_MIN_INT16(z, x, y)
    ccall((:GB__func_MIN_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_MAX_INT16(z, x, y)
    ccall((:GB__func_MAX_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_BOR_INT16(z, x, y)
    ccall((:GB__func_BOR_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_BAND_INT16(z, x, y)
    ccall((:GB__func_BAND_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_BXOR_INT16(z, x, y)
    ccall((:GB__func_BXOR_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_BXNOR_INT16(z, x, y)
    ccall((:GB__func_BXNOR_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_BGET_INT16(z, x, y)
    ccall((:GB__func_BGET_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_BSET_INT16(z, x, y)
    ccall((:GB__func_BSET_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_BCLR_INT16(z, x, y)
    ccall((:GB__func_BCLR_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_BSHIFT_INT16(z, x, y)
    ccall((:GB__func_BSHIFT_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int8}), z, x, y)
end

function GB__func_ISEQ_INT16(z, x, y)
    ccall((:GB__func_ISEQ_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_ISNE_INT16(z, x, y)
    ccall((:GB__func_ISNE_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_ISGT_INT16(z, x, y)
    ccall((:GB__func_ISGT_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_ISLT_INT16(z, x, y)
    ccall((:GB__func_ISLT_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_ISGE_INT16(z, x, y)
    ccall((:GB__func_ISGE_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_ISLE_INT16(z, x, y)
    ccall((:GB__func_ISLE_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_LOR_INT16(z, x, y)
    ccall((:GB__func_LOR_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_LAND_INT16(z, x, y)
    ccall((:GB__func_LAND_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_LXOR_INT16(z, x, y)
    ccall((:GB__func_LXOR_INT16, libgraphblas), Cvoid, (Ptr{Int16}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_EQ_INT16(z, x, y)
    ccall((:GB__func_EQ_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_NE_INT16(z, x, y)
    ccall((:GB__func_NE_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_GT_INT16(z, x, y)
    ccall((:GB__func_GT_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_LT_INT16(z, x, y)
    ccall((:GB__func_LT_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_GE_INT16(z, x, y)
    ccall((:GB__func_GE_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_LE_INT16(z, x, y)
    ccall((:GB__func_LE_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, Ptr{Int16}), z, x, y)
end

function GB__func_VALUEEQ_INT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_INT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_INT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_INT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_INT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_INT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_INT32(z, x)
    ccall((:GB__func_ONE_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}), z, x)
end

function GB__func_IDENTITY_INT32(z, x)
    ccall((:GB__func_IDENTITY_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}), z, x)
end

function GB__func_AINV_INT32(z, x)
    ccall((:GB__func_AINV_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}), z, x)
end

function GB__func_MINV_INT32(z, x)
    ccall((:GB__func_MINV_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}), z, x)
end

function GB__func_ABS_INT32(z, x)
    ccall((:GB__func_ABS_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}), z, x)
end

function GB__func_LNOT_INT32(z, x)
    ccall((:GB__func_LNOT_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}), z, x)
end

function GB__func_BNOT_INT32(z, x)
    ccall((:GB__func_BNOT_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}), z, x)
end

function GB__func_FIRST_INT32(z, x, y)
    ccall((:GB__func_FIRST_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_SECOND_INT32(z, x, y)
    ccall((:GB__func_SECOND_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_PAIR_INT32(z, x, y)
    ccall((:GB__func_PAIR_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_ANY_INT32(z, x, y)
    ccall((:GB__func_ANY_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_PLUS_INT32(z, x, y)
    ccall((:GB__func_PLUS_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_MINUS_INT32(z, x, y)
    ccall((:GB__func_MINUS_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_RMINUS_INT32(z, x, y)
    ccall((:GB__func_RMINUS_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_TIMES_INT32(z, x, y)
    ccall((:GB__func_TIMES_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_DIV_INT32(z, x, y)
    ccall((:GB__func_DIV_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_RDIV_INT32(z, x, y)
    ccall((:GB__func_RDIV_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_POW_INT32(z, x, y)
    ccall((:GB__func_POW_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_MIN_INT32(z, x, y)
    ccall((:GB__func_MIN_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_MAX_INT32(z, x, y)
    ccall((:GB__func_MAX_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_BOR_INT32(z, x, y)
    ccall((:GB__func_BOR_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_BAND_INT32(z, x, y)
    ccall((:GB__func_BAND_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_BXOR_INT32(z, x, y)
    ccall((:GB__func_BXOR_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_BXNOR_INT32(z, x, y)
    ccall((:GB__func_BXNOR_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_BGET_INT32(z, x, y)
    ccall((:GB__func_BGET_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_BSET_INT32(z, x, y)
    ccall((:GB__func_BSET_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_BCLR_INT32(z, x, y)
    ccall((:GB__func_BCLR_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_BSHIFT_INT32(z, x, y)
    ccall((:GB__func_BSHIFT_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int8}), z, x, y)
end

function GB__func_ISEQ_INT32(z, x, y)
    ccall((:GB__func_ISEQ_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_ISNE_INT32(z, x, y)
    ccall((:GB__func_ISNE_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_ISGT_INT32(z, x, y)
    ccall((:GB__func_ISGT_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_ISLT_INT32(z, x, y)
    ccall((:GB__func_ISLT_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_ISGE_INT32(z, x, y)
    ccall((:GB__func_ISGE_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_ISLE_INT32(z, x, y)
    ccall((:GB__func_ISLE_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_LOR_INT32(z, x, y)
    ccall((:GB__func_LOR_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_LAND_INT32(z, x, y)
    ccall((:GB__func_LAND_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_LXOR_INT32(z, x, y)
    ccall((:GB__func_LXOR_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_EQ_INT32(z, x, y)
    ccall((:GB__func_EQ_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_NE_INT32(z, x, y)
    ccall((:GB__func_NE_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_GT_INT32(z, x, y)
    ccall((:GB__func_GT_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_LT_INT32(z, x, y)
    ccall((:GB__func_LT_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_GE_INT32(z, x, y)
    ccall((:GB__func_GE_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_LE_INT32(z, x, y)
    ccall((:GB__func_LE_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, Ptr{Int32}), z, x, y)
end

function GB__func_ROWINDEX_INT32(z, unused, i, j_unused, thunk)
    ccall((:GB__func_ROWINDEX_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int32}), z, unused, i, j_unused, thunk)
end

function GB__func_COLINDEX_INT32(z, unused, i_unused, j, thunk)
    ccall((:GB__func_COLINDEX_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int32}), z, unused, i_unused, j, thunk)
end

function GB__func_DIAGINDEX_INT32(z, unused, i, j, thunk)
    ccall((:GB__func_DIAGINDEX_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int32}), z, unused, i, j, thunk)
end

function GB__func_FLIPDIAGINDEX_INT32(z, unused, i, j, thunk)
    ccall((:GB__func_FLIPDIAGINDEX_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int32}), z, unused, i, j, thunk)
end

function GB__func_VALUEEQ_INT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_INT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_INT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_INT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_INT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_INT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_INT64(z, x)
    ccall((:GB__func_ONE_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}), z, x)
end

function GB__func_IDENTITY_INT64(z, x)
    ccall((:GB__func_IDENTITY_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}), z, x)
end

function GB__func_AINV_INT64(z, x)
    ccall((:GB__func_AINV_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}), z, x)
end

function GB__func_MINV_INT64(z, x)
    ccall((:GB__func_MINV_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}), z, x)
end

function GB__func_ABS_INT64(z, x)
    ccall((:GB__func_ABS_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}), z, x)
end

function GB__func_LNOT_INT64(z, x)
    ccall((:GB__func_LNOT_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}), z, x)
end

function GB__func_BNOT_INT64(z, x)
    ccall((:GB__func_BNOT_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}), z, x)
end

function GB__func_FIRST_INT64(z, x, y)
    ccall((:GB__func_FIRST_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_SECOND_INT64(z, x, y)
    ccall((:GB__func_SECOND_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_PAIR_INT64(z, x, y)
    ccall((:GB__func_PAIR_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_ANY_INT64(z, x, y)
    ccall((:GB__func_ANY_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_PLUS_INT64(z, x, y)
    ccall((:GB__func_PLUS_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_MINUS_INT64(z, x, y)
    ccall((:GB__func_MINUS_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_RMINUS_INT64(z, x, y)
    ccall((:GB__func_RMINUS_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_TIMES_INT64(z, x, y)
    ccall((:GB__func_TIMES_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_DIV_INT64(z, x, y)
    ccall((:GB__func_DIV_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_RDIV_INT64(z, x, y)
    ccall((:GB__func_RDIV_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_POW_INT64(z, x, y)
    ccall((:GB__func_POW_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_MIN_INT64(z, x, y)
    ccall((:GB__func_MIN_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_MAX_INT64(z, x, y)
    ccall((:GB__func_MAX_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_BOR_INT64(z, x, y)
    ccall((:GB__func_BOR_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_BAND_INT64(z, x, y)
    ccall((:GB__func_BAND_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_BXOR_INT64(z, x, y)
    ccall((:GB__func_BXOR_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_BXNOR_INT64(z, x, y)
    ccall((:GB__func_BXNOR_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_BGET_INT64(z, x, y)
    ccall((:GB__func_BGET_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_BSET_INT64(z, x, y)
    ccall((:GB__func_BSET_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_BCLR_INT64(z, x, y)
    ccall((:GB__func_BCLR_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_BSHIFT_INT64(z, x, y)
    ccall((:GB__func_BSHIFT_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int8}), z, x, y)
end

function GB__func_ISEQ_INT64(z, x, y)
    ccall((:GB__func_ISEQ_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_ISNE_INT64(z, x, y)
    ccall((:GB__func_ISNE_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_ISGT_INT64(z, x, y)
    ccall((:GB__func_ISGT_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_ISLT_INT64(z, x, y)
    ccall((:GB__func_ISLT_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_ISGE_INT64(z, x, y)
    ccall((:GB__func_ISGE_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_ISLE_INT64(z, x, y)
    ccall((:GB__func_ISLE_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_LOR_INT64(z, x, y)
    ccall((:GB__func_LOR_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_LAND_INT64(z, x, y)
    ccall((:GB__func_LAND_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_LXOR_INT64(z, x, y)
    ccall((:GB__func_LXOR_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_EQ_INT64(z, x, y)
    ccall((:GB__func_EQ_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_NE_INT64(z, x, y)
    ccall((:GB__func_NE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_GT_INT64(z, x, y)
    ccall((:GB__func_GT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_LT_INT64(z, x, y)
    ccall((:GB__func_LT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_GE_INT64(z, x, y)
    ccall((:GB__func_GE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_LE_INT64(z, x, y)
    ccall((:GB__func_LE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, Ptr{Int64}), z, x, y)
end

function GB__func_ROWINDEX_INT64(z, unused, i, j_unused, thunk)
    ccall((:GB__func_ROWINDEX_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j_unused, thunk)
end

function GB__func_COLINDEX_INT64(z, unused, i_unused, j, thunk)
    ccall((:GB__func_COLINDEX_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i_unused, j, thunk)
end

function GB__func_DIAGINDEX_INT64(z, unused, i, j, thunk)
    ccall((:GB__func_DIAGINDEX_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, thunk)
end

function GB__func_FLIPDIAGINDEX_INT64(z, unused, i, j, thunk)
    ccall((:GB__func_FLIPDIAGINDEX_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, thunk)
end

function GB__func_TRIL_INT64(z, unused, i, j, thunk)
    ccall((:GB__func_TRIL_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, thunk)
end

function GB__func_TRIU_INT64(z, unused, i, j, thunk)
    ccall((:GB__func_TRIU_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, thunk)
end

function GB__func_DIAG_INT64(z, unused, i, j, thunk)
    ccall((:GB__func_DIAG_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, thunk)
end

function GB__func_OFFDIAG_INT64(z, unused, i, j, thunk)
    ccall((:GB__func_OFFDIAG_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, thunk)
end

function GB__func_COLLE_INT64(z, unused, i_unused, j, thunk)
    ccall((:GB__func_COLLE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i_unused, j, thunk)
end

function GB__func_COLGT_INT64(z, unused, i_unused, j, thunk)
    ccall((:GB__func_COLGT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i_unused, j, thunk)
end

function GB__func_ROWLE_INT64(z, unused, i, j_unused, thunk)
    ccall((:GB__func_ROWLE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j_unused, thunk)
end

function GB__func_ROWGT_INT64(z, unused, i, j_unused, thunk)
    ccall((:GB__func_ROWGT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j_unused, thunk)
end

function GB__func_VALUEEQ_INT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_INT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_INT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_INT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_INT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_INT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_UINT8(z, x)
    ccall((:GB__func_ONE_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}), z, x)
end

function GB__func_IDENTITY_UINT8(z, x)
    ccall((:GB__func_IDENTITY_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}), z, x)
end

function GB__func_AINV_UINT8(z, x)
    ccall((:GB__func_AINV_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}), z, x)
end

function GB__func_MINV_UINT8(z, x)
    ccall((:GB__func_MINV_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}), z, x)
end

function GB__func_ABS_UINT8(z, x)
    ccall((:GB__func_ABS_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}), z, x)
end

function GB__func_LNOT_UINT8(z, x)
    ccall((:GB__func_LNOT_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}), z, x)
end

function GB__func_BNOT_UINT8(z, x)
    ccall((:GB__func_BNOT_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}), z, x)
end

function GB__func_FIRST_UINT8(z, x, y)
    ccall((:GB__func_FIRST_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_SECOND_UINT8(z, x, y)
    ccall((:GB__func_SECOND_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_PAIR_UINT8(z, x, y)
    ccall((:GB__func_PAIR_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_ANY_UINT8(z, x, y)
    ccall((:GB__func_ANY_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_PLUS_UINT8(z, x, y)
    ccall((:GB__func_PLUS_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_MINUS_UINT8(z, x, y)
    ccall((:GB__func_MINUS_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_RMINUS_UINT8(z, x, y)
    ccall((:GB__func_RMINUS_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_TIMES_UINT8(z, x, y)
    ccall((:GB__func_TIMES_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_DIV_UINT8(z, x, y)
    ccall((:GB__func_DIV_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_RDIV_UINT8(z, x, y)
    ccall((:GB__func_RDIV_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_POW_UINT8(z, x, y)
    ccall((:GB__func_POW_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_MIN_UINT8(z, x, y)
    ccall((:GB__func_MIN_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_MAX_UINT8(z, x, y)
    ccall((:GB__func_MAX_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_BOR_UINT8(z, x, y)
    ccall((:GB__func_BOR_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_BAND_UINT8(z, x, y)
    ccall((:GB__func_BAND_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_BXOR_UINT8(z, x, y)
    ccall((:GB__func_BXOR_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_BXNOR_UINT8(z, x, y)
    ccall((:GB__func_BXNOR_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_BGET_UINT8(z, x, y)
    ccall((:GB__func_BGET_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_BSET_UINT8(z, x, y)
    ccall((:GB__func_BSET_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_BCLR_UINT8(z, x, y)
    ccall((:GB__func_BCLR_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_BSHIFT_UINT8(z, x, y)
    ccall((:GB__func_BSHIFT_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{Int8}), z, x, y)
end

function GB__func_ISEQ_UINT8(z, x, y)
    ccall((:GB__func_ISEQ_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_ISNE_UINT8(z, x, y)
    ccall((:GB__func_ISNE_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_ISGT_UINT8(z, x, y)
    ccall((:GB__func_ISGT_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_ISLT_UINT8(z, x, y)
    ccall((:GB__func_ISLT_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_ISGE_UINT8(z, x, y)
    ccall((:GB__func_ISGE_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_ISLE_UINT8(z, x, y)
    ccall((:GB__func_ISLE_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_LOR_UINT8(z, x, y)
    ccall((:GB__func_LOR_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_LAND_UINT8(z, x, y)
    ccall((:GB__func_LAND_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_LXOR_UINT8(z, x, y)
    ccall((:GB__func_LXOR_UINT8, libgraphblas), Cvoid, (Ptr{UInt8}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_EQ_UINT8(z, x, y)
    ccall((:GB__func_EQ_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_NE_UINT8(z, x, y)
    ccall((:GB__func_NE_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_GT_UINT8(z, x, y)
    ccall((:GB__func_GT_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_LT_UINT8(z, x, y)
    ccall((:GB__func_LT_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_GE_UINT8(z, x, y)
    ccall((:GB__func_GE_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_LE_UINT8(z, x, y)
    ccall((:GB__func_LE_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, Ptr{UInt8}), z, x, y)
end

function GB__func_VALUEEQ_UINT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_UINT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_UINT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_UINT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_UINT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_UINT8(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_UINT16(z, x)
    ccall((:GB__func_ONE_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}), z, x)
end

function GB__func_IDENTITY_UINT16(z, x)
    ccall((:GB__func_IDENTITY_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}), z, x)
end

function GB__func_AINV_UINT16(z, x)
    ccall((:GB__func_AINV_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}), z, x)
end

function GB__func_MINV_UINT16(z, x)
    ccall((:GB__func_MINV_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}), z, x)
end

function GB__func_ABS_UINT16(z, x)
    ccall((:GB__func_ABS_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}), z, x)
end

function GB__func_LNOT_UINT16(z, x)
    ccall((:GB__func_LNOT_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}), z, x)
end

function GB__func_BNOT_UINT16(z, x)
    ccall((:GB__func_BNOT_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}), z, x)
end

function GB__func_FIRST_UINT16(z, x, y)
    ccall((:GB__func_FIRST_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_SECOND_UINT16(z, x, y)
    ccall((:GB__func_SECOND_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_PAIR_UINT16(z, x, y)
    ccall((:GB__func_PAIR_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_ANY_UINT16(z, x, y)
    ccall((:GB__func_ANY_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_PLUS_UINT16(z, x, y)
    ccall((:GB__func_PLUS_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_MINUS_UINT16(z, x, y)
    ccall((:GB__func_MINUS_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_RMINUS_UINT16(z, x, y)
    ccall((:GB__func_RMINUS_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_TIMES_UINT16(z, x, y)
    ccall((:GB__func_TIMES_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_DIV_UINT16(z, x, y)
    ccall((:GB__func_DIV_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_RDIV_UINT16(z, x, y)
    ccall((:GB__func_RDIV_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_POW_UINT16(z, x, y)
    ccall((:GB__func_POW_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_MIN_UINT16(z, x, y)
    ccall((:GB__func_MIN_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_MAX_UINT16(z, x, y)
    ccall((:GB__func_MAX_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_BOR_UINT16(z, x, y)
    ccall((:GB__func_BOR_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_BAND_UINT16(z, x, y)
    ccall((:GB__func_BAND_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_BXOR_UINT16(z, x, y)
    ccall((:GB__func_BXOR_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_BXNOR_UINT16(z, x, y)
    ccall((:GB__func_BXNOR_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_BGET_UINT16(z, x, y)
    ccall((:GB__func_BGET_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_BSET_UINT16(z, x, y)
    ccall((:GB__func_BSET_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_BCLR_UINT16(z, x, y)
    ccall((:GB__func_BCLR_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_BSHIFT_UINT16(z, x, y)
    ccall((:GB__func_BSHIFT_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{Int8}), z, x, y)
end

function GB__func_ISEQ_UINT16(z, x, y)
    ccall((:GB__func_ISEQ_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_ISNE_UINT16(z, x, y)
    ccall((:GB__func_ISNE_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_ISGT_UINT16(z, x, y)
    ccall((:GB__func_ISGT_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_ISLT_UINT16(z, x, y)
    ccall((:GB__func_ISLT_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_ISGE_UINT16(z, x, y)
    ccall((:GB__func_ISGE_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_ISLE_UINT16(z, x, y)
    ccall((:GB__func_ISLE_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_LOR_UINT16(z, x, y)
    ccall((:GB__func_LOR_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_LAND_UINT16(z, x, y)
    ccall((:GB__func_LAND_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_LXOR_UINT16(z, x, y)
    ccall((:GB__func_LXOR_UINT16, libgraphblas), Cvoid, (Ptr{UInt16}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_EQ_UINT16(z, x, y)
    ccall((:GB__func_EQ_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_NE_UINT16(z, x, y)
    ccall((:GB__func_NE_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_GT_UINT16(z, x, y)
    ccall((:GB__func_GT_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_LT_UINT16(z, x, y)
    ccall((:GB__func_LT_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_GE_UINT16(z, x, y)
    ccall((:GB__func_GE_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_LE_UINT16(z, x, y)
    ccall((:GB__func_LE_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, Ptr{UInt16}), z, x, y)
end

function GB__func_VALUEEQ_UINT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_UINT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_UINT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_UINT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_UINT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_UINT16(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_UINT32(z, x)
    ccall((:GB__func_ONE_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}), z, x)
end

function GB__func_IDENTITY_UINT32(z, x)
    ccall((:GB__func_IDENTITY_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}), z, x)
end

function GB__func_AINV_UINT32(z, x)
    ccall((:GB__func_AINV_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}), z, x)
end

function GB__func_MINV_UINT32(z, x)
    ccall((:GB__func_MINV_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}), z, x)
end

function GB__func_ABS_UINT32(z, x)
    ccall((:GB__func_ABS_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}), z, x)
end

function GB__func_LNOT_UINT32(z, x)
    ccall((:GB__func_LNOT_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}), z, x)
end

function GB__func_BNOT_UINT32(z, x)
    ccall((:GB__func_BNOT_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}), z, x)
end

function GB__func_FIRST_UINT32(z, x, y)
    ccall((:GB__func_FIRST_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_SECOND_UINT32(z, x, y)
    ccall((:GB__func_SECOND_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_PAIR_UINT32(z, x, y)
    ccall((:GB__func_PAIR_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_ANY_UINT32(z, x, y)
    ccall((:GB__func_ANY_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_PLUS_UINT32(z, x, y)
    ccall((:GB__func_PLUS_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_MINUS_UINT32(z, x, y)
    ccall((:GB__func_MINUS_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_RMINUS_UINT32(z, x, y)
    ccall((:GB__func_RMINUS_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_TIMES_UINT32(z, x, y)
    ccall((:GB__func_TIMES_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_DIV_UINT32(z, x, y)
    ccall((:GB__func_DIV_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_RDIV_UINT32(z, x, y)
    ccall((:GB__func_RDIV_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_POW_UINT32(z, x, y)
    ccall((:GB__func_POW_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_MIN_UINT32(z, x, y)
    ccall((:GB__func_MIN_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_MAX_UINT32(z, x, y)
    ccall((:GB__func_MAX_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_BOR_UINT32(z, x, y)
    ccall((:GB__func_BOR_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_BAND_UINT32(z, x, y)
    ccall((:GB__func_BAND_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_BXOR_UINT32(z, x, y)
    ccall((:GB__func_BXOR_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_BXNOR_UINT32(z, x, y)
    ccall((:GB__func_BXNOR_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_BGET_UINT32(z, x, y)
    ccall((:GB__func_BGET_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_BSET_UINT32(z, x, y)
    ccall((:GB__func_BSET_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_BCLR_UINT32(z, x, y)
    ccall((:GB__func_BCLR_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_BSHIFT_UINT32(z, x, y)
    ccall((:GB__func_BSHIFT_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{Int8}), z, x, y)
end

function GB__func_ISEQ_UINT32(z, x, y)
    ccall((:GB__func_ISEQ_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_ISNE_UINT32(z, x, y)
    ccall((:GB__func_ISNE_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_ISGT_UINT32(z, x, y)
    ccall((:GB__func_ISGT_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_ISLT_UINT32(z, x, y)
    ccall((:GB__func_ISLT_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_ISGE_UINT32(z, x, y)
    ccall((:GB__func_ISGE_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_ISLE_UINT32(z, x, y)
    ccall((:GB__func_ISLE_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_LOR_UINT32(z, x, y)
    ccall((:GB__func_LOR_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_LAND_UINT32(z, x, y)
    ccall((:GB__func_LAND_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_LXOR_UINT32(z, x, y)
    ccall((:GB__func_LXOR_UINT32, libgraphblas), Cvoid, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_EQ_UINT32(z, x, y)
    ccall((:GB__func_EQ_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_NE_UINT32(z, x, y)
    ccall((:GB__func_NE_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_GT_UINT32(z, x, y)
    ccall((:GB__func_GT_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_LT_UINT32(z, x, y)
    ccall((:GB__func_LT_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_GE_UINT32(z, x, y)
    ccall((:GB__func_GE_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_LE_UINT32(z, x, y)
    ccall((:GB__func_LE_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, Ptr{UInt32}), z, x, y)
end

function GB__func_VALUEEQ_UINT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_UINT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_UINT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_UINT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_UINT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_UINT32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_UINT64(z, x)
    ccall((:GB__func_ONE_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}), z, x)
end

function GB__func_IDENTITY_UINT64(z, x)
    ccall((:GB__func_IDENTITY_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}), z, x)
end

function GB__func_AINV_UINT64(z, x)
    ccall((:GB__func_AINV_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}), z, x)
end

function GB__func_MINV_UINT64(z, x)
    ccall((:GB__func_MINV_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}), z, x)
end

function GB__func_ABS_UINT64(z, x)
    ccall((:GB__func_ABS_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}), z, x)
end

function GB__func_LNOT_UINT64(z, x)
    ccall((:GB__func_LNOT_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}), z, x)
end

function GB__func_BNOT_UINT64(z, x)
    ccall((:GB__func_BNOT_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}), z, x)
end

function GB__func_FIRST_UINT64(z, x, y)
    ccall((:GB__func_FIRST_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_SECOND_UINT64(z, x, y)
    ccall((:GB__func_SECOND_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_PAIR_UINT64(z, x, y)
    ccall((:GB__func_PAIR_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_ANY_UINT64(z, x, y)
    ccall((:GB__func_ANY_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_PLUS_UINT64(z, x, y)
    ccall((:GB__func_PLUS_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_MINUS_UINT64(z, x, y)
    ccall((:GB__func_MINUS_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_RMINUS_UINT64(z, x, y)
    ccall((:GB__func_RMINUS_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_TIMES_UINT64(z, x, y)
    ccall((:GB__func_TIMES_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_DIV_UINT64(z, x, y)
    ccall((:GB__func_DIV_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_RDIV_UINT64(z, x, y)
    ccall((:GB__func_RDIV_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_POW_UINT64(z, x, y)
    ccall((:GB__func_POW_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_MIN_UINT64(z, x, y)
    ccall((:GB__func_MIN_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_MAX_UINT64(z, x, y)
    ccall((:GB__func_MAX_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_BOR_UINT64(z, x, y)
    ccall((:GB__func_BOR_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_BAND_UINT64(z, x, y)
    ccall((:GB__func_BAND_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_BXOR_UINT64(z, x, y)
    ccall((:GB__func_BXOR_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_BXNOR_UINT64(z, x, y)
    ccall((:GB__func_BXNOR_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_BGET_UINT64(z, x, y)
    ccall((:GB__func_BGET_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_BSET_UINT64(z, x, y)
    ccall((:GB__func_BSET_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_BCLR_UINT64(z, x, y)
    ccall((:GB__func_BCLR_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_BSHIFT_UINT64(z, x, y)
    ccall((:GB__func_BSHIFT_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{Int8}), z, x, y)
end

function GB__func_ISEQ_UINT64(z, x, y)
    ccall((:GB__func_ISEQ_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_ISNE_UINT64(z, x, y)
    ccall((:GB__func_ISNE_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_ISGT_UINT64(z, x, y)
    ccall((:GB__func_ISGT_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_ISLT_UINT64(z, x, y)
    ccall((:GB__func_ISLT_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_ISGE_UINT64(z, x, y)
    ccall((:GB__func_ISGE_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_ISLE_UINT64(z, x, y)
    ccall((:GB__func_ISLE_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_LOR_UINT64(z, x, y)
    ccall((:GB__func_LOR_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_LAND_UINT64(z, x, y)
    ccall((:GB__func_LAND_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_LXOR_UINT64(z, x, y)
    ccall((:GB__func_LXOR_UINT64, libgraphblas), Cvoid, (Ptr{UInt64}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_EQ_UINT64(z, x, y)
    ccall((:GB__func_EQ_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_NE_UINT64(z, x, y)
    ccall((:GB__func_NE_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_GT_UINT64(z, x, y)
    ccall((:GB__func_GT_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_LT_UINT64(z, x, y)
    ccall((:GB__func_LT_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_GE_UINT64(z, x, y)
    ccall((:GB__func_GE_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_LE_UINT64(z, x, y)
    ccall((:GB__func_LE_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, Ptr{UInt64}), z, x, y)
end

function GB__func_VALUEEQ_UINT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_UINT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_UINT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_UINT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_UINT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_UINT64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_FP32(z, x)
    ccall((:GB__func_ONE_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_IDENTITY_FP32(z, x)
    ccall((:GB__func_IDENTITY_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_AINV_FP32(z, x)
    ccall((:GB__func_AINV_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_MINV_FP32(z, x)
    ccall((:GB__func_MINV_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ABS_FP32(z, x)
    ccall((:GB__func_ABS_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_LNOT_FP32(z, x)
    ccall((:GB__func_LNOT_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_FREXPX_FP32(z, x)
    ccall((:GB__func_FREXPX_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_FREXPE_FP32(z, x)
    ccall((:GB__func_FREXPE_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_SQRT_FP32(z, x)
    ccall((:GB__func_SQRT_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_LOG_FP32(z, x)
    ccall((:GB__func_LOG_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_EXP_FP32(z, x)
    ccall((:GB__func_EXP_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_SIN_FP32(z, x)
    ccall((:GB__func_SIN_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_COS_FP32(z, x)
    ccall((:GB__func_COS_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_TAN_FP32(z, x)
    ccall((:GB__func_TAN_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ASIN_FP32(z, x)
    ccall((:GB__func_ASIN_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ACOS_FP32(z, x)
    ccall((:GB__func_ACOS_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ATAN_FP32(z, x)
    ccall((:GB__func_ATAN_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_SINH_FP32(z, x)
    ccall((:GB__func_SINH_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_COSH_FP32(z, x)
    ccall((:GB__func_COSH_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_TANH_FP32(z, x)
    ccall((:GB__func_TANH_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ASINH_FP32(z, x)
    ccall((:GB__func_ASINH_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ACOSH_FP32(z, x)
    ccall((:GB__func_ACOSH_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ATANH_FP32(z, x)
    ccall((:GB__func_ATANH_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_SIGNUM_FP32(z, x)
    ccall((:GB__func_SIGNUM_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_CEIL_FP32(z, x)
    ccall((:GB__func_CEIL_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_FLOOR_FP32(z, x)
    ccall((:GB__func_FLOOR_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ROUND_FP32(z, x)
    ccall((:GB__func_ROUND_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_TRUNC_FP32(z, x)
    ccall((:GB__func_TRUNC_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_EXP2_FP32(z, x)
    ccall((:GB__func_EXP2_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_EXPM1_FP32(z, x)
    ccall((:GB__func_EXPM1_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_LOG10_FP32(z, x)
    ccall((:GB__func_LOG10_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_LOG1P_FP32(z, x)
    ccall((:GB__func_LOG1P_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_LOG2_FP32(z, x)
    ccall((:GB__func_LOG2_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_LGAMMA_FP32(z, x)
    ccall((:GB__func_LGAMMA_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_TGAMMA_FP32(z, x)
    ccall((:GB__func_TGAMMA_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ERF_FP32(z, x)
    ccall((:GB__func_ERF_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ERFC_FP32(z, x)
    ccall((:GB__func_ERFC_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_CBRT_FP32(z, x)
    ccall((:GB__func_CBRT_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}), z, x)
end

function GB__func_ISINF_FP32(z, x)
    ccall((:GB__func_ISINF_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}), z, x)
end

function GB__func_ISNAN_FP32(z, x)
    ccall((:GB__func_ISNAN_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}), z, x)
end

function GB__func_ISFINITE_FP32(z, x)
    ccall((:GB__func_ISFINITE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}), z, x)
end

function GB__func_FIRST_FP32(z, x, y)
    ccall((:GB__func_FIRST_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_SECOND_FP32(z, x, y)
    ccall((:GB__func_SECOND_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_PAIR_FP32(z, x, y)
    ccall((:GB__func_PAIR_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_ANY_FP32(z, x, y)
    ccall((:GB__func_ANY_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_PLUS_FP32(z, x, y)
    ccall((:GB__func_PLUS_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_MINUS_FP32(z, x, y)
    ccall((:GB__func_MINUS_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_RMINUS_FP32(z, x, y)
    ccall((:GB__func_RMINUS_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_TIMES_FP32(z, x, y)
    ccall((:GB__func_TIMES_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_DIV_FP32(z, x, y)
    ccall((:GB__func_DIV_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_RDIV_FP32(z, x, y)
    ccall((:GB__func_RDIV_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_POW_FP32(z, x, y)
    ccall((:GB__func_POW_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_MIN_FP32(z, x, y)
    ccall((:GB__func_MIN_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_MAX_FP32(z, x, y)
    ccall((:GB__func_MAX_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_ATAN2_FP32(z, x, y)
    ccall((:GB__func_ATAN2_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_HYPOT_FP32(z, x, y)
    ccall((:GB__func_HYPOT_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_FMOD_FP32(z, x, y)
    ccall((:GB__func_FMOD_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_REMAINDER_FP32(z, x, y)
    ccall((:GB__func_REMAINDER_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_COPYSIGN_FP32(z, x, y)
    ccall((:GB__func_COPYSIGN_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_LDEXP_FP32(z, x, y)
    ccall((:GB__func_LDEXP_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_CMPLX_FP32(z, x, y)
    ccall((:GB__func_CMPLX_FP32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_ISEQ_FP32(z, x, y)
    ccall((:GB__func_ISEQ_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_ISNE_FP32(z, x, y)
    ccall((:GB__func_ISNE_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_ISGT_FP32(z, x, y)
    ccall((:GB__func_ISGT_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_ISLT_FP32(z, x, y)
    ccall((:GB__func_ISLT_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_ISGE_FP32(z, x, y)
    ccall((:GB__func_ISGE_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_ISLE_FP32(z, x, y)
    ccall((:GB__func_ISLE_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_LOR_FP32(z, x, y)
    ccall((:GB__func_LOR_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_LAND_FP32(z, x, y)
    ccall((:GB__func_LAND_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_LXOR_FP32(z, x, y)
    ccall((:GB__func_LXOR_FP32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_EQ_FP32(z, x, y)
    ccall((:GB__func_EQ_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_NE_FP32(z, x, y)
    ccall((:GB__func_NE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_GT_FP32(z, x, y)
    ccall((:GB__func_GT_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_LT_FP32(z, x, y)
    ccall((:GB__func_LT_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_GE_FP32(z, x, y)
    ccall((:GB__func_GE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_LE_FP32(z, x, y)
    ccall((:GB__func_LE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, Ptr{Cfloat}), z, x, y)
end

function GB__func_VALUEEQ_FP32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_FP32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_FP32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_FP32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_FP32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_FP32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_FP64(z, x)
    ccall((:GB__func_ONE_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_IDENTITY_FP64(z, x)
    ccall((:GB__func_IDENTITY_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_AINV_FP64(z, x)
    ccall((:GB__func_AINV_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_MINV_FP64(z, x)
    ccall((:GB__func_MINV_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ABS_FP64(z, x)
    ccall((:GB__func_ABS_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_LNOT_FP64(z, x)
    ccall((:GB__func_LNOT_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_FREXPX_FP64(z, x)
    ccall((:GB__func_FREXPX_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_FREXPE_FP64(z, x)
    ccall((:GB__func_FREXPE_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_SQRT_FP64(z, x)
    ccall((:GB__func_SQRT_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_LOG_FP64(z, x)
    ccall((:GB__func_LOG_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_EXP_FP64(z, x)
    ccall((:GB__func_EXP_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_SIN_FP64(z, x)
    ccall((:GB__func_SIN_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_COS_FP64(z, x)
    ccall((:GB__func_COS_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_TAN_FP64(z, x)
    ccall((:GB__func_TAN_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ASIN_FP64(z, x)
    ccall((:GB__func_ASIN_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ACOS_FP64(z, x)
    ccall((:GB__func_ACOS_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ATAN_FP64(z, x)
    ccall((:GB__func_ATAN_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_SINH_FP64(z, x)
    ccall((:GB__func_SINH_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_COSH_FP64(z, x)
    ccall((:GB__func_COSH_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_TANH_FP64(z, x)
    ccall((:GB__func_TANH_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ASINH_FP64(z, x)
    ccall((:GB__func_ASINH_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ACOSH_FP64(z, x)
    ccall((:GB__func_ACOSH_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ATANH_FP64(z, x)
    ccall((:GB__func_ATANH_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_SIGNUM_FP64(z, x)
    ccall((:GB__func_SIGNUM_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_CEIL_FP64(z, x)
    ccall((:GB__func_CEIL_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_FLOOR_FP64(z, x)
    ccall((:GB__func_FLOOR_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ROUND_FP64(z, x)
    ccall((:GB__func_ROUND_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_TRUNC_FP64(z, x)
    ccall((:GB__func_TRUNC_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_EXP2_FP64(z, x)
    ccall((:GB__func_EXP2_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_EXPM1_FP64(z, x)
    ccall((:GB__func_EXPM1_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_LOG10_FP64(z, x)
    ccall((:GB__func_LOG10_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_LOG1P_FP64(z, x)
    ccall((:GB__func_LOG1P_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_LOG2_FP64(z, x)
    ccall((:GB__func_LOG2_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_LGAMMA_FP64(z, x)
    ccall((:GB__func_LGAMMA_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_TGAMMA_FP64(z, x)
    ccall((:GB__func_TGAMMA_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ERF_FP64(z, x)
    ccall((:GB__func_ERF_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ERFC_FP64(z, x)
    ccall((:GB__func_ERFC_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_CBRT_FP64(z, x)
    ccall((:GB__func_CBRT_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}), z, x)
end

function GB__func_ISINF_FP64(z, x)
    ccall((:GB__func_ISINF_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}), z, x)
end

function GB__func_ISNAN_FP64(z, x)
    ccall((:GB__func_ISNAN_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}), z, x)
end

function GB__func_ISFINITE_FP64(z, x)
    ccall((:GB__func_ISFINITE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}), z, x)
end

function GB__func_FIRST_FP64(z, x, y)
    ccall((:GB__func_FIRST_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_SECOND_FP64(z, x, y)
    ccall((:GB__func_SECOND_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_PAIR_FP64(z, x, y)
    ccall((:GB__func_PAIR_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_ANY_FP64(z, x, y)
    ccall((:GB__func_ANY_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_PLUS_FP64(z, x, y)
    ccall((:GB__func_PLUS_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_MINUS_FP64(z, x, y)
    ccall((:GB__func_MINUS_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_RMINUS_FP64(z, x, y)
    ccall((:GB__func_RMINUS_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_TIMES_FP64(z, x, y)
    ccall((:GB__func_TIMES_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_DIV_FP64(z, x, y)
    ccall((:GB__func_DIV_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_RDIV_FP64(z, x, y)
    ccall((:GB__func_RDIV_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_POW_FP64(z, x, y)
    ccall((:GB__func_POW_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_MIN_FP64(z, x, y)
    ccall((:GB__func_MIN_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_MAX_FP64(z, x, y)
    ccall((:GB__func_MAX_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_ATAN2_FP64(z, x, y)
    ccall((:GB__func_ATAN2_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_HYPOT_FP64(z, x, y)
    ccall((:GB__func_HYPOT_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_FMOD_FP64(z, x, y)
    ccall((:GB__func_FMOD_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_REMAINDER_FP64(z, x, y)
    ccall((:GB__func_REMAINDER_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_COPYSIGN_FP64(z, x, y)
    ccall((:GB__func_COPYSIGN_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_LDEXP_FP64(z, x, y)
    ccall((:GB__func_LDEXP_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_CMPLX_FP64(z, x, y)
    ccall((:GB__func_CMPLX_FP64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_ISEQ_FP64(z, x, y)
    ccall((:GB__func_ISEQ_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_ISNE_FP64(z, x, y)
    ccall((:GB__func_ISNE_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_ISGT_FP64(z, x, y)
    ccall((:GB__func_ISGT_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_ISLT_FP64(z, x, y)
    ccall((:GB__func_ISLT_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_ISGE_FP64(z, x, y)
    ccall((:GB__func_ISGE_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_ISLE_FP64(z, x, y)
    ccall((:GB__func_ISLE_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_LOR_FP64(z, x, y)
    ccall((:GB__func_LOR_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_LAND_FP64(z, x, y)
    ccall((:GB__func_LAND_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_LXOR_FP64(z, x, y)
    ccall((:GB__func_LXOR_FP64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_EQ_FP64(z, x, y)
    ccall((:GB__func_EQ_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_NE_FP64(z, x, y)
    ccall((:GB__func_NE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_GT_FP64(z, x, y)
    ccall((:GB__func_GT_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_LT_FP64(z, x, y)
    ccall((:GB__func_LT_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_GE_FP64(z, x, y)
    ccall((:GB__func_GE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_LE_FP64(z, x, y)
    ccall((:GB__func_LE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, Ptr{Cdouble}), z, x, y)
end

function GB__func_VALUEEQ_FP64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_FP64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELT_FP64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELT_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUELE_FP64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUELE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGT_FP64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGT_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUEGE_FP64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEGE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_FC32(z, x)
    ccall((:GB__func_ONE_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_IDENTITY_FC32(z, x)
    ccall((:GB__func_IDENTITY_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_AINV_FC32(z, x)
    ccall((:GB__func_AINV_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_MINV_FC32(z, x)
    ccall((:GB__func_MINV_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ABS_FC32(z, x)
    ccall((:GB__func_ABS_FC32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_SQRT_FC32(z, x)
    ccall((:GB__func_SQRT_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_LOG_FC32(z, x)
    ccall((:GB__func_LOG_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_EXP_FC32(z, x)
    ccall((:GB__func_EXP_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_SIN_FC32(z, x)
    ccall((:GB__func_SIN_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_COS_FC32(z, x)
    ccall((:GB__func_COS_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_TAN_FC32(z, x)
    ccall((:GB__func_TAN_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ASIN_FC32(z, x)
    ccall((:GB__func_ASIN_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ACOS_FC32(z, x)
    ccall((:GB__func_ACOS_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ATAN_FC32(z, x)
    ccall((:GB__func_ATAN_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_SINH_FC32(z, x)
    ccall((:GB__func_SINH_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_COSH_FC32(z, x)
    ccall((:GB__func_COSH_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_TANH_FC32(z, x)
    ccall((:GB__func_TANH_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ASINH_FC32(z, x)
    ccall((:GB__func_ASINH_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ACOSH_FC32(z, x)
    ccall((:GB__func_ACOSH_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ATANH_FC32(z, x)
    ccall((:GB__func_ATANH_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_SIGNUM_FC32(z, x)
    ccall((:GB__func_SIGNUM_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_CEIL_FC32(z, x)
    ccall((:GB__func_CEIL_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_FLOOR_FC32(z, x)
    ccall((:GB__func_FLOOR_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ROUND_FC32(z, x)
    ccall((:GB__func_ROUND_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_TRUNC_FC32(z, x)
    ccall((:GB__func_TRUNC_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_EXP2_FC32(z, x)
    ccall((:GB__func_EXP2_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_EXPM1_FC32(z, x)
    ccall((:GB__func_EXPM1_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_LOG10_FC32(z, x)
    ccall((:GB__func_LOG10_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_LOG1P_FC32(z, x)
    ccall((:GB__func_LOG1P_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_LOG2_FC32(z, x)
    ccall((:GB__func_LOG2_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_CONJ_FC32(z, x)
    ccall((:GB__func_CONJ_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ISINF_FC32(z, x)
    ccall((:GB__func_ISINF_FC32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ISNAN_FC32(z, x)
    ccall((:GB__func_ISNAN_FC32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_ISFINITE_FC32(z, x)
    ccall((:GB__func_ISFINITE_FC32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_CREAL_FC32(z, x)
    ccall((:GB__func_CREAL_FC32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_CIMAG_FC32(z, x)
    ccall((:GB__func_CIMAG_FC32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_CARG_FC32(z, x)
    ccall((:GB__func_CARG_FC32, libgraphblas), Cvoid, (Ptr{Cfloat}, Ptr{GxB_FC32_t}), z, x)
end

function GB__func_FIRST_FC32(z, x, y)
    ccall((:GB__func_FIRST_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_SECOND_FC32(z, x, y)
    ccall((:GB__func_SECOND_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_PAIR_FC32(z, x, y)
    ccall((:GB__func_PAIR_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_ANY_FC32(z, x, y)
    ccall((:GB__func_ANY_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_PLUS_FC32(z, x, y)
    ccall((:GB__func_PLUS_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_MINUS_FC32(z, x, y)
    ccall((:GB__func_MINUS_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_RMINUS_FC32(z, x, y)
    ccall((:GB__func_RMINUS_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_TIMES_FC32(z, x, y)
    ccall((:GB__func_TIMES_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_DIV_FC32(z, x, y)
    ccall((:GB__func_DIV_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_RDIV_FC32(z, x, y)
    ccall((:GB__func_RDIV_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_POW_FC32(z, x, y)
    ccall((:GB__func_POW_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_ISEQ_FC32(z, x, y)
    ccall((:GB__func_ISEQ_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_ISNE_FC32(z, x, y)
    ccall((:GB__func_ISNE_FC32, libgraphblas), Cvoid, (Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_EQ_FC32(z, x, y)
    ccall((:GB__func_EQ_FC32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_NE_FC32(z, x, y)
    ccall((:GB__func_NE_FC32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC32_t}, Ptr{GxB_FC32_t}), z, x, y)
end

function GB__func_VALUEEQ_FC32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_FC32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC32_t}, GrB_Index, GrB_Index, Ptr{GxB_FC32_t}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_FC32(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_FC32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC32_t}, GrB_Index, GrB_Index, Ptr{GxB_FC32_t}), z, x, i_unused, j_unused, thunk)
end

function GB__func_ONE_FC64(z, x)
    ccall((:GB__func_ONE_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_IDENTITY_FC64(z, x)
    ccall((:GB__func_IDENTITY_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_AINV_FC64(z, x)
    ccall((:GB__func_AINV_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_MINV_FC64(z, x)
    ccall((:GB__func_MINV_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ABS_FC64(z, x)
    ccall((:GB__func_ABS_FC64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_SQRT_FC64(z, x)
    ccall((:GB__func_SQRT_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_LOG_FC64(z, x)
    ccall((:GB__func_LOG_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_EXP_FC64(z, x)
    ccall((:GB__func_EXP_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_SIN_FC64(z, x)
    ccall((:GB__func_SIN_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_COS_FC64(z, x)
    ccall((:GB__func_COS_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_TAN_FC64(z, x)
    ccall((:GB__func_TAN_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ASIN_FC64(z, x)
    ccall((:GB__func_ASIN_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ACOS_FC64(z, x)
    ccall((:GB__func_ACOS_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ATAN_FC64(z, x)
    ccall((:GB__func_ATAN_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_SINH_FC64(z, x)
    ccall((:GB__func_SINH_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_COSH_FC64(z, x)
    ccall((:GB__func_COSH_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_TANH_FC64(z, x)
    ccall((:GB__func_TANH_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ASINH_FC64(z, x)
    ccall((:GB__func_ASINH_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ACOSH_FC64(z, x)
    ccall((:GB__func_ACOSH_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ATANH_FC64(z, x)
    ccall((:GB__func_ATANH_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_SIGNUM_FC64(z, x)
    ccall((:GB__func_SIGNUM_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_CEIL_FC64(z, x)
    ccall((:GB__func_CEIL_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_FLOOR_FC64(z, x)
    ccall((:GB__func_FLOOR_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ROUND_FC64(z, x)
    ccall((:GB__func_ROUND_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_TRUNC_FC64(z, x)
    ccall((:GB__func_TRUNC_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_EXP2_FC64(z, x)
    ccall((:GB__func_EXP2_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_EXPM1_FC64(z, x)
    ccall((:GB__func_EXPM1_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_LOG10_FC64(z, x)
    ccall((:GB__func_LOG10_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_LOG1P_FC64(z, x)
    ccall((:GB__func_LOG1P_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_LOG2_FC64(z, x)
    ccall((:GB__func_LOG2_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_CONJ_FC64(z, x)
    ccall((:GB__func_CONJ_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ISINF_FC64(z, x)
    ccall((:GB__func_ISINF_FC64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ISNAN_FC64(z, x)
    ccall((:GB__func_ISNAN_FC64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_ISFINITE_FC64(z, x)
    ccall((:GB__func_ISFINITE_FC64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_CREAL_FC64(z, x)
    ccall((:GB__func_CREAL_FC64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_CIMAG_FC64(z, x)
    ccall((:GB__func_CIMAG_FC64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_CARG_FC64(z, x)
    ccall((:GB__func_CARG_FC64, libgraphblas), Cvoid, (Ptr{Cdouble}, Ptr{GxB_FC64_t}), z, x)
end

function GB__func_FIRST_FC64(z, x, y)
    ccall((:GB__func_FIRST_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_SECOND_FC64(z, x, y)
    ccall((:GB__func_SECOND_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_PAIR_FC64(z, x, y)
    ccall((:GB__func_PAIR_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_ANY_FC64(z, x, y)
    ccall((:GB__func_ANY_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_PLUS_FC64(z, x, y)
    ccall((:GB__func_PLUS_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_MINUS_FC64(z, x, y)
    ccall((:GB__func_MINUS_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_RMINUS_FC64(z, x, y)
    ccall((:GB__func_RMINUS_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_TIMES_FC64(z, x, y)
    ccall((:GB__func_TIMES_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_DIV_FC64(z, x, y)
    ccall((:GB__func_DIV_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_RDIV_FC64(z, x, y)
    ccall((:GB__func_RDIV_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_POW_FC64(z, x, y)
    ccall((:GB__func_POW_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_ISEQ_FC64(z, x, y)
    ccall((:GB__func_ISEQ_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_ISNE_FC64(z, x, y)
    ccall((:GB__func_ISNE_FC64, libgraphblas), Cvoid, (Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_EQ_FC64(z, x, y)
    ccall((:GB__func_EQ_FC64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_NE_FC64(z, x, y)
    ccall((:GB__func_NE_FC64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC64_t}, Ptr{GxB_FC64_t}), z, x, y)
end

function GB__func_VALUEEQ_FC64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUEEQ_FC64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC64_t}, GrB_Index, GrB_Index, Ptr{GxB_FC64_t}), z, x, i_unused, j_unused, thunk)
end

function GB__func_VALUENE_FC64(z, x, i_unused, j_unused, thunk)
    ccall((:GB__func_VALUENE_FC64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC64_t}, GrB_Index, GrB_Index, Ptr{GxB_FC64_t}), z, x, i_unused, j_unused, thunk)
end

struct GB_cuda_device
    name::NTuple{256, Cchar}
    total_global_memory::Csize_t
    number_of_sms::Cint
    compute_capability_major::Cint
    compute_capability_minor::Cint
    use_memory_pool::Bool
    pool_size::Csize_t
    max_pool_size::Csize_t
    memory_resource::Ptr{Cvoid}
end

function GB_ngpus_to_use(work)
    ccall((:GB_ngpus_to_use, libgraphblas), Cint, (Cdouble,), work)
end

function GB_cuda_init()
    ccall((:GB_cuda_init, libgraphblas), GrB_Info, ())
end

function GB_cuda_get_device_count(gpu_count)
    ccall((:GB_cuda_get_device_count, libgraphblas), Bool, (Ptr{Cint},), gpu_count)
end

function GB_cuda_warmup(device)
    ccall((:GB_cuda_warmup, libgraphblas), Bool, (Cint,), device)
end

function GB_cuda_get_device(device)
    ccall((:GB_cuda_get_device, libgraphblas), Bool, (Ptr{Cint},), device)
end

function GB_cuda_set_device(device)
    ccall((:GB_cuda_set_device, libgraphblas), Bool, (Cint,), device)
end

function GB_cuda_get_device_properties(device, prop)
    ccall((:GB_cuda_get_device_properties, libgraphblas), Bool, (Cint, Ptr{GB_cuda_device}), device, prop)
end

function GB_reduce_to_scalar_cuda_branch(reduce, A, Context)
    ccall((:GB_reduce_to_scalar_cuda_branch, libgraphblas), Bool, (GrB_Monoid, GrB_Matrix, GB_Context), reduce, A, Context)
end

function GB_reduce_to_scalar_cuda(s, reduce, A, Context)
    ccall((:GB_reduce_to_scalar_cuda, libgraphblas), GrB_Info, (Ptr{GB_void}, GrB_Monoid, GrB_Matrix, GB_Context), s, reduce, A, Context)
end

function GB_AxB_dot3_cuda(C, M, Mask_struct, A, B, semiring, flipxy, Context)
    ccall((:GB_AxB_dot3_cuda, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, Bool, GrB_Matrix, GrB_Matrix, GrB_Semiring, Bool, GB_Context), C, M, Mask_struct, A, B, semiring, flipxy, Context)
end

function GB_AxB_dot3_cuda_branch(M, Mask_struct, A, B, semiring, flipxy, Context)
    ccall((:GB_AxB_dot3_cuda_branch, libgraphblas), Bool, (GrB_Matrix, Bool, GrB_Matrix, GrB_Matrix, GrB_Semiring, Bool, GB_Context), M, Mask_struct, A, B, semiring, flipxy, Context)
end

function GxB_Type_new(type, sizeof_ctype, type_name, type_defn)
    ccall((:GxB_Type_new, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Csize_t, Ptr{Cchar}, Ptr{Cchar}), type, sizeof_ctype, type_name, type_defn)
end

function GxB_UnaryOp_new(unaryop, _function, ztype, xtype, unop_name, unop_defn)
    ccall((:GxB_UnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp}, GxB_unary_function, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), unaryop, _function, ztype, xtype, unop_name, unop_defn)
end

function GxB_BinaryOp_new(op, _function, ztype, xtype, ytype, binop_name, binop_defn)
    ccall((:GxB_BinaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_binary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), op, _function, ztype, xtype, ytype, binop_name, binop_defn)
end

function GB_SelectOp_new(selectop, _function, xtype, ttype, name)
    ccall((:GB_SelectOp_new, libgraphblas), GrB_Info, (Ptr{GxB_SelectOp}, GxB_select_function, GrB_Type, GrB_Type, Ptr{Cchar}), selectop, _function, xtype, ttype, name)
end

function GxB_IndexUnaryOp_new(op, _function, ztype, xtype, ytype, idxop_name, idxop_defn)
    ccall((:GxB_IndexUnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_IndexUnaryOp}, GxB_index_unary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}, Ptr{Cchar}), op, _function, ztype, xtype, ytype, idxop_name, idxop_defn)
end

function GrB_Vector_setElement_Scalar(w, x, i)
    ccall((:GrB_Vector_setElement_Scalar, libgraphblas), GrB_Info, (GrB_Vector, GrB_Scalar, GrB_Index), w, x, i)
end

function GrB_Vector_extractElement_Scalar(x, v, i)
    ccall((:GrB_Vector_extractElement_Scalar, libgraphblas), GrB_Info, (GrB_Scalar, GrB_Vector, GrB_Index), x, v, i)
end

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

function GrB_Monoid_free(monoid)
    ccall((:GrB_Monoid_free, libgraphblas), GrB_Info, (Ptr{GrB_Monoid},), monoid)
end

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
end