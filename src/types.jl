mutable struct TypedUnaryOperator{F, X, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    p::LibGraphBLAS.GrB_UnaryOp
    fn::F
    function TypedUnaryOperator{F, X, Z}(builtin, loaded, typestr, p, fn) where {F, X, Z}
        unop = new(builtin, loaded, typestr, p, fn)
        return finalizer(unop) do op
            @wraperror LibGraphBLAS.GrB_UnaryOp_free(Ref(op.p))
        end
    end
end

function (op::TypedUnaryOperator{F, X, Z})(::Type{T}) where {F, X, Z, T}
    return op
end

function TypedUnaryOperator(fn::F, ::Type{X}, ::Type{Z}) where {F, X, Z}
    return TypedUnaryOperator{F, X, Z}(false, false, string(fn), LibGraphBLAS.GrB_UnaryOp(), fn)
end

function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_UnaryOp}, op::TypedUnaryOperator{F, X, Z}) where {F, X, Z}
    # We can lazily load the built-ins since they are already constants. 
    # Could potentially do this with UDFs, but probably not worth the effort.
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, LibGraphBLAS.GrB_UnaryOp)
            
        else
            fn = op.fn
            function unaryopfn(z, x)
                unsafe_store!(z, fn(x))
                return nothing
            end
            opref = Ref{LibGraphBLAS.GrB_UnaryOp}()
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
    p::LibGraphBLAS.GrB_BinaryOp
    fn::F
    function TypedBinaryOperator{F, X, Y, Z}(builtin, loaded, typestr, p, fn::F) where {F, X, Y, Z}
        binop = new(builtin, loaded, typestr, p, fn)
        return finalizer(binop) do op
            @wraperror LibGraphBLAS.GrB_BinaryOp_free(Ref(op.p))
        end
    end
end
function TypedBinaryOperator(fn::F, ::Type{X}, ::Type{Y}, ::Type{Z}) where {F, X, Y, Z}
    return TypedBinaryOperator{F, X, Y, Z}(false, false, string(fn), LibGraphBLAS.GrB_BinaryOp(), fn)
end

function (op::TypedBinaryOperator{F, X, Y, Z})(::Type{T1}, ::Type{T2}) where {F, X, Y, Z, T1, T2}
    return op
end
(op::TypedBinaryOperator)(T) = op(T, T)

function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_BinaryOp}, op::TypedBinaryOperator{F, X, Y, Z}) where {F, X, Y, Z}
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, LibGraphBLAS.GrB_UnaryOp)
        else
            fn = op.fn
            function binaryopfn(z, x, y)
                unsafe_store!(z, fn(x, y))
                return nothing
            end
            opref = Ref{LibGraphBLAS.GrB_BinaryOp}()
            binaryopfn_C = @cfunction($binaryopfn, Cvoid, (Ptr{Z}, Ref{X}, Ref{Y}))
            @wraperror LibGraphBLAS.GB_BinaryOp_new(opref, binaryopfn_C, gbtype(Z), gbtype(X), gbtype(Y), string(fn))
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
    p::LibGraphBLAS.GrB_Monoid
    binaryop::TypedBinaryOperator{F, Z, Z, Z}
    identity::Z
    terminal::T
    function TypedMonoid(builtin, loaded, typestr, p, binaryop::TypedBinaryOperator{F, Z, Z, Z}, identity::Z, terminal::T) where {F, Z, T<:Union{Z, Nothing}}
        monoid = new{F, Z, T}(builtin, loaded, typestr, p, binaryop, identity, terminal)
        return finalizer(monoid) do op
            @wraperror LibGraphBLAS.GrB_Monoid_free(Ref(op.p))
        end
    end
end

function (op::TypedMonoid{F, Z, T})(::Type{X}) where {F, X, Z, T}
    return op
end

for Z ∈ valid_vec
    if Z ∈ gxb_vec
        prefix = :GxB
    else
        prefix = :GrB
    end
    # Build functions
    func = Symbol(prefix, :_Monoid_new_, suffix(Z))
    functerm = Symbol(:GxB_Monoid_terminal_new_, suffix(Z))
    @eval begin
        function _monoidnew!(op::TypedMonoid{F, $Z, T}) where {F, T}
            opref = Ref{LibGraphBLAS.GrB_Monoid}()
            if op.terminal === nothing
                if Z ∈ valid_union
                    @wraperror LibGraphBLAS.$func(opref, op.binop, op.identity)
                else
                    @wraperror LibGraphBLAS.GrB_Monoid_new_UDT(opref, op.binop, Ref(op.identity))
                end
            else
                if Z ∈ valid_union
                    @wraperror LibGraphBLAS.$functerm(opref, op.binop, op.identity, op.terminal)
                else
                    @wraperror LibGraphBLAS.GrB_Monoid_terminal_new_UDT(opref, op.binop, Ref(op.identity), Ref(op.terminal))
                end
            end
            op.p = opref[]
        end
    end
end
function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Monoid}, op::TypedMonoid{F, Z, T}) where {F, Z, T}
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, LibGraphBLAS.GrB_Monoid)
        else
            _monoidnew!(op)
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
    return TypedMonoid(true, false, typestr, LibGraphBLAS.GrB_Monoid(), binaryop, identity, terminal)
