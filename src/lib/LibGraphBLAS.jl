module libgb
using Base: Float64
import ..libgraphblas
using ..SuiteSparseGraphBLAS: suffix, towrappertype
using MacroTools
using CEnum
const GxB_FC32_t = ComplexF32

const GxB_FC64_t = ComplexF32

const GrB_Index = UInt64

struct UninitializedObjectError <: Exception end
struct InvalidObjectError <: Exception end
struct NullPointerError <: Exception end
struct InvalidValueError <: Exception end
struct InvalidIndexError <: Exception end
struct OutputNotEmptyError <: Exception end
struct InsufficientSpaceError <: Exception end
struct PANIC <: Exception end

macro wraperror(code)
    MacroTools.@q begin
        info = $(esc(code))
        if info == GrB_SUCCESS
            return true
        elseif info == GrB_NO_VALUE
            return nothing
        else
            if info == GrB_UNINITIALIZED_OBJECT
                throw(UninitializedObjectError)
            elseif info == GrB_INVALID_OBJECT
                throw(InvalidObjectError)
            elseif info == GrB_NULL_POINTER
                throw(NullPointerError)
            elseif info == GrB_INVALID_VALUE
                throw(InvalidValueError)
            elseif info == GrB_INVALID_INDEX
                throw(InvalidIndexError)
            elseif info == GrB_DOMAIN_MISMATCH
                throw(DomainError(nothing, "GraphBLAS Domain Mismatch"))
            elseif info == GrB_DIMENSION_MISMATCH
                throw(DimensionMismatch())
            elseif info == GrB_OUTPUT_NOT_EMPTY
                throw(OutputNotEmptyError)
            elseif info == GrB_OUT_OF_MEMORY
                throw(OutOfMemoryError())
            elseif info == GrB_INSUFFICIENT_SPACE
                throw(InsufficientSpaceError)
            elseif info == GrB_INDEX_OUT_OF_BOUNDS
                throw(BoundsError())
            elseif info == GrB_PANIC
                throw(PANIC)
            else
                throw(ErrorException("I don't know how I got here."))
            end
        end
    end
end
function tozerobased(I)
    I isa Vector && (return I .- 1)
    I isa Integer && (return I - 1)
    return I
end
function toonebased(I)
    I isa Vector && (return I .+ 1)
    I isa Integer && (return I + 1)
    return I
end
const valid_vec = [Bool, Int8, UInt8, Int16, UInt16, Int32, UInt32,
Int64, UInt64, Float32, Float64, ComplexF32, ComplexF64]

@cenum GrB_Info::UInt32 begin
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

@cenum GrB_Mode::UInt32 begin
    GrB_NONBLOCKING = 0
    GrB_BLOCKING = 1
end

function GrB_init(mode)
    @wraperror ccall((:GrB_init, libgraphblas), GrB_Info, (GrB_Mode,), mode)
end

function GxB_init(mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function, user_malloc_is_thread_safe)
    @wraperror ccall((:GxB_init, libgraphblas), GrB_Info, (GrB_Mode, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Bool), mode, user_malloc_function, user_calloc_function, user_realloc_function, user_free_function, user_malloc_is_thread_safe)
end

function GxB_cuda_init(mode)
    @wraperror ccall((:GxB_cuda_init, libgraphblas), GrB_Info, (GrB_Mode,), mode)
end

function GrB_finalize()
    @wraperror ccall((:GrB_finalize, libgraphblas), GrB_Info, ())
end

function GrB_getVersion(version=Ref{Cuint}(0), subversion=Ref{Cuint}(0))
    @wraperror ccall((:GrB_getVersion, libgraphblas), GrB_Info, (Ptr{Cuint}, Ptr{Cuint}), version, subversion)
    return version[], subversion[]
end

@cenum GrB_Desc_Field::UInt32 begin
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

@cenum GrB_Desc_Value::UInt32 begin
    GxB_DEFAULT = 0
    GrB_REPLACE = 1
    GrB_COMP = 2
    # GrB_SCMP = 2
    GrB_STRUCTURE = 4
    GrB_STRUCT_COMP = 6
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
    @wraperror ccall((:GrB_Descriptor_new, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), descriptor)
end

function GrB_Descriptor_new()
    desc = Ref{GrB_Descriptor}()
    GrB_Descriptor_new(desc)
    return desc[]
end

function GrB_Descriptor_set(desc, field, val)
    @wraperror ccall((:GrB_Descriptor_set, libgraphblas), GrB_Info, (GrB_Descriptor, GrB_Desc_Field, GrB_Desc_Value), desc, field, val)
end

function GxB_Descriptor_get(val, desc, field)
    @wraperror ccall((:GxB_Descriptor_get, libgraphblas), GrB_Info, (Ptr{GrB_Desc_Value}, GrB_Descriptor, GrB_Desc_Field), val, desc, field)
end
function GxB_Descriptor_get(desc, field)
    v = Ref{GrB_Desc_Value}()
    GxB_Descriptor_get(v, desc, field)
    return v[]
end

function GrB_Descriptor_free(descriptor)
    @wraperror ccall((:GrB_Descriptor_free, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), descriptor)
end

mutable struct GB_Type_opaque end

const GrB_Type = Ptr{GB_Type_opaque}

function GB_Type_new(type, sizeof_ctype, name)
    @wraperror ccall((:GB_Type_new, libgraphblas), GrB_Info, (Ptr{GrB_Type}, Csize_t, Ptr{Cchar}), type, sizeof_ctype, name)
end

function GxB_Type_size(size, type)
    @wraperror ccall((:GxB_Type_size, libgraphblas), GrB_Info, (Ptr{Csize_t}, GrB_Type), size, type)
end

function GrB_Type_free(type)
    @wraperror ccall((:GrB_Type_free, libgraphblas), GrB_Info, (Ptr{GrB_Type},), type)
end

mutable struct GB_UnaryOp_opaque end

const GrB_UnaryOp = Ptr{GB_UnaryOp_opaque}

# typedef void ( * GxB_unary_function ) ( void * , const void * )
const GxB_unary_function = Ptr{Cvoid}

function GB_UnaryOp_new(unaryop, _function, ztype, xtype, name)
    @wraperror ccall((:GB_UnaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp}, GxB_unary_function, GrB_Type, GrB_Type, Ptr{Cchar}), unaryop, _function, ztype, xtype, name)
end

function GxB_UnaryOp_ztype(ztype, unaryop)
    @wraperror ccall((:GxB_UnaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), ztype, unaryop)
end
function GxB_UnaryOp_ztype(unaryop)
    z = Ref{GrB_Type}()
    GxB_UnaryOp_ztype(z, unaryop)
    return z[]
end

function GxB_UnaryOp_xtype(xtype, unaryop)
    @wraperror ccall((:GxB_UnaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_UnaryOp), xtype, unaryop)
end
function GxB_UnaryOp_xtype(unaryop)
    x = Ref{GrB_Type}()
    GxB_UnaryOp_ztype(x, unaryop)
    return x[]
end


function GrB_UnaryOp_free(unaryop)
    @wraperror ccall((:GrB_UnaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp},), unaryop)
end

mutable struct GB_BinaryOp_opaque end

const GrB_BinaryOp = Ptr{GB_BinaryOp_opaque}

# typedef void ( * GxB_binary_function ) ( void * , const void * , const void * )
const GxB_binary_function = Ptr{Cvoid}

function GB_BinaryOp_new(binaryop, _function, ztype, xtype, ytype, name)
    @wraperror ccall((:GB_BinaryOp_new, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GxB_binary_function, GrB_Type, GrB_Type, GrB_Type, Ptr{Cchar}), binaryop, _function, ztype, xtype, ytype, name)
end

function GxB_BinaryOp_ztype(ztype, binaryop)
    @wraperror ccall((:GxB_BinaryOp_ztype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), ztype, binaryop)
end
function GxB_BinaryOp_ztype(binaryop)
    z = Ref{GrB_Type}()
    GxB_BinaryOp_ztype(z, binaryop)
    return z[]
end

function GxB_BinaryOp_xtype(xtype, binaryop)
    @wraperror ccall((:GxB_BinaryOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), xtype, binaryop)
end
function GxB_BinaryOp_xtype(binaryop)
    x = Ref{GrB_Type}()
    GxB_BinaryOp_xtype(x, binaryop)
    return x[]
end

function GxB_BinaryOp_ytype(ytype, binaryop)
    @wraperror ccall((:GxB_BinaryOp_ytype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_BinaryOp), ytype, binaryop)
end
function GxB_BinaryOp_ytype(binaryop)
    y= Ref{GrB_Type}()
    GxB_BinaryOp_ztype(y, binaryop)
    return y[]
end

function GrB_BinaryOp_free(binaryop)
    @wraperror ccall((:GrB_BinaryOp_free, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp},), binaryop)
end

mutable struct GB_SelectOp_opaque end

const GxB_SelectOp = Ptr{GB_SelectOp_opaque}

# typedef bool ( * GxB_select_function ) // return true if A(i,j) is kept ( GrB_Index i , // row index of A(i,j) GrB_Index j , // column index of A(i,j) const void * x , // value of A(i,j) const void * thunk // optional input for select function )
const GxB_select_function = Ptr{Cvoid}

function GB_SelectOp_new(selectop, _function, xtype, ttype, name)
    @wraperror ccall((:GB_SelectOp_new, libgraphblas), GrB_Info, (Ptr{GxB_SelectOp}, GxB_select_function, GrB_Type, GrB_Type, Ptr{Cchar}), selectop, _function, xtype, ttype, name)
end

function GxB_SelectOp_xtype(xtype, selectop)
    @wraperror ccall((:GxB_SelectOp_xtype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), xtype, selectop)
end

function GxB_SelectOp_ttype(ttype, selectop)
    @wraperror ccall((:GxB_SelectOp_ttype, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_SelectOp), ttype, selectop)
end

function GxB_SelectOp_free(selectop)
    @wraperror ccall((:GxB_SelectOp_free, libgraphblas), GrB_Info, (Ptr{GxB_SelectOp},), selectop)
end

mutable struct GB_Monoid_opaque end

const GrB_Monoid = Ptr{GB_Monoid_opaque}
const monoididnew = Dict{DataType, Function}()

function GrB_Monoid_new_BOOL(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool), monoid, op, identity)
end
monoididnew[Bool] = GrB_Monoid_new_BOOL
function GrB_Monoid_new_INT8(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8), monoid, op, identity)
end
monoididnew[Int8] = GrB_Monoid_new_INT8
function GrB_Monoid_new_UINT8(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8), monoid, op, identity)
end
monoididnew[UInt8] = GrB_Monoid_new_UINT8
function GrB_Monoid_new_INT16(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16), monoid, op, identity)
end
monoididnew[Int16] = GrB_Monoid_new_INT16
function GrB_Monoid_new_UINT16(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16), monoid, op, identity)
end
monoididnew[UInt16] = GrB_Monoid_new_UINT16
function GrB_Monoid_new_INT32(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32), monoid, op, identity)
end
monoididnew[Int32] = GrB_Monoid_new_INT32
function GrB_Monoid_new_UINT32(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32), monoid, op, identity)
end
monoididnew[UInt32] = GrB_Monoid_new_UINT32
function GrB_Monoid_new_INT64(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64), monoid, op, identity)
end
monoididnew[Int64] = GrB_Monoid_new_INT64
function GrB_Monoid_new_UINT64(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64), monoid, op, identity)
end
monoididnew[UInt64] = GrB_Monoid_new_UINT64
function GrB_Monoid_new_FP32(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat), monoid, op, identity)
end
monoididnew[Float32] = GrB_Monoid_new_FP32
function GrB_Monoid_new_FP64(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble), monoid, op, identity)
end
monoididnew[Float64] = GrB_Monoid_new_FP64
function GxB_Monoid_new_FC32(monoid, op, identity)
    @wraperror ccall((:GxB_Monoid_new_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t), monoid, op, identity)
