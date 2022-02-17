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
    libgb.GB_UnaryOp_new(opref, unaryopfn_C, toGBType(Z), toGBType(X), string(fn))
    return TypedUnaryOperator{X, Z}(false, true, string(fn), opref[])
end

function Base.unsafe_convert(::Type{libgb.GrB_UnaryOp}, op::TypedUnaryOperator)
    # We can lazily load the built-ins since they are already constants. 
    # Could potentially do this with UDFs, but probably not worth the effort.
    if op.builtin && !op.loaded
        op.p = load_global(op.typestr, libgb.GrB_UnaryOp)
        op.loaded = true
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end
mutable struct TypedBinaryOperator{X, Y, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    p::libgb.GrB_BinaryOp
    function TypedBinaryOperator{X, Y, Z}(builtin, loaded, typestr, p) where {X, Y, Z}
        binop = new(builtin, loaded, typestr, p)
        return finalizer(binop) do op
            libgb.GrB_BinaryOp_free(Ref(op.p))
        end
    end
end
function TypedBinaryOperator(fn::Function, ::Type{X}, ::Type{Y} ::Type{Z}) where {X, Y, Z}
    function binaryopfn(z, x, y)
        unsafe_store!(z, fn(x, y))
        return nothing
    end
    opref = Ref{libgb.GrB_BinaryOp}()
    binaryopfn_C = @cfunction($binaryopfn, Cvoid, (Ptr{Z}, Ref{X}, Ref{Y}))
    libgb.GB_BinaryOp_new(opref, binaryopfn_C, toGBType(Z), toGBType(X), toGBType(Y), string(fn))
    return TypedBinaryOperator{X, Y, Z}(false, true, string(fn), opref[])
end

function Base.unsafe_convert(::Type{libgb.GrB_BinaryOp}, op::TypedBinaryOperator)
    # We can lazily load the built-ins since they are already constants. 
    # Could potentially do this with UDFs, but probably not worth the effort.
    if op.builtin && !op.loaded
        op.p = load_global(op.typestr, libgb.GrB_UnaryOp)
        op.loaded = true
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end

mutable struct TypedMonoid{Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GrB_PLUS_FP64, if not it's just some user defined string.
    p::libgb.GrB_Monoid
    binaryop::libgb.GrB_BinaryOp{Z, Z, Z}
    function TypedMonoid{Z}(builtin, loaded, typestr, p, binaryop::TypedBinaryOperator{Z, Z, Z})
        monoid = new(builtin, loaded, typestr, p, binaryop)
        return finalizer(monoid) do op
            libgb.GrB_Monoid_free(Ref(op.p))
        end
    end
end

# We do this AoT because we need to know whether there's a terminal or not.
function _builtinMonoid(typestr, binaryop::TypedBinaryOperator{Z, Z, Z}) where {Z}
    p = load_global(typestr, libgb.GrB_Monoid)
    return TypedMonoid{Z}(true, true, typestr, p, binaryop)
end

function TypedMonoid(binop::TypedBinaryOperator{Z, Z, Z}, identity::Z, terminal::T) where {Z, T<:Union{Z, Nothing}}
    opref = Ref{libgb.GrB_Monoid}()
    if terminal === nothing
        if Z ∈ valid_union
            libgb.monoididnew[Z](opref, binop, identity)
        else
            libgb.monoididnew[Any](opref, binop, Ref(identity))
        end
    else
        if Z ∈ valid_union
            libgb.monoidtermnew[Z](opref, binop, identity, terminal)
        else
            libgb.monoidtermnew[Any](opref, binop, Ref(identity), Ref(terminal))
        end
    end
    return TypedMonoid{Z}(false, true, string(fn), opref[])
end

# These are sort of ugly...
TypedMonoid(binop::TypedBinaryOperator{Z, Z, Z}, identity::Function) where {Z} = TypedMonoid(binop, identity(Z))
TypedMonoid(binop::TypedBinaryOperator{Z, Z, Z}, identity::Function, terminal::Function) where {Z} = TypedMonoid(binop, identity(Z), terminal(Z))

TypedMonoid(binop::TypedBinaryOperator, identity) = TypedMonoid(binop, identity, nothing)

function Base.unsafe_convert(::Type{libgb.GrB_Monoid}, op::TypedMonoid) 
    return op.p
end

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