end

function TypedMonoid(binop::TypedBinaryOperator{F, Z, Z, Z}, identity::Z, terminal::T) where {F, Z, T}
    return TypedMonoid(false, false, string(binop.fn), LibGraphBLAS.GrB_Monoid(), binop, identity, terminal)
end

#Enable use of functions for determining identity and terminal values. Could likely be pared down to 2 functions somehow.
TypedMonoid(builtin, loaded, typestr, p, binaryop::TypedBinaryOperator{F, Z, Z, Z}, identity::Function, terminal::Function) where {F, Z} =
    TypedMonoid(builtin, loaded, typestr, p, binaryop, identity(Z), terminal(Z))

TypedMonoid(builtin, loaded, typestr, p, binaryop::TypedBinaryOperator{F, Z, Z, Z}, identity::Function, terminal::Nothing) where {F, Z} =
    TypedMonoid(builtin, loaded, typestr, p, binaryop, identity(Z), terminal)

TypedMonoid(binop::TypedBinaryOperator{F, Z, Z, Z}, identity::Function) where {F, Z} = TypedMonoid(binop, identity(Z))
TypedMonoid(binop::TypedBinaryOperator{F, Z, Z, Z}, identity::Function, terminal::Function) where {F, Z} = TypedMonoid(binop, identity(Z), terminal(Z))
TypedMonoid(binop::TypedBinaryOperator{F, Z, Z, Z}, identity::Function, terminal::Nothing) where {F, Z} = TypedMonoid(binop, identity(Z), terminal)

TypedMonoid(binop::TypedBinaryOperator, identity) = TypedMonoid(binop, identity, nothing)

mutable struct TypedSemiring{FA, FM, X, Y, Z, T} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String
    p::LibGraphBLAS.GrB_Semiring
    addop::TypedMonoid{FA, Z, T}
    mulop::TypedBinaryOperator{FM, X, Y, Z}
    function TypedSemiring(builtin, loaded, typestr, p, addop::TypedMonoid{FA, Z, T}, mulop::TypedBinaryOperator{FM, X, Y, Z}) where {FA, FM, X, Y, Z, T}
        semiring = new{FA, FM, X, Y, Z, T}(builtin, loaded, typestr, p, addop, mulop)
        return finalizer(semiring) do rig
            @wraperror LibGraphBLAS.GrB_Semiring_free(Ref(rig.p))
        end
    end
end


function (op::TypedSemiring{FA, FM, X, Y, Z, T})(::Type{T1}, ::Type{T2}) where {FA, FM, X, Y, Z, T, T1, T2}
    return op
end

function Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Semiring}, op::TypedSemiring)
    if !op.loaded
        if op.builtin
            op.p = load_global(op.typestr, LibGraphBLAS.GrB_Semiring)
        else
            opref = Ref{LibGraphBLAS.GrB_Semiring}()
            @wraperror LibGraphBLAS.GrB_Semiring_new(opref, op.addop, op.mulop)
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

TypedSemiring(addop, mulop) = TypedSemiring(false, false, "", LibGraphBLAS.GrB_Semiring(), addop, mulop)

"""
"""
mutable struct GBScalar{T}
    p::LibGraphBLAS.GxB_Scalar
    function GBScalar{T}(p::LibGraphBLAS.GxB_Scalar) where {T}
        s = new(p)
        function f(scalar)
            @wraperror LibGraphBLAS.GxB_Scalar_free(Ref(scalar.p))
        end
        return finalizer(f, s)
    end
end

"""
    GBVector{T, F} <: AbstractSparseArray{T, UInt64, 1}

One-dimensional GraphBLAS array with elements of type T. `F` is the type of the fill-value, 
which is typically `Nothing` or `T`. 
Internal representation is specified as opaque, but may be either a dense vector, bitmap vector, or 
compressed sparse vector.

See also: [`GBMatrix`](@ref).
"""
mutable struct GBVector{T, F} <: AbstractGBVector{T, F}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix} # a GBVector is a GBMatrix internally.
    fill::F
end

"""
    GBMatrix{T, F} <: AbstractSparseArray{T, UInt64, 2}

Two-dimensional GraphBLAS array with elements of type `T`. `F` is the type of the fill-value, 
which is typically `Nothing` or `T`. 
Internal representation is specified as opaque, but in this implementation is stored as one of 
the following in either row or column orientation:

    1. Dense
    2. Bitmap
    3. Sparse Compressed
    4. Hypersparse

The storage type is automatically determined by the library.
"""
mutable struct GBMatrix{T, F} <: AbstractGBMatrix{T, F}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    fill::F
end

# Most likely this will be the case for all AbstractGBArray.
# However, if one (for some reason) wraps another AbstractGBArray
# this should be overloaded.
gbpointer(A::AbstractGBArray) = A.p[]

# We need to do this at runtime. This should perhaps be `RuntimeOrder`, but that trait should likely be removed.
# This should ideally work out fine. a GBMatrix or GBVector won't have 
StorageOrders.storageorder(A::AbstractGBMatrix) = gbget(A, :format) == Integer(BYCOL) ? StorageOrders.ColMajor() : StorageOrders.RowMajor()
StorageOrders.storageorder(A::AbstractGBVector) = ColMajor()