abstract type AbstractSparsity end
struct Dense <: AbstractSparsity end
struct Bytemap <: AbstractSparsity end
struct Sparse <: AbstractSparsity end
struct Hypersparse <: AbstractSparsity end

mutable struct TypedUnaryOperator{F, X, Z} <: AbstractTypedOp{Z}
    builtin::Bool
    loaded::Bool
    typestr::String # If a built-in this is something like GxB_AINV_FP64, if not it's just some user defined string.
    p::LibGraphBLAS.GrB_UnaryOp
    fn::F
    keepalive::Any
    function TypedUnaryOperator{F, X, Z}(builtin, loaded, typestr, p, fn) where {F, X, Z}
        unop = new(builtin, loaded, typestr, p, fn, nothing)
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

function TypedUnaryOperator(fn::F, ::Type{X}) where {F, X}
    return TypedUnaryOperator(fn, X, Base._return_type(fn, Tuple{X}))
end

@generated function cunary(f::F, ::Type{X}, ::Type{Z}) where {F, X, Z}
    if Base.issingletontype(F)
        :(@cfunction($(F.instance), Cvoid, (Ptr{Z}, Ref{X})))
    else
        throw("Unsupported function $f. Closure functions are not supported.")
    end
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
            unaryopfn_C = cunary(unaryopfn, X, Z)
            op.keepalive = (unaryopfn, unaryopfn_C)
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
    keepalive::Any
    function TypedBinaryOperator{F, X, Y, Z}(builtin, loaded, typestr, p, fn::F) where {F, X, Y, Z}
        binop = new(builtin, loaded, typestr, p, fn, nothing)
        return finalizer(binop) do op
            @wraperror LibGraphBLAS.GrB_BinaryOp_free(Ref(op.p))
        end
    end
end
function TypedBinaryOperator(fn::F, ::Type{X}, ::Type{Y}, ::Type{Z}) where {F, X, Y, Z}
    return TypedBinaryOperator{F, X, Y, Z}(false, false, string(fn), LibGraphBLAS.GrB_BinaryOp(), fn)
end

function TypedBinaryOperator(fn::F, ::Type{X}, ::Type{Y}) where {F, X, Y}
    return TypedBinaryOperator(fn, X, Y, Base._return_type(fn, Tuple{X, Y}))
end

function (op::TypedBinaryOperator{F, X, Y, Z})(::Type{T1}, ::Type{T2}) where {F, X, Y, Z, T1, T2}
    return op
end
(op::TypedBinaryOperator)(T) = op(T, T)

@generated function cbinary(f::F, ::Type{X}, ::Type{Y}, ::Type{Z}) where {F, X, Y, Z}
    if Base.issingletontype(F)
        :(@cfunction($(F.instance), Cvoid, (Ptr{Z}, Ref{X}, Ref{Y})))
    else
        throw("Unsupported function $f")
    end
end

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
            binaryopfn_C = cbinary(binaryopfn, X, Y, Z)
            op.keepalive = (binaryopfn, binaryopfn_C)
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

binaryop(m::TypedMonoid) = m.binaryop

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
                @wraperror LibGraphBLAS.$func(opref, op.binaryop, op.identity)
            else
                @wraperror LibGraphBLAS.$functerm(opref, op.binaryop, op.identity, op.terminal)
            end
            op.p = opref[]
        end
    end
end

function _monoidnew!(op::TypedMonoid{F, Z, T}) where {F, Z, T}
    opref = Ref{LibGraphBLAS.GrB_Monoid}()
    if op.terminal === nothing
        @wraperror LibGraphBLAS.GrB_Monoid_new_UDT(opref, op.binaryop, Ref(op.identity))
    else
        @wraperror LibGraphBLAS.GxB_Monoid_terminal_new_UDT(opref, op.binaryop, Ref(op.identity), Ref(op.terminal))
    end
    op.p = opref[]
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

# TODO: Determine TERMINAL::T, T ∈ Z always, or if T can be outside Z.
function _builtinMonoid(typestr, binaryop::TypedBinaryOperator{F, Z, Z, Z}, identity, terminal::T) where {F, Z, T}
    return TypedMonoid(true, false, typestr, LibGraphBLAS.GrB_Monoid(), binaryop, identity, terminal)
