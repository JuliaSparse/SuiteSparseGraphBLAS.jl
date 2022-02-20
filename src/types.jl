mutable struct TypedUnaryOperator{F, X, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    p::libgb.GrB_UnaryOp
    fn::F
    function TypedUnaryOperator{F, X, Z}(builtin, loaded, typestr, p, fn) where {F, X, Z}
        unop = new(builtin, loaded, typestr, p, fn)
        return finalizer(unop) do op
            libgb.GrB_UnaryOp_free(Ref(op.p))
        end
    end
end

function TypedUnaryOperator(fn::F, ::Type{X}, ::Type{Z}) where {F, X, Z}
    return TypedUnaryOperator{F, X, Z}(false, false, string(fn), libgb.GrB_UnaryOp(), fn)
end

function Base.unsafe_convert(::Type{libgb.GrB_UnaryOp}, op::TypedUnaryOperator{F, X, Z}) where {F, X, Z}
    # We can lazily load the built-ins since they are already constants. 
    # Could potentially do this with UDFs, but probably not worth the effort.
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, libgb.GrB_UnaryOp)
            
        else
            fn = op.fn
            function unaryopfn(z, x)
                unsafe_store!(z, fn(x))
                return nothing
            end
            opref = Ref{libgb.GrB_UnaryOp}()
            unaryopfn_C = @cfunction($unaryopfn, Cvoid, (Ptr{Z}, Ref{X}))
            # the "" below is a placeholder for C code in the future for JIT'ing. (And maybe compiled code as a ptr :pray:?)
            LibGraphBLAS.GxB_UnaryOp_new(opref, unaryopfn_C, gbtype(Z), gbtype(X), string(fn), "")
            op.p = opref[]
        end
        op.loaded = true
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end

mutable struct TypedBinaryOperator{F, X, Y, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    p::libgb.GrB_BinaryOp
    fn::F
    function TypedBinaryOperator{F, X, Y, Z}(builtin, loaded, typestr, p, fn::F) where {F, X, Y, Z}
        binop = new(builtin, loaded, typestr, p, fn)
        return finalizer(binop) do op
            libgb.GrB_BinaryOp_free(Ref(op.p))
        end
    end
end
function TypedBinaryOperator(fn::F, ::Type{X}, ::Type{Y}, ::Type{Z}) where {F, X, Y, Z}
    return TypedBinaryOperator{F, X, Y, Z}(false, false, string(fn), libgb.GrB_BinaryOp(), fn)
end

function Base.unsafe_convert(::Type{libgb.GrB_BinaryOp}, op::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z}
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, libgb.GrB_UnaryOp)
        else
            fn = op.fn
            function binaryopfn(z, x, y)
                unsafe_store!(z, fn(x, y))
                return nothing
            end
            opref = Ref{libgb.GrB_BinaryOp}()
            binaryopfn_C = @cfunction($binaryopfn, Cvoid, (Ptr{Z}, Ref{X}, Ref{Y}))
            libgb.GB_BinaryOp_new(opref, binaryopfn_C, gbtype(Z), gbtype(X), gbtype(Y), string(fn))
            op.p = opref[]
        end
        op.loaded = true
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end

mutable struct TypedMonoid{F, Z, T} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GrB_PLUS_FP64, if not it's just some user defined string.
    p::libgb.GrB_Monoid
    binaryop::TypedBinaryOperator{F, Z, Z, Z}
    identity::Z
    terminal::T
    function TypedMonoid(builtin, loaded, typestr, p, binaryop::TypedBinaryOperator{F, Z, Z, Z}, identity::Z, terminal::T) where {F, Z, T<:Union{Z, Nothing}}
        monoid = new{F, Z, T}(builtin, loaded, typestr, p, binaryop, identity, terminal)
        return finalizer(monoid) do op
            libgb.GrB_Monoid_free(Ref(op.p))
        end
    end
end

function Base.unsafe_convert(::Type{libgb.GrB_Monoid}, op::TypedMonoid{Z, T}) where {Z, T}
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, libgb.GrB_Monoid)
        else
            opref = Ref{libgb.GrB_Monoid}()
            if op.terminal === nothing
                if Z ∈ valid_union
                    libgb.monoididnew[Z](opref, op.binop, op.identity)
                else
                    libgb.monoididnew[Any](opref, op.binop, Ref(op.identity))
                end
            else
                if Z ∈ valid_union
                    libgb.monoidtermnew[Z](opref, op.binop, op.identity, op.terminal)
                else
                    libgb.monoidtermnew[Any](opref, op.binop, Ref(op.identity), Ref(op.terminal))
                end
            end
            op.p = opref[]
        end
        op.loaded = true
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end

function _builtinMonoid(typestr, binaryop::TypedBinaryOperator{F, Z, Z, Z}, identity, terminal::T) where {F, Z, T}
    return TypedMonoid(true, false, typestr, libgb.GrB_Monoid(), binaryop, identity, terminal)
end

function TypedMonoid(binop::TypedBinaryOperator{F, Z, Z, Z}, identity::Z, terminal::T) where {F, Z, T}
    return TypedMonoid(false, false, string(fn), libgb.GrB_Monoid(), binop, identity, terminal)
end

#Enable use of functions for determining identity and terminal values. Could likely be pared down to 2 functions somehow.
TypedMonoid(builtin, loaded, typestr, p, binaryop::TypedBinaryOperator{F, Z, Z, Z}, identity::Function, terminal::Function) where {F, Z} =
    TypedMonoid(builtin, loaded, typestr, p, binaryop, identity(Z), terminal(Z))

TypedMonoid(builtin, loaded, typestr, p, binaryop::TypedBinaryOperator{F, Z, Z, Z}, identity::Function, terminal::Nothing) where {F, Z} =
    TypedMonoid(builtin, loaded, typestr, p, binaryop, identity(Z), terminal)

TypedMonoid(binop::TypedBinaryOperator{F, Z, Z, Z}, identity::Function) where {F, Z} = TypedMonoid(binop, identity(Z))
TypedMonoid(binop::TypedBinaryOperator{F, Z, Z, Z}, identity::Function, terminal::Function) where {F, Z} = TypedMonoid(binop, identity(Z), terminal(Z))

TypedMonoid(binop::TypedBinaryOperator, identity) = TypedMonoid(binop, identity, nothing)

mutable struct TypedSemiring{FA, FM, X, Y, Z, T} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String
    p::libgb.GrB_Semiring
    addop::TypedMonoid{FA, Z, T}
    mulop::TypedBinaryOperator{FM, X, Y, Z}
    function TypedSemiring(builtin, loaded, typestr, p, addop::TypedMonoid{FA, Z, T}, mulop::TypedBinaryOperator{FM, X, Y, Z}) where {FA, FM, X, Y, Z, T}
        semiring = new{FA, FM, X, Y, Z, T}(builtin, loaded, typestr, p, addop, mulop)
        return finalizer(semiring) do rig
            libgb.GrB_Semiring_free(Ref(rig.p))
        end
    end
end

function Base.unsafe_convert(::Type{libgb.GrB_Semiring}, op::TypedSemiring)
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, libgb.GrB_Semiring)
        else
            opref = Ref{libgb.GrB_Semiring}()
            libgb.GrB_Semiring_new(opref, op.addop, op.mulop)
            op.p = opref[]
        end
        op.loaded = true
    end
    if !op.loaded
        error("This operator could not be loaded, and is invalid.")
    else
        return op.p
    end
end

TypedSemiring(addop, mulop) = TypedSemiring(false, false, "", libgb.GrB_Semiring(), addop, mulop)

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
