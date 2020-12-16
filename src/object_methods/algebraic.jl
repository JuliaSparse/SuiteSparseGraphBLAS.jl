import GraphBLASInterface:
        GrB_UnaryOp_new, GrB_BinaryOp_new, GrB_Monoid_new, GrB_Semiring_new

"""
    GrB_UnaryOp_new(op, fn, ztype, xtype)

Initialize a GraphBLAS unary operator with a specified user-defined function and its types.
The function should take a single value(x) & return an output(z), f(x) = z.

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> u = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(u, GrB_INT64, 3)
GrB_SUCCESS::GrB_Info = 0

julia> I = ZeroBasedIndex[0, 2]; X = [10, 20]; n = 2;

julia> GrB_Vector_build(u, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(w, GrB_INT64, 3)
GrB_SUCCESS::GrB_Info = 0

julia> function NEG(a)
           return -a
       end
NEG (generic function with 1 method)

julia> negative = GrB_UnaryOp()
GrB_UnaryOp

julia> GrB_UnaryOp_new(negative, NEG, GrB_INT64, GrB_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_apply(w, GrB_NULL, GrB_NULL, negative, u, GrB_NULL)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

3x1 GraphBLAS int64_t vector, sparse by col:
w, 2 entries

    (0,0)   -10
    (2,0)   -20
```
"""
function GrB_UnaryOp_new(
    op::GrB_UnaryOp,
    fn::Function,
    ztype::GrB_Type{T},
    xtype::GrB_Type{U}) where {T, U}

    op_ptr = pointer_from_objref(op)

    function unaryop_fn(z, x)
        unsafe_store!(z, fn(x))
        return nothing
    end

    unaryop_fn_C = @cfunction($unaryop_fn, Cvoid, (Ptr{T}, Ref{U}))

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, "GrB_UnaryOp_new"),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                    op_ptr, unaryop_fn_C, ztype.p, xtype.p
                )
            )
end

"""
    GrB_BinaryOp_new(op, fn, ztype, xtype, ytype)

Initialize a GraphBLAS binary operator with a specified user-defined function and its types.
The function should take 2 values(x, y) & return an output(z), f(x, y) = z.

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(V, GrB_FP64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = ZeroBasedIndex[0, 0, 3, 3]; X = [2.1, 3.2, 4.5, 5.0]; n = 4;  # two values at position 0 and 3

julia> dup = GrB_BinaryOp()  # dup is a binary operator which is applied when duplicate values for the same location are present in the vector
GrB_BinaryOp

julia> function ADD(b, c)
           return b+c
       end
ADD (generic function with 1 method)

julia> GrB_BinaryOp_new(dup, ADD, GrB_FP64, GrB_FP64, GrB_FP64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_build(V, I, X, n, dup)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(V, GxB_COMPLETE)

4x1 GraphBLAS double vector, sparse by col:
V, 2 entries

    (0,0)    5.3
    (3,0)    9.5
```
"""
function GrB_BinaryOp_new(
    op::GrB_BinaryOp,
    fn::Function,
    ztype::GrB_Type{T},
    xtype::GrB_Type{U},
    ytype::GrB_Type{V}) where {T, U, V}

    op_ptr = pointer_from_objref(op)

    function binaryop_fn(z, x, y)
        unsafe_store!(z, fn(x, y))
        return nothing
    end

    binaryop_fn_C = @cfunction($binaryop_fn, Cvoid, (Ptr{T}, Ref{U}, Ref{V}))

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, "GrB_BinaryOp_new"),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                    op_ptr, binaryop_fn_C, ztype.p, xtype.p, ytype.p
                )
            )
end

"""
    GrB_Monoid_new(monoid, binary_op, identity)

Initialize a GraphBLAS monoid with specified binary operator and identity value.
"""
function GrB_Monoid_new(monoid::GrB_Monoid, binary_op::GrB_BinaryOp, identity::T) where T
    monoid_ptr = pointer_from_objref(monoid)
    fn_name = "GrB_Monoid_new_" * suffix(T)

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, fn_name),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t),
                    monoid_ptr, binary_op.p, identity
                )
            )
end

function GrB_Monoid_new(monoid::GrB_Monoid, binary_op::GrB_BinaryOp, identity::UInt64)
    monoid_ptr = pointer_from_objref(monoid)
    fn_name = "GrB_Monoid_new_UINT64"
    
    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, fn_name),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t),
                    monoid_ptr, binary_op.p, identity
                )
            )
end

function GrB_Monoid_new(monoid::GrB_Monoid, binary_op::GrB_BinaryOp, identity::Float32)
    monoid_ptr = pointer_from_objref(monoid)
    fn_name = "GrB_Monoid_new_FP32"

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, fn_name),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Cfloat),
                    monoid_ptr, binary_op.p, identity
                )
            )
end

function GrB_Monoid_new(monoid::GrB_Monoid, binary_op::GrB_BinaryOp, identity::Float64)
    monoid_ptr = pointer_from_objref(monoid)
    fn_name = "GrB_Monoid_new_FP64"

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, fn_name),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Cdouble),
                    monoid_ptr, binary_op.p, identity
                )
            )
end

"""
    GrB_Semiring_new(semiring, monoid, binary_op)

Initialize a GraphBLAS semiring with specified monoid and binary operator.
"""
function GrB_Semiring_new(semiring::GrB_Semiring, monoid::GrB_Monoid, binary_op::GrB_BinaryOp)
    semiring_ptr = pointer_from_objref(semiring)

    return GrB_Info(
            ccall(
                    dlsym(graphblas_lib, "GrB_Semiring_new"),
                    Cint,
                    (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}),
                    semiring_ptr, monoid.p, binary_op.p
                )
            )
end