end

function TypedMonoid(binop::TypedBinaryOperator{F, Z, Z, Z}, identity::Z, terminal::T) where {F, Z, T}
    return TypedMonoid(false, false, string(binop.fn), LibGraphBLAS.GrB_Monoid(), binop, identity, terminal)
end

function TypedMonoid(binop::TypedBinaryOperator{F, Z, Z, Z}, identity, terminal::T) where {F, Z, T}
    return TypedMonoid(false, false, string(binop.fn), LibGraphBLAS.GrB_Monoid(), binop, convert(Z, identity), terminal)
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

binaryop(s::TypedSemiring) = s.mulop
monoid(s::TypedSemiring) = s.addop
binaryop(s::Tuple) = s[2]
monoid(s::Tuple) = s[1]

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
    _newGrBRef()::Ref{LibGraphBLAS.GrB_Matrix}

Create a reference to a `GrB_Matrix` and attach a finalizer.
"""
_newGrBRef() = finalizer(Ref{LibGraphBLAS.GrB_Matrix}()) do ref
    @wraperror LibGraphBLAS.GrB_Matrix_free(ref)
end

"""
    _copyGrBMat(r::RefValue{LibGraphBLAS.GrB_Matrix})

copy `r` to a new Ref. This copy shares nothing with `r`.
"""
function _copyGrBMat(r::Base.RefValue{LibGraphBLAS.GrB_Matrix})
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, r[])
    return finalizer(C) do ref
        @wraperror LibGraphBLAS.GrB_Matrix_free(ref)
    end
end


"""
    @gbmatrixtype <typename>

