module LibGraphBLAS

const GxB_FC32_t = ComplexF32

const GxB_FC64_t = ComplexF32

const GrB_Index = UInt64

@enum GrB_Info::UInt32 begin
    GrB_SUCCESS = 0
    GrB_NO_VALUE = 1
    GrB_UNINITIALIZED_OBJECT = 2
    GrB_INVALID_OBJECT = 3
    GrB_NULL_POINTER = 4
    GrB_INVALID_VALUE = 5
    GrB_INVALID_INDEX = 6
    GrB_DOMAIN_MISMATCH = 7
    GrB_DIMENSION_MISMATCH = 8
    GrB_OUTPUT_NOT_EMPTY = 9
    GrB_OUT_OF_MEMORY = 10
    GrB_INSUFFICIENT_SPACE = 11
    GrB_INDEX_OUT_OF_BOUNDS = 12
    GrB_PANIC = 13
end

@enum GrB_Mode::UInt32 begin
    GrB_NONBLOCKING = 0
    GrB_BLOCKING = 1
end

function GrB_init(mode)
    ccall((:GrB_init, libgraphblas), GrB_Info, (GrB_Mode,), mode)
end

function GxB_init(mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function, user_malloc_is_thread_safe)
    ccall((:GxB_init, libgraphblas), GrB_Info, (GrB_Mode, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Bool), mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function, user_malloc_is_thread_safe)
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
end

@enum GrB_Desc_Value::UInt32 begin
    GxB_DEFAULT = 0
    GrB_REPLACE = 1
    GrB_COMP = 2
    # GrB_SCMP = 2
    GrB_STRUCTURE = 4
    GrB_TRAN = 3
    GxB_GPU_ALWAYS = 2001
    GxB_GPU_NEVER = 2002
    GxB_AxB_GUSTAVSON = 1001
    GxB_AxB_DOT = 1003
    GxB_AxB_HASH = 1004
    GxB_AxB_SAXPY = 1005
end

mutable struct GB_Descriptor_opaque end

const GrB_Descriptor = Ptr{GB_Descriptor_opaque}

function GrB_Descriptor_new(descriptor)
    ccall((:GrB_Descriptor_new, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), descriptor)
end

function GrB_Descriptor_set(desc, field, val)
    ccall((:GrB_Descriptor_set, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Desc_Field, GrB_Desc_Value), desc, field, val)
end

function GxB_Descriptor_get(val, desc, field)
    ccall((:GxB_Descriptor_get, libgraphblas), GrB_Info, (Ptr{GrB_Desc_Value}, GrB_Descriptor, GrB_Desc_Field), val, desc, field)
end

function GrB_Descriptor_free(descriptor)
    ccall((:GrB_Descriptor_free, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), descriptor)
end

mutable struct GB_Type_opaque end

const GrB_Type = Ptr{GB_Type_opaque}

function GB_Type_new(type, sizeof_ctype, name)
    ccall((:GB_Type_new, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Csize_t, Ptr{Cchar}), type, sizeof_ctype, name)
end

function GxB_Type_size(size, type)
    ccall((:GxB_Type_size, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Type), size, type)
end

function GrB_Type_free(type)
    ccall((:GrB_Type_free, libgraphblas), GrB_Info, (Ptr{GrB_Type},), type)
end

mutable struct GB_UnaryOp_opaque end

const GrB_UnaryOp = Ptr{GB_UnaryOp_opaque}

# typedef void ( * GxB_unary_function ) ( void * , const void * )
const GxB_unary_function = Ptr{Cvoid}

function GB_UnaryOp_new(unaryop, _function, ztype, xtype, name)
    ccall((:GB_UnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp}, GxB_unary_function, GrB_Type, GrB_Type, Ptr{Cchar}), unaryop, _function, ztype, xtype, name)
end

function GxB_UnaryOp_ztype(ztype, unaryop)
    ccall((:GxB_UnaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), ztype, unaryop)
