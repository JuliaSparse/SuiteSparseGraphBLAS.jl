mutable struct TypedUnaryOperator{X, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    p::libgb.GrB_UnaryOp
    function TypedUnaryOperator{X, Z}(builtin, loaded, typestr, p) where {X, Z}
        unop = new(builtin, loaded, typestr, p)
        return finalizer(unop) do op
            libgb.GrB_UnaryOp_free(Ref(op.p))
        end
    end
end

function TypedUnaryOperator(fn::Function, ::Type{X}, ::Type{Z}) where {X, Z}
    function unaryopfn(z, x)
        unsafe_store!(z, fn(x))
        return nothing
    end
    opref = Ref{libgb.GrB_UnaryOp}()
    unaryopfn_C = @cfunction($unaryopfn, Cvoid, (Ptr{Z}, Ref{X}))
    libgb.GB_UnaryOp_new(opref, unaryopfn_C, toGBType(Z), toGBType(X))
    return TypedUnaryOperator{X, Z}(false, true, string(fn), opref[])
end

function Base.unsafe_convert(::Type{libgb.GrB_UnaryOp}, op::TypedUnaryOperator)
    # We can lazily load the built-ins since they are already constants. 
    # Could potentially do this with UDFs, but probably not worth the effort.
    if op.builtin && !op.loaded
        op.p = load_global(typestr, libgb.GrB_BinaryOp)
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end
mutable struct TypedBinaryOperator{X, Y, Z} <: AbstractTypedOp{Z}
    p::libgb.GrB_BinaryOp
    function TypedBinaryOperator{X, Y, Z}(p) where {X, Y, Z}
        binop = new(p)
        function f(op)
            libgb.GrB_BinaryOp_free(Ref(op.p))
        end
        return finalizer(f, binop)
    end
end
function TypedBinaryOperator(p::libgb.GrB_BinaryOp)
    return TypedBinaryOperator{xtype(p), ytype(p), ztype(p)}(p)
end
Base.unsafe_convert(::Type{libgb.GrB_BinaryOp}, op::TypedBinaryOperator) = op.p

mutable struct TypedMonoid{X, Y, Z} <: AbstractTypedOp{Z}
    p::libgb.GrB_Monoid
    function TypedMonoid{X, Y, Z}(p) where {X, Y, Z}
        monoid = new(p)
        function f(m)
            libgb.GrB_Monoid_free(Ref(m.p))
        end
        return finalizer(f, monoid)
    end
end
function TypedMonoid(p::libgb.GrB_Monoid)
    return TypedMonoid{xtype(p), ytype(p), ztype(p)}(p)
end
Base.unsafe_convert(::Type{libgb.GrB_Monoid}, op::TypedMonoid) = op.p

mutable struct TypedSemiring{X, Y, Z} <: AbstractTypedOp{Z}
    p::libgb.GrB_Semiring
    function TypedSemiring{X, Y, Z}(p) where {X, Y, Z}
        semiring = new(p)
        function f(rig)
            libgb.GrB_Semiring_free(Ref(rig.p))
        end
        return finalizer(f, semiring)
    end
end
function TypedSemiring(p::libgb.GrB_Semiring)
    return TypedSemiring{xtype(p), ytype(p), ztype(p)}(p)
end
Base.unsafe_convert(::Type{libgb.GrB_Semiring}, op::TypedSemiring) = op.p


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
    p::libgb.GrB_Matrix
    function GBVector{T}(p::libgb.GrB_Matrix) where {T}
        v = new(p)
        function f(vector)
            libgb.GrB_Matrix_free(Ref(vector.p))
        end
        return finalizer(f, v)
    end
end

"""
    GBMatrix{T} <: AbstractSparseArray{T, UInt64, 2}

Two-dimensional GraphBLAS array with elements of type T. Internal representation is
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