Automatically define the basic AbstractGBMatrix interface constructors.
"""
macro gbmatrixtype(typename)
    esc(quote
        # Empty Constructors:
        function $typename{T, F}(nrows::Integer, ncols::Integer; fill = defaultfill(F)) where {T, F}
            ((F === Nothing) || (F === Missing) || (T === F)) || 
                throw(ArgumentError("Fill type $F must be <: Union{Nothing, Missing, $T}"))
            m = _newGrBRef()
            @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), nrows, ncols)
            return $typename{T, F}(m; fill)
        end
        $typename{T}(nrows::Integer, ncols::Integer; fill::F = defaultfill(T)) where {T, F} =
            $typename{T, F}(nrows, ncols; fill)

        $typename{T, F}(dims::D; fill = defaultfill(F)) where {T, F, D<:Union{Dims{2}, Tuple{<:Integer, <:Integer}}} = 
            $typename{T, F}(dims...; fill)
        $typename{T}(dims::Dims{2}; fill::F = defaultfill(T)) where {T, F} = $typename{T, F}(dims...; fill)
        $typename{T}(dims::Tuple{<:Integer, <:Integer}; fill::F = defaultfill(T)) where {T, F} = $typename{T, F}(dims...; fill)

        $typename{T, F}(size::Tuple{Base.OneTo, Base.OneTo}; fill = defaultfill(F)) where {T, F} =
            $typename{T, F}(size[1].stop, size[2].stop; fill)
        $typename{T}(size::Tuple{Base.OneTo, Base.OneTo}; fill::F = defaultfill(T)) where {T, F} =
            $typename{T, F}(size; fill)
        
        # Coordinate Form Constructors:
        function $typename{T, F}(
            I::AbstractVector, J::AbstractVector, X::AbstractVector{T2}, nrows, ncols;
            combine = +, fill = defaultfill(F)
        ) where {T, F, T2}
            I isa Vector || (I = collect(I))
            J isa Vector || (J = collect(J))
            (T2 == T && X isa DenseVector) || (X = convert(Vector{T2}, X))
            A = $typename{T, F}(nrows, ncols; fill)
            build!(A, I, J, X; combine)
            return A
        end
        $typename{T, F}(
            I::AbstractVector, J::AbstractVector, X::AbstractVector{T2};
            combine = +, fill = defaultfill(F)
        ) where {T, F, T2} = $typename{T, F}(I, J, X, maximum(I), maximum(J); combine, fill)
        
        function $typename{T}(
            I::AbstractVector, J::AbstractVector, X::AbstractVector,
            nrows, ncols; combine = +, fill::F = defaultfill(T)
        ) where {T, F}
            return $typename{T, F}(I, J, X, nrows, ncols; combine, fill)
        end
        $typename{T}(
            I::AbstractVector, J::AbstractVector, X::AbstractVector;
            combine = +, fill = defaultfill(T)
        ) where {T} = $typename{T}(I, J, X, maximum(I), maximum(J); combine, fill)
        
        $typename(
            I::AbstractVector, J::AbstractVector, X::AbstractVector{T}, nrows, ncols;
            combine = +, fill = defaultfill(T)
        ) where T = $typename{T}(I, J, X, nrows, ncols; combine, fill)
        $typename(
            I::AbstractVector, J::AbstractVector, X::AbstractVector{T};
            combine = +, fill = defaultfill(T)
        ) where {T} = $typename{T}(I, J, X; combine, fill)

        # ISO constructors:
        function $typename{T, F}(
            I::AbstractVector, J::AbstractVector, x, 
            nrows, ncols; fill = defaultfill(F)
        ) where {T, F}
            A = $typename{T, F}(nrows, ncols; fill)
            build!(A, I, J, convert(T, x))
            return A
        end
        $typename{T, F}(
            I::AbstractVector, J::AbstractVector, x;
            fill = defaultfill(F)
        ) where {T, F} = $typename{T, F}(I, J, x, maximum(I), maximum(J); fill)
        
        function $typename{T}(
            I::AbstractVector, J::AbstractVector, x, nrows, ncols;
            fill::F = defaultfill(T)
        ) where {T, F}
            return $typename{T, F}(I, J, x, nrows, ncols; fill)
        end
        $typename{T}(
            I::AbstractVector, J::AbstractVector, x; fill = defaultfill(T)
        ) where {T} = $typename{T}(I, J, x, maximum(I), maximum(J); fill)
        
        function $typename(
            I::AbstractVector, J::AbstractVector, x::T, nrows, ncols;
            fill = defaultfill(T)) where {T}
            $typename{T}(I, J, x, nrows, ncols; fill)
        end
        $typename(I::AbstractVector, J::AbstractVector, x::T; fill = defaultfill(T)) where T = 
            $typename{T}(I, J, x, maximum(I), maximum(J); fill)
        
        function $typename{T, F}(dims::Dims{2}, x; fill = defaultfill(F)) where {T, F}
            A = $typename{T, F}(dims; fill)
            A .= x
            return A
        end
        $typename{T}(dims::Dims{2}, x; fill::F = defaultfill(T)) where {T, F} = 
            $typename{T, F}(dims, x; fill)
        $typename(dims::Dims{2}, x::T; fill = defaultfill(T)) where T = 
            $typename{T}(dims, x, fill)
        
        $typename(nrows, ncols, x::T; fill = defaultfill(T)) where T = 
            $typename{T}((nrows, ncols), x; fill)
        $typename(dims::Tuple{<:Integer}, x::T; fill = defaultfill(T)) where T = 
            $typename{T}(dims..., x; fill)
        $typename(size::Tuple{Base.OneTo, Base.OneTo}, x::T; fill = defaultfill(T)) where T = 
            $typename{T}(size[1].stop, size[2].stop, x; fill)
        
        function $typename{T, F}(v::AbstractGBVector; fill = getfill(v)) where {T, F}
            return convert($typename{T, F}, v; fill)
        end
        function $typename{T}(v::AbstractGBVector; fill::F = getfill(v)) where {T, F}
            return $typename{T, F}(v; fill)
        end

        # Pack based constructors:
        function $typename{T, F}(
            A::Union{<:AbstractVector, <:AbstractMatrix}; 
            fill = defaultfill(F)
        ) where {T, F}
            vpack = _sizedjlmalloc(length(A), T)
            vpack = unsafe_wrap(Array, vpack, size(A))
            copyto!(vpack, A)
            C = $typename{T, F}(size(A, 1), size(A, 2); fill)
            return unsafepack!(C, vpack, false; order = storageorder(A))
        end
        $typename{T}(
            A::Union{<:AbstractVector, <:AbstractMatrix}; 
            fill::F = defaultfill(T)
        ) where {T, F} = $typename{T, F}(A; fill)
        $typename(
            A::Union{<:AbstractVector{T}, <:AbstractMatrix{T}}; 
            fill::F = defaultfill(T)
        ) where {T, F} = $typename{T, F}(A; fill)

        # similar
        function Base.similar(
            A::$typename{T}, ::Type{TNew} = T,
            dims::Tuple{Int64, Vararg{Int64, N}} = size(A); fill::F = getfill(A)
        ) where {T, TNew, N, F}
            !(F <: Union{Nothing, Missing}) && (fill = convert(TNew, fill))
            if dims isa Dims{1}
                # TODO: When new Vector types are added this will be incorrect.
                x = GBVector{TNew}(dims...; fill)
            else
                x = $typename{TNew}(dims...; fill)
                _hasconstantorder(x) || setstorageorder!(x, storageorder(A))
            end
            return x
        end
        
        function Base.similar(A::$typename{T}, dims::Tuple; fill = getfill(A)) where T
            return similar(A, T, dims; fill)
        end
        
        function Base.similar(
            A::$typename, ::Type{TNew},
            dims::Integer; fill = getfill(A)
        ) where TNew
            return similar(A, TNew, (dims,); fill)
        end
        
        function Base.similar(
            A::$typename, ::Type{TNew},
            dim1::Integer, dim2::Integer; fill = getfill(A)
        ) where TNew
            return similar(A, TNew, (dim1, dim2); fill)
        end
        
        function Base.similar(
            A::$typename,
            dims::Integer; fill = getfill(A)
        )
            return similar(A, (dims,); fill)
        end
        
        function Base.similar(
            A::$typename,
            dim1::Integer, dim2::Integer; fill = getfill(A)
        )
            return similar(A, (dim1, dim2); fill)
        end
    end)
end

macro gbvectortype(typename)
    esc(quote
        function $typename{T, F}(n::Integer; fill = defaultfill(F)) where {T, F}
            ((F === Nothing) || (F === Missing) || (T === F)) || 
                throw(ArgumentError("Fill type $F must be <: Union{Nothing, Missing, $T}"))
            m = _newGrBRef()
            @wraperror LibGraphBLAS.GrB_Matrix_new(m, gbtype(T), n, 1)
            return $typename{T, F}(m; fill)
        end
        $typename{T}(n::Integer; fill::F = defaultfill(T)) where {T, F} = 
            $typename{T, F}(n; fill)
        
        $typename{T, F}(dims::D; fill = defaultfill(F)) where {T, F, D<:Union{Dims{1}, Tuple{<:Integer}}} = 
            $typename{T, F}(dims...; fill)
        $typename{T}(dims::Dims{1}; fill::F = defaultfill(T)) where {T, F} = $typename{T, F}(dims...; fill)
        $typename{T}(dims::Tuple{<:Integer}; fill::F = defaultfill(T)) where {T, F} = $typename{T, F}(dims...; fill)

        $typename{T, F}(size::Tuple{Base.OneTo}; fill = defaultfill(F)) where {T, F} =
            $typename{T, F}(size[1].stop; fill)
        $typename{T}(size::Tuple{Base.OneTo}; fill::F = defaultfill(T)) where {T, F} =
            $typename{T, F}(size; fill)
        
        function $typename{T, F}(
            I::AbstractVector, X::AbstractVector{T2}, n;
            combine = +, fill = defaultfill(F)
        ) where {T, F, T2}
            I isa Vector || (I = collect(I))
            (T2 == T && X isa DenseVector) || (X = convert(Vector{T2}, X))
            A = $typename{T, F}(n; fill)
            build!(A, I, X; combine)
            return A
        end
        $typename{T, F}(
            I::AbstractVector, X::AbstractVector{T2};
            combine = +, fill = defaultfill(F)
        ) where {T, F, T2} = $typename{T, F}(I, X, maximum(I); combine, fill)
        
        function $typename{T}(
            I::AbstractVector, X::AbstractVector,
            n; combine = +, fill::F = defaultfill(T)
        ) where {T, F}
            return $typename{T, F}(I, X, n; combine, fill)
        end
        $typename{T}(
            I::AbstractVector, X::AbstractVector;
            combine = +, fill = defaultfill(T)
        ) where {T} = $typename{T}(I, X, maximum(I); combine, fill)
        
        $typename(
            I::AbstractVector, X::AbstractVector{T}, n;
            combine = +, fill = defaultfill(T)
        ) where T = $typename{T}(I, X, n; combine, fill)
        $typename(
            I::AbstractVector, X::AbstractVector{T};
            combine = +, fill = defaultfill(T)
        ) where {T} = $typename{T}(I, X; combine, fill)

        function $typename{T, F}(
            I::AbstractVector, x, 
            n; fill = defaultfill(F)
        ) where {T, F}
            A = $typename{T, F}(n; fill)
            build!(A, I, convert(T, x))
            return A
        end
        $typename{T, F}(
            I::AbstractVector, x;
            fill = defaultfill(F)
        ) where {T, F} = $typename{T, F}(I, x, maximum(I); fill)
        
        function $typename{T}(
            I::AbstractVector, x, n;
            fill::F = defaultfill(T)
        ) where {T, F}
            return $typename{T, F}(I, x, n; fill)
        end
        $typename{T}(
            I::AbstractVector, x; fill = defaultfill(T)
        ) where {T} = $typename{T}(I, x, maximum(I); fill)
        
        function $typename(
            I::AbstractVector, x::T, n;
            fill = defaultfill(T)) where {T}
            $typename{T}(I, J, x, n; fill)
        end
        $typename(I::AbstractVector, x::T; fill = defaultfill(T)) where T = 
            $typename{T}(I, x, maximum(I); fill)
        
        function $typename{T, F}(dims::Dims{1}, x; fill = defaultfill(F)) where {T, F}
            A = $typename{T, F}(dims; fill)
            A .= x
            return A
        end
        $typename{T}(dims::Dims{1}, x; fill::F = defaultfill(T)) where {T, F} = 
            $typename{T, F}(dims, x; fill)
        $typename(dims::Dims{1}, x::T; fill = defaultfill(T)) where T = 
            $typename{T}(dims, x, fill)
        
        $typename(nrows, ncols, x::T; fill = defaultfill(T)) where T = 
            $typename{T}((nrows, ncols), x; fill)
        $typename(dims::Tuple{<:Integer}, x::T; fill = defaultfill(T)) where T = 
            $typename{T}(dims..., x; fill)
        $typename(size::Tuple{Base.OneTo, Base.OneTo}, x::T; fill = defaultfill(T)) where T = 
            $typename{T}(size[1].stop, size[2].stop, x; fill)
        
        function $typename{T, F}(v::AbstractGBVector; fill = getfill(v)) where {T, F}
            return convert($typename{T, F}, v; fill)
        end
        function $typename{T}(v::AbstractGBVector; fill::F = getfill(v)) where {T, F}
            return $typename{T, F}(v; fill)
        end

        # Pack based constructors:
        function $typename{T, F}(
            A::AbstractVector; 
            fill = defaultfill(F)
        ) where {T, F}
            vpack = _sizedjlmalloc(length(A), T)
            vpack = unsafe_wrap(Array, vpack, size(A))
            copyto!(vpack, A)
            C = $typename{T, F}(size(A); fill)
            return unsafepack!(C, vpack, false; order = storageorder(A))
        end
        $typename{T}(
            A::AbstractVector; 
            fill::F = defaultfill(T)
        ) where {T, F} = $typename{T, F}(A; fill)
        $typename(
            A::AbstractVector{T}; 
            fill::F = defaultfill(T)
        ) where {T, F} = $typename{T, F}(A; fill)

        function $typename{T, F}(
            A::SparseVector; 
            fill = defaultfill(F)
        ) where {T, F}
            C = $typename{T, F}(size(A, 1); fill)
            return unsafepack!(C, _copytoraw(A)..., false)
        end
        $typename{T}(
            A::SparseVector; 
            fill::F = defaultfill(T)
        ) where {T, F} = $typename{T, F}(A; fill)
        $typename(
            A::SparseVector{T}; 
            fill::F = defaultfill(T)
        ) where {T, F} = $typename{T, F}(A; fill)
        
        # similar
        function Base.similar(
            v::$typename{T}, ::Type{TNew} = T,
            dims::Tuple{Int64, Vararg{Int64, N}} = size(v); fill::F = getfill(v)
        ) where {T, TNew, N, F}
            !(F <: Union{Nothing, Missing}) && (fill = convert(TNew, fill))
            if dims isa Dims{1}
                # TODO: Check this for correctness!!!
                x = $typename{TNew}(dims...; fill)
            else
                x = $GBMatrix{TNew}(dims...; fill)
                _hasconstantorder(x) || setstorageorder!(x, storageorder(v))
            end
            return x
        end
        
        function Base.similar(v::$typename{T}, dims::Tuple; fill = getfill(v)) where T
            return similar(v, T, dims; fill)
        end
        
        function Base.similar(
            v::$typename, ::Type{TNew},
            dims::Integer; fill = getfill(v)
        ) where TNew
            return similar(v, TNew, (dims,); fill)
        end
        
        function Base.similar(
            v::$typename, ::Type{TNew},
            dim1::Integer, dim2::Integer; fill = getfill(v)
        ) where TNew
            return similar(v, TNew, (dim1, dim2); fill)
        end
        
        function Base.similar(
            v::$typename,
            dims::Integer; fill = getfill(v)
        )
            return similar(v, (dims,); fill)
        end
        
        function Base.similar(
            v::$typename,
            dim1::Integer, dim2::Integer; fill = getfill(v)
        )
            return similar(v, (dim1, dim2); fill)
        end
    end)
end

"""
    GBVector{T, F} <: AbstractSparseArray{T, UInt64, 1}

