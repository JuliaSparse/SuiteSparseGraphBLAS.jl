import GraphBLASInterface:
        GrB_free, GrB_UnaryOp_free, GrB_BinaryOp_free, GrB_Monoid_free, 
        GrB_Semiring_free, GrB_Vector_free, GrB_Matrix_free, GrB_Descriptor_free

"""
    GrB_free(object)

Generic method to free a GraphBLAS object.

# Examples
```jldoctest
julia> using GraphBLASInterface, SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> w = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> I = ZeroBasedIndex[0, 2, 4]; X = [10, 20, 30]; n = 3;

julia> GrB_Vector_new(w, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_build(w, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

5x1 GraphBLAS int64_t vector, sparse by col:
w, 3 entries

    (0,0)   10
    (2,0)   20
    (4,0)   30


julia> GrB_free(w)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_fprint(w, GxB_COMPLETE)

GraphBLAS vector: w NULL
```
"""
function GrB_free end

"""
    GrB_UnaryOp_free(unaryop)

Free unary operator.
"""
function GrB_UnaryOp_free(unaryop::GrB_UnaryOp)
    unaryop_ptr = pointer_from_objref(unaryop)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_UnaryOp_free"),
                Cint,
                (Ptr{Cvoid}, ),
                unaryop_ptr
            )
        )
end

"""
    GrB_BinaryOp_free(binaryop)

Free binary operator.
"""
function GrB_BinaryOp_free(binaryop::GrB_BinaryOp)
    binaryop_ptr = pointer_from_objref(binaryop)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_BinaryOp_free"),
                Cint,
                (Ptr{Cvoid}, ),
                binaryop_ptr
            )
        )
end

"""
    GrB_Monoid_free(monoid)

Free monoid.
"""
function GrB_Monoid_free(monoid::GrB_Monoid)
    monoid_ptr = pointer_from_objref(monoid)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Monoid_free"),
                Cint,
                (Ptr{Cvoid}, ),
                monoid_ptr
            )
        )
end

"""
    GrB_Semiring_free(semiring)

Free semiring.
"""
function GrB_Semiring_free(semiring::GrB_Semiring)
    semiring_ptr = pointer_from_objref(semiring)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Semiring_free"),
                Cint,
                (Ptr{Cvoid}, ),
                semiring_ptr
            )
        )
end

"""
    GrB_Vector_free(v)

Free vector.
"""
function GrB_Vector_free(v::GrB_Vector)
    v_ptr = pointer_from_objref(v)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Vector_free"),
                Cint,
                (Ptr{Cvoid}, ),
                v_ptr
            )
        )
end

"""
    GrB_Matrix_free(A)

Free matrix.
"""
function GrB_Matrix_free(A::GrB_Matrix)
    A_ptr = pointer_from_objref(A)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_free"),
                Cint,
                (Ptr{Cvoid}, ),
                A_ptr
            )
        )
end

"""
    GrB_Descriptor_free(desc)

Free descriptor.
"""
function GrB_Descriptor_free(desc::GrB_Descriptor)
    desc_ptr = pointer_from_objref(desc)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Descriptor_free"),
                Cint,
                (Ptr{Cvoid}, ),
                desc_ptr
            )
        )
end