end
monoididnew[ComplexF32] = GxB_Monoid_new_FC32
function GxB_Monoid_new_FC64(monoid, op, identity)
    @wraperror ccall((:GxB_Monoid_new_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t), monoid, op, identity)
end
monoididnew[ComplexF64] = GxB_Monoid_new_FC64
function GrB_Monoid_new_UDT(monoid, op, identity)
    @wraperror ccall((:GrB_Monoid_new_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}), monoid, op, identity)
end
monoididnew[Any] = GrB_Monoid_new_UDT

const monoidtermnew = Dict{DataType, Function}()
function GxB_Monoid_terminal_new_BOOL(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_BOOL, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Bool, Bool), monoid, op, identity, terminal)
end
monoidtermnew[Bool] = GxB_Monoid_terminal_new_BOOL
function GxB_Monoid_terminal_new_INT8(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_INT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int8, Int8), monoid, op, identity, terminal)
end
monoidtermnew[Int8] = GxB_Monoid_terminal_new_INT8
function GxB_Monoid_terminal_new_UINT8(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_UINT8, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt8, UInt8), monoid, op, identity, terminal)
end
monoidtermnew[UInt8] = GxB_Monoid_terminal_new_UINT8
function GxB_Monoid_terminal_new_INT16(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_INT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int16, Int16), monoid, op, identity, terminal)
end
monoidtermnew[Int16] = GxB_Monoid_terminal_new_INT16
function GxB_Monoid_terminal_new_UINT16(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_UINT16, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt16, UInt16), monoid, op, identity, terminal)
end
monoidtermnew[UInt16] = GxB_Monoid_terminal_new_UINT16
function GxB_Monoid_terminal_new_INT32(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_INT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int32, Int32), monoid, op, identity, terminal)
end
monoidtermnew[Int32] = GxB_Monoid_terminal_new_INT32
function GxB_Monoid_terminal_new_UINT32(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_UINT32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt32, UInt32), monoid, op, identity, terminal)
end
monoidtermnew[UInt32] = GxB_Monoid_terminal_new_UINT32
function GxB_Monoid_terminal_new_INT64(monoid, op, identity, terminal)
    println(monoid)
    println(op)
    println(terminal)
    println(identity)
    @wraperror ccall((:GxB_Monoid_terminal_new_INT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Int64, Int64), monoid, op, identity, terminal)
end
monoidtermnew[Int64] = GxB_Monoid_terminal_new_INT64
function GxB_Monoid_terminal_new_UINT64(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_UINT64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, UInt64, UInt64), monoid, op, identity, terminal)
end
monoidtermnew[UInt64] = GxB_Monoid_terminal_new_UINT64
function GxB_Monoid_terminal_new_FP32(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_FP32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cfloat, Cfloat), monoid, op, identity, terminal)
end
monoidtermnew[Float32] = GxB_Monoid_terminal_new_FP32
function GxB_Monoid_terminal_new_FP64(monoid, op, identity, terminal)
@wraperror ccall((:GxB_Monoid_terminal_new_FP64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Cdouble, Cdouble), monoid, op, identity, terminal)
end
monoidtermnew[Float64] = GxB_Monoid_terminal_new_FP64
function GxB_Monoid_terminal_new_FC32(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_FC32, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC32_t, GxB_FC32_t), monoid, op, identity, terminal)
end
monoidtermnew[ComplexF32] = GxB_Monoid_terminal_new_FC32
function GxB_Monoid_terminal_new_FC64(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_FC64, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, GxB_FC64_t, GxB_FC64_t), monoid, op, identity, terminal)
end
monoidtermnew[ComplexF64] = GxB_Monoid_terminal_new_FC64
function GxB_Monoid_terminal_new_UDT(monoid, op, identity, terminal)
    @wraperror ccall((:GxB_Monoid_terminal_new_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_BinaryOp, Ptr{Cvoid}, Ptr{Cvoid}), monoid, op, identity, terminal)
end
monoidtermnew[Any] = GxB_Monoid_terminal_new_UDT

function GxB_Monoid_operator(op, monoid)
    @wraperror ccall((:GxB_Monoid_operator, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GrB_Monoid), op, monoid)
end
function GxB_Monoid_operator(monoid)
    op = Ref{GrB_BinaryOp}()
    GxB_Monoid_operator(op, monoid)
    return op[]
end
function GxB_Monoid_identity(identity, monoid)
    @wraperror ccall((:GxB_Monoid_identity, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Monoid), identity, monoid)
end

function GxB_Monoid_terminal(T, monoid)

    has_terminal = Ref{Bool}()
    terminal = Ref{T}()
    ccall((:GxB_Monoid_terminal, libgraphblas), GrB_Info, (Ptr{Bool}, Ptr{Cvoid}, GrB_Monoid), has_terminal, terminal, monoid)
    has_terminal = has_terminal[]
    println(has_terminal)
    if has_terminal
        return terminal[]
    else
        return nothing
    end
end

function GrB_Monoid_free(monoid)
    @wraperror ccall((:GrB_Monoid_free, libgraphblas), GrB_Info, (Ptr{GrB_Monoid},), monoid)
end

mutable struct GB_Semiring_opaque end

const GrB_Semiring = Ptr{GB_Semiring_opaque}

function GrB_Semiring_new(semiring, add, multiply)
    @wraperror ccall((:GrB_Semiring_new, libgraphblas), GrB_Info, (Ptr{GrB_Semiring}, GrB_Monoid, GrB_BinaryOp), semiring, add, multiply)
end

function GxB_Semiring_add(add, semiring)
    @wraperror ccall((:GxB_Semiring_add, libgraphblas), GrB_Info, (Ptr{GrB_Monoid}, GrB_Semiring), add, semiring)
end
function GxB_Semiring_add(semiring)
    m = Ref{GrB_Monoid}()
    GxB_Semiring_add(m, semiring)
    return m[]
end

function GxB_Semiring_multiply(multiply, semiring)
    @wraperror ccall((:GxB_Semiring_multiply, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp}, GrB_Semiring), multiply, semiring)
end
function GxB_Semiring_multiply(semiring)
    m = Ref{GrB_BinaryOp}()
    GxB_Semiring_multiply(m, semiring)
    return m[]
end

function GrB_Semiring_free(semiring)
    @wraperror ccall((:GrB_Semiring_free, libgraphblas), GrB_Info, (Ptr{GrB_Semiring},), semiring)
end

mutable struct GB_Scalar_opaque end

const GxB_Scalar = Ptr{GB_Scalar_opaque}

function GxB_Scalar_new(s, type)
    @wraperror ccall((:GxB_Scalar_new, libgraphblas), GrB_Info, (Ptr{GxB_Scalar}, GrB_Type), s, type)
end

function GxB_Scalar_new(type)
    s = Ref{GxB_Scalar}()
    GxB_Scalar_new(s, type)
    return s[]
end
function GxB_Scalar_dup(s, t)
    @wraperror ccall((:GxB_Scalar_dup, libgraphblas), GrB_Info, (Ptr{GxB_Scalar}, GxB_Scalar), s, t)
end

function GxB_Scalar_dup(t)
    s = Ref{GxB_Scalar}()
    GxB_Scalar_dup(s, t)
    return s[]
end

    function GxB_Scalar_clear(s)
    @wraperror ccall((:GxB_Scalar_clear, libgraphblas), GrB_Info, (GxB_Scalar,), s)
    return nothing
end

function GxB_Scalar_nvals(nvals, s)
    @wraperror ccall((:GxB_Scalar_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GxB_Scalar), nvals, s)
end

function GxB_Scalar_nvals(s)
    nvals = Ref{GrB_Index}()
    GxB_Scalar_nvals(nvals, s)
    return nvals[]
end

function GxB_Scalar_type(type, s)
@wraperror ccall((:GxB_Scalar_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GxB_Scalar), type, s)
end

function GxB_Scalar_type(s)
    type = Ref{GrB_Type}()
    GxB_Scalar_type(type, s)
    return type[]
end

function GxB_Scalar_free(s)
    @wraperror ccall((:GxB_Scalar_free, libgraphblas), GrB_Info, (Ptr{GxB_Scalar},), s)
end

function GxB_Scalar_setElement_BOOL(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_BOOL, libgraphblas), GrB_Info, (GxB_Scalar, Bool), s, x)
end

function GxB_Scalar_setElement_INT8(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_INT8, libgraphblas), GrB_Info, (GxB_Scalar, Int8), s, x)
end

function GxB_Scalar_setElement_UINT8(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_UINT8, libgraphblas), GrB_Info, (GxB_Scalar, UInt8), s, x)
end

function GxB_Scalar_setElement_INT16(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_INT16, libgraphblas), GrB_Info, (GxB_Scalar, Int16), s, x)
end

function GxB_Scalar_setElement_UINT16(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_UINT16, libgraphblas), GrB_Info, (GxB_Scalar, UInt16), s, x)
end

function GxB_Scalar_setElement_INT32(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_INT32, libgraphblas), GrB_Info, (GxB_Scalar, Int32), s, x)
end

function GxB_Scalar_setElement_UINT32(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_UINT32, libgraphblas), GrB_Info, (GxB_Scalar, UInt32), s, x)
end

function GxB_Scalar_setElement_INT64(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_INT64, libgraphblas), GrB_Info, (GxB_Scalar, Int64), s, x)
end

function GxB_Scalar_setElement_UINT64(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_UINT64, libgraphblas), GrB_Info, (GxB_Scalar, UInt64), s, x)
end

function GxB_Scalar_setElement_FP32(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_FP32, libgraphblas), GrB_Info, (GxB_Scalar, Cfloat), s, x)
end

function GxB_Scalar_setElement_FP64(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_FP64, libgraphblas), GrB_Info, (GxB_Scalar, Cdouble), s, x)
end

function GxB_Scalar_setElement_FC32(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_FC32, libgraphblas), GrB_Info, (GxB_Scalar, GxB_FC32_t), s, x)
end

function GxB_Scalar_setElement_FC64(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_FC64, libgraphblas), GrB_Info, (GxB_Scalar, GxB_FC64_t), s, x)
end

function GxB_Scalar_setElement_UDT(s, x)
    @wraperror ccall((:GxB_Scalar_setElement_UDT, libgraphblas), GrB_Info, (GxB_Scalar, Ptr{Cvoid}), s, x)
end