One-dimensional GraphBLAS array with elements of type T. `F` is the type of the fill-value, 
which is typically `Nothing` or `T`. 
Internal representation is specified as opaque, but may be either a dense vector, bitmap vector, or 
compressed sparse vector.

See also: [`GBMatrix`](@ref).
"""
mutable struct GBVector{T, F} <: AbstractGBVector{T, F, ColMajor()}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix} # a GBVector is a GBMatrix internally.
    fill::F
end

function GBVector{T, F}(p::Base.RefValue{LibGraphBLAS.GrB_Matrix}; fill = defaultfill(F)) where {T, F}
    ((F === Nothing) || (F === Missing) || (T === F)) || 
        throw(ArgumentError("Fill type $F must be <: Union{Nothing, Missing, $T}"))
    fill = convert(F, fill) # conversion to F happens at the last possible moment.
    return GBVector{T, F}(p, fill)
end
GBVector{T}(
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}; 
    fill::F = defaultfill(T)
) where {T, F} = return GBVector{T, F}(p; fill)

# we call @gbvectortype GBVector below GBMatrix defn.

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
mutable struct GBMatrix{T, F} <: AbstractGBMatrix{T, F, RuntimeOrder()}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    fill::F
end

function GBMatrix{T, F}(p::Base.RefValue{LibGraphBLAS.GrB_Matrix}; fill = defaultfill(F)) where {T, F}
    ((F === Nothing) || (F === Missing) || (T === F)) || 
        throw(ArgumentError("Fill type $F must be <: Union{Nothing, Missing, $T}"))
    fill = convert(F, fill) # conversion to F happens at the last possible moment.
    return GBMatrix{T, F}(p, fill)
end
GBMatrix{T}(
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}; 
    fill::F = defaultfill(T)
) where {T, F} = return GBMatrix{T, F}(p; fill)

@gbmatrixtype GBMatrix
@gbvectortype GBVector

mutable struct OrientedGBMatrix{T, F, O} <: AbstractGBMatrix{T, F, O}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    fill::F
    function OrientedGBMatrix{T, F, O}(
        p::Base.RefValue{LibGraphBLAS.GrB_Matrix},
        fill::F
    ) where {T, F, O}
        O isa StorageOrders.StorageOrder || throw(ArgumentError("$O is not a valid StorageOrder"))
        A = new{T, F, O}(p, fill)
        order = option_toconst(O)
        LibGraphBLAS.GxB_Matrix_Option_set(A, LibGraphBLAS.GxB_FORMAT, order)
        return A
    end
end
function OrientedGBMatrix{T, F, O}(
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix};
    fill = defaultfill(F)
) where {T, F, O}
    fill = convert(F, fill)
    A = OrientedGBMatrix{T, F, O}(p, fill)
    # we can't use `setstorageorder!` here since it's banned for OrientedGBMatrix
    return A
end

function OrientedGBMatrix{T, O}(
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix};
    fill::F = defaultfill(T)
) where {T, F, O}
    return OrientedGBMatrix{T, F, O}(p; fill)
end

const GBMatrixC{T, F} = OrientedGBMatrix{T, F, StorageOrders.ColMajor()}
const GBMatrixR{T, F} = OrientedGBMatrix{T, F, StorageOrders.RowMajor()}

@gbmatrixtype GBMatrixC
@gbmatrixtype GBMatrixR

#=
    Shallow array types

These types do not have the general constructors created by `@gbmatrixtype` since they
should *never* be constructed by a user directly. Only through the `pack` interface.
=#
mutable struct GBShallowVector{T, F, P, B, A} <: AbstractGBShallowArray{T, F, ColMajor(), P, B, A, 1}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    fill::F
    # storage for sparse formats supported by SS:GraphBLAS
    ptr::P #colptr / rowptr
    idx::P # rowidx / colidx
    h::P # hypersparse-only
    bitmap::B # bitmap only
    nzval::A # array storage for dense arrays, nonzero values storage for everyone else.
end
function GBShallowVector{T}(p, fill::F, ptr::P, idx::P, h::P, bitmap::B, nzval::A) where {T, F, P, B, A}
    GBShallowVector{T, F, P, B, A}(p, fill, ptr, idx, h, bitmap, nzval)
end

mutable struct GBShallowMatrix{T, F, O, P, B, A} <: AbstractGBShallowArray{T, F, O, P, B, A, 2}
    p::Base.RefValue{LibGraphBLAS.GrB_Matrix}
    fill::F
    # storage for sparse formats supported by SS:GraphBLAS
    ptr::P #colptr / rowptr
    idx::P # rowidx / colidx
    h::P # hypersparse-only
    bitmap::B # bitmap only
    nzval::A # array storage for dense arrays, nonzero values storage for everyone else.
end
function GBShallowMatrix{T}(p, fill::F, ptr::P, idx::P, h::P, bitmap::B, nzval::A, order = ColMajor()) where {T, F, P, B, A}
    GBShallowMatrix{T, F, order, P, B, A}(p, fill, ptr, idx, h, bitmap, nzval)
end

# We need to do this at runtime. This should perhaps be `RuntimeOrder`, but that trait should likely be removed.
# This should ideally work out fine. a GBMatrix or GBVector won't have 
StorageOrders.runtime_storageorder(A::AbstractGBMatrix) = gbget(A, :format) == Integer(BYCOL) ? StorageOrders.ColMajor() : StorageOrders.RowMajor()
StorageOrders.comptime_storageorder(::AbstractGBArray{<:Any, <:Any, O}) where O = O

defaultfill(::Type{T}) where T = zero(T)
defaultfill(::Type{Nothing}) = nothing
defaultfill(::Type{Missing}) = missing
# This is bold, I'm not sure if I like it...
# It boils down to whether we want numeric sparse arrays to be default
# or for graph sparse arrays to be default.
# I don't think it is onerous for graph algorithm writers to say `GBMatrix{Int64, Nothing}`,
# and provides better defaults for other users.
defaultfill(::Type{Union{T, Nothing}}) where T = T
defaultfill(::Type{Union{T, Missing}}) where T = T