end

function GxB_UnaryOp_xtype(xtype, unaryop)
    ccall((:GxB_UnaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), xtype, unaryop)
end

function GrB_UnaryOp_free(unaryop)
    ccall((:GrB_UnaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp},), unaryop)
end

mutable struct GB_BinaryOp_opaque end

const GrB_BinaryOp = Ptr{GB_BinaryOp_opaque}

# typedef void ( * GxB_binary_function ) ( void * , const void * , const void * )
const GxB_binary_function = Ptr{Cvoid}

function GB_BinaryOp_new(binaryop, _function, ztype, xtype, ytype, name)
    ccall((:GB_BinaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_binary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}), binaryop, _function, ztype, xtype, ytype, name)
end

function GxB_BinaryOp_ztype(ztype, binaryop)
    ccall((:GxB_BinaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), ztype, binaryop)
end

function GxB_BinaryOp_xtype(xtype, binaryop)
    ccall((:GxB_BinaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), xtype, binaryop)
end

function GxB_BinaryOp_ytype(ytype, binaryop)
    ccall((:GxB_BinaryOp_ytype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), ytype, binaryop)
end

function GrB_BinaryOp_free(binaryop)
    ccall((:GrB_BinaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp},), binaryop)
end

mutable struct GB_SelectOp_opaque end

const GxB_SelectOp = Ptr{GB_SelectOp_opaque}

# typedef bool ( * GxB_select_function ) // return true if A(i,j) is kept ( GrB_Index i , // row index of A(i,j) GrB_Index j , // column index of A(i,j) const void * x , // value of A(i,j) const void * thunk // optional input for select function )
const GxB_select_function = Ptr{Cvoid}

function GB_SelectOp_new(selectop, _function, xtype, ttype, name)
    ccall((:GB_SelectOp_new, libgraphblas), GrB_Info, (Ptr{GxB_SelectOp}, GxB_select_function, GrB_Type, GrB_Type, Ptr{Cchar}), selectop, _function, xtype, ttype, name)
end

function GxB_SelectOp_xtype(xtype, selectop)
    ccall((:GxB_SelectOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), xtype, selectop)
end

function GxB_SelectOp_ttype(ttype, selectop)
    ccall((:GxB_SelectOp_ttype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), ttype, selectop)
end

function GxB_SelectOp_free(selectop)
    ccall((:GxB_SelectOp_free, libgraphblas), GrB_Info, (Ptr{GxB_SelectOp},), selectop)
end

mutable struct GB_Monoid_opaque end

const GrB_Monoid = Ptr{GB_Monoid_opaque}

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

function GrB_Monoid_free(monoid)
    ccall((:GrB_Monoid_free, libgraphblas), GrB_Info, (Ptr{GrB_Monoid},), monoid)
end

mutable struct GB_Semiring_opaque end

const GrB_Semiring = Ptr{GB_Semiring_opaque}

function GrB_Semiring_new(semiring, add, multiply)
    ccall((:GrB_Semiring_new, libgraphblas), GrB_Info, (Ptr{GrB_Semiring}, GrB_Monoid, GrB_BinaryOp), semiring, add, multiply)
end

function GxB_Semiring_add(add, semiring)
    ccall((:GxB_Semiring_add, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_Semiring), add, semiring)
end

function GxB_Semiring_multiply(multiply, semiring)
    ccall((:GxB_Semiring_multiply, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GrB_Semiring), multiply, semiring)
end

function GrB_Semiring_free(semiring)
    ccall((:GrB_Semiring_free, libgraphblas), GrB_Info, (Ptr{GrB_Semiring},), semiring)
end

mutable struct GB_Scalar_opaque end

const GxB_Scalar = Ptr{GB_Scalar_opaque}

function GxB_Scalar_new(s, type)
    ccall((:GxB_Scalar_new, libgraphblas), GrB_Info, (Ptr{GxB_Scalar}, GrB_Type), s, type)
