module LibGraphBLAS_Internal

to_c_type(t::Type) = t
to_c_type_pairs(va_list) = map(enumerate(to_c_type.(va_list))) do (ind, type)
    :(va_list[$ind]::$type)
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
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    size::Csize_t
    code::GB_Type_code
    name_len::Int32
    name::NTuple{128, Cchar}
    defn::Ptr{Cchar}
    defn_size::Csize_t
    hash::UInt64
end

const GB_void = Cuchar

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
    GB_NONZOMBIE_idxunop_code = 64
    GB_VALUENE_idxunop_code = 65
    GB_VALUEEQ_idxunop_code = 66
    GB_VALUEGT_idxunop_code = 67
    GB_VALUEGE_idxunop_code = 68
    GB_VALUELT_idxunop_code = 69
    GB_VALUELE_idxunop_code = 70
    GB_USER_idxunop_code = 71
    GB_FIRST_binop_code = 72
    GB_SECOND_binop_code = 73
    GB_ANY_binop_code = 74
    GB_PAIR_binop_code = 75
    GB_MIN_binop_code = 76
    GB_MAX_binop_code = 77
    GB_PLUS_binop_code = 78
    GB_MINUS_binop_code = 79
    GB_RMINUS_binop_code = 80
    GB_TIMES_binop_code = 81
    GB_DIV_binop_code = 82
    GB_RDIV_binop_code = 83
    GB_POW_binop_code = 84
    GB_ISEQ_binop_code = 85
    GB_ISNE_binop_code = 86
    GB_ISGT_binop_code = 87
    GB_ISLT_binop_code = 88
    GB_ISGE_binop_code = 89
    GB_ISLE_binop_code = 90
    GB_LOR_binop_code = 91
    GB_LAND_binop_code = 92
    GB_LXOR_binop_code = 93
    GB_BOR_binop_code = 94
    GB_BAND_binop_code = 95
    GB_BXOR_binop_code = 96
    GB_BXNOR_binop_code = 97
    GB_BGET_binop_code = 98
    GB_BSET_binop_code = 99
    GB_BCLR_binop_code = 100
    GB_BSHIFT_binop_code = 101
    GB_EQ_binop_code = 102
    GB_NE_binop_code = 103
    GB_GT_binop_code = 104
    GB_LT_binop_code = 105
    GB_GE_binop_code = 106
    GB_LE_binop_code = 107
    GB_ATAN2_binop_code = 108
    GB_HYPOT_binop_code = 109
    GB_FMOD_binop_code = 110
    GB_REMAINDER_binop_code = 111
    GB_COPYSIGN_binop_code = 112
    GB_LDEXP_binop_code = 113
    GB_CMPLX_binop_code = 114
    GB_FIRSTI_binop_code = 115
    GB_FIRSTI1_binop_code = 116
    GB_FIRSTJ_binop_code = 117
    GB_FIRSTJ1_binop_code = 118
    GB_SECONDI_binop_code = 119
    GB_SECONDI1_binop_code = 120
    GB_SECONDJ_binop_code = 121
    GB_SECONDJ1_binop_code = 122
    GB_USER_binop_code = 123
    GB_TRIL_selop_code = 124
    GB_TRIU_selop_code = 125
    GB_DIAG_selop_code = 126
    GB_OFFDIAG_selop_code = 127
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
end

struct GB_BinaryOp_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    name::NTuple{128, Cchar}
    name_len::Int32
    opcode::GB_Opcode
    defn::Ptr{Cchar}
    defn_size::Csize_t
    hash::UInt64
end

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

struct GB_Vector_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
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
    Y::GrB_Matrix
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
    Y_shallow::Bool
    static_header::Bool
    is_csc::Bool
    jumbled::Bool
    iso::Bool
end

struct GB_Scalar_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
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
    Y::GrB_Matrix
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
    Y_shallow::Bool
    static_header::Bool
    is_csc::Bool
    jumbled::Bool
    iso::Bool
end

struct GB_Descriptor_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    logger::Ptr{Cchar}
    logger_size::Csize_t
    out::GrB_Desc_Value
    mask::GrB_Desc_Value
    in0::GrB_Desc_Value
    in1::GrB_Desc_Value
    axb::GrB_Desc_Value
    compression::Cint
    do_sort::Bool
    _import::Cint
end

struct GB_Context_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    chunk::Cdouble
    nthreads_max::Cint
    gpu_id::Cint
end

struct GB_UnaryOp_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    name::NTuple{128, Cchar}
    name_len::Int32
    opcode::GB_Opcode
    defn::Ptr{Cchar}
    defn_size::Csize_t
    hash::UInt64
end

struct GB_IndexUnaryOp_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    name::NTuple{128, Cchar}
    name_len::Int32
    opcode::GB_Opcode
    defn::Ptr{Cchar}
    defn_size::Csize_t
    hash::UInt64
end

struct GB_Monoid_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    op::GrB_BinaryOp
    identity::Ptr{Cvoid}
    terminal::Ptr{Cvoid}
    identity_size::Csize_t
    terminal_size::Csize_t
    hash::UInt64
end

struct GB_Semiring_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    add::GrB_Monoid
    multiply::GrB_BinaryOp
    name::Ptr{Cchar}
    name_len::Int32
    name_size::Csize_t
    hash::UInt64
end

mutable struct GB_Global_opaque end

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

struct GB_SelectOp_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    name::NTuple{128, Cchar}
    name_len::Int32
    opcode::GB_Opcode
    defn::Ptr{Cchar}
    defn_size::Csize_t
    hash::UInt64
end

function GB_Iterator_rc_bitmap_next(iterator)
    ccall((:GB_Iterator_rc_bitmap_next, libgraphblas), GrB_Info, (GxB_Iterator,), iterator)
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

struct GB_blob16
    stuff::NTuple{2, UInt64}
end

function GB_nnz(A)
    ccall((:GB_nnz, libgraphblas), Int64, (GrB_Matrix,), A)
end

function GB_nnz_held(A)
    ccall((:GB_nnz_held, libgraphblas), Int64, (GrB_Matrix,), A)
end

function GB_free_memory(p, size_allocated)
    ccall((:GB_free_memory, libgraphblas), Cvoid, (Ptr{Ptr{Cvoid}}, Csize_t), p, size_allocated)
end

function GB_calloc_memory(nitems, size_of_item, size_allocated)
    ccall((:GB_calloc_memory, libgraphblas), Ptr{Cvoid}, (Csize_t, Csize_t, Ptr{Csize_t}), nitems, size_of_item, size_allocated)
end

function GB_malloc_memory(nitems, size_of_item, size_allocated)
    ccall((:GB_malloc_memory, libgraphblas), Ptr{Cvoid}, (Csize_t, Csize_t, Ptr{Csize_t}), nitems, size_of_item, size_allocated)
end

function GB_realloc_memory(nitems_new, size_of_item, p, size_allocated, ok)
    ccall((:GB_realloc_memory, libgraphblas), Ptr{Cvoid}, (Csize_t, Csize_t, Ptr{Cvoid}, Ptr{Csize_t}, Ptr{Bool}), nitems_new, size_of_item, p, size_allocated, ok)
end

function GB_xalloc_memory(use_calloc, iso, n, type_size, size)
    ccall((:GB_xalloc_memory, libgraphblas), Ptr{Cvoid}, (Bool, Bool, Int64, Csize_t, Ptr{Csize_t}), use_calloc, iso, n, type_size, size)
end

struct GB_Werk_struct
    Stack::NTuple{16384, GB_void}
    where::Ptr{Cchar}
    logger_handle::Ptr{Ptr{Cchar}}
    logger_size_handle::Ptr{Csize_t}
    pwerk::Cint
end

const GB_Werk = Ptr{GB_Werk_struct}

function GB_werk_push(size_allocated, on_stack, nitems, size_of_item, Werk)
    ccall((:GB_werk_push, libgraphblas), Ptr{Cvoid}, (Ptr{Csize_t}, Ptr{Bool}, Csize_t, Csize_t, GB_Werk), size_allocated, on_stack, nitems, size_of_item, Werk)
end

function GB_werk_pop(p, size_allocated, on_stack, nitems, size_of_item, Werk)
    ccall((:GB_werk_pop, libgraphblas), Ptr{Cvoid}, (Ptr{Cvoid}, Ptr{Csize_t}, Bool, Csize_t, Csize_t, GB_Werk), p, size_allocated, on_stack, nitems, size_of_item, Werk)
end

function GB_ek_slice_ntasks(nthreads, ntasks, anz_held, ntasks_per_thread, work, chunk, nthreads_max)
    ccall((:GB_ek_slice_ntasks, libgraphblas), Cvoid, (Ptr{Cint}, Ptr{Cint}, Int64, Cint, Cdouble, Cdouble, Cint), nthreads, ntasks, anz_held, ntasks_per_thread, work, chunk, nthreads_max)
end

function GB_ek_slice(A_ek_slicing, A, ntasks)
    ccall((:GB_ek_slice, libgraphblas), Cvoid, (Ptr{Int64}, GrB_Matrix, Cint), A_ek_slicing, A, ntasks)
end

struct GB_saxpy3task_struct
    start::Int64
    _end::Int64
    vector::Int64
    hsize::Int64
    Hi::Ptr{Int64}
    Hf::Ptr{GB_void}
    Hx::Ptr{GB_void}
    my_cjnz::Int64
    leader::Cint
    team_size::Cint
end

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

function GB_is_dense(A)
    ccall((:GB_is_dense, libgraphblas), Bool, (GrB_Matrix,), A)
end

function GB_Global_abort()
    ccall((:GB_Global_abort, libgraphblas), Cvoid, ())
end

function GB_Type_check(type, name, pr, f)
    ccall((:GB_Type_check, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), type, name, pr, f)
end