function GxB_Scalar_extractElement_BOOL(x, s)
    ccall((:GxB_Scalar_extractElement_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_BOOL(s)
    x = Ref{Bool}()
    GxB_Scalar_extractElement_BOOL(x, s)
    return x[]
end

function GxB_Scalar_extractElement_INT8(x, s)
    ccall((:GxB_Scalar_extractElement_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_INT8(s)
    x = Ref{Int8}()
    GxB_Scalar_extractElement_INT8(x, s)
    return x[]
end

function GxB_Scalar_extractElement_UINT8(x, s)
    ccall((:GxB_Scalar_extractElement_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_UINT8(s)
    x = Ref{UInt8}()
    GxB_Scalar_extractElement_UINT8(x, s)
    return x[]
end

function GxB_Scalar_extractElement_INT16(x, s)
    ccall((:GxB_Scalar_extractElement_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_INT16(s)
    x = Ref{Int16}()
    GxB_Scalar_extractElement_INT16(x, s)
    return x[]
end

function GxB_Scalar_extractElement_UINT16(x, s)
    ccall((:GxB_Scalar_extractElement_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_UINT16(s)
    x = Ref{UInt16}()
    GxB_Scalar_extractElement_UINT16(x, s)
    return x[]
end

function GxB_Scalar_extractElement_INT32(x, s)
    ccall((:GxB_Scalar_extractElement_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_INT32(s)
    x = Ref{Int32}()
    GxB_Scalar_extractElement_INT32(x, s)
    return x[]
end

function GxB_Scalar_extractElement_UINT32(x, s)
    ccall((:GxB_Scalar_extractElement_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_UINT32(s)
    x = Ref{UInt32}()
    GxB_Scalar_extractElement_UINT32(x, s)
    return x[]
end

function GxB_Scalar_extractElement_INT64(x, s)
    ccall((:GxB_Scalar_extractElement_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_INT64(s)
    x = Ref{Int64}()
    GxB_Scalar_extractElement_INT64(x, s)
    return x[]
end

function GxB_Scalar_extractElement_UINT64(x, s)
    ccall((:GxB_Scalar_extractElement_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_UINT64(s)
    x = Ref{UInt64}()
    GxB_Scalar_extractElement_UINT64(x, s)
    return x[]
end

function GxB_Scalar_extractElement_FP32(x, s)
    ccall((:GxB_Scalar_extractElement_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_FP32(s)
    x = Ref{Float32}()
    GxB_Scalar_extractElement_FP32(x, s)
    return x[]
end

function GxB_Scalar_extractElement_FP64(x, s)
    ccall((:GxB_Scalar_extractElement_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_FP64(s)
    x = Ref{Float64}()
    GxB_Scalar_extractElement_FP64(x, s)
    return x[]
end

function GxB_Scalar_extractElement_FC32(x, s)
    ccall((:GxB_Scalar_extractElement_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_FC32(s)
    x = Ref{ComplexF32}()
    GxB_Scalar_extractElement_FC32(x, s)
    return x[]
end

function GxB_Scalar_extractElement_FC64(x, s)
    ccall((:GxB_Scalar_extractElement_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GxB_Scalar), x, s)
end
function GxB_Scalar_extractElement_FC64(s)
    x = Ref{ComplexF64}()
    GxB_Scalar_extractElement_FC64(x, s)
    return x[]
end

function GxB_Scalar_extractElement_UDT(x, s)
ccall((:GxB_Scalar_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GxB_Scalar), x, s)
end

mutable struct GB_Vector_opaque end

const GrB_Vector = Ptr{GB_Vector_opaque}

function GrB_Vector_new(v, type, n)
    @wraperror ccall((:GrB_Vector_new, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index), v, type, n)
end
function GrB_Vector_new(type, n)
    v = Ref{GrB_Vector}()
    GrB_Vector_new(v, type, n)
    return v[]
end

function GrB_Vector_dup(w, u)
    @wraperror ccall((:GrB_Vector_dup, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Vector), w, u)
end
function GrB_Vector_dup(u)
    w = Ref{GrB_Vector}()
    GrB_Vector_new(w, GxB_Vector_type(u), GrB_Vector_size(u))
    GrB_Vector_dup(w, u)
    return w[]
end

function GrB_Vector_clear(v)
    @wraperror ccall((:GrB_Vector_clear, libgraphblas), GrB_Info, (GrB_Vector,), v)
    return nothing
end

function GrB_Vector_size(n, v)
    @wraperror ccall((:GrB_Vector_size, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Vector), n, v)
end
function GrB_Vector_size(v)
    n = Ref{GrB_Index}()
    GrB_Vector_size(n, v)
    return n[]
end

function GrB_Vector_nvals(nvals, v)
    @wraperror ccall((:GrB_Vector_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Vector), nvals, v)
end
function GrB_Vector_nvals(v)
    nvals = Ref{GrB_Index}()
    GrB_Vector_nvals(nvals, v)
    return nvals[]
end

function GxB_Vector_type(type, v)
    @wraperror ccall((:GxB_Vector_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Vector), type, v)
end
function GxB_Vector_type(v)
    type = Ref{GrB_Type}()
    GxB_Vector_type(type, v)
    return type[]
end

function GrB_Vector_free(v)
    @wraperror ccall((:GrB_Vector_free, libgraphblas), GrB_Info, (Ptr{GrB_Vector},), v)
end

function GrB_Vector_build_UDT(w, I, X, nvals, dup)
    @wraperror ccall((:GrB_Vector_build_UDT, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
end

function GxB_Vector_build_Scalar(w, I, scalar, nvals)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_build_Scalar, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, GxB_Scalar, GrB_Index), w, I, scalar, nvals)
end

function GrB_Vector_setElement_UDT(w, x, i)
    @wraperror ccall((:GrB_Vector_setElement_UDT, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cvoid}, GrB_Index), w, x, i)
end

function GrB_Vector_extractElement_UDT(x, v, i)
    ccall((:GrB_Vector_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Vector, GrB_Index), x, v, i)
end

function GrB_Vector_removeElement(v, i)
    i = tozerobased(i)
    @wraperror ccall((:GrB_Vector_removeElement, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), v, i)
end

#Generate functions for Vector_extractElement and Vector_extractTuples.
#Both have multiple forms, the second creates its own output( vectors) and returns them.
for T ∈ valid_vec
    if T ∈ [ComplexF32, ComplexF64]
        prefix = :GxB
    else
        prefix = :GrB
    end
    type = towrappertype(T)

    # GrB_Vector_build_* Functions:
    func = Symbol(prefix, :_Vector_build_, suffix(T))
    funcstr = string(func)
    @eval begin
        function $func(w, I, X, nvals, dup)
            I = tozerobased(I) #Switch to 0-based indexing at ccall barrier
            @wraperror ccall(($funcstr, libgraphblas), GrB_Info, (GrB_Vector, Ptr{GrB_Index}, Ptr{$type}, GrB_Index, GrB_BinaryOp), w, I, X, nvals, dup)
        end
    end

    # GrB_Vector_setElement* Functions:
    func = Symbol(prefix, :_Vector_setElement_, suffix(T))
    funcstr = string(func)
    @eval begin
        function $func(w, x, i)
            i = tozerobased(i) #Switch to 0-based indexing at ccall barrier
            @wraperror ccall(($funcstr, libgraphblas), GrB_Info, (GrB_Vector, $type, GrB_Index), w, x, i)
        end
    end

    # GrB_Vector_extractElement Functions:
    func = Symbol(prefix, :_Vector_extractElement_, suffix(T))
    funcstr = string(func)
    @eval begin
        function $func(x, v, i)
            i = tozerobased(i) #Switch to 0-based indexing at ccall barrier
            ccall(($funcstr, libgraphblas), GrB_Info, (Ptr{$type}, GrB_Vector, GrB_Index), x, v, i)
        end
        function $func(v, i)
            x = Ref{$T}()
            result = $func(x, v, i)
            if result == GrB_SUCCESS
                return x[]
            elseif result == GrB_NO_VALUE
                return zero($T)
            else
                throw(ErrorException("Invalid extractElement return value."))
            end
        end
    end

    # GrB_Vector_extractTuples functions:
    func = Symbol(prefix, :_Vector_extractTuples_, suffix(T))
    funcstr = string(func)
    @eval begin
        function $func(I, X, nvals, v)
            #I, X, and nvals are outputs
            @wraperror ccall(($funcstr, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{$T}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
            #I .+= 1 #Back to 1-based indexing after ccall
        end
        function $func(v)
            nvals = GrB_Vector_nvals(v)
            I = Vector{GrB_Index}(undef, nvals)
            X = Vector{$type}(undef, nvals)
            nvals = Ref{GrB_Index}(nvals)
            $func(I, X, nvals, v)
            nvals[] == length(I) == length(X) || throw(DimensionMismatch())
            return I .+ 1, X
        end
    end
end

function GrB_Vector_extractTuples_UDT(I, X, nvals, v)
    @wraperror ccall((:GrB_Vector_extractTuples_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Vector), I, X, nvals, v)
end

mutable struct GB_Matrix_opaque end

const GrB_Matrix = Ptr{GB_Matrix_opaque}

function GrB_Matrix_new(A, type, nrows, ncols)
    @wraperror ccall((:GrB_Matrix_new, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index), A, type, nrows, ncols)
end
function GrB_Matrix_new(type, nrows, ncols)
    m = Ref{GrB_Matrix}()
    GrB_Matrix_new(m, type, nrows, ncols)
    return m[]
end

function GrB_Matrix_dup(C, A)
    @wraperror ccall((:GrB_Matrix_dup, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Matrix), C, A)
end
function GrB_Matrix_dup(A)
    C = Ref{GrB_Matrix}()
    GrB_Matrix_new(C, GxB_Matrix_type(A), GrB_Matrix_nrows(A), GrB_Matrix_ncols(A))
    GrB_Matrix_dup(C, A)
    return C[]
end

function GrB_Matrix_clear(A)
    @wraperror ccall((:GrB_Matrix_clear, libgraphblas), GrB_Info, (GrB_Matrix,), A)
    return nothing
end

function GrB_Matrix_nrows(nrows, A)
    @wraperror ccall((:GrB_Matrix_nrows, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), nrows, A)
end
function GrB_Matrix_nrows(A)
    nrows = Ref{GrB_Index}()
    GrB_Matrix_nrows(nrows, A)
    return nrows[]
end

function GrB_Matrix_ncols(ncols, A)
    @wraperror ccall((:GrB_Matrix_ncols, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), ncols, A)
end
function GrB_Matrix_ncols(A)
    ncols = Ref{GrB_Index}()
    GrB_Matrix_ncols(ncols, A)
    return ncols[]
end

function GrB_Matrix_nvals(nvals, A)
    @wraperror ccall((:GrB_Matrix_nvals, libgraphblas), GrB_Info, (Ptr{GrB_Index}, GrB_Matrix), nvals, A)
end
function GrB_Matrix_nvals(A)
    nvals = Ref{GrB_Index}()
    GrB_Matrix_nvals(nvals, A)
    return nvals[]
end

function GxB_Matrix_type(type, A)
    @wraperror ccall((:GxB_Matrix_type, libgraphblas), GrB_Info, (Ptr{GrB_Type}, GrB_Matrix), type, A)
end
function GxB_Matrix_type(A)
    type = Ref{GrB_Type}()
    GxB_Matrix_type(type, A)
    return type[]
end

function GrB_Matrix_free(A)
    @wraperror ccall((:GrB_Matrix_free, libgraphblas), GrB_Info, (Ptr{GrB_Matrix},), A)
end

for T ∈ valid_vec
    if T ∈ [ComplexF32, ComplexF64]
        prefix = :GxB
    else
        prefix = :GrB
    end
    type = towrappertype(T)

    # GrB_Matrix_build_* Functions:
    func = Symbol(prefix, :_Matrix_build_, suffix(T))
    funcstr = string(func)
    @eval begin
        function $func(C, I, J, X, nvals, dup)
            I = tozerobased(I) #Switch to 0-based indexing at ccall barrier
            J = tozerobased(J)
            @wraperror ccall(($funcstr, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{$type}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
        end
    end

    # GrB_Matrix_setElement* Functions:
    func = Symbol(prefix, :_Matrix_setElement_, suffix(T))
    funcstr = string(func)
    @eval begin
        function $func(C, x, i, j)
            i = tozerobased(i) #Switch to 0-based indexing at ccall barrier
            j = tozerobased(j)
            @wraperror ccall(($funcstr, libgraphblas), GrB_Info, (GrB_Matrix, $type, GrB_Index, GrB_Index), C, x, i, j)
        end
    end

    # GrB_Matrix_extractElement Functions:
    func = Symbol(prefix, :_Matrix_extractElement_, suffix(T))
    funcstr = string(func)
    @eval begin
        function $func(x, A, i, j)
            i = tozerobased(i) #Switch to 0-based indexing at ccall barrier
            j = tozerobased(j)
            return ccall(($funcstr, libgraphblas), GrB_Info, (Ptr{$type}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
        end
        function $func(A, i, j)
            x = Ref{$T}()
            result = $func(x, A, i, j)
            if result == GrB_SUCCESS
                return x[]
            elseif result == GrB_NO_VALUE
                zero($T)
            else
                throw(ErrorException("Invalid return from Matrix_extractElement"))
            end
        end
    end

    # GrB_Matrix_extractTuples functions:
    func = Symbol(prefix, :_Matrix_extractTuples_, suffix(T))
    funcstr = string(func)
    @eval begin
        function $func(I, J, X, nvals, A)
            #I, X, and nvals are output
            @wraperror ccall(
                ($funcstr, libgraphblas),
                GrB_Info,
                (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{$type}, Ptr{GrB_Index}, GrB_Matrix),
                I, J, X, nvals, A
            )
        end
        function $func(A)
            nvals = GrB_Matrix_nvals(A)
            I = Vector{GrB_Index}(undef, nvals)
            J = Vector{GrB_Index}(undef, nvals)
            X = Vector{$type}(undef, nvals)
            nvals = Ref{GrB_Index}(nvals)
            $func(I, J, X, nvals, A)
            nvals[] == length(I) == length(X) == length(J) || throw(DimensionMismatch())
            return I .+ 1, J .+ 1, X
        end
    end
end

function GrB_Matrix_build_UDT(C, I, J, X, nvals, dup)
    @wraperror ccall((:GrB_Matrix_build_UDT, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, GrB_Index, GrB_BinaryOp), C, I, J, X, nvals, dup)
end

function GxB_Matrix_build_Scalar(C, I, J, scalar, nvals)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_build_Scalar, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Index}, Ptr{GrB_Index}, GxB_Scalar, GrB_Index), C, I, J, scalar, nvals)
end

function GrB_Matrix_setElement_UDT(C, x, i, j)
    @wraperror ccall((:GrB_Matrix_setElement_UDT, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cvoid}, GrB_Index, GrB_Index), C, x, i, j)
end

function GrB_Matrix_extractElement_UDT(x, A, i, j)
    @wraperror ccall((:GrB_Matrix_extractElement_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_Matrix, GrB_Index, GrB_Index), x, A, i, j)
end

function GrB_Matrix_removeElement(C, i, j)
    i = tozerobased(i)
    j = tozerobased(j)
    @wraperror ccall((:GrB_Matrix_removeElement, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, i, j)
end

function GrB_Matrix_extractTuples_UDT(I, J, X, nvals, A)
    @wraperror ccall((:GrB_Matrix_extractTuples_UDT, libgraphblas), GrB_Info, (Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Matrix), I, J, X, nvals, A)
end

function GxB_Matrix_concat(C, Tiles, m, n, desc)
    @wraperror ccall((:GxB_Matrix_concat, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{GrB_Matrix}, GrB_Index, GrB_Index, GrB_Descriptor), C, Tiles, m, n, desc)
end

function GxB_Matrix_split(Tiles, m, n, Tile_nrows, Tile_ncols, A, desc)
@wraperror ccall((:GxB_Matrix_split, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Index, GrB_Index, Ptr{GrB_Index}, Ptr{GrB_Index}, GrB_Matrix, GrB_Descriptor), Tiles, m, n, Tile_nrows, Tile_ncols, A, desc)
end

function GxB_Matrix_diag(C, v, k, desc)
    @wraperror ccall((:GxB_Matrix_diag, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, Int64, GrB_Descriptor), C, v, k, desc)
end
function GxB_Matrix_diag(v, k, desc)
    s = GrB_Vector_size(v)
    C = GrB_Matrix_new(GrB_Vector_type(v), s + abs(k), s + abs(k))
    GxB_Matrix_diag(C, v, k, desc)
    return C
end
function GxB_Vector_diag(v, A, k, desc)
    @wraperror ccall((:GxB_Vector_diag, libgraphblas), GrB_Info, (GrB_Vector, GrB_Matrix, Int64, GrB_Descriptor), v, A, k, desc)
end
function GxB_Vector_diag(A, k, desc)
    m = GrB_Matrix_nrows(A)
    n = GrB_Matrix_ncols(A)
    if 0 <= k <= n - 1
        s = min(m, n - k)
    elseif -m + 1 <= k <= -1
        s = min(m+k, n)
    else
        s = 0
    end
    v = GrB_Vector_new(GxB_Matrix_type(A), s)
    GxB_Vector_diag(v, A, k, desc)
    return v
end
@cenum GxB_Option_Field::UInt32 begin
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

@cenum GxB_Format_Value::Int32 begin
    GxB_BY_ROW = 0
    GxB_BY_COL = 1
    GxB_NO_FORMAT = -1
end

function GrB_Type_wait(type)
    @wraperror ccall((:GrB_Type_wait, libgraphblas), GrB_Info, (Ptr{GrB_Type},), type)
end

function GrB_UnaryOp_wait(op)
    @wraperror ccall((:GrB_UnaryOp_wait, libgraphblas), GrB_Info, (Ptr{GrB_UnaryOp},), op)
end

function GrB_BinaryOp_wait(op)
    @wraperror ccall((:GrB_BinaryOp_wait, libgraphblas), GrB_Info, (Ptr{GrB_BinaryOp},), op)
end

function GxB_SelectOp_wait(op)
    @wraperror ccall((:GxB_SelectOp_wait, libgraphblas), GrB_Info, (Ptr{GxB_SelectOp},), op)
end

function GrB_Monoid_wait(monoid)
    @wraperror ccall((:GrB_Monoid_wait, libgraphblas), GrB_Info, (Ptr{GrB_Monoid},), monoid)
end

function GrB_Semiring_wait(semiring)
    @wraperror ccall((:GrB_Semiring_wait, libgraphblas), GrB_Info, (Ptr{GrB_Semiring},), semiring)
end

function GrB_Descriptor_wait(desc)
    @wraperror ccall((:GrB_Descriptor_wait, libgraphblas), GrB_Info, (Ptr{GrB_Descriptor},), desc)
end

function GxB_Scalar_wait(s)
    @wraperror ccall((:GxB_Scalar_wait, libgraphblas), GrB_Info, (Ptr{GxB_Scalar},), s)
end

function GrB_Vector_wait(v)
    @wraperror ccall((:GrB_Vector_wait, libgraphblas), GrB_Info, (Ptr{GrB_Vector},), v)
end

function GrB_Matrix_wait(A)
    @wraperror ccall((:GrB_Matrix_wait, libgraphblas), GrB_Info, (Ptr{GrB_Matrix},), A)
end

function GrB_Type_error(type)
    p = Ptr{Ptr{Cchar}}()
    @wraperror ccall((:GrB_Type_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Type), p, type)
    return unsafe_string(p[])
end

function GrB_UnaryOp_error(op)
    p = Ptr{Ptr{Cchar}}()
    @wraperror ccall((:GrB_UnaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_UnaryOp), p, op)
    return unsafe_string(p[])
end

function GrB_BinaryOp_error(op)
    p = Ptr{Ptr{Cchar}}()
    @wraperror ccall((:GrB_BinaryOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_BinaryOp), p, op)
    return unsafe_string(p[])
end

function GxB_SelectOp_error(op)
    p = Ptr{Ptr{Cchar}}()
    @wraperror ccall((:GxB_SelectOp_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GxB_SelectOp), p, op)
    return unsafe_string(p[])
end

function GrB_Monoid_error(monoid)
    p = Ptr{Ptr{Cchar}}()
    @wraperror ccall((:GrB_Monoid_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Monoid), p, monoid)
    return unsafe_string(p[])
end

function GrB_Semiring_error(semiring)
    p = Ptr{Ptr{Cchar}}()
    @wraperror ccall((:GrB_Semiring_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Semiring), p, semiring)
    return unsafe_string(p[])
end

function GxB_Scalar_error(s)
    p = Ptr{Ptr{Cchar}}()
    @wraperror ccall((:GxB_Scalar_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GxB_Scalar), p, s)
    return unsafe_string(p[])
end

function GrB_Vector_error(v)
    p = Ptr{Ptr{Cchar}}()
    @wraperror ccall((:GrB_Vector_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Vector), p, v)
    return unsafe_string(p[])
end

function GrB_Matrix_error(A)
    p = Vector{String}()
    println("HI")

    @wraperror ccall((:GrB_Matrix_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Matrix), p, A)
    return unsafe_string(pointer(p))
end

function GrB_Descriptor_error(d)
    p = Ptr{Ptr{Cchar}}()
    @wraperror ccall((:GrB_Descriptor_error, libgraphblas), GrB_Info, (Ptr{Ptr{Cchar}}, GrB_Descriptor), p, d)
    return unsafe_string(p[])
end

#Most functions here have an input only version, creating the output.
# It's more annoying here so those will be in the parent module.
function GrB_mxm(C, Mask, accum, semiring, A, B, desc)
    @wraperror ccall((:GrB_mxm, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

function GrB_vxm(w, mask, accum, semiring, u, A, desc)
    @wraperror ccall((:GrB_vxm, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Matrix, GrB_Descriptor), w, mask, accum, semiring, u, A, desc)
end

function GrB_mxv(w, mask, accum, semiring, A, u, desc)
    @wraperror ccall((:GrB_mxv, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, A, u, desc)
end

function GrB_Vector_eWiseMult_Semiring(w, mask, accum, semiring, u, v, desc)
    @wraperror ccall((:GrB_Vector_eWiseMult_Semiring, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, u, v, desc)
end

function GrB_Vector_eWiseMult_Monoid(w, mask, accum, monoid, u, v, desc)
    @wraperror ccall((:GrB_Vector_eWiseMult_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, monoid, u, v, desc)
end

function GrB_Vector_eWiseMult_BinaryOp(w, mask, accum, mult, u, v, desc)
    @wraperror ccall((:GrB_Vector_eWiseMult_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, mult, u, v, desc)
end

function GrB_Matrix_eWiseMult_Semiring(C, Mask, accum, semiring, A, B, desc)
    @wraperror ccall((:GrB_Matrix_eWiseMult_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

function GrB_Matrix_eWiseMult_Monoid(C, Mask, accum, monoid, A, B, desc)
    @wraperror ccall((:GrB_Matrix_eWiseMult_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, monoid, A, B, desc)
end

function GrB_Matrix_eWiseMult_BinaryOp(C, Mask, accum, mult, A, B, desc)
    @wraperror ccall((:GrB_Matrix_eWiseMult_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, mult, A, B, desc)
end

function GrB_Vector_eWiseAdd_Semiring(w, mask, accum, semiring, u, v, desc)
    @wraperror ccall((:GrB_Vector_eWiseAdd_Semiring, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Semiring, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, semiring, u, v, desc)
end

function GrB_Vector_eWiseAdd_Monoid(w, mask, accum, monoid, u, v, desc)
    @wraperror ccall((:GrB_Vector_eWiseAdd_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, monoid, u, v, desc)
end

function GrB_Vector_eWiseAdd_BinaryOp(w, mask, accum, add, u, v, desc)
    @wraperror ccall((:GrB_Vector_eWiseAdd_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GrB_Vector, GrB_Descriptor), w, mask, accum, add, u, v, desc)
end

function GrB_Matrix_eWiseAdd_Semiring(C, Mask, accum, semiring, A, B, desc)
    @wraperror ccall((:GrB_Matrix_eWiseAdd_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, semiring, A, B, desc)
end

function GrB_Matrix_eWiseAdd_Monoid(C, Mask, accum, monoid, A, B, desc)
    @wraperror ccall((:GrB_Matrix_eWiseAdd_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, monoid, A, B, desc)
end

function GrB_Matrix_eWiseAdd_BinaryOp(C, Mask, accum, add, A, B, desc)
    @wraperror ccall((:GrB_Matrix_eWiseAdd_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, add, A, B, desc)
end

function GrB_Vector_extract(w, mask, accum, u, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end
function GrB_Matrix_extract(C, Mask, accum, A, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_extract, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

function GrB_Col_extract(w, mask, accum, A, I, ni, j, desc)
    I = tozerobased(I)
    j = tozerobased(j)
    @wraperror ccall((:GrB_Col_extract, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), w, mask, accum, A, I, ni, j, desc)
end

const scalarvecsubassign = Dict{DataType, Function}()
const scalarmatsubassign = Dict{DataType, Function}()
function GxB_Vector_subassign(w, mask, accum, u, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

function GxB_Matrix_subassign(C, Mask, accum, A, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

function GxB_Col_subassign(C, mask, accum, u, I, ni, j, desc)
    I = tozerobased(I)
    j = tozerobased(j)
    @wraperror ccall((:GxB_Col_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I, ni, j, desc)
end

function GxB_Row_subassign(C, mask, accum, u, i, J, nj, desc)
    i = tozerobased(i)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Row_subassign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, mask, accum, u, i, J, nj, desc)
end

function GxB_Vector_subassign_BOOL(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[Bool] = GxB_Vector_subassign_BOOL

function GxB_Vector_subassign_INT8(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[Int8] = GxB_Vector_subassign_INT8

function GxB_Vector_subassign_UINT8(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[UInt8] = GxB_Vector_subassign_UINT8

function GxB_Vector_subassign_INT16(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[Int16] = GxB_Vector_subassign_INT16

function GxB_Vector_subassign_UINT16(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[UInt16] = GxB_Vector_subassign_UINT16

function GxB_Vector_subassign_INT32(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[Int32] = GxB_Vector_subassign_INT32

function GxB_Vector_subassign_UINT32(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[UInt32] = GxB_Vector_subassign_UINT32

function GxB_Vector_subassign_INT64(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[Int64] = GxB_Vector_subassign_INT64

function GxB_Vector_subassign_UINT64(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[UInt64] = GxB_Vector_subassign_UINT64

function GxB_Vector_subassign_FP32(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[Float32] = GxB_Vector_subassign_FP32

function GxB_Vector_subassign_FP64(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[Float64] = GxB_Vector_subassign_FP64

function GxB_Vector_subassign_FC32(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[ComplexF32] = GxB_Vector_subassign_FC32

function GxB_Vector_subassign_FC64(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_subassign_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecsubassign[ComplexF64] = GxB_Vector_subassign_FC64

function GxB_Vector_subassign_UDT(w, mask, accum, x, I, ni, desc)
    @wraperror ccall((:GxB_Vector_subassign_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GxB_Matrix_subassign_BOOL(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[Bool] = GxB_Matrix_subassign_BOOL

function GxB_Matrix_subassign_INT8(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[Int8] = GxB_Matrix_subassign_INT8

function GxB_Matrix_subassign_UINT8(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[UInt8] = GxB_Matrix_subassign_UINT8

function GxB_Matrix_subassign_INT16(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[Int16] = GxB_Matrix_subassign_INT16

function GxB_Matrix_subassign_UINT16(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[UInt16] = GxB_Matrix_subassign_UINT16

function GxB_Matrix_subassign_INT32(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[Int32] = GxB_Matrix_subassign_INT32

function GxB_Matrix_subassign_UINT32(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[UInt32] = GxB_Matrix_subassign_UINT32

function GxB_Matrix_subassign_INT64(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[Int64] = GxB_Matrix_subassign_INT64

function GxB_Matrix_subassign_UINT64(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[UInt64] = GxB_Matrix_subassign_UINT64

function GxB_Matrix_subassign_FP32(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[Float32] = GxB_Matrix_subassign_FP32

function GxB_Matrix_subassign_FP64(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[Float64] = GxB_Matrix_subassign_FP64

function GxB_Matrix_subassign_FC32(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[ComplexF32] = GxB_Matrix_subassign_FC32

function GxB_Matrix_subassign_FC64(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatsubassign[ComplexF64] = GxB_Matrix_subassign_FC64

function GxB_Matrix_subassign_UDT(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_subassign_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

const scalarvecassign = Dict{DataType, Function}()
const scalarmatassign = Dict{DataType, Function}()
function GrB_Vector_assign(w, mask, accum, u, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, u, I, ni, desc)
end

function GrB_Matrix_assign(C, Mask, accum, A, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, A, I, ni, J, nj, desc)
end

function GrB_Col_assign(C, mask, accum, u, I, ni, j, desc)
    I = tozerobased(I)
    j = tozerobased(j)
    @wraperror ccall((:GrB_Col_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, Ptr{GrB_Index}, GrB_Index, GrB_Index, GrB_Descriptor), C, mask, accum, u, I, ni, j, desc)
end

function GrB_Row_assign(C, mask, accum, u, i, J, nj, desc)
    i = tozerobased(i)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Row_assign, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Vector, GrB_BinaryOp, GrB_Vector, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, mask, accum, u, i, J, nj, desc)
end

function GrB_Vector_assign_BOOL(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[Bool] = GrB_Vector_assign_BOOL

function GrB_Vector_assign_INT8(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[Int8] = GrB_Vector_assign_INT8

function GrB_Vector_assign_UINT8(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[UInt8] = GrB_Vector_assign_UINT8

function GrB_Vector_assign_INT16(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[Int16] = GrB_Vector_assign_INT16

function GrB_Vector_assign_UINT16(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[UInt16] = GrB_Vector_assign_UINT16

function GrB_Vector_assign_INT32(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[Int32] = GrB_Vector_assign_INT32

function GrB_Vector_assign_UINT32(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[UInt32] = GrB_Vector_assign_UINT32

function GrB_Vector_assign_INT64(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[Int64] = GrB_Vector_assign_INT64

function GrB_Vector_assign_UINT64(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[UInt64] = GrB_Vector_assign_UINT64

function GrB_Vector_assign_FP32(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[Float32] = GrB_Vector_assign_FP32

function GrB_Vector_assign_FP64(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[Float64] = GrB_Vector_assign_FP64

function GxB_Vector_assign_FC32(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:xrB_Vector_assign_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[ComplexF32] = GxB_Vector_assign_FC32

function GxB_Vector_assign_FC64(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GxB_Vector_assign_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end
scalarvecassign[ComplexF64] = GxB_Vector_assign_FC64

function GrB_Vector_assign_UDT(w, mask, accum, x, I, ni, desc)
    I = tozerobased(I)
    @wraperror ccall((:GrB_Vector_assign_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), w, mask, accum, x, I, ni, desc)
end

function GrB_Matrix_assign_BOOL(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Bool, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[Bool] = GrB_Matrix_assign_BOOL

function GrB_Matrix_assign_INT8(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[Int8] = GrB_Matrix_assign_INT8

function GrB_Matrix_assign_UINT8(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt8, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[UInt8] = GrB_Matrix_assign_UINT8

function GrB_Matrix_assign_INT16(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[Int16] = GrB_Matrix_assign_INT16

function GrB_Matrix_assign_UINT16(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt16, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[UInt16] = GrB_Matrix_assign_UINT16

function GrB_Matrix_assign_INT32(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[Int32] = GrB_Matrix_assign_INT32

function GrB_Matrix_assign_UINT32(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt32, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[UInt32] = GrB_Matrix_assign_UINT32

function GrB_Matrix_assign_INT64(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Int64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[Int64] = GrB_Matrix_assign_INT64

function GrB_Matrix_assign_UINT64(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, UInt64, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[UInt64] = GrB_Matrix_assign_UINT64

function GrB_Matrix_assign_FP32(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cfloat, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[Float32] = GrB_Matrix_assign_FP32

function GrB_Matrix_assign_FP64(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Cdouble, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[Float64] = GrB_Matrix_assign_FP64

function GxB_Matrix_assign_FC32(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_assign_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC32_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[ComplexF32] = GxB_Matrix_assign_FC32

function GxB_Matrix_assign_FC64(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GxB_Matrix_assign_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_FC64_t, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end
scalarmatassign[ComplexF64] = GxB_Matrix_assign_FC64

function GrB_Matrix_assign_UDT(C, Mask, accum, x, I, ni, J, nj, desc)
    I = tozerobased(I)
    J = tozerobased(J)
    @wraperror ccall((:GrB_Matrix_assign_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, Ptr{Cvoid}, Ptr{GrB_Index}, GrB_Index, Ptr{GrB_Index}, GrB_Index, GrB_Descriptor), C, Mask, accum, x, I, ni, J, nj, desc)
end

function GrB_Vector_apply(w, mask, accum, op, u, desc)
    @wraperror ccall((:GrB_Vector_apply, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_UnaryOp, GrB_Vector, GrB_Descriptor), w, mask, accum, op, u, desc)
end

function GrB_Matrix_apply(C, Mask, accum, op, A, desc)
    @wraperror ccall((:GrB_Matrix_apply, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_UnaryOp, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, A, desc)
end

const scalarvecapply1st = Dict{DataType, Function}()

function GxB_Vector_apply_BinaryOp1st(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GxB_Vector_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_Scalar, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

function GrB_Vector_apply_BinaryOp1st_BOOL(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Bool, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[Bool] = GrB_Vector_apply_BinaryOp1st_BOOL

function GrB_Vector_apply_BinaryOp1st_INT8(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int8, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[Int8] = GrB_Vector_apply_BinaryOp1st_INT8

function GrB_Vector_apply_BinaryOp1st_INT16(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int16, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[Int16] = GrB_Vector_apply_BinaryOp1st_INT16

function GrB_Vector_apply_BinaryOp1st_INT32(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int32, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[Int32] = GrB_Vector_apply_BinaryOp1st_INT32

function GrB_Vector_apply_BinaryOp1st_INT64(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Int64, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[Int64] = GrB_Vector_apply_BinaryOp1st_INT64

function GrB_Vector_apply_BinaryOp1st_UINT8(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt8, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[UInt8] = GrB_Vector_apply_BinaryOp1st_UINT8

function GrB_Vector_apply_BinaryOp1st_UINT16(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt16, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[UInt16] = GrB_Vector_apply_BinaryOp1st_UINT16

function GrB_Vector_apply_BinaryOp1st_UINT32(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt32, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[UInt32] = GrB_Vector_apply_BinaryOp1st_UINT32

function GrB_Vector_apply_BinaryOp1st_UINT64(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, UInt64, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[UInt64] = GrB_Vector_apply_BinaryOp1st_UINT64

function GrB_Vector_apply_BinaryOp1st_FP32(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Cfloat, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[Float32] = GrB_Vector_apply_BinaryOp1st_FP32

function GrB_Vector_apply_BinaryOp1st_FP64(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Cdouble, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[Float64] = GrB_Vector_apply_BinaryOp1st_FP64

function GxB_Vector_apply_BinaryOp1st_FC32(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GxB_Vector_apply_BinaryOp1st_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_FC32_t, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[ComplexF32] = GxB_Vector_apply_BinaryOp1st_FC32

function GxB_Vector_apply_BinaryOp1st_FC64(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GxB_Vector_apply_BinaryOp1st_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GxB_FC64_t, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end
scalarvecapply1st[ComplexF64] = GxB_Vector_apply_BinaryOp1st_FC64

function GrB_Vector_apply_BinaryOp1st_UDT(w, mask, accum, op, x, u, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp1st_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, Ptr{Cvoid}, GrB_Vector, GrB_Descriptor), w, mask, accum, op, x, u, desc)
end

const scalarvecapply2nd = Dict{DataType, Function}()

function GxB_Vector_apply_BinaryOp2nd(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GxB_Vector_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_Scalar, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

function GrB_Vector_apply_BinaryOp2nd_BOOL(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_BOOL, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Bool, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[Bool] = GrB_Vector_apply_BinaryOp2nd_BOOL

function GrB_Vector_apply_BinaryOp2nd_INT8(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_INT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[Int8] = GrB_Vector_apply_BinaryOp2nd_INT8

function GrB_Vector_apply_BinaryOp2nd_INT16(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_INT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[Int16] = GrB_Vector_apply_BinaryOp2nd_INT16

function GrB_Vector_apply_BinaryOp2nd_INT32(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_INT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[Int32] = GrB_Vector_apply_BinaryOp2nd_INT32

function GrB_Vector_apply_BinaryOp2nd_INT64(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_INT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Int64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[Int64] = GrB_Vector_apply_BinaryOp2nd_INT64

function GrB_Vector_apply_BinaryOp2nd_UINT8(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_UINT8, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt8, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[UInt8] = GrB_Vector_apply_BinaryOp2nd_UINT8

function GrB_Vector_apply_BinaryOp2nd_UINT16(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_UINT16, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt16, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[UInt16] = GrB_Vector_apply_BinaryOp2nd_UINT16

function GrB_Vector_apply_BinaryOp2nd_UINT32(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_UINT32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt32, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[UInt32] = GrB_Vector_apply_BinaryOp2nd_UINT32

function GrB_Vector_apply_BinaryOp2nd_UINT64(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_UINT64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, UInt64, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[UInt64] = GrB_Vector_apply_BinaryOp2nd_UINT64

function GrB_Vector_apply_BinaryOp2nd_FP32(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_FP32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Cfloat, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[Float32] = GrB_Vector_apply_BinaryOp2nd_FP32

function GrB_Vector_apply_BinaryOp2nd_FP64(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_FP64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Cdouble, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[Float64] = GrB_Vector_apply_BinaryOp2nd_FP64

function GxB_Vector_apply_BinaryOp2nd_FC32(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GxB_Vector_apply_BinaryOp2nd_FC32, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_FC32_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[ComplexF32] = GxB_Vector_apply_BinaryOp2nd_FC32

function GxB_Vector_apply_BinaryOp2nd_FC64(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GxB_Vector_apply_BinaryOp2nd_FC64, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, GxB_FC64_t, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end
scalarvecapply2nd[ComplexF64] = GxB_Vector_apply_BinaryOp2nd_FC64

function GrB_Vector_apply_BinaryOp2nd_UDT(w, mask, accum, op, u, y, desc)
    @wraperror ccall((:GrB_Vector_apply_BinaryOp2nd_UDT, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Vector, Ptr{Cvoid}, GrB_Descriptor), w, mask, accum, op, u, y, desc)
end

const scalarmatapply1st = Dict{DataType, Function}()

function GxB_Matrix_apply_BinaryOp1st(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GxB_Matrix_apply_BinaryOp1st, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_Scalar, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

function GrB_Matrix_apply_BinaryOp1st_BOOL(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Bool, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[Bool] = GrB_Matrix_apply_BinaryOp1st_BOOL

function GrB_Matrix_apply_BinaryOp1st_INT8(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int8, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[Int8] = GrB_Matrix_apply_BinaryOp1st_INT8

function GrB_Matrix_apply_BinaryOp1st_INT16(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int16, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[Int16] = GrB_Matrix_apply_BinaryOp1st_INT16

function GrB_Matrix_apply_BinaryOp1st_INT32(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int32, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[Int32] = GrB_Matrix_apply_BinaryOp1st_INT32

function GrB_Matrix_apply_BinaryOp1st_INT64(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Int64, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[Int64] = GrB_Matrix_apply_BinaryOp1st_INT64

function GrB_Matrix_apply_BinaryOp1st_UINT8(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt8, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[UInt8] = GrB_Matrix_apply_BinaryOp1st_UINT8

function GrB_Matrix_apply_BinaryOp1st_UINT16(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt16, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[UInt16] = GrB_Matrix_apply_BinaryOp1st_UINT16

function GrB_Matrix_apply_BinaryOp1st_UINT32(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt32, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[UInt32] = GrB_Matrix_apply_BinaryOp1st_UINT32

function GrB_Matrix_apply_BinaryOp1st_UINT64(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, UInt64, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[UInt64] = GrB_Matrix_apply_BinaryOp1st_UINT64

function GrB_Matrix_apply_BinaryOp1st_FP32(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Cfloat, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[Float32] = GrB_Matrix_apply_BinaryOp1st_FP32

function GrB_Matrix_apply_BinaryOp1st_FP64(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Cdouble, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[Float64] = GrB_Matrix_apply_BinaryOp1st_FP64

function GxB_Matrix_apply_BinaryOp1st_FC32(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GxB_Matrix_apply_BinaryOp1st_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_FC32_t, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[ComplexF32] = GxB_Matrix_apply_BinaryOp1st_FC32

function GxB_Matrix_apply_BinaryOp1st_FC64(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GxB_Matrix_apply_BinaryOp1st_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GxB_FC64_t, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end
scalarmatapply1st[ComplexF64] = GxB_Matrix_apply_BinaryOp1st_FC64

function GrB_Matrix_apply_BinaryOp1st_UDT(C, Mask, accum, op, x, A, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp1st_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, Ptr{Cvoid}, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, x, A, desc)
end

const scalarmatapply2nd = Dict{DataType, Function}()

function GxB_Matrix_apply_BinaryOp2nd(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GxB_Matrix_apply_BinaryOp2nd, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GrB_Matrix_apply_BinaryOp2nd_BOOL(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_BOOL, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Bool, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[Bool] = GrB_Matrix_apply_BinaryOp2nd_BOOL

function GrB_Matrix_apply_BinaryOp2nd_INT8(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_INT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[Int8] = GrB_Matrix_apply_BinaryOp2nd_INT8

function GrB_Matrix_apply_BinaryOp2nd_INT16(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_INT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[Int16] = GrB_Matrix_apply_BinaryOp2nd_INT16

function GrB_Matrix_apply_BinaryOp2nd_INT32(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_INT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[Int32] = GrB_Matrix_apply_BinaryOp2nd_INT32

function GrB_Matrix_apply_BinaryOp2nd_INT64(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_INT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Int64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[Int64] = GrB_Matrix_apply_BinaryOp2nd_INT64

function GrB_Matrix_apply_BinaryOp2nd_UINT8(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT8, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt8, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[UInt8] = GrB_Matrix_apply_BinaryOp2nd_UINT8

function GrB_Matrix_apply_BinaryOp2nd_UINT16(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT16, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt16, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[UInt16] = GrB_Matrix_apply_BinaryOp2nd_UINT16

function GrB_Matrix_apply_BinaryOp2nd_UINT32(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt32, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[UInt32] = GrB_Matrix_apply_BinaryOp2nd_UINT32

function GrB_Matrix_apply_BinaryOp2nd_UINT64(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_UINT64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, UInt64, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[UInt64] = GrB_Matrix_apply_BinaryOp2nd_UINT64

function GrB_Matrix_apply_BinaryOp2nd_FP32(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_FP32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Cfloat, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[Float32] = GrB_Matrix_apply_BinaryOp2nd_FP32

function GrB_Matrix_apply_BinaryOp2nd_FP64(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_FP64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Cdouble, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[Float64] = GrB_Matrix_apply_BinaryOp2nd_FP64

function GxB_Matrix_apply_BinaryOp2nd_FC32(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GxB_Matrix_apply_BinaryOp2nd_FC32, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_FC32_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[ComplexF32] = GxB_Matrix_apply_BinaryOp2nd_FC32

function GxB_Matrix_apply_BinaryOp2nd_FC64(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GxB_Matrix_apply_BinaryOp2nd_FC64, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GxB_FC64_t, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end
scalarmatapply2nd[ComplexF64] = GxB_Matrix_apply_BinaryOp2nd_FC64

function GrB_Matrix_apply_BinaryOp2nd_UDT(C, Mask, accum, op, A, y, desc)
    @wraperror ccall((:GrB_Matrix_apply_BinaryOp2nd_UDT, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, Ptr{Cvoid}, GrB_Descriptor), C, Mask, accum, op, A, y, desc)
end

function GxB_Vector_select(w, mask, accum, op, u, Thunk, desc)
    @wraperror ccall((:GxB_Vector_select, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GxB_SelectOp, GrB_Vector, GxB_Scalar, GrB_Descriptor), w, mask, accum, op, u, Thunk, desc)
end

function GxB_Matrix_select(C, Mask, accum, op, A, Thunk, desc)
    @wraperror ccall((:GxB_Matrix_select, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GxB_SelectOp, GrB_Matrix, GxB_Scalar, GrB_Descriptor), C, Mask, accum, op, A, Thunk, desc)
end

function GrB_Matrix_reduce_Monoid(w, mask, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_Monoid, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), w, mask, accum, monoid, A, desc)
end

function GrB_Matrix_reduce_BinaryOp(w, mask, accum, op, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_BinaryOp, libgraphblas), GrB_Info, (GrB_Vector, GrB_Vector, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), w, mask, accum, op, A, desc)
end

const scalarvecreduce = Dict{DataType, Function}()

function GrB_Vector_reduce_BOOL(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[Bool] = GrB_Vector_reduce_BOOL

function GrB_Vector_reduce_INT8(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[Int8] = GrB_Vector_reduce_INT8

function GrB_Vector_reduce_UINT8(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[UInt8] = GrB_Vector_reduce_UINT8

function GrB_Vector_reduce_INT16(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[Int16] = GrB_Vector_reduce_INT16

function GrB_Vector_reduce_UINT16(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[UInt16] = GrB_Vector_reduce_UINT16

function GrB_Vector_reduce_INT32(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[Int32] = GrB_Vector_reduce_INT32

function GrB_Vector_reduce_UINT32(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[UInt32] = GrB_Vector_reduce_UINT32

function GrB_Vector_reduce_INT64(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[Int64] = GrB_Vector_reduce_INT64

function GrB_Vector_reduce_UINT64(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[UInt64] = GrB_Vector_reduce_UINT64

function GrB_Vector_reduce_FP32(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[Float32] = GrB_Vector_reduce_FP32
function GrB_Vector_reduce_FP64(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[Float64] = GrB_Vector_reduce_FP64
function GxB_Vector_reduce_FC32(c, accum, monoid, u, desc)
    @wraperror ccall((:GxB_Vector_reduce_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[ComplexF32] = GxB_Vector_reduce_FC32

function GxB_Vector_reduce_FC64(c, accum, monoid, u, desc)
    @wraperror ccall((:GxB_Vector_reduce_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end
scalarvecreduce[ComplexF64] = GxB_Vector_reduce_FC64

function GrB_Vector_reduce_UDT(c, accum, monoid, u, desc)
    @wraperror ccall((:GrB_Vector_reduce_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_BinaryOp, GrB_Monoid, GrB_Vector, GrB_Descriptor), c, accum, monoid, u, desc)
end

const scalarmatreduce = Dict{DataType, Function}()

function GrB_Matrix_reduce_BOOL(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_BOOL, libgraphblas), GrB_Info, (Ptr{Bool}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[Bool] = GrB_Matrix_reduce_BOOL

function GrB_Matrix_reduce_INT8(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_INT8, libgraphblas), GrB_Info, (Ptr{Int8}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[Int8] = GrB_Matrix_reduce_INT8

function GrB_Matrix_reduce_UINT8(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_UINT8, libgraphblas), GrB_Info, (Ptr{UInt8}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[UInt8] = GrB_Matrix_reduce_UINT8

function GrB_Matrix_reduce_INT16(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_INT16, libgraphblas), GrB_Info, (Ptr{Int16}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[Int16] = GrB_Matrix_reduce_INT16

function GrB_Matrix_reduce_UINT16(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_UINT16, libgraphblas), GrB_Info, (Ptr{UInt16}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[UInt16] = GrB_Matrix_reduce_UINT16

function GrB_Matrix_reduce_INT32(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_INT32, libgraphblas), GrB_Info, (Ptr{Int32}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[Int32] = GrB_Matrix_reduce_INT32

function GrB_Matrix_reduce_UINT32(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_UINT32, libgraphblas), GrB_Info, (Ptr{UInt32}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[UInt32] = GrB_Matrix_reduce_UINT32

function GrB_Matrix_reduce_INT64(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_INT64, libgraphblas), GrB_Info, (Ptr{Int64}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[Int64] = GrB_Matrix_reduce_INT64

function GrB_Matrix_reduce_UINT64(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_UINT64, libgraphblas), GrB_Info, (Ptr{UInt64}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[UInt64] = GrB_Matrix_reduce_UINT64

function GrB_Matrix_reduce_FP32(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_FP32, libgraphblas), GrB_Info, (Ptr{Cfloat}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[Float32] = GrB_Matrix_reduce_FP32

function GrB_Matrix_reduce_FP64(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_FP64, libgraphblas), GrB_Info, (Ptr{Cdouble}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[Float64] = GrB_Matrix_reduce_FP64

function GxB_Matrix_reduce_FC32(c, accum, monoid, A, desc)
    @wraperror ccall((:GxB_Matrix_reduce_FC32, libgraphblas), GrB_Info, (Ptr{GxB_FC32_t}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[ComplexF32] = GxB_Matrix_reduce_FC32

function GxB_Matrix_reduce_FC64(c, accum, monoid, A, desc)
    @wraperror ccall((:GxB_Matrix_reduce_FC64, libgraphblas), GrB_Info, (Ptr{GxB_FC64_t}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end
scalarmatreduce[ComplexF64] = GxB_Matrix_reduce_FC64

function GrB_Matrix_reduce_UDT(c, accum, monoid, A, desc)
    @wraperror ccall((:GrB_Matrix_reduce_UDT, libgraphblas), GrB_Info, (Ptr{Cvoid}, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Descriptor), c, accum, monoid, A, desc)
end

function GrB_transpose(C, Mask, accum, A, desc)
    @wraperror ccall((:GrB_transpose, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Matrix, GrB_Descriptor), C, Mask, accum, A, desc)
end

function GxB_kron(C, Mask, accum, op, A, B, desc)
    @wraperror ccall((:GxB_kron, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, Mask, accum, op, A, B, desc)
end

function GrB_Matrix_kronecker_BinaryOp(C, M, accum, op, A, B, desc)
    @wraperror ccall((:GrB_Matrix_kronecker_BinaryOp, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_BinaryOp, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, op, A, B, desc)
end

function GrB_Matrix_kronecker_Monoid(C, M, accum, monoid, A, B, desc)
    @wraperror ccall((:GrB_Matrix_kronecker_Monoid, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Monoid, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, monoid, A, B, desc)
end

function GrB_Matrix_kronecker_Semiring(C, M, accum, semiring, A, B, desc)
    @wraperror ccall((:GrB_Matrix_kronecker_Semiring, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Matrix, GrB_BinaryOp, GrB_Semiring, GrB_Matrix, GrB_Matrix, GrB_Descriptor), C, M, accum, semiring, A, B, desc)
end

function GrB_Matrix_resize(C, nrows_new, ncols_new)
    @wraperror ccall((:GrB_Matrix_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, nrows_new, ncols_new)
end

function GrB_Vector_resize(w, nrows_new)
    @wraperror ccall((:GrB_Vector_resize, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), w, nrows_new)
end

function GxB_Matrix_resize(C, nrows_new, ncols_new)
    @wraperror ccall((:GxB_Matrix_resize, libgraphblas), GrB_Info, (GrB_Matrix, GrB_Index, GrB_Index), C, nrows_new, ncols_new)
end

function GxB_Vector_resize(w, nrows_new)
    @wraperror ccall((:GxB_Vector_resize, libgraphblas), GrB_Info, (GrB_Vector, GrB_Index), w, nrows_new)
end

@cenum GxB_Print_Level::UInt32 begin
    GxB_SILENT = 0
    GxB_SUMMARY = 1
    GxB_SHORT = 2
    GxB_COMPLETE = 3
    GxB_SHORT_VERBOSE = 4
    GxB_COMPLETE_VERBOSE = 5
end

function GxB_Type_fprint(type, name, pr, f)
    @wraperror ccall((:GxB_Type_fprint, libgraphblas), GrB_Info, (GrB_Type, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), type, name, pr, f)
end

function GxB_UnaryOp_fprint(unaryop, name, pr, f)
    @wraperror ccall((:GxB_UnaryOp_fprint, libgraphblas), GrB_Info, (GrB_UnaryOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), unaryop, name, pr, f)
end

function GxB_BinaryOp_fprint(binaryop, name, pr, f)
    @wraperror ccall((:GxB_BinaryOp_fprint, libgraphblas), GrB_Info, (GrB_BinaryOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), binaryop, name, pr, f)
end

function GxB_SelectOp_fprint(selectop, name, pr, f)
    @wraperror ccall((:GxB_SelectOp_fprint, libgraphblas), GrB_Info, (GxB_SelectOp, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), selectop, name, pr, f)
end

function GxB_Monoid_fprint(monoid, name, pr, f)
    @wraperror ccall((:GxB_Monoid_fprint, libgraphblas), GrB_Info, (GrB_Monoid, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), monoid, name, pr, f)
end

function GxB_Semiring_fprint(semiring, name, pr, f)
    @wraperror ccall((:GxB_Semiring_fprint, libgraphblas), GrB_Info, (GrB_Semiring, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), semiring, name, pr, f)
end

function GxB_Descriptor_fprint(descriptor, name, pr, f)
    @wraperror ccall((:GxB_Descriptor_fprint, libgraphblas), GrB_Info, (GrB_Descriptor, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), descriptor, name, pr, f)
end

function GxB_Matrix_fprint(A, name, pr, f)
    @wraperror ccall((:GxB_Matrix_fprint, libgraphblas), GrB_Info, (GrB_Matrix, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), A, name, pr, f)
end

function GxB_Vector_fprint(v, name, pr, f)
    @wraperror ccall((:GxB_Vector_fprint, libgraphblas), GrB_Info, (GrB_Vector, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), v, name, pr, f)
end

function GxB_Scalar_fprint(s, name, pr, f)
    @wraperror ccall((:GxB_Scalar_fprint, libgraphblas), GrB_Info, (GxB_Scalar, Ptr{Cchar}, GxB_Print_Level, Ptr{Libc.FILE}), s, name, pr, f)
end

function GxB_Matrix_import_CSR(A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, is_uniform, jumbled, desc)
    @wraperror ccall((:GxB_Matrix_import_CSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, is_uniform, jumbled, desc)
end

function GxB_Matrix_import_CSC(A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, is_uniform, jumbled, desc)
    @wraperror ccall((:GxB_Matrix_import_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, Bool, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, is_uniform, jumbled, desc)
end

function GxB_Matrix_import_HyperCSR(A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, is_uniform, nvec, jumbled, desc)
    @wraperror ccall((:GxB_Matrix_import_HyperCSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, is_uniform, nvec, jumbled, desc)
end

function GxB_Matrix_import_HyperCSC(A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, is_uniform, nvec, jumbled, desc)
    @wraperror ccall((:GxB_Matrix_import_HyperCSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, is_uniform, nvec, jumbled, desc)
end

function GxB_Matrix_import_BitmapR(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, is_uniform, nvals, desc)
    @wraperror ccall((:GxB_Matrix_import_BitmapR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, is_uniform, nvals, desc)
end

function GxB_Matrix_import_BitmapC(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, is_uniform, nvals, desc)
    @wraperror ccall((:GxB_Matrix_import_BitmapC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, is_uniform, nvals, desc)
end

function GxB_Matrix_import_FullR(A, type, nrows, ncols, Ax, Ax_size, is_uniform, desc)
    @wraperror ccall((:GxB_Matrix_import_FullR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, is_uniform, desc)
end

function GxB_Matrix_import_FullC(A, type, nrows, ncols, Ax, Ax_size, is_uniform, desc)
    @wraperror ccall((:GxB_Matrix_import_FullC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, GrB_Type, GrB_Index, GrB_Index, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, is_uniform, desc)
end

function GxB_Vector_import_CSC(v, type, n, vi, vx, vi_size, vx_size, is_uniform, nvals, jumbled, desc)
    @wraperror ccall((:GxB_Vector_import_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, Bool, GrB_Descriptor), v, type, n, vi, vx, vi_size, vx_size, is_uniform, nvals, jumbled, desc)
end

function GxB_Vector_import_Bitmap(v, type, n, vb, vx, vb_size, vx_size, is_uniform, nvals, desc)
    @wraperror ccall((:GxB_Vector_import_Bitmap, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, GrB_Index, GrB_Index, Bool, GrB_Index, GrB_Descriptor), v, type, n, vb, vx, vb_size, vx_size, is_uniform, nvals, desc)
end

function GxB_Vector_import_Full(v, type, n, vx, vx_size, is_uniform, desc)
    @wraperror ccall((:GxB_Vector_import_Full, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, GrB_Type, GrB_Index, Ptr{Ptr{Cvoid}}, GrB_Index, Bool, GrB_Descriptor), v, type, n, vx, vx_size, is_uniform, desc)
end

function GxB_Matrix_export_CSR(A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, is_uniform, jumbled, desc)
    @wraperror ccall((:GxB_Matrix_export_CSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Aj, Ax, Ap_size, Aj_size, Ax_size, is_uniform, jumbled, desc)
end

function GxB_Matrix_export_CSC(A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, is_uniform, jumbled, desc)
    @wraperror ccall((:GxB_Matrix_export_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Ai, Ax, Ap_size, Ai_size, Ax_size, is_uniform, jumbled, desc)
end

function GxB_Matrix_export_HyperCSR(A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, is_uniform, nvec, jumbled, desc)
    @wraperror ccall((:GxB_Matrix_export_HyperCSR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Aj, Ax, Ap_size, Ah_size, Aj_size, Ax_size, is_uniform, nvec, jumbled, desc)
end

function GxB_Matrix_export_HyperCSC(A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, is_uniform, nvec, jumbled, desc)
    @wraperror ccall((:GxB_Matrix_export_HyperCSC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ap, Ah, Ai, Ax, Ap_size, Ah_size, Ai_size, Ax_size, is_uniform, nvec, jumbled, desc)
end

function GxB_Matrix_export_BitmapR(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, is_uniform, nvals, desc)
    @wraperror ccall((:GxB_Matrix_export_BitmapR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, is_uniform, nvals, desc)
end

function GxB_Matrix_export_BitmapC(A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, is_uniform, nvals, desc)
    @wraperror ccall((:GxB_Matrix_export_BitmapC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), A, type, nrows, ncols, Ab, Ax, Ab_size, Ax_size, is_uniform, nvals, desc)
end

function GxB_Matrix_export_FullR(A, type, nrows, ncols, Ax, Ax_size, is_uniform, desc)
    @wraperror ccall((:GxB_Matrix_export_FullR, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, is_uniform, desc)
end

function GxB_Matrix_export_FullC(A, type, nrows, ncols, Ax, Ax_size, is_uniform, desc)
    @wraperror ccall((:GxB_Matrix_export_FullC, libgraphblas), GrB_Info, (Ptr{GrB_Matrix}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), A, type, nrows, ncols, Ax, Ax_size, is_uniform, desc)
end

function GxB_Vector_export_CSC(v, type, n, vi, vx, vi_size, vx_size, is_uniform, nvals, jumbled, desc)
    @wraperror ccall((:GxB_Vector_export_CSC, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{Ptr{GrB_Index}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, type, n, vi, vx, vi_size, vx_size, is_uniform, nvals, jumbled, desc)
end

function GxB_Vector_export_Bitmap(v, type, n, vb, vx, vb_size, vx_size, is_uniform, nvals, desc)
    @wraperror ccall((:GxB_Vector_export_Bitmap, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{Ptr{Int8}}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{GrB_Index}, Ptr{Bool}, Ptr{GrB_Index}, GrB_Descriptor), v, type, n, vb, vx, vb_size, vx_size, is_uniform, nvals, desc)
end

function GxB_Vector_export_Full(v, type, n, vx, vx_size, is_uniform, desc)
    @wraperror ccall((:GxB_Vector_export_Full, libgraphblas), GrB_Info, (Ptr{GrB_Vector}, Ptr{GrB_Type}, Ptr{GrB_Index}, Ptr{Ptr{Cvoid}}, Ptr{GrB_Index}, Ptr{Bool}, GrB_Descriptor), v, type, n, vx, vx_size, is_uniform, desc)
end

function GxB_cuda_malloc(size)
    ccall((:GxB_cuda_malloc, libgraphblas), Ptr{Cvoid}, (Csize_t,), size)
end

function GxB_cuda_calloc(n, size)
    ccall((:GxB_cuda_calloc, libgraphblas), Ptr{Cvoid}, (Csize_t, Csize_t), n, size)
end

function GxB_cuda_free(p)
    ccall((:GxB_cuda_free, libgraphblas), Cvoid, (Ptr{Cvoid},), p)
end

function GxB_Global_Option_get(field)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH]
        T = Cdouble
    elseif field ∈ [GxB_FORMAT]
        T = UInt32
    elseif field ∈ [GxB_GLOBAL_NTHREADS, GxB_GLOBAL_CHUNK]
        T = Cint
    end
    v = Ref{T}()
    ccall(
        (:GxB_Global_Option_get, libgraphblas),
        Cvoid,
        (UInt32, Ptr{Cvoid}),
        field,
        v
    )
    return v[]
end

function GxB_Global_Option_set(field, value)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH]
        ccall(
            (:GxB_Global_Option_set, libgraphblas),
            Cvoid,
            (UInt32, Cdouble),
            field,
            value
        )
    elseif field ∈ [GxB_FORMAT]
        ccall(
            (:GxB_Global_Option_set, libgraphblas),
            Cvoid,
            (UInt32, UInt32),
            field,
            value
        )
    elseif field ∈ [GxB_GLOBAL_NTHREADS, GxB_GLOBAL_CHUNK]
        ccall(
            (:GxB_Global_Option_set, libgraphblas),
            Cvoid,
            (UInt32, Cint),
            field,
            value
        )
    elseif field ∈ [GxB_PRINT_1BASED]
        ccall(
            (:GxB_Global_Option_set, libgraphblas),
            Cvoid,
            (UInt32, Bool),
            field,
            value
        )
    end
end

function GxB_Matrix_Option_get(A, field)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH]
        T = Cdouble
    elseif field ∈ [GxB_FORMAT]
        T = UInt32
    elseif field ∈ [GxB_SPARSITY_STATUS, GxB_SPARSITY_CONTROL]
        T = Cint
    end
    v = Ref{T}()
    ccall(
        (:GxB_Matrix_Option_get, libgraphblas),
        Cvoid,
        (GrB_Matrix, UInt32, Ptr{Cvoid}),
        A,
        field,
        v
    )
    return v[]
end

function GxB_Matrix_Option_set(A, field, value)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH]
        ccall(
            (:GxB_Matrix_Option_set, libgraphblas),
            Cvoid,
            (GrB_Matrix, UInt32, Cdouble),
            A,
            field,
            value
        )
    elseif field ∈ [GxB_FORMAT]
        ccall(
            (:GxB_Matrix_Option_set, libgraphblas),
            Cvoid,
            (GrB_Matrix, UInt32, UInt32),
            A,
            field,
            value
        )
    elseif field ∈ [GxB_SPARSITY_CONTROL]
        ccall(
            (:GxB_Matrix_Option_set, libgraphblas),
            Cvoid,
            (GrB_Matrix, UInt32, Cint),
            A,
            field,
            value
        )
    end
end

function GxB_Vector_Option_get(A, field)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH]
        T = Cdouble
    elseif field ∈ [GxB_FORMAT]
        T = UInt32
    elseif field ∈ [GxB_SPARSITY_STATUS, GxB_SPARSITY_CONTROL]
        T = Cint
    end
    v = Ref{T}()
    ccall(
        (:GxB_Vector_Option_get, libgraphblas),
        Cvoid,
        (GrB_Vector, UInt32, Ptr{Cvoid}),
        A,
        field,
        v
    )
    return v[]
end

function GxB_Vector_Option_set(A, field, value)
    if field ∈ [GxB_HYPER_SWITCH, GxB_BITMAP_SWITCH]
        ccall(
            (:GxB_Vector_Option_set, libgraphblas),
            Cvoid,
            (GrB_Vector, UInt32, Cdouble),
            A,
            field,
            value
        )
    elseif field ∈ [GxB_FORMAT]
        ccall(
            (:GxB_Vector_Option_set, libgraphblas),
            Cvoid,
            (GrB_Vector, UInt32, UInt32),
            A,
            field,
            value
        )
    elseif field ∈ [GxB_SPARSITY_CONTROL]
        ccall(
            (:GxB_Vector_Option_set, libgraphblas),
            Cvoid,
            (GrB_Vector, UInt32, Cint),
            A,
            field,
            value
        )
    end
end

# Skipping MacroDefinition: GB_PUBLIC extern

# const GxB_STDC_VERSION = __STDC_VERSION__

const GxB_IMPLEMENTATION_NAME = "SuiteSparse:GraphBLAS"

const GxB_IMPLEMENTATION_DATE = "May 13, 2021"

const GxB_IMPLEMENTATION_MAJOR = 5

const GxB_IMPLEMENTATION_MINOR = 0

const GxB_IMPLEMENTATION_SUB = 4

const GxB_SPEC_DATE = "Sept 25, 2019"

const GxB_SPEC_MAJOR = 1

const GxB_SPEC_MINOR = 3

const GxB_SPEC_SUB = 0

const GxB_IMPLEMENTATION = (GxB_IMPLEMENTATION_MAJOR, GxB_IMPLEMENTATION_MINOR, GxB_IMPLEMENTATION_SUB)

# Skipping MacroDefinition: GxB_IMPLEMENTATION_ABOUT \
# "SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2021, All Rights Reserved." \
# "\nhttp://suitesparse.com  Dept of Computer Sci. & Eng, Texas A&M University.\n"

# Skipping MacroDefinition: GxB_IMPLEMENTATION_LICENSE \
# "SuiteSparse:GraphBLAS, Timothy A. Davis, (c) 2017-2021, All Rights Reserved." \
# "\nLicensed under the Apache License, Version 2.0 (the \"License\"); you may\n" \
# "not use SuiteSparse:GraphBLAS except in compliance with the License.  You\n" \
# "may obtain a copy of the License at\n\n" \
# "    http://www.apache.org/licenses/LICENSE-2.0\n\n" \
# "Unless required by applicable law or agreed to in writing, software\n" \
# "distributed under the License is distributed on an \"AS IS\" BASIS,\n" \
# "WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n" \
# "See the License for the specific language governing permissions and\n" \
# "limitations under the License.\n"

const GxB_SPEC_VERSION = (GxB_SPEC_MAJOR, GxB_SPEC_MINOR, GxB_SPEC_SUB)

# Skipping MacroDefinition: GxB_SPEC_ABOUT \
# "GraphBLAS C API, by Aydin Buluc, Timothy Mattson, Scott McMillan,\n" \
# "Jose' Moreira, Carl Yang, and Benjamin Brock.  Based on 'GraphBLAS\n" \
# "Mathematics by Jeremy Kepner.  See also 'Graph Algorithms in the Language\n" \
# "of Linear Algebra,' edited by J. Kepner and J. Gilbert, SIAM, 2011.\n"

const GxB_INDEX_MAX = GrB_Index(Culonglong(1) << 60)

const GRB_VERSION = GxB_SPEC_MAJOR

const GRB_SUBVERSION = GxB_SPEC_MINOR

const GxB_NTHREADS = 5

const GxB_CHUNK = 7

const GxB_GPU_CONTROL = 21

const GxB_GPU_CHUNK = 22

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

end # module