end

function GxB_Scalar_dup(s, t)
    ccall((:GxB_Scalar_dup, libgraphblas), GrB_Info, (Ptr{GxB_Scalar}, GxB_Scalar), s, t)
end

function GxB_Scalar_clear(s)
    ccall((:GxB_Scalar_clear, libgraphblas), GrB_Info, (GxB_Scalar,), s)
end

function GxB_Scalar_nvals(nvals, s)
    ccall((:GxB_Scalar_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GxB_Scalar), nvals, s)
end

function GxB_Scalar_type(type, s)
    ccall((:GxB_Scalar_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_Scalar), type, s)
end

function GxB_Scalar_memoryUsage(size, s)
    ccall((:GxB_Scalar_memoryUsage, libgraphblas), GrB_Info, (Ptr{Csize_t}, GxB_Scalar), size, s)
end

function GxB_Scalar_free(s)
    ccall((:GxB_Scalar_free, libgraphblas), GrB_Info, (Ptr{GxB_Scalar},), s)
end

function GxB_Scalar_setElement_BOOL(s, x)
    ccall((:GxB_Scalar_setElement_BOOL, libgraphblas), GrB_Info, (GxB_Scalar, Bool), s, x)
end

function GxB_Scalar_setElement_INT8(s, x)
    ccall((:GxB_Scalar_setElement_INT8, libgraphblas), GrB_Info, (GxB_Scalar, Int8), s, x)
end

function GxB_Scalar_setElement_UINT8(s, x)
    ccall((:GxB_Scalar_setElement_UINT8, libgraphblas), GrB_Info, (GxB_Scalar, UInt8), s, x)
end

function GxB_Scalar_setElement_INT16(s, x)
    ccall((:GxB_Scalar_setElement_INT16, libgraphblas), GrB_Info, (GxB_Scalar, Int16), s, x)
end

function GxB_Scalar_setElement_UINT16(s, x)
    ccall((:GxB_Scalar_setElement_UINT16, libgraphblas), GrB_Info, (GxB_Scalar, UInt16), s, x)
end

function GxB_Scalar_setElement_INT32(s, x)
    ccall((:GxB_Scalar_setElement_INT32, libgraphblas), GrB_Info, (GxB_Scalar, Int32), s, x)
end

function GxB_Scalar_setElement_UINT32(s, x)
    ccall((:GxB_Scalar_setElement_UINT32, libgraphblas), GrB_Info, (GxB_Scalar, UInt32), s, x)
end

function GxB_Scalar_setElement_INT64(s, x)
    ccall((:GxB_Scalar_setElement_INT64, libgraphblas), GrB_Info, (GxB_Scalar, Int64), s, x)
end

function GxB_Scalar_setElement_UINT64(s, x)
    ccall((:GxB_Scalar_setElement_UINT64, libgraphblas), GrB_Info, (GxB_Scalar, UInt64), s, x)
end

function GxB_Scalar_setElement_FP32(s, x)
    ccall((:GxB_Scalar_setElement_FP32, libgraphblas), GrB_Info, (GxB_Scalar, Cfloat), s, x)
end

function GxB_Scalar_setElement_FP64(s, x)
    ccall((:GxB_Scalar_setElement_FP64, libgraphblas), GrB_Info, (GxB_Scalar, Cdouble), s, x)
end

function GxB_Scalar_setElement_FC32(s, x)
    ccall((:GxB_Scalar_setElement_FC32, libgraphblas), GrB_Info, (GxB_Scalar, GxB_FC32_t), s, x)
end

function GxB_Scalar_setElement_FC64(s, x)
    ccall((:GxB_Scalar_setElement_FC64, libgraphblas), GrB_Info, (GxB_Scalar, GxB_FC64_t), s, x)
end