function GB_BinaryOp_check(op, name, pr, f)
    ccall((:GB_BinaryOp_check, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

function GB_IndexUnaryOp_check(op, name, pr, f)
    ccall((:GB_IndexUnaryOp_check, libgraphblas), GrB_Info, (GrB_IndexUnaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

function GB_UnaryOp_check(op, name, pr, f)
    ccall((:GB_UnaryOp_check, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

function GB_SelectOp_check(op, name, pr, f)
    ccall((:GB_SelectOp_check, libgraphblas), GrB_Info, (GxB_SelectOp, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

struct GB_Operator_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
    ztype::GrB_Type
    xtype::GrB_Type
    ytype::GrB_Type
    unop_function::GxB_unary_function
    idxunop_function::GxB_index_unary_function
    binop_function::GxB_binary_function
    name::NTuple{128, Cchar}
    name_len::Int32
    opcode::GB_Opcode
    defn::Ptr{Cchar}
    defn_size::Csize_t
    hash::UInt64
end

const GB_Operator = Ptr{GB_Operator_opaque}

function GB_Operator_check(op, name, pr, f)
    ccall((:GB_Operator_check, libgraphblas), GrB_Info, (GB_Operator, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), op, name, pr, f)
end

function GB_Monoid_check(monoid, name, pr, f)
    ccall((:GB_Monoid_check, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), monoid, name, pr, f)
end

function GB_Semiring_check(semiring, name, pr, f)
    ccall((:GB_Semiring_check, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), semiring, name, pr, f)
end

function GB_Matrix_check(A, name, pr, f)
    ccall((:GB_Matrix_check, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), A, name, pr, f)
end

function GB_Vector_check(v, name, pr, f)
    ccall((:GB_Vector_check, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), v, name, pr, f)
end

function GB_Scalar_check(v, name, pr, f)
    ccall((:GB_Scalar_check, libgraphblas), GrB_Info, (GrB_Scalar, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), v, name, pr, f)
end

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

function GB_mcast(Mx, pM, msize)
    ccall((:GB_mcast, libgraphblas), Bool, (Ptr{GB_void}, Int64, Csize_t), Mx, pM, msize)
end

function GB_Pending_n(A)
    ccall((:GB_Pending_n, libgraphblas), Int64, (GrB_Matrix,), A)
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

function GB_status_code(info)
    ccall((:GB_status_code, libgraphblas), Ptr{Cchar}, (GrB_Info,), info)
end

function GB_clear(A, Werk)
    ccall((:GB_clear, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_Descriptor_get(desc, C_replace, Mask_comp, Mask_struct, In0_transpose, In1_transpose, AxB_method, do_sort)
    ccall((:GB_Descriptor_get, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Bool}, Ptr{Bool}, Ptr{Bool}, Ptr{Bool}, Ptr{Bool}, Ptr{GrB_Desc_Value}, Ptr{Cint}), desc, C_replace, Mask_comp, Mask_struct, In0_transpose, In1_transpose, AxB_method, do_sort)
end

function GB_wait(A, name, Werk)
    ccall((:GB_wait, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, GB_Werk), A, name, Werk)
end

function GB_convert_bitmap_to_sparse(A, Werk)
    ccall((:GB_convert_bitmap_to_sparse, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_convert_full_to_sparse(A)
    ccall((:GB_convert_full_to_sparse, libgraphblas), GrB_Info, (GrB_Matrix,), A)
end

function GB_Global_GrB_init_called_get()
    ccall((:GB_Global_GrB_init_called_get, libgraphblas), Bool, ())
end

struct GB_Matrix_opaque
    magic::Int64
    header_size::Csize_t
    user_name::Ptr{Cchar}
    user_name_size::Csize_t
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
    Y::GrB_Matrix
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
    Y_shallow::Bool
    static_header::Bool
    is_csc::Bool
    jumbled::Bool
    iso::Bool
end

function GB_nthreads(work, chunk, nthreads_max)
    ccall((:GB_nthreads, libgraphblas), Cint, (Cdouble, Cdouble, Cint), work, chunk, nthreads_max)
end

function GB_hyper_hash_lookup(Ah, anvec, Ap, Yp, Yi, Yx, hash_bits, j, pstart, pend)
    ccall((:GB_hyper_hash_lookup, libgraphblas), Int64, (Ptr{Int64}, Int64, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Int64, Int64, Ptr{Int64}, Ptr{Int64}), Ah, anvec, Ap, Yp, Yi, Yx, hash_bits, j, pstart, pend)
end

# typedef GB_CALLBACK_SAXPY3_CUMSUM_PROTO ( ( * GB_AxB_saxpy3_cumsum_f ) )
const GB_AxB_saxpy3_cumsum_f = Ptr{Cvoid}

# typedef GB_CALLBACK_BITMAP_M_SCATTER_PROTO ( ( * GB_bitmap_M_scatter_f ) )
const GB_bitmap_M_scatter_f = Ptr{Cvoid}

# typedef GB_CALLBACK_BITMAP_M_SCATTER_WHOLE_PROTO ( ( * GB_bitmap_M_scatter_whole_f ) )
const GB_bitmap_M_scatter_whole_f = Ptr{Cvoid}

# typedef GB_CALLBACK_BIX_ALLOC_PROTO ( ( * GB_bix_alloc_f ) )
const GB_bix_alloc_f = Ptr{Cvoid}

# typedef GB_CALLBACK_EK_SLICE_PROTO ( ( * GB_ek_slice_f ) )
const GB_ek_slice_f = Ptr{Cvoid}

# typedef GB_CALLBACK_EK_SLICE_MERGE1_PROTO ( ( * GB_ek_slice_merge1_f ) )
const GB_ek_slice_merge1_f = Ptr{Cvoid}

# typedef GB_CALLBACK_FREE_MEMORY_PROTO ( ( * GB_free_memory_f ) )
const GB_free_memory_f = Ptr{Cvoid}

# typedef GB_CALLBACK_MALLOC_MEMORY_PROTO ( ( * GB_malloc_memory_f ) )
const GB_malloc_memory_f = Ptr{Cvoid}

# typedef GB_CALLBACK_MEMSET_PROTO ( ( * GB_memset_f ) )
const GB_memset_f = Ptr{Cvoid}

# typedef GB_CALLBACK_QSORT_1_PROTO ( ( * GB_qsort_1_f ) )
const GB_qsort_1_f = Ptr{Cvoid}

# typedef GB_CALLBACK_WERK_POP_PROTO ( ( * GB_werk_pop_f ) )
const GB_werk_pop_f = Ptr{Cvoid}

# typedef GB_CALLBACK_WERK_PUSH_PROTO ( ( * GB_werk_push_f ) )
const GB_werk_push_f = Ptr{Cvoid}

struct GB_callback_struct
    GB_AxB_saxpy3_cumsum_func::GB_AxB_saxpy3_cumsum_f
    GB_bitmap_M_scatter_func::GB_bitmap_M_scatter_f
    GB_bitmap_M_scatter_whole_func::GB_bitmap_M_scatter_whole_f
    GB_bix_alloc_func::GB_bix_alloc_f
    GB_ek_slice_func::GB_ek_slice_f
    GB_ek_slice_merge1_func::GB_ek_slice_merge1_f
    GB_free_memory_func::GB_free_memory_f
    GB_malloc_memory_func::GB_malloc_memory_f
    GB_memset_func::GB_memset_f
    GB_qsort_1_func::GB_qsort_1_f
    GB_werk_pop_func::GB_werk_pop_f
    GB_werk_push_func::GB_werk_push_f
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

function GB_Global_GrB_init_called_set(init_called)
    ccall((:GB_Global_GrB_init_called_set, libgraphblas), Cvoid, (Bool,), init_called)
end

function GB_Global_hyper_switch_set(hyper_switch)
    ccall((:GB_Global_hyper_switch_set, libgraphblas), Cvoid, (Cfloat,), hyper_switch)
end

function GB_Global_hyper_switch_get()
    ccall((:GB_Global_hyper_switch_get, libgraphblas), Cfloat, ())
end

function GB_Global_hyper_hash_set(hyper_hash)
    ccall((:GB_Global_hyper_hash_set, libgraphblas), Cvoid, (Int64,), hyper_hash)
end

function GB_Global_hyper_hash_get()
    ccall((:GB_Global_hyper_hash_get, libgraphblas), Int64, ())
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

function GB_Global_abort_set(abort_function)
    ccall((:GB_Global_abort_set, libgraphblas), Cvoid, (Ptr{Cvoid},), abort_function)
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

function GB_Global_calloc_function_set(calloc_function)
    ccall((:GB_Global_calloc_function_set, libgraphblas), Cvoid, (Ptr{Cvoid},), calloc_function)
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

function GB_Global_persistent_malloc(size)
    ccall((:GB_Global_persistent_malloc, libgraphblas), Ptr{Cvoid}, (Csize_t,), size)
end

function GB_Global_persistent_set(persistent_function)
    ccall((:GB_Global_persistent_set, libgraphblas), Cvoid, (Ptr{Cvoid},), persistent_function)
end

function GB_Global_persistent_free(p)
    ccall((:GB_Global_persistent_free, libgraphblas), Cvoid, (Ptr{Ptr{Cvoid}},), p)
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

function GB_Global_printf_set(p)
    ccall((:GB_Global_printf_set, libgraphblas), Cvoid, (GB_printf_function_t,), p)
end

function GB_Global_flush_set(p)
    ccall((:GB_Global_flush_set, libgraphblas), Cvoid, (GB_flush_function_t,), p)
end

function GB_Global_get_wtime()
    ccall((:GB_Global_get_wtime, libgraphblas), Cdouble, ())
end

function GB_Global_malloc_function_get()
    ccall((:GB_Global_malloc_function_get, libgraphblas), Ptr{Cvoid}, ())
end

function GB_Global_calloc_function_get()
    ccall((:GB_Global_calloc_function_get, libgraphblas), Ptr{Cvoid}, ())
end

function GB_Global_realloc_function_get()
    ccall((:GB_Global_realloc_function_get, libgraphblas), Ptr{Cvoid}, ())
end

function GB_Global_free_function_get()
    ccall((:GB_Global_free_function_get, libgraphblas), Ptr{Cvoid}, ())
end

function GB_assign_burble(C_replace, Ikind, Jkind, M, Mask_comp, Mask_struct, accum, A, assign_kind)
    ccall((:GB_assign_burble, libgraphblas), Cvoid, (Bool, Cint, Cint, GrB_Matrix, Bool, Bool, GrB_BinaryOp, GrB_Matrix, Cint), C_replace, Ikind, Jkind, M, Mask_comp, Mask_struct, accum, A, assign_kind)
end

function GB_assign_describe(str, slen, C_replace, Ikind, Jkind, M_is_null, M_sparsity, Mask_comp, Mask_struct, accum, A_is_null, assign_kind)
    ccall((:GB_assign_describe, libgraphblas), Cvoid, (Ptr{Cchar}, Cint, Bool, Cint, Cint, Bool, Cint, Bool, Bool, GrB_BinaryOp, Bool, Cint), str, slen, C_replace, Ikind, Jkind, M_is_null, M_sparsity, Mask_comp, Mask_struct, accum, A_is_null, assign_kind)
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

function GB_positional_offset(opcode, Thunk, depends_on_j)
    ccall((:GB_positional_offset, libgraphblas), Int64, (GB_Opcode, GrB_Scalar, Ptr{Bool}), opcode, Thunk, depends_on_j)
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

function GB_FC64_div(x, y)
    ccall((:GB_FC64_div, libgraphblas), GxB_FC64_t, (GxB_FC64_t, GxB_FC64_t), x, y)
end

function GB_FC32_div(x, y)
    ccall((:GB_FC32_div, libgraphblas), GxB_FC32_t, (GxB_FC32_t, GxB_FC32_t), x, y)
end

function GB_powf(x, y)
    ccall((:GB_powf, libgraphblas), Cfloat, (Cfloat, Cfloat), x, y)
end

function GB_pow(x, y)
    ccall((:GB_pow, libgraphblas), Cdouble, (Cdouble, Cdouble), x, y)
end

function GB_FC32_pow(x, y)
    ccall((:GB_FC32_pow, libgraphblas), GxB_FC32_t, (GxB_FC32_t, GxB_FC32_t), x, y)
end

function GB_FC64_pow(x, y)
    ccall((:GB_FC64_pow, libgraphblas), GxB_FC64_t, (GxB_FC64_t, GxB_FC64_t), x, y)
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

function GB_bitget_int8(x, k)
    ccall((:GB_bitget_int8, libgraphblas), Int8, (Int8, Int8), x, k)
end

function GB_bitget_int16(x, k)
    ccall((:GB_bitget_int16, libgraphblas), Int16, (Int16, Int16), x, k)
end

function GB_bitget_int32(x, k)
    ccall((:GB_bitget_int32, libgraphblas), Int32, (Int32, Int32), x, k)
end

function GB_bitget_int64(x, k)
    ccall((:GB_bitget_int64, libgraphblas), Int64, (Int64, Int64), x, k)
end

function GB_bitget_uint8(x, k)
    ccall((:GB_bitget_uint8, libgraphblas), UInt8, (UInt8, UInt8), x, k)
end

function GB_bitget_uint16(x, k)
    ccall((:GB_bitget_uint16, libgraphblas), UInt16, (UInt16, UInt16), x, k)
end

function GB_bitget_uint32(x, k)
    ccall((:GB_bitget_uint32, libgraphblas), UInt32, (UInt32, UInt32), x, k)
end

function GB_bitget_uint64(x, k)
    ccall((:GB_bitget_uint64, libgraphblas), UInt64, (UInt64, UInt64), x, k)
end

function GB_bitset_int8(x, k)
    ccall((:GB_bitset_int8, libgraphblas), Int8, (Int8, Int8), x, k)
end

function GB_bitset_int16(x, k)
    ccall((:GB_bitset_int16, libgraphblas), Int16, (Int16, Int16), x, k)
end

function GB_bitset_int32(x, k)
    ccall((:GB_bitset_int32, libgraphblas), Int32, (Int32, Int32), x, k)
end

function GB_bitset_int64(x, k)
    ccall((:GB_bitset_int64, libgraphblas), Int64, (Int64, Int64), x, k)
end

function GB_bitset_uint8(x, k)
    ccall((:GB_bitset_uint8, libgraphblas), UInt8, (UInt8, UInt8), x, k)
end

function GB_bitset_uint16(x, k)
    ccall((:GB_bitset_uint16, libgraphblas), UInt16, (UInt16, UInt16), x, k)
end

function GB_bitset_uint32(x, k)
    ccall((:GB_bitset_uint32, libgraphblas), UInt32, (UInt32, UInt32), x, k)
end

function GB_bitset_uint64(x, k)
    ccall((:GB_bitset_uint64, libgraphblas), UInt64, (UInt64, UInt64), x, k)
end

function GB_bitclr_int8(x, k)
    ccall((:GB_bitclr_int8, libgraphblas), Int8, (Int8, Int8), x, k)
end

function GB_bitclr_int16(x, k)
    ccall((:GB_bitclr_int16, libgraphblas), Int16, (Int16, Int16), x, k)
end

function GB_bitclr_int32(x, k)
    ccall((:GB_bitclr_int32, libgraphblas), Int32, (Int32, Int32), x, k)
end

function GB_bitclr_int64(x, k)
    ccall((:GB_bitclr_int64, libgraphblas), Int64, (Int64, Int64), x, k)
end

function GB_bitclr_uint8(x, k)
    ccall((:GB_bitclr_uint8, libgraphblas), UInt8, (UInt8, UInt8), x, k)
end

function GB_bitclr_uint16(x, k)
    ccall((:GB_bitclr_uint16, libgraphblas), UInt16, (UInt16, UInt16), x, k)
end

function GB_bitclr_uint32(x, k)
    ccall((:GB_bitclr_uint32, libgraphblas), UInt32, (UInt32, UInt32), x, k)
end

function GB_bitclr_uint64(x, k)
    ccall((:GB_bitclr_uint64, libgraphblas), UInt64, (UInt64, UInt64), x, k)
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

function GB_entry_check(type, x, pr, f)
    ccall((:GB_entry_check, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cvoid}, Cint, Ptr{Libc.FILE}), type, x, pr, f)
end

function GB_code_check(code, x, pr, f)
    ccall((:GB_code_check, libgraphblas), GrB_Info, (GB_Type_code, Ptr{Cvoid}, Cint, Ptr{Libc.FILE}), code, x, pr, f)
end

function GB_Context_check(Context, name, pr, f)
    ccall((:GB_Context_check, libgraphblas), GrB_Info, (GxB_Context, Ptr{Cchar}, Cint, Ptr{Libc.FILE}), Context, name, pr, f)
end

function GB_matvec_check(A, name, pr, f, kind)
    ccall((:GB_matvec_check, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, Cint, Ptr{Libc.FILE}, Ptr{Cchar}), A, name, pr, f, kind)
end

function GB_nnz_full(A)
    ccall((:GB_nnz_full, libgraphblas), Int64, (GrB_Matrix,), A)
end

function GB_nnz_max(A)
    ccall((:GB_nnz_max, libgraphblas), Int64, (GrB_Matrix,), A)
end

function GB_omp_get_max_threads()
    ccall((:GB_omp_get_max_threads, libgraphblas), Cint, ())
end

function GB_omp_get_wtime()
    ccall((:GB_omp_get_wtime, libgraphblas), Cdouble, ())
end

function GB_memoryUsage(nallocs, mem_deep, mem_shallow, A, count_hyper_hash)
    ccall((:GB_memoryUsage, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Csize_t}, Ptr{Csize_t}, GrB_Matrix, Bool), nallocs, mem_deep, mem_shallow, A, count_hyper_hash)
end

function GB_memcpy(dest, src, n, nthreads)
    ccall((:GB_memcpy, libgraphblas), Cvoid, (Ptr{Cvoid}, Ptr{Cvoid}, Csize_t, Cint), dest, src, n, nthreads)
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

function GB_unop_code_iso(A, op, binop_bind1st)
    ccall((:GB_unop_code_iso, libgraphblas), GB_iso_code, (GrB_Matrix, GB_Operator, Bool), A, op, binop_bind1st)
end

function GB_unop_iso(Cx, ctype, C_code_iso, op, A, scalar)
    ccall((:GB_unop_iso, libgraphblas), Cvoid, (Ptr{GB_void}, GrB_Type, GB_iso_code, GB_Operator, GrB_Matrix, GrB_Scalar), Cx, ctype, C_code_iso, op, A, scalar)
end

function GB_convert_any_to_non_iso(A, initialize)
    ccall((:GB_convert_any_to_non_iso, libgraphblas), GrB_Info, (GrB_Matrix, Bool), A, initialize)
end

function GB_convert_any_to_iso(A, scalar)
    ccall((:GB_convert_any_to_iso, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GB_void}), A, scalar)
end

function GB_expand_iso(X, n, scalar, size)
    ccall((:GB_expand_iso, libgraphblas), Cvoid, (Ptr{Cvoid}, Int64, Ptr{Cvoid}, Csize_t), X, n, scalar, size)
end

function GB_check_if_iso(A)
    ccall((:GB_check_if_iso, libgraphblas), Bool, (GrB_Matrix,), A)
end

function GB_nvals(nvals, A, Werk)
    ccall((:GB_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix, GB_Werk), nvals, A, Werk)
end

function GB_any_aliased(A, B)
    ccall((:GB_any_aliased, libgraphblas), Bool, (GrB_Matrix, GrB_Matrix), A, B)
end

function GB_all_aliased(A, B)
    ccall((:GB_all_aliased, libgraphblas), Bool, (GrB_Matrix, GrB_Matrix), A, B)
end

function GB_is_shallow(A)
    ccall((:GB_is_shallow, libgraphblas), Bool, (GrB_Matrix,), A)
end

@enum GB_Ap_code::UInt32 begin
    GB_Ap_calloc = 0
    GB_Ap_malloc = 1
    GB_Ap_null = 2
end

function GB_Matrix_new(A, type, nrows, ncols)
    ccall((:GB_Matrix_new, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index), A, type, nrows, ncols)
end

function GB_new(Ahandle, type, vlen, vdim, Ap_option, is_csc, sparsity, hyper_switch, plen)
    ccall((:GB_new, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Int64, Int64, GB_Ap_code, Bool, Cint, Cfloat, Int64), Ahandle, type, vlen, vdim, Ap_option, is_csc, sparsity, hyper_switch, plen)
end

function GB_new_bix(Ahandle, type, vlen, vdim, Ap_option, is_csc, sparsity, bitmap_calloc, hyper_switch, plen, nzmax, numeric, iso)
    ccall((:GB_new_bix, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, Int64, Int64, GB_Ap_code, Bool, Cint, Bool, Cfloat, Int64, Int64, Bool, Bool), Ahandle, type, vlen, vdim, Ap_option, is_csc, sparsity, bitmap_calloc, hyper_switch, plen, nzmax, numeric, iso)
end

function GB_ix_realloc(A, nzmax_new)
    ccall((:GB_ix_realloc, libgraphblas), GrB_Info, (GrB_Matrix, Int64), A, nzmax_new)
end

function GB_bix_free(A)
    ccall((:GB_bix_free, libgraphblas), Cvoid, (GrB_Matrix,), A)
end

function GB_phy_free(A)
    ccall((:GB_phy_free, libgraphblas), Cvoid, (GrB_Matrix,), A)
end

function GB_hyper_hash_free(A)
    ccall((:GB_hyper_hash_free, libgraphblas), Cvoid, (GrB_Matrix,), A)
end

function GB_phybix_free(A)
    ccall((:GB_phybix_free, libgraphblas), Cvoid, (GrB_Matrix,), A)
end

function GB_Matrix_free(Ahandle)
    ccall((:GB_Matrix_free, libgraphblas), Cvoid, (Ptr{GrB_Matrix},), Ahandle)
end

function GB_resize(A, nrows_new, ncols_new, Werk)
    ccall((:GB_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index, GB_Werk), A, nrows_new, ncols_new, Werk)
end

function GB_dup(Chandle, A, Werk)
    ccall((:GB_dup, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Matrix, GB_Werk), Chandle, A, Werk)
end

function GB_dup_worker(Chandle, C_iso, A, numeric, ctype)
    ccall((:GB_dup_worker, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Bool, GrB_Matrix, Bool, GrB_Type), Chandle, C_iso, A, numeric, ctype)
end

function GB_code_compatible(acode, bcode)
    ccall((:GB_code_compatible, libgraphblas), Bool, (GB_Type_code, GB_Type_code), acode, bcode)
end

function GB_Type_compatible(atype, btype)
    ccall((:GB_Type_compatible, libgraphblas), Bool, (GrB_Type, GrB_Type), atype, btype)
end

function GB_compatible(ctype, C, M, Mask_struct, accum, ttype, Werk)
    ccall((:GB_compatible, libgraphblas), GrB_Info, (GrB_Type, GrB_Matrix, GrB_Matrix, Bool, GrB_BinaryOp, GrB_Type, GB_Werk), ctype, C, M, Mask_struct, accum, ttype, Werk)
end

function GB_Mask_compatible(M, Mask_struct, C, nrows, ncols, Werk)
    ccall((:GB_Mask_compatible, libgraphblas), GrB_Info, (GrB_Matrix, Bool, GrB_Matrix, GrB_Index, GrB_Index, GB_Werk), M, Mask_struct, C, nrows, ncols, Werk)
end

function GB_BinaryOp_compatible(op, ctype, atype, btype, bcode, Werk)
    ccall((:GB_BinaryOp_compatible, libgraphblas), GrB_Info, (GrB_BinaryOp, GrB_Type, GrB_Type, GrB_Type, GB_Type_code, GB_Werk), op, ctype, atype, btype, bcode, Werk)
end

function GB_ewise_slice(p_TaskList, p_TaskList_size, p_ntasks, p_nthreads, Cnvec, Ch, C_to_M, C_to_A, C_to_B, Ch_is_Mh, M, A, B, Werk)
    ccall((:GB_ewise_slice, libgraphblas), GrB_Info, (Ptr{Ptr{GB_task_struct}}, Ptr{Csize_t}, Ptr{Cint}, Ptr{Cint}, Int64, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Bool, GrB_Matrix, GrB_Matrix, GrB_Matrix, GB_Werk), p_TaskList, p_TaskList_size, p_ntasks, p_nthreads, Cnvec, Ch, C_to_M, C_to_A, C_to_B, Ch_is_Mh, M, A, B, Werk)
end

function GB_slice_vector(p_i, p_pM, p_pA, p_pB, pM_start, pM_end, Mi, pA_start, pA_end, Ai, pB_start, pB_end, Bi, vlen, target_work)
    ccall((:GB_slice_vector, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Int64, Int64, Ptr{Int64}, Int64, Int64, Ptr{Int64}, Int64, Int64, Ptr{Int64}, Int64, Cdouble), p_i, p_pM, p_pA, p_pB, pM_start, pM_end, Mi, pA_start, pA_end, Ai, pB_start, pB_end, Bi, vlen, target_work)
end

function GB_task_cumsum(Cp, Cnvec, Cnvec_nonempty, TaskList, ntasks, nthreads, Werk)
    ccall((:GB_task_cumsum, libgraphblas), Cvoid, (Ptr{Int64}, Int64, Ptr{Int64}, Ptr{GB_task_struct}, Cint, Cint, GB_Werk), Cp, Cnvec, Cnvec_nonempty, TaskList, ntasks, nthreads, Werk)
end

function GB_transplant(C, ctype, Ahandle, Werk)
    ccall((:GB_transplant, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Type, Ptr{GrB_Matrix}, GB_Werk), C, ctype, Ahandle, Werk)
end

function GB_transplant_conform(C, ctype, Thandle, Werk)
    ccall((:GB_transplant_conform, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Type, Ptr{GrB_Matrix}, GB_Werk), C, ctype, Thandle, Werk)
end

function GB_matvec_type(type, A, Werk)
    ccall((:GB_matvec_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Matrix, GB_Werk), type, A, Werk)
end

function GB_matvec_type_name(type_name, A, Werk)
    ccall((:GB_matvec_type_name, libgraphblas), GrB_Info, (Ptr{Cchar}, GrB_Matrix, GB_Werk), type_name, A, Werk)
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

function GB_uint64_multiply(c, a, b)
    ccall((:GB_uint64_multiply, libgraphblas), Bool, (Ptr{UInt64}, UInt64, UInt64), c, a, b)
end

function GB_int64_multiply(c, a, b)
    ccall((:GB_int64_multiply, libgraphblas), Bool, (Ptr{UInt64}, Int64, Int64), c, a, b)
end

function GB_size_t_multiply(c, a, b)
    ccall((:GB_size_t_multiply, libgraphblas), Bool, (Ptr{Csize_t}, Csize_t, Csize_t), c, a, b)
end

function GB_extract_vector_list(J, A, Werk)
    ccall((:GB_extract_vector_list, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_Matrix, GB_Werk), J, A, Werk)
end

function GB_extractTuples(I_out, J_out, X, p_nvals, xcode, A, Werk)
    ccall((:GB_extractTuples, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GB_Type_code, GrB_Matrix, GB_Werk), I_out, J_out, X, p_nvals, xcode, A, Werk)
end

function GB_cumsum(count, n, kresult, nthreads, Werk)
    ccall((:GB_cumsum, libgraphblas), Cvoid, (Ptr{Int64}, Int64, Ptr{Int64}, Cint, GB_Werk), count, n, kresult, nthreads, Werk)
end

function GB_setElement(C, accum, scalar, row, col, scalar_code, Werk)
    ccall((:GB_setElement, libgraphblas), GrB_Info, (GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, GrB_Index, GrB_Index, GB_Type_code, GB_Werk), C, accum, scalar, row, col, scalar_code, Werk)
end

function GB_Vector_removeElement(V, i, Werk)
    ccall((:GB_Vector_removeElement, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index, GB_Werk), V, i, Werk)
end

function GB_Matrix_removeElement(C, row, col, Werk)
    ccall((:GB_Matrix_removeElement, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index, GB_Werk), C, row, col, Werk)
end

function GB_Op_free(op_handle)
    ccall((:GB_Op_free, libgraphblas), GrB_Info, (Ptr{GB_Operator},), op_handle)
end

function GB_op_is_second(op, type)
    ccall((:GB_op_is_second, libgraphblas), Bool, (GrB_BinaryOp, GrB_Type), op, type)
end

function GB_op_name_and_defn(op_name, op_name_len, op_hash, op_defn, op_defn_size, input_name, input_defn, user_op, jitable)
    ccall((:GB_op_name_and_defn, libgraphblas), GrB_Info, (Ptr{Cchar}, Ptr{Int32}, Ptr{UInt64}, Ptr{Ptr{Cchar}}, Ptr{Csize_t}, Ptr{Cchar}, Ptr{Cchar}, Bool, Bool), op_name, op_name_len, op_hash, op_defn, op_defn_size, input_name, input_defn, user_op, jitable)
end

function GB_nvec_nonempty(A)
    ccall((:GB_nvec_nonempty, libgraphblas), Int64, (GrB_Matrix,), A)
end

function GB_hyper_realloc(A, plen_new, Werk)
    ccall((:GB_hyper_realloc, libgraphblas), GrB_Info, (GrB_Matrix, Int64, GB_Werk), A, plen_new, Werk)
end

function GB_conform_hyper(A, Werk)
    ccall((:GB_conform_hyper, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_hyper_prune(p_Ap, p_Ap_size, p_Ah, p_Ah_size, p_nvec, p_plen, Ap_old, Ah_old, nvec_old, Werk)
    ccall((:GB_hyper_prune, libgraphblas), GrB_Info, (Ptr{Ptr{Int64}}, Ptr{Csize_t}, Ptr{Ptr{Int64}}, Ptr{Csize_t}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Int64, GB_Werk), p_Ap, p_Ap_size, p_Ah, p_Ah_size, p_nvec, p_plen, Ap_old, Ah_old, nvec_old, Werk)
end

function GB_hypermatrix_prune(A, Werk)
    ccall((:GB_hypermatrix_prune, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_hyper_hash_build(A, Werk)
    ccall((:GB_hyper_hash_build, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_hyper_hash_need(A)
    ccall((:GB_hyper_hash_need, libgraphblas), Bool, (GrB_Matrix,), A)
end

function GB_cast_scalar(z, zcode, x, xcode, size)
    ccall((:GB_cast_scalar, libgraphblas), Cvoid, (Ptr{Cvoid}, GB_Type_code, Ptr{Cvoid}, GB_Type_code, Csize_t), z, zcode, x, xcode, size)
end

function GB_cast_one(z, zcode)
    ccall((:GB_cast_one, libgraphblas), Cvoid, (Ptr{Cvoid}, GB_Type_code), z, zcode)
end

function GB_cast_array(Cx, code1, A, nthreads)
    ccall((:GB_cast_array, libgraphblas), GrB_Info, (Ptr{GB_void}, GB_Type_code, GrB_Matrix, Cint), Cx, code1, A, nthreads)
end

function GB_cast_matrix(C, A)
    ccall((:GB_cast_matrix, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix), C, A)
end

function GB_block(A, Werk)
    ccall((:GB_block, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_unjumble(A, Werk)
    ccall((:GB_unjumble, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_sparsity_control(sparsity_control, vdim)
    ccall((:GB_sparsity_control, libgraphblas), Cint, (Cint, Int64), sparsity_control, vdim)
end

function GB_sparsity(A)
    ccall((:GB_sparsity, libgraphblas), Cint, (GrB_Matrix,), A)
end

function GB_convert_hyper_to_sparse(A, do_burble)
    ccall((:GB_convert_hyper_to_sparse, libgraphblas), GrB_Info, (GrB_Matrix, Bool), A, do_burble)
end

function GB_convert_sparse_to_hyper(A, Werk)
    ccall((:GB_convert_sparse_to_hyper, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
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

function GB_convert_s2b_test(bitmap_switch, anz, vlen, vdim)
    ccall((:GB_convert_s2b_test, libgraphblas), Bool, (Cfloat, Int64, Int64, Int64), bitmap_switch, anz, vlen, vdim)
end

function GB_convert_full_to_bitmap(A)
    ccall((:GB_convert_full_to_bitmap, libgraphblas), GrB_Info, (GrB_Matrix,), A)
end

function GB_convert_s2b(A, Werk)
    ccall((:GB_convert_s2b, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_convert_bitmap_worker(Ap, Ai, Aj, Ax_new, anvec_nonempty, A, Werk)
    ccall((:GB_convert_bitmap_worker, libgraphblas), GrB_Info, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{GB_void}, Ptr{Int64}, GrB_Matrix, GB_Werk), Ap, Ai, Aj, Ax_new, anvec_nonempty, A, Werk)
end

function GB_convert_any_to_bitmap(A, Werk)
    ccall((:GB_convert_any_to_bitmap, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_convert_any_to_full(A)
    ccall((:GB_convert_any_to_full, libgraphblas), Cvoid, (GrB_Matrix,), A)
end

function GB_convert_any_to_hyper(A, Werk)
    ccall((:GB_convert_any_to_hyper, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_convert_any_to_sparse(A, Werk)
    ccall((:GB_convert_any_to_sparse, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_convert_to_nonfull(A, Werk)
    ccall((:GB_convert_to_nonfull, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
end

function GB_as_if_full(A)
    ccall((:GB_as_if_full, libgraphblas), Bool, (GrB_Matrix,), A)
end

function GB_conform(A, Werk)
    ccall((:GB_conform, libgraphblas), GrB_Info, (GrB_Matrix, GB_Werk), A, Werk)
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

function GB_nonzombie_func(z, x, i, j, y)
    ccall((:GB_nonzombie_func, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, Int64, GrB_Index, Ptr{Cvoid}), z, x, i, j, y)
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

function GB__func_VALUEEQ_BOOL(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_BOOL(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_BOOL(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_BOOL(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_BOOL(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_BOOL(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_BOOL, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Bool}, GrB_Index, GrB_Index, Ptr{Bool}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_INT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_INT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_INT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_INT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_INT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_INT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_INT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int8}, GrB_Index, GrB_Index, Ptr{Int8}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_INT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_INT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_INT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_INT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_INT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_INT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_INT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int16}, GrB_Index, GrB_Index, Ptr{Int16}), z, x, i_unused, j_unused, y)
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

function GB__func_ROWINDEX_INT32(z, unused, i, j_unused, y)
    ccall((:GB__func_ROWINDEX_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int32}), z, unused, i, j_unused, y)
end

function GB__func_COLINDEX_INT32(z, unused, i_unused, j, y)
    ccall((:GB__func_COLINDEX_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int32}), z, unused, i_unused, j, y)
end

function GB__func_DIAGINDEX_INT32(z, unused, i, j, y)
    ccall((:GB__func_DIAGINDEX_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int32}), z, unused, i, j, y)
end

function GB__func_FLIPDIAGINDEX_INT32(z, unused, i, j, y)
    ccall((:GB__func_FLIPDIAGINDEX_INT32, libgraphblas), Cvoid, (Ptr{Int32}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int32}), z, unused, i, j, y)
end

function GB__func_VALUEEQ_INT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_INT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_INT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_INT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_INT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_INT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_INT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int32}, GrB_Index, GrB_Index, Ptr{Int32}), z, x, i_unused, j_unused, y)
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

function GB__func_ROWINDEX_INT64(z, unused, i, j_unused, y)
    ccall((:GB__func_ROWINDEX_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j_unused, y)
end

function GB__func_COLINDEX_INT64(z, unused, i_unused, j, y)
    ccall((:GB__func_COLINDEX_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i_unused, j, y)
end

function GB__func_DIAGINDEX_INT64(z, unused, i, j, y)
    ccall((:GB__func_DIAGINDEX_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, y)
end

function GB__func_FLIPDIAGINDEX_INT64(z, unused, i, j, y)
    ccall((:GB__func_FLIPDIAGINDEX_INT64, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, y)
end

function GB__func_TRIL_INT64(z, unused, i, j, y)
    ccall((:GB__func_TRIL_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, y)
end

function GB__func_TRIU_INT64(z, unused, i, j, y)
    ccall((:GB__func_TRIU_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, y)
end

function GB__func_DIAG_INT64(z, unused, i, j, y)
    ccall((:GB__func_DIAG_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, y)
end

function GB__func_OFFDIAG_INT64(z, unused, i, j, y)
    ccall((:GB__func_OFFDIAG_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j, y)
end

function GB__func_COLLE_INT64(z, unused, i_unused, j, y)
    ccall((:GB__func_COLLE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i_unused, j, y)
end

function GB__func_COLGT_INT64(z, unused, i_unused, j, y)
    ccall((:GB__func_COLGT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i_unused, j, y)
end

function GB__func_ROWLE_INT64(z, unused, i, j_unused, y)
    ccall((:GB__func_ROWLE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j_unused, y)
end

function GB__func_ROWGT_INT64(z, unused, i, j_unused, y)
    ccall((:GB__func_ROWGT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cvoid}, GrB_Index, GrB_Index, Ptr{Int64}), z, unused, i, j_unused, y)
end

function GB__func_VALUEEQ_INT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_INT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_INT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_INT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_INT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_INT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_INT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Int64}, GrB_Index, GrB_Index, Ptr{Int64}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_UINT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_UINT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_UINT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_UINT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_UINT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_UINT8(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_UINT8, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt8}, GrB_Index, GrB_Index, Ptr{UInt8}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_UINT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_UINT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_UINT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_UINT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_UINT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_UINT16(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_UINT16, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt16}, GrB_Index, GrB_Index, Ptr{UInt16}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_UINT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_UINT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_UINT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_UINT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_UINT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_UINT32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_UINT32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt32}, GrB_Index, GrB_Index, Ptr{UInt32}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_UINT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_UINT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_UINT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_UINT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_UINT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_UINT64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_UINT64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{UInt64}, GrB_Index, GrB_Index, Ptr{UInt64}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_FP32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_FP32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_FP32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_FP32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_FP32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_FP32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_FP32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cfloat}, GrB_Index, GrB_Index, Ptr{Cfloat}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_FP64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_FP64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELT_FP64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELT_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUELE_FP64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUELE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGT_FP64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGT_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUEGE_FP64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEGE_FP64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{Cdouble}, GrB_Index, GrB_Index, Ptr{Cdouble}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_FC32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_FC32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC32_t}, GrB_Index, GrB_Index, Ptr{GxB_FC32_t}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_FC32(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_FC32, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC32_t}, GrB_Index, GrB_Index, Ptr{GxB_FC32_t}), z, x, i_unused, j_unused, y)
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

function GB__func_VALUEEQ_FC64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUEEQ_FC64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC64_t}, GrB_Index, GrB_Index, Ptr{GxB_FC64_t}), z, x, i_unused, j_unused, y)
end

function GB__func_VALUENE_FC64(z, x, i_unused, j_unused, y)
    ccall((:GB__func_VALUENE_FC64, libgraphblas), Cvoid, (Ptr{Bool}, Ptr{GxB_FC64_t}, GrB_Index, GrB_Index, Ptr{GxB_FC64_t}), z, x, i_unused, j_unused, y)
end

function GB_Context_engage(Context)
    ccall((:GB_Context_engage, libgraphblas), GrB_Info, (GxB_Context,), Context)
end

function GB_Context_disengage(Context)
    ccall((:GB_Context_disengage, libgraphblas), GrB_Info, (GxB_Context,), Context)
end

function GB_Context_nthreads_max()
    ccall((:GB_Context_nthreads_max, libgraphblas), Cint, ())
end

function GB_Context_nthreads_max_get(Context)
    ccall((:GB_Context_nthreads_max_get, libgraphblas), Cint, (GxB_Context,), Context)
end

function GB_Context_nthreads_max_set(Context, nthreads_max)
    ccall((:GB_Context_nthreads_max_set, libgraphblas), Cvoid, (GxB_Context, Cint), Context, nthreads_max)
end

function GB_Context_chunk()
    ccall((:GB_Context_chunk, libgraphblas), Cdouble, ())
end

function GB_Context_chunk_get(Context)
    ccall((:GB_Context_chunk_get, libgraphblas), Cdouble, (GxB_Context,), Context)
end

function GB_Context_chunk_set(Context, chunk)
    ccall((:GB_Context_chunk_set, libgraphblas), Cvoid, (GxB_Context, Cdouble), Context, chunk)
end

function GB_Context_gpu_id()
    ccall((:GB_Context_gpu_id, libgraphblas), Cint, ())
end

function GB_Context_gpu_id_get(Context)
    ccall((:GB_Context_gpu_id_get, libgraphblas), Cint, (GxB_Context,), Context)
end

function GB_Context_gpu_id_set(Context, gpu_id)
    ccall((:GB_Context_gpu_id_set, libgraphblas), Cvoid, (GxB_Context, Cint), Context, gpu_id)
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

function GB_reduce_to_scalar_cuda_branch(monoid, A)
    ccall((:GB_reduce_to_scalar_cuda_branch, libgraphblas), Bool, (GrB_Monoid, GrB_Matrix), monoid, A)
end

function GB_reduce_to_scalar_cuda(s, V_handle, monoid, A)
    ccall((:GB_reduce_to_scalar_cuda, libgraphblas), GrB_Info, (Ptr{GB_void}, Ptr{GrB_Matrix}, GrB_Monoid, GrB_Matrix), s, V_handle, monoid, A)
end

function GB_cuda_type_branch(type)
    ccall((:GB_cuda_type_branch, libgraphblas), Bool, (GrB_Type,), type)
end

function GB_AxB_dot3_cuda(C, M, Mask_struct, A, B, semiring, flipxy)
    ccall((:GB_AxB_dot3_cuda, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, Bool, GrB_Matrix, GrB_Matrix, GrB_Semiring, Bool), C, M, Mask_struct, A, B, semiring, flipxy)
end

function GB_AxB_dot3_cuda_branch(M, Mask_struct, A, B, semiring, flipxy)
    ccall((:GB_AxB_dot3_cuda_branch, libgraphblas), Bool, (GrB_Matrix, Bool, GrB_Matrix, GrB_Matrix, GrB_Semiring, Bool), M, Mask_struct, A, B, semiring, flipxy)
end

function GB_AxB_saxpy3_cumsum(C, SaxpyTasks, nfine, chunk, nthreads, Werk)
    ccall((:GB_AxB_saxpy3_cumsum, libgraphblas), Cvoid, (GrB_Matrix, Ptr{GB_saxpy3task_struct}, Cint, Cdouble, Cint, GB_Werk), C, SaxpyTasks, nfine, chunk, nthreads, Werk)
end

function GB_ek_slice_merge1(Cp, Wfirst, Wlast, A_ek_slicing, A_ntasks)
    ccall((:GB_ek_slice_merge1, libgraphblas), Cvoid, (Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Ptr{Int64}, Cint), Cp, Wfirst, Wlast, A_ek_slicing, A_ntasks)
end

function GB_memset(dest, c, n, nthreads)
    ccall((:GB_memset, libgraphblas), Cvoid, (Ptr{Cvoid}, Cint, Csize_t, Cint), dest, c, n, nthreads)
end

function GB_bix_alloc(A, nzmax, sparsity, bitmap_calloc, numeric, A_iso)
    ccall((:GB_bix_alloc, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, Cint, Bool, Bool, Bool), A, nzmax, sparsity, bitmap_calloc, numeric, A_iso)
end

function GB_qsort_1(A_0, n)
    ccall((:GB_qsort_1, libgraphblas), Cvoid, (Ptr{Int64}, Int64), A_0, n)
end

function GB_bitmap_M_scatter(C, I, nI, Ikind, Icolon, J, nJ, Jkind, Jcolon, M, Mask_struct, assign_kind, operation, M_ek_slicing, M_ntasks, M_nthreads)
    ccall((:GB_bitmap_M_scatter, libgraphblas), Cvoid, (GrB_Matrix, Ptr{GrB_Index}, Int64, Cint, Ptr{Int64}, Ptr{GrB_Index}, Int64, Cint, Ptr{Int64}, GrB_Matrix, Bool, Cint, Cint, Ptr{Int64}, Cint, Cint), C, I, nI, Ikind, Icolon, J, nJ, Jkind, Jcolon, M, Mask_struct, assign_kind, operation, M_ek_slicing, M_ntasks, M_nthreads)
end

function GB_bitmap_M_scatter_whole(C, M, Mask_struct, operation, M_ek_slicing, M_ntasks, M_nthreads)
    ccall((:GB_bitmap_M_scatter_whole, libgraphblas), Cvoid, (GrB_Matrix, GrB_Matrix, Bool, Cint, Ptr{Int64}, Cint, Cint), C, M, Mask_struct, operation, M_ek_slicing, M_ntasks, M_nthreads)
end

const GB_COMPILER_NVCC = 0

const GB_COMPILER_ICX = 0

const GB_COMPILER_ICC = 0

const GB_COMPILER_CLANG = 0

const GB_COMPILER_GCC = 0

const GB_COMPILER_MSC = 0

const GB_COMPILER_XLC = 0

const GB_COMPILER_MAJOR = __clang_major__

const GB_COMPILER_MINOR = __clang_minor__

const GB_COMPILER_SUB = __clang_patchlevel__

const GB_COMPILER_NAME = ("clang ")(__clang_version__)

const GB_COMPILER_MSC_2019_OR_NEWER = GB_COMPILER_MSC && (GB_COMPILER_MAJOR == 19 && GB_COMPILER_MINOR >= 20)

const GB_PRAGMA_SIMD = GB_PRAGMA(omp(simd))

const GB_PRAGMA_SIMD_VECTORIZE = GB_PRAGMA_SIMD

const GB_HAS_VLA = 1

const GBX86 = 0

const GB_COMPILER_SUPPORTS_AVX512F = 0

const GB_COMPILER_SUPPORTS_AVX2 = 0

const GBCOVER_MAX = 31000

# Skipping MacroDefinition: GB_GLOBAL extern

const GB_HAS_CMPLX_MACROS = 1

const GB_restrict = restrict

const GRB_VERSION = GxB_SPEC_MAJOR

const GRB_SUBVERSION = GxB_SPEC_MINOR

const restrict = GB_restrict

# Skipping MacroDefinition: GB_STATIC_INLINE static inline

# Skipping MacroDefinition: GB_1BYTE ( sizeof ( uint8_t ) )

# Skipping MacroDefinition: GB_2BYTE ( sizeof ( uint16_t ) )

# Skipping MacroDefinition: GB_4BYTE ( sizeof ( uint32_t ) )

# Skipping MacroDefinition: GB_8BYTE ( sizeof ( uint64_t ) )

# Skipping MacroDefinition: GB_16BYTE ( sizeof ( GB_blob16 ) )

const GB_HYPER_SWITCH_DEFAULT = 0.0625

const GB_HYPER_HASH_DEFAULT = 1024

const GB_CHUNK_DEFAULT = 64 * 1024

const GB_PENDING_INIT = 256

const GB_NMAX = GrB_INDEX_MAX + 1

const GB_ALL = 0

const GB_RANGE = 1

const GB_STRIDE = 2

const GB_LIST = 3

const GB_ASSIGN = 0

const GB_SUBASSIGN = 1

const GB_ROW_ASSIGN = 2

const GB_COL_ASSIGN = 3

const GBu = ("%")(PRIu64)

const GBd = ("%")(PRId64)

# Skipping MacroDefinition: GB_ABORT /* abort ( ) */ ;

const GB_HERE = $(Expr(:toplevel, :(GBDUMP((("%2d: Here: ")(__FILE__))("\n"), __LINE__))))

const GB_DEAD_CODE = 0

const GB_MAGIC = Culonglong(0x0072657473786f62)

const GB_FREED = Culonglong(0x006c6c756e786f62)

const GB_MAGIC2 = Culonglong(0x007265745f786f62)

const GB_WERK_SIZE = 16384

# Skipping MacroDefinition: GB_64 ( 8 * sizeof ( unsigned long long ) )

const GB_SAXPY4_PANEL_SIZE = 4

const GB_SAXBIT_PANEL_SIZE = 4

const GB_SAXPY_METHOD_3 = 3

const GB_SAXPY_METHOD_BITMAP = 5

const GB_SAXPY_METHOD_ISO_FULL = 6

const GB_BITMAP_M_SCATTER_PLUS_2 = 0

const GB_BITMAP_M_SCATTER_MINUS_2 = 1

const GB_BITMAP_M_SCATTER_SET_2 = 2

const GB_BITMAP_M_SCATTER_MOD_2 = 3

const GB_OPENMP_MAX_THREADS = 1

const GB_OPENMP_GET_WTIME = 0

const GBNSTATIC = 0

# Skipping MacroDefinition: GJ_cast_to_int8_DEFN \
#"int8_t GJ_cast_to_int8 (double x)                      \n" \
#"{                                                      \n" \
#"    if (isnan (x)) return (0) ;                        \n" \
#"    if (x <= (double) INT8_MIN) return (INT8_MIN) ;    \n" \
#"    if (x >= (double) INT8_MAX) return (INT8_MAX) ;    \n" \
#"    return ((int8_t) x) ;                              \n" \
#"}"

# Skipping MacroDefinition: GJ_cast_to_int16_DEFN \
#"int16_t GJ_cast_to_int16 (double x)                    \n" \
#"{                                                      \n" \
#"    if (isnan (x)) return (0) ;                        \n" \
#"    if (x <= (double) INT16_MIN) return (INT16_MIN) ;  \n" \
#"    if (x >= (double) INT16_MAX) return (INT16_MAX) ;  \n" \
#"    return ((int16_t) x) ;                             \n" \
#"}"

# Skipping MacroDefinition: GJ_cast_to_int32_DEFN \
#"int32_t GJ_cast_to_int32 (double x)                    \n" \
#"{                                                      \n" \
#"    if (isnan (x)) return (0) ;                        \n" \
#"    if (x <= (double) INT32_MIN) return (INT32_MIN) ;  \n" \
#"    if (x >= (double) INT32_MAX) return (INT32_MAX) ;  \n" \
#"    return ((int32_t) x) ;                             \n" \
#"}"

# Skipping MacroDefinition: GJ_cast_to_int64_DEFN \
#"int64_t GJ_cast_to_int64 (double x)                    \n" \
#"{                                                      \n" \
#"    if (isnan (x)) return (0) ;                        \n" \
#"    if (x <= (double) INT64_MIN) return (INT64_MIN) ;  \n" \
#"    if (x >= (double) INT64_MAX) return (INT64_MAX) ;  \n" \
#"    return ((int64_t) x) ;                             \n" \
#"}"

# Skipping MacroDefinition: GJ_cast_to_uint8_DEFN \
#"uint8_t GJ_cast_to_uint8 (double x)                    \n" \
#"{                                                      \n" \
#"    if (isnan (x) || x <= 0) return (0) ;              \n" \
#"    if (x >= (double) UINT8_MAX) return (UINT8_MAX) ;  \n" \
#"    return ((uint8_t) x) ;                             \n" \
#"}"

# Skipping MacroDefinition: GJ_cast_to_uint16_DEFN \
#"uint16_t GJ_cast_to_uint16 (double x)                      \n" \
#"{                                                          \n" \
#"    if (isnan (x) || x <= 0) return (0) ;                  \n" \
#"    if (x >= (double) UINT16_MAX) return (UINT16_MAX) ;    \n" \
#"    return ((uint16_t) x) ;                                \n" \
#"}"

# Skipping MacroDefinition: GJ_cast_to_uint32_DEFN \
#"uint32_t GJ_cast_to_uint32 (double x)                      \n" \
#"{                                                          \n" \
#"    if (isnan (x) || x <= 0) return (0) ;                  \n" \
#"    if (x >= (double) UINT32_MAX) return (UINT32_MAX) ;    \n" \
#"    return ((uint32_t) x) ;                                \n" \
#"}"

# Skipping MacroDefinition: GJ_cast_to_uint64_DEFN \
#"uint64_t GJ_cast_to_uint64 (double x)                      \n" \
#"{                                                          \n" \
#"    if (isnan (x) || x <= 0) return (0) ;                  \n" \
#"    if (x >= (double) UINT64_MAX) return (UINT64_MAX) ;    \n" \
#"    return ((uint64_t) x) ;                                \n" \
#"}"

const GB_CAST = (((ztype, x))(ztype))(x)

# Skipping MacroDefinition: GB_CAST_FUNCTION ( ztype , xtype ) inline void GB ( _cast_ ## ztype ## _ ## xtype ) \
#( void * z , /* typecasted output, of type ztype */ const void * x , /* input value to typecast, of type xtype */ size_t s /* size of type, for GB_copy_user_user only */ \
#) \
#{ xtype xx = ( * ( ( xtype * ) x ) ) ; ztype zz = GB_CAST ( ztype , xx ) ; ( * ( ( ztype * ) z ) ) = zz ; \
#}

const GB_M_TYPE = GB_void

# Skipping MacroDefinition: GJ_idiv_int8_DEFN \
#"int8_t GJ_idiv_int8 (int8_t x, int8_t y)                            \n" \
#"{                                                                   \n" \
#"    if (y == -1)                                                    \n" \
#"    {                                                               \n" \
#"        return (-x) ;                                               \n" \
#"    }                                                               \n" \
#"    else if (y == 0)                                                \n" \
#"    {                                                               \n" \
#"        return ((x == 0) ? 0 : ((x < 0) ? INT8_MIN : INT8_MAX)) ;   \n" \
#"    }                                                               \n" \
#"    else                                                            \n" \
#"    {                                                               \n" \
#"        return (x / y) ;                                            \n" \
#"    }                                                               \n" \
#"}"

# Skipping MacroDefinition: GJ_idiv_int16_DEFN \
#"int16_t GJ_idiv_int16 (int16_t x, int16_t y)                        \n" \
#"{                                                                   \n" \
#"    if (y == -1)                                                    \n" \
#"    {                                                               \n" \
#"        return (-x) ;                                               \n" \
#"    }                                                               \n" \
#"    else if (y == 0)                                                \n" \
#"    {                                                               \n" \
#"        return ((x == 0) ? 0 : ((x < 0) ? INT16_MIN : INT16_MAX)) ; \n" \
#"    }                                                               \n" \
#"    else                                                            \n" \
#"    {                                                               \n" \
#"        return (x / y) ;                                            \n" \
#"    }                                                               \n" \
#"}"

# Skipping MacroDefinition: GJ_idiv_int32_DEFN \
#"int32_t GJ_idiv_int32 (int32_t x, int32_t y)                        \n" \
#"{                                                                   \n" \
#"    if (y == -1)                                                    \n" \
#"    {                                                               \n" \
#"        return (-x) ;                                               \n" \
#"    }                                                               \n" \
#"    else if (y == 0)                                                \n" \
#"    {                                                               \n" \
#"        return ((x == 0) ? 0 : ((x < 0) ? INT32_MIN : INT32_MAX)) ; \n" \
#"    }                                                               \n" \
#"    else                                                            \n" \
#"    {                                                               \n" \
#"        return (x / y) ;                                            \n" \
#"    }                                                               \n" \
#"}"

# Skipping MacroDefinition: GJ_idiv_int64_DEFN \
#"int64_t GJ_idiv_int64 (int64_t x, int64_t y)                        \n" \
#"{                                                                   \n" \
#"    if (y == -1)                                                    \n" \
#"    {                                                               \n" \
#"        return (-x) ;                                               \n" \
#"    }                                                               \n" \
#"    else if (y == 0)                                                \n" \
#"    {                                                               \n" \
#"        return ((x == 0) ? 0 : ((x < 0) ? INT64_MIN : INT64_MAX)) ; \n" \
#"    }                                                               \n" \
#"    else                                                            \n" \
#"    {                                                               \n" \
#"        return (x / y) ;                                            \n" \
#"    }                                                               \n" \
#"}"

# Skipping MacroDefinition: GJ_idiv_uint8_DEFN \
#"uint8_t GJ_idiv_uint8 (uint8_t x, uint8_t y)                        \n" \
#"{                                                                   \n" \
#"    if (y == 0)                                                     \n" \
#"    {                                                               \n" \
#"        return ((x == 0) ? 0 : UINT8_MAX) ;                         \n" \
#"    }                                                               \n" \
#"    else                                                            \n" \
#"    {                                                               \n" \
#"        return (x / y) ;                                            \n" \
#"    }                                                               \n" \
#"}"

# Skipping MacroDefinition: GJ_idiv_uint16_DEFN \
#"uint16_t GJ_idiv_uint16 (uint16_t x, uint16_t y)                    \n" \
#"{                                                                   \n" \
#"    if (y == 0)                                                     \n" \
#"    {                                                               \n" \
#"        return ((x == 0) ? 0 : UINT16_MAX) ;                        \n" \
#"    }                                                               \n" \
#"    else                                                            \n" \
#"    {                                                               \n" \
#"        return (x / y) ;                                            \n" \
#"    }                                                               \n" \
#"}"

# Skipping MacroDefinition: GJ_idiv_uint32_DEFN \
#"uint32_t GJ_idiv_uint32 (uint32_t x, uint32_t y)                    \n" \
#"{                                                                   \n" \
#"    if (y == 0)                                                     \n" \
#"    {                                                               \n" \
#"        return ((x == 0) ? 0 : UINT32_MAX) ;                        \n" \
#"    }                                                               \n" \
#"    else                                                            \n" \
#"    {                                                               \n" \
#"        return (x / y) ;                                            \n" \
#"    }                                                               \n" \
#"}"

# Skipping MacroDefinition: GJ_idiv_uint64_DEFN \
#"uint64_t GJ_idiv_uint64 (uint64_t x, uint64_t y)                    \n" \
#"{                                                                   \n" \
#"    if (y == 0)                                                     \n" \
#"    {                                                               \n" \
#"        return ((x == 0) ? 0 : UINT64_MAX) ;                        \n" \
#"    }                                                               \n" \
#"    else                                                            \n" \
#"    {                                                               \n" \
#"        return (x / y) ;                                            \n" \
#"    }                                                               \n" \
#"}"

# Skipping MacroDefinition: GJ_FC64_div_DEFN \
#"GxB_FC64_t GJ_FC64_div (GxB_FC64_t x, GxB_FC64_t y)                 \n" \
#"{                                                                   \n" \
#"    double xr = GB_creal (x) ;                                      \n" \
#"    double xi = GB_cimag (x) ;                                      \n" \
#"    double yr = GB_creal (y) ;                                      \n" \
#"    double yi = GB_cimag (y) ;                                      \n" \
#"    int yr_class = fpclassify (yr) ;                                \n" \
#"    int yi_class = fpclassify (yi) ;                                \n" \
#"    if (yi_class == FP_ZERO)                                        \n" \
#"    {                                                               \n" \
#"        return (GJ_CMPLX64 (xr / yr, xi / yr)) ;                    \n" \
#"    }                                                               \n" \
#"    else if (yr_class == FP_ZERO)                                   \n" \
#"    {                                                               \n" \
#"        return (GJ_CMPLX64 (xi / yi, -xr / yi)) ;                   \n" \
#"    }                                                               \n" \
#"    else if (yi_class == FP_INFINITE && yr_class == FP_INFINITE)    \n" \
#"    {                                                               \n" \
#"        double r = (signbit (yr) == signbit (yi)) ? (1) : (-1) ;    \n" \
#"        double d = yr + r * yi ;                                    \n" \
#"        return (GJ_CMPLX64 ((xr + xi * r) / d, (xi - xr * r) / d)) ;\n" \
#"    }                                                               \n" \
#"    else if (fabs (yr) >= fabs (yi))                                \n" \
#"    {                                                               \n" \
#"        double r = yi / yr ;                                        \n" \
#"        double d = yr + r * yi ;                                    \n" \
#"        return (GJ_CMPLX64 ((xr + xi * r) / d, (xi - xr * r) / d)) ;\n" \
#"    }                                                               \n" \
#"    else                                                            \n" \
#"    {                                                               \n" \
#"        double r = yr / yi ;                                        \n" \
#"        double d = r * yr + yi ;                                    \n" \
#"        return (GJ_CMPLX64 ((xr * r + xi) / d, (xi * r - xr) / d)) ;\n" \
#"    }                                                               \n" \
#"}"

# Skipping MacroDefinition: GJ_FC32_div_DEFN \
#"GxB_FC32_t GJ_FC32_div (GxB_FC32_t x, GxB_FC32_t y)                    \n" \
#"{                                                                      \n" \
#"    double xr = (double) GB_crealf (x) ;                               \n" \
#"    double xi = (double) GB_cimagf (x) ;                               \n" \
#"    double yr = (double) GB_crealf (y) ;                               \n" \
#"    double yi = (double) GB_cimagf (y) ;                               \n" \
#"    GxB_FC64_t zz ;                                                    \n" \
#"    zz = GJ_FC64_div (GJ_CMPLX64 (xr, xi), GJ_CMPLX64 (yr, yi)) ;      \n" \
#"    return (GJ_CMPLX32 ((float) GB_creal(zz), (float) GB_cimag(zz))) ; \n" \
#"}"

# Skipping MacroDefinition: GJ_powf_DEFN "float GJ_powf (float x, float y)                                   \n" \
#"{                                                                   \n" \
#"    int xr_class = fpclassify (x) ;                                 \n" \
#"    int yr_class = fpclassify (y) ;                                 \n" \
#"    if (xr_class == FP_NAN || yr_class == FP_NAN)                   \n" \
#"    {                                                               \n" \
#"        return (NAN) ;                                              \n" \
#"    }                                                               \n" \
#"    if (yr_class == FP_ZERO)                                        \n" \
#"    {                                                               \n" \
#"        return (1) ;                                                \n" \
#"    }                                                               \n" \
#"    return (powf (x, y)) ;                                          \n" \
#"}"

# Skipping MacroDefinition: GJ_pow_DEFN \
#"double GJ_pow (double x, double y)                                  \n" \
#"{                                                                   \n" \
#"    int xr_class = fpclassify (x) ;                                 \n" \
#"    int yr_class = fpclassify (y) ;                                 \n" \
#"    if (xr_class == FP_NAN || yr_class == FP_NAN)                   \n" \
#"    {                                                               \n" \
#"        // z is nan if either x or y are nan                        \n" \
#"        return (NAN) ;                                              \n" \
#"    }                                                               \n" \
#"    if (yr_class == FP_ZERO)                                        \n" \
#"    {                                                               \n" \
#"        // z is 1 if y is zero                                      \n" \
#"        return (1) ;                                                \n" \
#"    }                                                               \n" \
#"    // otherwise, z = pow (x,y)                                     \n" \
#"    return (pow (x, y)) ;                                           \n" \
#"}"

# Skipping MacroDefinition: GJ_FC32_pow_DEFN \
#"GxB_FC32_t GJ_FC32_pow (GxB_FC32_t x, GxB_FC32_t y)                 \n" \
#"{                                                                   \n" \
#"    float xr = GB_crealf (x) ;                                      \n" \
#"    float yr = GB_crealf (y) ;                                      \n" \
#"    int xr_class = fpclassify (xr) ;                                \n" \
#"    int yr_class = fpclassify (yr) ;                                \n" \
#"    int xi_class = fpclassify (GB_cimagf (x)) ;                     \n" \
#"    int yi_class = fpclassify (GB_cimagf (y)) ;                     \n" \
#"    if (xi_class == FP_ZERO && yi_class == FP_ZERO)                 \n" \
#"    {                                                               \n" \
#"        if (xr >= 0 || yr_class == FP_NAN ||                        \n" \
#"            yr_class == FP_INFINITE || yr == truncf (yr))           \n" \
#"        {                                                           \n" \
#"            return (GJ_CMPLX32 (GJ_powf (xr, yr), 0)) ;             \n" \
#"        }                                                           \n" \
#"    }                                                               \n" \
#"    if (xr_class == FP_NAN || xi_class == FP_NAN ||                 \n" \
#"        yr_class == FP_NAN || yi_class == FP_NAN)                   \n" \
#"    {                                                               \n" \
#"        return (GJ_CMPLX32 (NAN, NAN)) ;                            \n" \
#"    }                                                               \n" \
#"    if (yr_class == FP_ZERO && yi_class == FP_ZERO)                 \n" \
#"    {                                                               \n" \
#"        return (GxB_CMPLXF (1, 0)) ;                                \n" \
#"    }                                                               \n" \
#"    return (GB_cpowf (x, y)) ;                                      \n" \
#"}"

# Skipping MacroDefinition: GJ_FC64_pow_DEFN \
#"GxB_FC64_t GJ_FC64_pow (GxB_FC64_t x, GxB_FC64_t y)                 \n" \
#"{                                                                   \n" \
#"    double xr = GB_creal (x) ;                                      \n" \
#"    double yr = GB_creal (y) ;                                      \n" \
#"    int xr_class = fpclassify (xr) ;                                \n" \
#"    int yr_class = fpclassify (yr) ;                                \n" \
#"    int xi_class = fpclassify (GB_cimag (x)) ;                      \n" \
#"    int yi_class = fpclassify (GB_cimag (y)) ;                      \n" \
#"    if (xi_class == FP_ZERO && yi_class == FP_ZERO)                 \n" \
#"    {                                                               \n" \
#"        if (xr >= 0 || yr_class == FP_NAN ||                        \n" \
#"            yr_class == FP_INFINITE || yr == trunc (yr))            \n" \
#"        {                                                           \n" \
#"            return (GJ_CMPLX64 (GJ_pow (xr, yr), 0)) ;              \n" \
#"        }                                                           \n" \
#"    }                                                               \n" \
#"    if (xr_class == FP_NAN || xi_class == FP_NAN ||                 \n" \
#"        yr_class == FP_NAN || yi_class == FP_NAN)                   \n" \
#"    {                                                               \n" \
#"        return (GJ_CMPLX64 (NAN, NAN)) ;                            \n" \
#"    }                                                               \n" \
#"    if (yr_class == FP_ZERO && yi_class == FP_ZERO)                 \n" \
#"    {                                                               \n" \
#"        return (GxB_CMPLX (1, 0)) ;                                 \n" \
#"    }                                                               \n" \
#"    return (GB_cpow (x, y)) ;                                       \n" \
#"}"

# Skipping MacroDefinition: GJ_pow_int8_DEFN \
#"int8_t GJ_pow_int8 (int8_t x, int8_t y)                            \n" \
#"{                                                                  \n" \
#"    return (GJ_cast_to_int8 (GJ_pow ((double) x, (double) y))) ;   \n" \
#"}"

# Skipping MacroDefinition: GJ_pow_int16_DEFN \
#"int16_t GJ_pow_int16 (int16_t x, int16_t y)                        \n" \
#"{                                                                  \n" \
#"    return (GJ_cast_to_int16 (GJ_pow ((double) x, (double) y))) ;  \n" \
#"}"

# Skipping MacroDefinition: GJ_pow_int32_DEFN \
#"int32_t GJ_pow_int32 (int32_t x, int32_t y)                        \n" \
#"{                                                                  \n" \
#"    return (GJ_cast_to_int32 (GJ_pow ((double) x, (double) y))) ;  \n" \
#"}"

# Skipping MacroDefinition: GJ_pow_int64_DEFN \
#"int64_t GJ_pow_int64 (int64_t x, int64_t y)                        \n" \
#"{                                                                  \n" \
#"    return (GJ_cast_to_int64 (GJ_pow ((double) x, (double) y))) ;  \n" \
#"}"

# Skipping MacroDefinition: GJ_pow_uint8_DEFN \
#"int8_t GJ_pow_uint8 (int8_t x, int8_t y)                           \n" \
#"{                                                                  \n" \
#"    return (GJ_cast_to_uint8 (GJ_pow ((double) x, (double) y))) ;  \n" \
#"}"

# Skipping MacroDefinition: GJ_pow_uint16_DEFN \
#"int16_t GJ_pow_uint16 (int16_t x, int16_t y)                       \n" \
#"{                                                                  \n" \
#"    return (GJ_cast_to_uint16 (GJ_pow ((double) x, (double) y))) ; \n" \
#"}"

# Skipping MacroDefinition: GJ_pow_uint32_DEFN \
#"int32_t GJ_pow_uint32 (int32_t x, int32_t y)                       \n" \
#"{                                                                  \n" \
#"    return (GJ_cast_to_uint32 (GJ_pow ((double) x, (double) y))) ; \n" \
#"}"

# Skipping MacroDefinition: GJ_pow_uint64_DEFN \
#"int64_t GJ_pow_uint64 (int64_t x, int64_t y)                       \n" \
#"{                                                                  \n" \
#"    return (GJ_cast_to_uint64 (GJ_pow ((double) x, (double) y))) ; \n" \
#"}"

# Skipping MacroDefinition: GJ_frexpxf_DEFN "float GJ_frexpxf (float x)                                        \n" \
#"{                                                                  \n" \
#"    int exp_ignored ;                                              \n" \
#"    return (frexpf (x, &exp_ignored)) ;                            \n" \
#"}"

# Skipping MacroDefinition: GJ_frexpef_DEFN "float GJ_frexpef (float x)                                        \n" \
#"{                                                                  \n" \
#"    int exp ;                                                      \n" \
#"    (void) frexpf (x, &exp) ;                                      \n" \
#"    return ((float) exp) ;                                         \n" \
#"}"

# Skipping MacroDefinition: GJ_frexpx_DEFN \
#"double GJ_frexpx (double x)                                        \n" \
#"{                                                                  \n" \
#"    int exp_ignored ;                                              \n" \
#"    return (frexp (x, &exp_ignored)) ;                             \n" \
#"}"

# Skipping MacroDefinition: GJ_frexpe_DEFN \
#"double GJ_frexpe (double x)                                        \n" \
#"{                                                                  \n" \
#"    int exp ;                                                      \n" \
#"    (void) frexp (x, &exp) ;                                       \n" \
#"    return ((double) exp) ;                                        \n" \
#"}"

# Skipping MacroDefinition: GJ_signumf_DEFN "float GJ_signumf (float x)                                        \n" \
#"{                                                                  \n" \
#"    if (isnan (x)) return (x) ;                                    \n" \
#"    return ((float) ((x < 0) ? (-1) : ((x > 0) ? 1 : 0))) ;        \n" \
#"}"

# Skipping MacroDefinition: GJ_signum_DEFN \
#"double GJ_signum (double x)                                        \n" \
#"{                                                                  \n" \
#"    if (isnan (x)) return (x) ;                                    \n" \
#"    return ((double) ((x < 0) ? (-1) : ((x > 0) ? 1 : 0))) ;       \n" \
#"}"

# Skipping MacroDefinition: GJ_csignumf_DEFN \
#"GxB_FC32_t GJ_csignumf (GxB_FC32_t x)                              \n" \
#"{                                                                  \n" \
#"    if (GB_crealf (x) == 0 && GB_cimagf (x) == 0)                  \n" \
#"    {                                                              \n" \
#"        return (GxB_CMPLXF (0,0)) ;                                \n" \
#"    }                                                              \n" \
#"    float y = GB_cabsf (x) ;                                       \n" \
#"    return (GJ_CMPLX32 (GB_crealf (x) / y, GB_cimagf (x) / y)) ;   \n" \
#"}"

# Skipping MacroDefinition: GJ_csignum_DEFN \
#"GxB_FC64_t GJ_csignum (GxB_FC64_t x)                               \n" \
#"{                                                                  \n" \
#"    if (GB_creal (x) == 0 && GB_cimag (x) == 0)                    \n" \
#"    {                                                              \n" \
#"        return (GxB_CMPLX (0,0)) ;                                 \n" \
#"    }                                                              \n" \
#"    double y = GB_cabs (x) ;                                       \n" \
#"    return (GJ_CMPLX64 (GB_creal (x) / y, GB_cimag (x) / y)) ;     \n" \
#"}"

# Skipping MacroDefinition: GJ_cceilf_DEFN \
#"GxB_FC32_t GJ_cceilf (GxB_FC32_t x)                                      \n" \
#"{                                                                        \n" \
#"    return (GJ_CMPLX32 (ceilf (GB_crealf (x)), ceilf (GB_cimagf (x)))) ; \n" \
#"}"

# Skipping MacroDefinition: GJ_cceil_DEFN \
#"GxB_FC64_t GJ_cceil (GxB_FC64_t x)                                     \n" \
#"{                                                                      \n" \
#"    return (GJ_CMPLX64 (ceil (GB_creal (x)), ceil (GB_cimag (x)))) ;   \n" \
#"}"

# Skipping MacroDefinition: GJ_cfloorf_DEFN \
#"GxB_FC32_t GJ_cfloorf (GxB_FC32_t x)                                      \n" \
#"{                                                                         \n" \
#"    return (GJ_CMPLX32 (floorf (GB_crealf (x)), floorf (GB_cimagf (x)))) ;\n" \
#"}"

# Skipping MacroDefinition: GJ_cfloor_DEFN \
#"GxB_FC64_t GJ_cfloor (GxB_FC64_t x)                                    \n" \
#"{                                                                      \n" \
#"    return (GJ_CMPLX64 (floor (GB_creal (x)), floor (GB_cimag (x)))) ; \n" \
#"}"

# Skipping MacroDefinition: GJ_croundf_DEFN \
#"GxB_FC32_t GJ_croundf (GxB_FC32_t x)                                      \n" \
#"{                                                                         \n" \
#"    return (GJ_CMPLX32 (roundf (GB_crealf (x)), roundf (GB_cimagf (x)))) ;\n" \
#"}"

# Skipping MacroDefinition: GJ_cround_DEFN \
#"GxB_FC64_t GJ_cround (GxB_FC64_t x)                                    \n" \
#"{                                                                      \n" \
#"    return (GJ_CMPLX64 (round (GB_creal (x)), round (GB_cimag (x)))) ; \n" \
#"}"

# Skipping MacroDefinition: GJ_ctruncf_DEFN \
#"GxB_FC32_t GJ_ctruncf (GxB_FC32_t x)                                      \n" \
#"{                                                                         \n" \
#"    return (GJ_CMPLX32 (truncf (GB_crealf (x)), truncf (GB_cimagf (x)))) ;\n" \
#"}"

# Skipping MacroDefinition: GJ_ctrunc_DEFN \
#"GxB_FC64_t GJ_ctrunc (GxB_FC64_t x)                                    \n" \
#"{                                                                      \n" \
#"    return (GJ_CMPLX64 (trunc (GB_creal (x)), trunc (GB_cimag (x)))) ; \n" \
#"}"

# Skipping MacroDefinition: GJ_cexp2f_DEFN \
#"GxB_FC32_t GJ_cexp2f (GxB_FC32_t x)                                \n" \
#"{                                                                  \n" \
#"    if (fpclassify (GB_cimagf (x)) == FP_ZERO)                     \n" \
#"    {                                                              \n" \
#"        return (GJ_CMPLX32 (exp2f (GB_crealf (x)), 0)) ;           \n" \
#"    }                                                              \n" \
#"    return (GJ_FC32_pow (GxB_CMPLXF (2,0), x)) ;                   \n" \
#"}"

# Skipping MacroDefinition: GJ_cexp2_DEFN \
#"GxB_FC64_t GJ_cexp2 (GxB_FC64_t x)                                 \n" \
#"{                                                                  \n" \
#"    if (fpclassify (GB_cimag (x)) == FP_ZERO)                      \n" \
#"    {                                                              \n" \
#"        return (GJ_CMPLX64 (exp2 (GB_creal (x)), 0)) ;             \n" \
#"    }                                                              \n" \
#"    return (GJ_FC64_pow (GxB_CMPLX (2,0), x)) ;                    \n" \
#"}"

# Skipping MacroDefinition: GJ_cexpm1_DEFN \
#"GxB_FC64_t GJ_cexpm1 (GxB_FC64_t x)                                \n" \
#"{                                                                  \n" \
#"    GxB_FC64_t z = GB_cexp (x) ;                                   \n" \
#"    return (GJ_CMPLX64 (GB_creal (z) - 1, GB_cimag (z))) ;         \n" \
#"}"

# Skipping MacroDefinition: GJ_cexpm1f_DEFN \
#"GxB_FC32_t GJ_cexpm1f (GxB_FC32_t x)                               \n" \
#"{                                                                  \n" \
#"    GxB_FC64_t z = GJ_CMPLX64 ((double) GB_crealf (x),             \n" \
#"                               (double) GB_cimagf (x)) ;           \n" \
#"    z = GJ_cexpm1 (z) ;                                            \n" \
#"    return (GJ_CMPLX32 ((float) GB_creal (z),                      \n" \
#"                        (float) GB_cimag (z))) ;                   \n" \
#"}"

# Skipping MacroDefinition: GJ_clog1p_DEFN \
#"GxB_FC64_t GJ_clog1p (GxB_FC64_t x)                                    \n" \
#"{                                                                      \n" \
#"    return (GB_clog (GJ_CMPLX64 (GB_creal (x) + 1, GB_cimag (x)))) ;   \n" \
#"}"

# Skipping MacroDefinition: GJ_clog1pf_DEFN \
#"GxB_FC32_t GJ_clog1pf (GxB_FC32_t x)                               \n" \
#"{                                                                  \n" \
#"    GxB_FC64_t z = GJ_CMPLX64 ((double) GB_crealf (x),             \n" \
#"                               (double) GB_cimagf (x)) ;           \n" \
#"    z = GJ_clog1p (z) ;                                            \n" \
#"    return (GJ_CMPLX32 ((float) GB_creal (z),                      \n" \
#"                        (float) GB_cimag (z))) ;                   \n" \
#"}"

# Skipping MacroDefinition: GJ_clog10f_DEFN \
#"GxB_FC32_t GJ_clog10f (GxB_FC32_t x)                                   \n" \
#"{                                                                      \n" \
#"    return (GJ_FC32_div (GB_clogf (x), GxB_CMPLXF (2.3025851f, 0))) ;  \n" \
#"}"

# Skipping MacroDefinition: GJ_clog10_DEFN \
#"GxB_FC64_t GJ_clog10 (GxB_FC64_t x)                                \n" \
#"{                                                                  \n" \
#"    return (GJ_FC64_div (GB_clog (x),                              \n" \
#"        GxB_CMPLX (2.302585092994045901, 0))) ;                    \n" \
#"}"

# Skipping MacroDefinition: GJ_clog2f_DEFN \
#"GxB_FC32_t GJ_clog2f (GxB_FC32_t x)                                    \n" \
#"{                                                                      \n" \
#"    return (GJ_FC32_div (GB_clogf (x), GxB_CMPLXF (0.69314718f, 0))) ; \n" \
#"}"

# Skipping MacroDefinition: GJ_clog2_DEFN \
#"GxB_FC64_t GJ_clog2 (GxB_FC64_t x)                                 \n" \
#"{                                                                  \n" \
#"    return (GJ_FC64_div (GB_clog (x),                              \n" \
#"        GxB_CMPLX (0.693147180559945286, 0))) ;                    \n" \
#"}"

# Skipping MacroDefinition: GJ_cisinff_DEFN "bool GJ_cisinff (GxB_FC32_t x)                                   \n" \
#"{                                                                  \n" \
#"    return (isinf (GB_crealf (x)) || isinf (GB_cimagf (x))) ;      \n" \
#"}"

# Skipping MacroDefinition: GJ_cisinf_DEFN "bool GJ_cisinf (GxB_FC64_t x)                                    \n" \
#"{                                                                  \n" \
#"    return (isinf (GB_creal (x)) || isinf (GB_cimag (x))) ;        \n" \
#"}"

# Skipping MacroDefinition: GJ_cisnanf_DEFN "bool GJ_cisnanf (GxB_FC32_t x)                                   \n" \
#"{                                                                  \n" \
#"    return (isnan (GB_crealf (x)) || isnan (GB_cimagf (x))) ;      \n" \
#"}"

# Skipping MacroDefinition: GJ_cisnan_DEFN "bool GJ_cisnan (GxB_FC64_t x)                                    \n" \
#"{                                                                  \n" \
#"    return (isnan (GB_creal (x)) || isnan (GB_cimag (x))) ;        \n" \
#"}"

# Skipping MacroDefinition: GJ_cisfinitef_DEFN "bool GJ_cisfinitef (GxB_FC32_t x)                                \n" \
#"{                                                                  \n" \
#"    return (isfinite (GB_crealf (x)) && isfinite (GB_cimagf (x))) ;\n" \
#"}"

# Skipping MacroDefinition: GJ_cisfinite_DEFN "bool GJ_cisfinite (GxB_FC64_t x)                                 \n" \
#"{                                                                  \n" \
#"    return (isfinite (GB_creal (x)) && isfinite (GB_cimag (x))) ;  \n" \
#"}"

# Skipping MacroDefinition: GJ_bitget_int8_DEFN \
#"int8_t GJ_bitget_int8 (int8_t x, int8_t k)                  \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 8) return (0) ;                        \n" \
#"    return ((x & (((int8_t) 1) << (k-1))) ? 1 : 0) ;        \n" \
#"}"

# Skipping MacroDefinition: GJ_bitget_int16_DEFN \
#"int16_t GJ_bitget_int16 (int16_t x, int16_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 16) return (0) ;                       \n" \
#"    return ((x & (((int16_t) 1) << (k-1))) ? 1 : 0) ;       \n" \
#"}"

# Skipping MacroDefinition: GJ_bitget_int32_DEFN \
#"int32_t GJ_bitget_int32 (int32_t x, int32_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 32) return (0) ;                       \n" \
#"    return ((x & (((int32_t) 1) << (k-1))) ? 1 : 0) ;       \n" \
#"}"

# Skipping MacroDefinition: GJ_bitget_int64_DEFN \
#"int64_t GJ_bitget_int64 (int64_t x, int64_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 64) return (0) ;                       \n" \
#"    return ((x & (((int64_t) 1) << (k-1))) ? 1 : 0) ;       \n" \
#"}"

# Skipping MacroDefinition: GJ_bitget_uint8_DEFN \
#"uint8_t GJ_bitget_uint8 (uint8_t x, uint8_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 8) return (0) ;                        \n" \
#"    return ((x & (((uint8_t) 1) << (k-1))) ? 1 : 0) ;       \n" \
#"}"

# Skipping MacroDefinition: GJ_bitget_uint16_DEFN \
#"uint16_t GJ_bitget_uint16 (uint16_t x, uint16_t k)          \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 16) return (0) ;                       \n" \
#"    return ((x & (((uint16_t) 1) << (k-1))) ? 1 : 0) ;      \n" \
#"}"

# Skipping MacroDefinition: GJ_bitget_uint32_DEFN \
#"uint32_t GJ_bitget_uint32 (uint32_t x, uint32_t k)          \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 32) return (0) ;                       \n" \
#"    return ((x & (((uint32_t) 1) << (k-1))) ? 1 : 0) ;      \n" \
#"}"

# Skipping MacroDefinition: GJ_bitget_uint64_DEFN \
#"uint64_t GJ_bitget_uint64 (uint64_t x, uint64_t k)          \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 64) return (0) ;                       \n" \
#"    return ((x & (((uint64_t) 1) << (k-1))) ? 1 : 0) ;      \n" \
#"}"

# Skipping MacroDefinition: GJ_bitset_int8_DEFN \
#"int8_t GJ_bitset_int8 (int8_t x, int8_t k)                  \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 8) return (x) ;                        \n" \
#"    return (x | (((int8_t) 1) << (k-1))) ;                  \n" \
#"}"

# Skipping MacroDefinition: GJ_bitset_int16_DEFN \
#"int16_t GJ_bitset_int16 (int16_t x, int16_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 16) return (x) ;                       \n" \
#"    return (x | (((int16_t) 1) << (k-1))) ;                 \n" \
#"}"

# Skipping MacroDefinition: GJ_bitset_int32_DEFN \
#"int32_t GJ_bitset_int32 (int32_t x, int32_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 32) return (x) ;                       \n" \
#"    return (x | (((int32_t) 1) << (k-1))) ;                 \n" \
#"}"

# Skipping MacroDefinition: GJ_bitset_int64_DEFN \
#"int64_t GJ_bitset_int64 (int64_t x, int64_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 64) return (x) ;                       \n" \
#"    return (x | (((int64_t) 1) << (k-1))) ;                 \n" \
#"}"

# Skipping MacroDefinition: GJ_bitset_uint8_DEFN \
#"uint8_t GJ_bitset_uint8 (uint8_t x, uint8_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 8) return (x) ;                        \n" \
#"    return (x | (((uint8_t) 1) << (k-1))) ;                 \n" \
#"}"

# Skipping MacroDefinition: GJ_bitset_uint16_DEFN \
#"uint16_t GJ_bitset_uint16 (uint16_t x, uint16_t k)          \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 16) return (x) ;                       \n" \
#"    return (x | (((uint16_t) 1) << (k-1))) ;                \n" \
#"}"

# Skipping MacroDefinition: GJ_bitset_uint32_DEFN \
#"uint32_t GJ_bitset_uint32 (uint32_t x, uint32_t k)          \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 32) return (x) ;                       \n" \
#"    return (x | (((uint32_t) 1) << (k-1))) ;                \n" \
#"}"

# Skipping MacroDefinition: GJ_bitset_uint64_DEFN \
#"uint64_t GJ_bitset_uint64 (uint64_t x, uint64_t k)          \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 64) return (x) ;                       \n" \
#"    return (x | (((uint64_t) 1) << (k-1))) ;                \n" \
#"}"

# Skipping MacroDefinition: GJ_bitclr_int8_DEFN \
#"int8_t GJ_bitclr_int8 (int8_t x, int8_t k)                  \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 8) return (x) ;                        \n" \
#"    return (x & ~(((int8_t) 1) << (k-1))) ;                 \n" \
#"}"

# Skipping MacroDefinition: GJ_bitclr_int16_DEFN \
#"int16_t GJ_bitclr_int16 (int16_t x, int16_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 16) return (x) ;                       \n" \
#"    return (x & ~(((int16_t) 1) << (k-1))) ;                \n" \
#"}"

# Skipping MacroDefinition: GJ_bitclr_int32_DEFN \
#"int32_t GJ_bitclr_int32 (int32_t x, int32_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 32) return (x) ;                       \n" \
#"    return (x & ~(((int32_t) 1) << (k-1))) ;                \n" \
#"}"

# Skipping MacroDefinition: GJ_bitclr_int64_DEFN \
#"int64_t GJ_bitclr_int64 (int64_t x, int64_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 64) return (x) ;                       \n" \
#"    return (x & ~(((int64_t) 1) << (k-1))) ;                \n" \
#"}"

# Skipping MacroDefinition: GJ_bitclr_uint8_DEFN \
#"uint8_t GJ_bitclr_uint8 (uint8_t x, uint8_t k)              \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 8) return (x) ;                        \n" \
#"    return (x & ~(((uint8_t) 1) << (k-1))) ;                \n" \
#"}"

# Skipping MacroDefinition: GJ_bitclr_uint16_DEFN \
#"uint16_t GJ_bitclr_uint16 (uint16_t x, uint16_t k)          \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 16) return (x) ;                       \n" \
#"    return (x & ~(((uint16_t) 1) << (k-1))) ;               \n" \
#"}"

# Skipping MacroDefinition: GJ_bitclr_uint32_DEFN \
#"uint32_t GJ_bitclr_uint32 (uint32_t x, uint32_t k)          \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 32) return (x) ;                       \n" \
#"    return (x & ~(((uint32_t) 1) << (k-1))) ;               \n" \
#"}"

# Skipping MacroDefinition: GJ_bitclr_uint64_DEFN \
#"uint64_t GJ_bitclr_uint64 (uint64_t x, uint64_t k)          \n" \
#"{                                                           \n" \
#"    if (k < 1 || k > 64) return (x) ;                       \n" \
#"    return (x & ~(((uint64_t) 1) << (k-1))) ;               \n" \
#"}"

# Skipping MacroDefinition: GJ_bitshift_uint8_DEFN \
#"uint8_t GJ_bitshift_uint8 (uint8_t x, int8_t k)                 \n" \
#"{                                                               \n" \
#"    if (k == 0)                                                 \n" \
#"    {                                                           \n" \
#"        return (x) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k >= 8 || k <= -8)                                 \n" \
#"    {                                                           \n" \
#"        return (0) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k > 0)                                             \n" \
#"    {                                                           \n" \
#"        return (x << k) ;                                       \n" \
#"    }                                                           \n" \
#"    else                                                        \n" \
#"    {                                                           \n" \
#"        return (x >> (-k)) ;                                    \n" \
#"    }                                                           \n" \
#"}"

# Skipping MacroDefinition: GJ_bitshift_uint16_DEFN \
#"uint16_t GJ_bitshift_uint16 (uint16_t x, int8_t k)              \n" \
#"{                                                               \n" \
#"    if (k == 0)                                                 \n" \
#"    {                                                           \n" \
#"        return (x) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k >= 16 || k <= -16)                               \n" \
#"    {                                                           \n" \
#"        return (0) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k > 0)                                             \n" \
#"    {                                                           \n" \
#"        return (x << k) ;                                       \n" \
#"    }                                                           \n" \
#"    else                                                        \n" \
#"    {                                                           \n" \
#"        return (x >> (-k)) ;                                    \n" \
#"    }                                                           \n" \
#"}"

# Skipping MacroDefinition: GJ_bitshift_uint32_DEFN \
#"uint32_t GJ_bitshift_uint32 (uint32_t x, int8_t k)              \n" \
#"{                                                               \n" \
#"    if (k == 0)                                                 \n" \
#"    {                                                           \n" \
#"        return (x) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k >= 32 || k <= -32)                               \n" \
#"    {                                                           \n" \
#"        return (0) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k > 0)                                             \n" \
#"    {                                                           \n" \
#"        return (x << k) ;                                       \n" \
#"    }                                                           \n" \
#"    else                                                        \n" \
#"    {                                                           \n" \
#"        return (x >> (-k)) ;                                    \n" \
#"    }                                                           \n" \
#"}"

# Skipping MacroDefinition: GJ_bitshift_uint64_DEFN \
#"uint64_t GJ_bitshift_uint64 (uint64_t x, int8_t k)              \n" \
#"{                                                               \n" \
#"    if (k == 0)                                                 \n" \
#"    {                                                           \n" \
#"        return (x) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k >= 64 || k <= -64)                               \n" \
#"    {                                                           \n" \
#"        return (0) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k > 0)                                             \n" \
#"    {                                                           \n" \
#"        return (x << k) ;                                       \n" \
#"    }                                                           \n" \
#"    else                                                        \n" \
#"    {                                                           \n" \
#"        return (x >> (-k)) ;                                    \n" \
#"    }                                                           \n" \
#"}"

# Skipping MacroDefinition: GJ_bitshift_int8_DEFN \
#"int8_t GJ_bitshift_int8 (int8_t x, int8_t k)                    \n" \
#"{                                                               \n" \
#"    if (k == 0)                                                 \n" \
#"    {                                                           \n" \
#"        return (x) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k >= 8)                                            \n" \
#"    {                                                           \n" \
#"        return (0) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k <= -8)                                           \n" \
#"    {                                                           \n" \
#"        return ((x >= 0) ? 0 : -1) ;                            \n" \
#"    }                                                           \n" \
#"    else if (k > 0)                                             \n" \
#"    {                                                           \n" \
#"        return (x << k) ;                                       \n" \
#"    }                                                           \n" \
#"    else                                                        \n" \
#"    {                                                           \n" \
#"        k = -k ;                                                \n" \
#"        if (x >= 0)                                             \n" \
#"        {                                                       \n" \
#"            return (x >> k) ;                                   \n" \
#"        }                                                       \n" \
#"        else                                                    \n" \
#"        {                                                       \n" \
#"            return ((x >> k) | (~(UINT8_MAX >> k))) ;           \n" \
#"        }                                                       \n" \
#"    }                                                           \n" \
#"}"

# Skipping MacroDefinition: GJ_bitshift_int16_DEFN \
#"int16_t GJ_bitshift_int16 (int16_t x, int8_t k)                 \n" \
#"{                                                               \n" \
#"    if (k == 0)                                                 \n" \
#"    {                                                           \n" \
#"        return (x) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k >= 16)                                           \n" \
#"    {                                                           \n" \
#"        return (0) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k <= -16)                                          \n" \
#"    {                                                           \n" \
#"        return ((x >= 0) ? 0 : -1) ;                            \n" \
#"    }                                                           \n" \
#"    else if (k > 0)                                             \n" \
#"    {                                                           \n" \
#"        return (x << k) ;                                       \n" \
#"    }                                                           \n" \
#"    else                                                        \n" \
#"    {                                                           \n" \
#"        k = -k ;                                                \n" \
#"        if (x >= 0)                                             \n" \
#"        {                                                       \n" \
#"            return (x >> k) ;                                   \n" \
#"        }                                                       \n" \
#"        else                                                    \n" \
#"        {                                                       \n" \
#"            return ((x >> k) | (~(UINT16_MAX >> k))) ;          \n" \
#"        }                                                       \n" \
#"    }                                                           \n" \
#"}"

# Skipping MacroDefinition: GJ_bitshift_int32_DEFN \
#"int32_t GJ_bitshift_int32 (int32_t x, int8_t k)                 \n" \
#"{                                                               \n" \
#"    if (k == 0)                                                 \n" \
#"    {                                                           \n" \
#"        return (x) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k >= 32)                                           \n" \
#"    {                                                           \n" \
#"        return (0) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k <= -32)                                          \n" \
#"    {                                                           \n" \
#"        return ((x >= 0) ? 0 : -1) ;                            \n" \
#"    }                                                           \n" \
#"    else if (k > 0)                                             \n" \
#"    {                                                           \n" \
#"        return (x << k) ;                                       \n" \
#"    }                                                           \n" \
#"    else                                                        \n" \
#"    {                                                           \n" \
#"        k = -k ;                                                \n" \
#"        if (x >= 0)                                             \n" \
#"        {                                                       \n" \
#"            return (x >> k) ;                                   \n" \
#"        }                                                       \n" \
#"        else                                                    \n" \
#"        {                                                       \n" \
#"            return ((x >> k) | (~(UINT32_MAX >> k))) ;          \n" \
#"        }                                                       \n" \
#"    }                                                           \n" \
#"}"

# Skipping MacroDefinition: GJ_bitshift_int64_DEFN \
#"int64_t GJ_bitshift_int64 (int64_t x, int8_t k)                 \n" \
#"{                                                               \n" \
#"    if (k == 0)                                                 \n" \
#"    {                                                           \n" \
#"        return (x) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k >= 64)                                           \n" \
#"    {                                                           \n" \
#"        return (0) ;                                            \n" \
#"    }                                                           \n" \
#"    else if (k <= -64)                                          \n" \
#"    {                                                           \n" \
#"        return ((x >= 0) ? 0 : -1) ;                            \n" \
#"    }                                                           \n" \
#"    else if (k > 0)                                             \n" \
#"    {                                                           \n" \
#"        return (x << k) ;                                       \n" \
#"    }                                                           \n" \
#"    else                                                        \n" \
#"    {                                                           \n" \
#"        k = -k ;                                                \n" \
#"        if (x >= 0)                                             \n" \
#"        {                                                       \n" \
#"            return (x >> k) ;                                   \n" \
#"        }                                                       \n" \
#"        else                                                    \n" \
#"        {                                                       \n" \
#"            return ((x >> k) | (~(UINT64_MAX >> k))) ;          \n" \
#"        }                                                       \n" \
#"    }                                                           \n" \
#"}"

const GB0 = GxB_SILENT

const GB1 = GxB_SUMMARY

const GB2 = GxB_SHORT

const GB3 = GxB_COMPLETE

const GB4 = GxB_SHORT_VERBOSE

const GB5 = GxB_COMPLETE_VERBOSE

const GB_TWO_TO_THE_30 = Clong(0x40000000)

const GB_LOGGER_LEN = 384

const GB_ALWAYS_HYPER = 1.0

const GB_NEVER_HYPER = -1.0

const GB_XTYPE = BOOL

const GB_TYPE = bool

const GB_BITS = 1

# Skipping MacroDefinition: GB_UNOP_STRUCT ( op , xtype ) GB_GLOBAL struct GB_UnaryOp_opaque GB_OPAQUE ( GB_EVAL3 ( op , _ , xtype ) )

# Skipping MacroDefinition: GB_BINOP_STRUCT ( op , xtype ) GB_GLOBAL struct GB_BinaryOp_opaque GB_OPAQUE ( GB_EVAL3 ( op , _ , xtype ) )

# Skipping MacroDefinition: GB_OP ( op , func ) GB_UNOP_STRUCT ( op , GB_XTYPE ) ; inline void GB_FUNC ( op ) ( GB_TYPE * z , const GB_TYPE * x ) { ( * z ) = func ( * x ) ; }

# Skipping MacroDefinition: GB_Z_X_Y_ARGS GB_TYPE * z , const GB_TYPE * x , const GB_TYPE * y

# Skipping MacroDefinition: GB_Zbool_X_Y_ARGS bool * z , const GB_TYPE * x , const GB_TYPE * y

const GB_CUDA_MAX_GPUS = 32

const GB_GPU_CHUNK_DEFAULT = 1024 * 1024

end # module
