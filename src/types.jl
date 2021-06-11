"""
Automatically generated type definitions. The struct definitions for
built in monoids, binary ops, etc can be found here.
"""
module Types
    import ...SuiteSparseGraphBLAS: AbstractUnaryOp, AbstractMonoid, AbstractSelectOp,
    AbstractSemiring, AbstractBinaryOp, AbstractDescriptor
    using ..libgb
end

"""
"""
mutable struct GBScalar{T}
    p::libgb.GxB_Scalar
    function GBScalar{T}(p::libgb.GxB_Scalar) where {T}
        s = new(p)
        function f(scalar)
            libgb.GxB_Scalar_free(Ref(scalar.p))
        end
        return finalizer(f, s)
    end
end

"""
    GBVector{T} <: AbstractSparseArray{T, UInt64, 1}

One-dimensional GraphBLAS array with elements of type T. Internal representation is
specified as opaque, but may be either a dense array, bitmap array, or
compressed sparse vector.

See also: [`GBMatrix`](@ref).
"""
mutable struct GBVector{T} <: AbstractSparseArray{T, UInt64, 1}
    p::libgb.GrB_Vector
    function GBVector{T}(p::libgb.GrB_Vector) where {T}
        v = new(p)
        function f(vector)
            libgb.GrB_Vector_free(Ref(vector.p))
        end
        return finalizer(f, v)
    end
end

"""
    GBMatrix{T} <: AbstractSparseArray{T, UInt64, 2}

TWo-dimensional GraphBLAS array with elements of type T. Internal representation is
specified as opaque, but in this implementation is stored as one of the following in either
row or column orientation:

    1. Dense
    2. Bitmap
    3. Sparse Compressed
    4. Hypersparse

The storage type is automatically determined by the library.
"""
mutable struct GBMatrix{T} <: AbstractSparseArray{T, UInt64, 2}
    p::libgb.GrB_Matrix
    function GBMatrix{T}(p::libgb.GrB_Matrix) where {T}
        A = new(p)
        function f(matrix)
            libgb.GrB_Matrix_free(Ref(matrix.p))
        end
        return finalizer(f, A)
    end
end