function GxB_Scalar_setElement_UDT(s, x)
    ccall((:GxB_Scalar_setElement_UDT, libgraphblas), GrB_Info, (GxB_Scalar, Ptr{Cvoid}), s, x)
end

function GxB_Scalar_extractElement_BOOL(x, s)
    ccall((:GxB_Scalar_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_INT8(x, s)
    ccall((:GxB_Scalar_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UINT8(x, s)
    ccall((:GxB_Scalar_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_INT16(x, s)
    ccall((:GxB_Scalar_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UINT16(x, s)
    ccall((:GxB_Scalar_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_INT32(x, s)
    ccall((:GxB_Scalar_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UINT32(x, s)
    ccall((:GxB_Scalar_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_INT64(x, s)
    ccall((:GxB_Scalar_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UINT64(x, s)
    ccall((:GxB_Scalar_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_FP32(x, s)
    ccall((:GxB_Scalar_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_FP64(x, s)
    ccall((:GxB_Scalar_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_FC32(x, s)
    ccall((:GxB_Scalar_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_FC64(x, s)
    ccall((:GxB_Scalar_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GxB_Scalar), x, s)
end

function GxB_Scalar_extractElement_UDT(x, s)
    ccall((:GxB_Scalar_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GxB_Scalar), x, s)
end

mutable struct GB_Vector_opaque end

const GrB_Vector = Ptr{GB_Vector_opaque}

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

function GxB_Vector_memoryUsage(size, v)
    ccall((:GxB_Vector_memoryUsage, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Vector), size, v)
end

function GxB_Vector_iso(iso, v)
    ccall((:GxB_Vector_iso, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Vector), iso, v)
end

function GrB_Vector_free(v)
    ccall((:GrB_Vector_free, libgraphblas), GrB_Info, (Ptr{GrB_Vector},), v)
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
    ccall((:GxB_Vector_build_Scalar, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, GxB_Scalar, GrB_Index), w, I, scalar, nvals)
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

mutable struct GB_Matrix_opaque end

const GrB_Matrix = Ptr{GB_Matrix_opaque}

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

function GxB_Matrix_memoryUsage(size, A)
    ccall((:GxB_Matrix_memoryUsage, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Matrix), size, A)
end

function GxB_Matrix_iso(iso, A)
    ccall((:GxB_Matrix_iso, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_Matrix), iso, A)
end

function GrB_Matrix_free(A)
    ccall((:GrB_Matrix_free, libgraphblas), GrB_Info, (Ptr{GrB_Matrix},), A)
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
    ccall((:GxB_Matrix_build_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, GxB_Scalar, GrB_Index), C, I, J, scalar, nvals)
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

function GxB_Matrix_diag(C, v, k, desc)
    ccall((:GxB_Matrix_diag, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, Int64, GrB_Descriptor), C, v, k, desc)
end

function GxB_Vector_diag(v, A, k, desc)
    ccall((:GxB_Vector_diag, libgraphblas), GrB_Info, (GrB_Vector, GrB_Matrix, Int64, GrB_Descriptor), v, A, k, desc)
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

@enum GxB_Format_Value::Int32 begin
    GxB_BY_ROW = 0
    GxB_BY_COL = 1
    GxB_NO_FORMAT = -1
end

function GrB_Type_wait(type)
    ccall((:GrB_Type_wait, libgraphblas), GrB_Info, (Ptr{GrB_Type},), type)
end

function GrB_UnaryOp_wait(op)
    ccall((:GrB_UnaryOp_wait, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp},), op)
end

function GrB_BinaryOp_wait(op)
    ccall((:GrB_BinaryOp_wait, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp},), op)
end

function GxB_SelectOp_wait(op)
    ccall((:GxB_SelectOp_wait, libgraphblas), GrB_Info, (Ptr{GxB_SelectOp},), op)
end

function GrB_Monoid_wait(monoid)
    ccall((:GrB_Monoid_wait, libgraphblas), GrB_Info, (Ptr{GrB_Monoid},), monoid)
end

function GrB_Semiring_wait(semiring)
    ccall((:GrB_Semiring_wait, libgraphblas), GrB_Info, (Ptr{GrB_Semiring},), semiring)
end

function GrB_Descriptor_wait(desc)
    ccall((:GrB_Descriptor_wait, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), desc)
end

function GxB_Scalar_wait(s)
    ccall((:GxB_Scalar_wait, libgraphblas), GrB_Info, (Ptr{GxB_Scalar},), s)
end

function GrB_Vector_wait(v)
    ccall((:GrB_Vector_wait, libgraphblas), GrB_Info, (Ptr{GrB_Vector},), v)
end

function GrB_Matrix_wait(A)
    ccall((:GrB_Matrix_wait, libgraphblas), GrB_Info, (Ptr{GrB_Matrix},), A)
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

function GrB_Monoid_error(error, monoid)
    ccall((:GrB_Monoid_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Monoid), error, monoid)
end

function GrB_Semiring_error(error, semiring)
    ccall((:GrB_Semiring_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Semiring), error, semiring)
end

function GxB_Scalar_error(error, s)
    ccall((:GxB_Scalar_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GxB_Scalar), error, s)
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

function GrB_mxm(C, Mask, accum, semiring, A, B, desc)
    ccall((:GrB_mxm, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

function GrB_vxm(w, mask, accum, semiring, u, A, desc)
    ccall((:GrB_vxm, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Matrix, GrB_Descriptor), w, mask, accum, semiring, u, A, desc)
end

function GrB_mxv(w, mask, accum, semiring, A, u, desc)
    ccall((:GrB_mxv, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, A, u, desc)
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

function GrB_Matrix_eWiseMult_Semiring(C, Mask, accum, semiring, A, B, desc)
    ccall((:GrB_Matrix_eWiseMult_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

function GrB_Matrix_eWiseMult_Monoid(C, Mask, accum, monoid, A, B, desc)
    ccall((:GrB_Matrix_eWiseMult_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, monoid, A, B, desc)
end

function GrB_Matrix_eWiseMult_BinaryOp(C, Mask, accum, mult, A, B, desc)
    ccall((:GrB_Matrix_eWiseMult_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, mult, A, B, desc)
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

function GrB_Matrix_eWiseAdd_Semiring(C, Mask, accum, semiring, A, B, desc)
    ccall((:GrB_Matrix_eWiseAdd_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

function GrB_Matrix_eWiseAdd_Monoid(C, Mask, accum, monoid, A, B, desc)
    ccall((:GrB_Matrix_eWiseAdd_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, monoid, A, B, desc)
end

function GrB_Matrix_eWiseAdd_BinaryOp(C, Mask, accum, add, A, B, desc)
    ccall((:GrB_Matrix_eWiseAdd_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, add, A, B, desc)
end

function GrB_Vector_extract(w, mask, accum, u, I, ni, desc)
    ccall((:GrB_Vector_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

function GrB_Matrix_extract(C, Mask, accum, A, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_extract, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

function GrB_Col_extract(w, mask, accum, A, I, ni, j, desc)
    ccall((:GrB_Col_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), w, mask, accum, A, I, ni, j, desc)
end

function GxB_Vector_subassign(w, mask, accum, u, I, ni, desc)
    ccall((:GxB_Vector_subassign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

function GxB_Matrix_subassign(C, Mask, accum, A, I, ni, J, nj, desc)
    ccall((:GxB_Matrix_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

function GxB_Col_subassign(C, mask, accum, u, I, ni, j, desc)
    ccall((:GxB_Col_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I, ni, j, desc)
end

function GxB_Row_subassign(C, mask, accum, u, i, J, nj, desc)
    ccall((:GxB_Row_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, mask, accum, u, i, J, nj, desc)
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

function GrB_Vector_assign(w, mask, accum, u, I, ni, desc)
    ccall((:GrB_Vector_assign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

function GrB_Matrix_assign(C, Mask, accum, A, I, ni, J, nj, desc)
    ccall((:GrB_Matrix_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

function GrB_Col_assign(C, mask, accum, u, I, ni, j, desc)
    ccall((:GrB_Col_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I, ni, j, desc)
end

function GrB_Row_assign(C, mask, accum, u, i, J, nj, desc)
    ccall((:GrB_Row_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, mask, accum, u, i, J, nj, desc)
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

function GrB_Vector_apply(w, mask, accum, op, u, desc)
    ccall((:GrB_Vector_apply, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_UnaryOp, GrB_Vector, GrB_Descriptor), w, mask, accum, op, u, desc)
end

function GrB_Matrix_apply(C, Mask, accum, op, A, desc)
    ccall((:GrB_Matrix_apply, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_UnaryOp, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, A, desc)
end

function GxB_Vector_apply_BinaryOp1st(w, mask, accum, op, x, u, desc)
    ccall((:GxB_Vector_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_Scalar, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
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

function GxB_Vector_apply_BinaryOp2nd(w, mask, accum, op, u, y, desc)
    ccall((:GxB_Vector_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
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

function GxB_Matrix_apply_BinaryOp1st(C, Mask, accum, op, x, A, desc)
    ccall((:GxB_Matrix_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_Scalar, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
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

function GxB_Matrix_apply_BinaryOp2nd(C, Mask, accum, op, A, y, desc)
    ccall((:GxB_Matrix_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
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

function GxB_Vector_select(w, mask, accum, op, u, Thunk, desc)
    ccall((:GxB_Vector_select, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_SelectOp, GrB_Vector, GxB_Scalar, GrB_Descriptor), w, mask, accum, op, u, Thunk, desc)
end

function GxB_Matrix_select(C, Mask, accum, op, A, Thunk, desc)
    ccall((:GxB_Matrix_select, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_SelectOp, GrB_Matrix, GxB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, Thunk, desc)
end

function GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)
    ccall((:GrB_Matrix_reduce_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), w, mask, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_BinaryOp(w, mask, accum, op, A, desc)
    ccall((:GrB_Matrix_reduce_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), w, mask, accum, op, A, desc)
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

function GrB_transpose(C, Mask, accum, A, desc)
    ccall((:GrB_transpose, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), C, Mask, accum, A, desc)
end

function GxB_kron(C, Mask, accum, op, A, B, desc)
    ccall((:GxB_kron, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, A, B, desc)
end

function GrB_Matrix_kronecker_BinaryOp(C, M, accum, op, A, B, desc)
    ccall((:GrB_Matrix_kronecker_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, op, A, B, desc)
end

function GrB_Matrix_kronecker_Monoid(C, M, accum, monoid, A, B, desc)
    ccall((:GrB_Matrix_kronecker_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, monoid, A, B, desc)
end

function GrB_Matrix_kronecker_Semiring(C, M, accum, semiring, A, B, desc)
    ccall((:GrB_Matrix_kronecker_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, semiring, A, B, desc)
end

function GrB_Matrix_resize(C, nrows_new, ncols_new)
    ccall((:GrB_Matrix_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, nrows_new, ncols_new)
end

function GrB_Vector_resize(w, nrows_new)
    ccall((:GrB_Vector_resize, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), w, nrows_new)
end

function GxB_Matrix_resize(C, nrows_new, ncols_new)
    ccall((:GxB_Matrix_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, nrows_new, ncols_new)
end

function GxB_Vector_resize(w, nrows_new)
    ccall((:GxB_Vector_resize, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), w, nrows_new)
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

function GxB_SelectOp_fprint(selectop, name, pr, f)
    ccall((:GxB_SelectOp_fprint, libgraphblas), GrB_Info, (GxB_SelectOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), selectop, name, pr, f)
end

function GxB_Monoid_fprint(monoid, name, pr, f)
    ccall((:GxB_Monoid_fprint, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), monoid, name, pr, f)
end

function GxB_Semiring_fprint(semiring, name, pr, f)
    ccall((:GxB_Semiring_fprint, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), semiring, name, pr, f)
end

function GxB_Descriptor_fprint(descriptor, name, pr, f)
    ccall((:GxB_Descriptor_fprint, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), descriptor, name, pr, f)
end

function GxB_Matrix_fprint(A, name, pr, f)
    ccall((:GxB_Matrix_fprint, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), A, name, pr, f)
end

function GxB_Vector_fprint(v, name, pr, f)
    ccall((:GxB_Vector_fprint, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), v, name, pr, f)
end

function GxB_Scalar_fprint(s, name, pr, f)
    ccall((:GxB_Scalar_fprint, libgraphblas), GrB_Info, (GxB_Scalar, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), s, name, pr, f)
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

# Skipping MacroDefinition: GB_PUBLIC extern

const GxB_STDC_VERSION = __STDC_VERSION__

const GxB_IMPLEMENTATION_NAME = "SuiteSparse:GraphBLAS"

const GxB_IMPLEMENTATION_DATE = "Aug 23, 2021"

const GxB_IMPLEMENTATION_MAJOR = 5

const GxB_IMPLEMENTATION_MINOR = 1

const GxB_IMPLEMENTATION_SUB = 7

const GxB_SPEC_DATE = "Sept 25, 2019"

const GxB_SPEC_MAJOR = 1

const GxB_SPEC_MINOR = 3

const GxB_SPEC_SUB = 0

const GxB_IMPLEMENTATION = GxB_VERSION(GxB_IMPLEMENTATION_MAJOR, GxB_IMPLEMENTATION_MINOR, GxB_IMPLEMENTATION_SUB)

# Skipping MacroDefinition: GxB_IMPLEMENTATION_ABOUT \
#"SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2021, All Rights Reserved." \
#"\nhttp://suitesparse.com  Dept of Computer Sci. & Eng, Texas A&M University.\n"

# Skipping MacroDefinition: GxB_IMPLEMENTATION_LICENSE \
#"SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2021, All Rights Reserved." \
#"\nLicensed under the Apache License, Version 2.0 (the \"License\"); you may\n" \
#"not use SuiteSparse:GraphBLAS except in compliance with the License.  You\n" \
#"may obtain a copy of the License at\n\n" \
#"    http://www.apache.org/licenses/LICENSE-2.0\n\n" \
#"Unless required by applicable law or agreed to in writing, software\n" \
#"distributed under the License is distributed on an \"AS IS\" BASIS,\n" \
#"WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n" \
#"See the License for the specific language governing permissions and\n" \
#"limitations under the License.\n"

const GxB_SPEC_VERSION = GxB_VERSION(GxB_SPEC_MAJOR, GxB_SPEC_MINOR, GxB_SPEC_SUB)

# Skipping MacroDefinition: GxB_SPEC_ABOUT \
#"GraphBLAS C API, by Aydin Buluc, Timothy Mattson, Scott McMillan,\n" \
#"Jose' Moreira, Carl Yang, and Benjamin Brock.  Based on 'GraphBLAS\n" \
#"Mathematics by Jeremy Kepner.  See also 'Graph Algorithms in the Language\n" \
#"of Linear Algebra,' edited by J. Kepner and J. Gilbert, SIAM, 2011.\n"

const GxB_INDEX_MAX = GrB_Index(Culonglong(1) << 60)

const GRB_VERSION = GxB_SPEC_MAJOR

const GRB_SUBVERSION = GxB_SPEC_MINOR

const GxB_NTHREADS = 5

const GxB_CHUNK = 7

const GxB_GPU_CONTROL = 21

const GxB_GPU_CHUNK = 22

const GxB_HYPER = 0

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

end # module
