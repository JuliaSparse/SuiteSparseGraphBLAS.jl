baremodule Monoids
    using ..Types
end
const MonoidUnion = Union{AbstractMonoid, TypedMonoid}

function _monoidnames(name)
    if isGxB(name) || isGrB(name)
        simple = splitconstant(name)[2]
    else
        simple = name
    end
    containername = Symbol(simple, "_MONOID_T")
    exportedname = Symbol(simple * "_MONOID")
    return containername, exportedname
end

#TODO: Rewrite
function _createmonoids()
    builtins = [
        "GrB_MIN",
        "GrB_MAX",
        "GrB_PLUS",
        "GrB_TIMES",
        "GxB_ANY",
        "GrB_LOR",
        "GrB_LAND",
        "GrB_LXOR",
        "GrB_LXNOR",
        "GxB_EQ",
        "GxB_BOR",
        "GxB_BAND",
        "GxB_BXOR",
        "GxB_BXNOR",
    ]
    for name ∈ builtins
        Monoid(name)
    end
end

function Monoid(name)
    containername, exportedname = _monoidnames(name)
    if isGxB(name) || isGrB(name) #Built-ins are immutable
        structquote = quote
            struct $containername <: AbstractMonoid
                typedops::Dict{DataType, TypedMonoid}
                name::String
                $containername() = new(Dict{DataType, TypedMonoid}(), $name)
            end
        end
    else #UDFs are mutable for finalizing
        structquote = quote
            mutable struct $containername <: AbstractMonoid
                typedops::Dict{DataType, TypedMonoid}
                name::String
                function $containername()
                    m = new(Dict{DataType, TypedMonoid}(), $name)
                    function f(monoid)
                        for k ∈ keys(monoid.typedops)
                            libgb.GrB_Monoid_free(Ref(monoid.typedops[k]))
                            delete!(monoid.typedops, k)
                        end
                    end
                    return finalizer(f, m)
                end
            end
        end
    end
    @eval(Types, $structquote)
    constquote = quote
        const $exportedname = Types.$containername()
        export $exportedname
    end
    @eval(Monoids, $constquote)
    return getproperty(Monoids, exportedname)
end

#This is adapted from the fork by cvdlab
#NOTE: Terminals do not work with built in BinaryOps.
function _addmonoid(op::AbstractMonoid, binop::BinaryUnion, id::T, terminal = nothing) where {T}
    if terminal === nothing
        terminal = C_NULL
    else
        typeof(terminal) == T || throw(ArgumentError("id and terminal must have the same type."))
    end
    if binop isa AbstractBinaryOp
        binop = binop[T]
    end
    monref = Ref{libgb.GrB_Monoid}()
    if T <: valid_union
        if terminal === C_NULL
            libgb.monoididnew[T](monref, binop, id)
        else
            libgb.monoidtermnew[T](monref, binop, id, terminal)
        end
    else
        libgb.monoidtermnew[Any](monref, binop, Ptr{Cvoid}(id), Ptr{Cvoid}(terminal))
    end
    op.typedops[T] = TypedMonoid{xtype(binop), ytype(binop), ztype(binop)}(monref[])
    return nothing
end

#Monoid Constructors
####################

function Monoid(name::String, binop::BinaryUnion, id::T, terminal = nothing) where {T}
    if binop isa AbstractBinaryOp #If this is an AbstractBinaryOp we need to narrow down
        binop = binop[T]
    end
    m = Monoid(name)
    _addmonoid(m, binop, id, terminal)
    return m
end
function Monoid(name::String, binop::AbstractBinaryOp, id::AbstractVector, terminal = nothing)
    m = Monoid(name)
    for i ∈ 1:length(id)
        binop2 = binop[typeof(id[i])]
        if terminal === nothing
            _addmonoid(m, binop2, id[i], nothing)
        else
            _addmonoid(m, binop2, id[i], terminal[i])
        end
    end
    return m
end
function _load(monoid::AbstractMonoid)
    booleans = ["GxB_ANY", "GrB_LOR", "GrB_LAND", "GrB_LXOR", "GrB_LXNOR", "GxB_EQ"]
    integers = ["GrB_MIN", "GrB_MAX", "GrB_PLUS", "GrB_TIMES", "GxB_ANY"]
    unsignedintegers = [
        "GrB_MIN",
        "GrB_MAX",
        "GrB_PLUS",
        "GrB_TIMES",
        "GxB_ANY",
        "GxB_BOR",
        "GxB_BAND",
        "GxB_BXOR",
        "GxB_BXNOR",
    ]
    floats = ["GrB_MIN", "GrB_MAX", "GrB_PLUS", "GrB_TIMES", "GxB_ANY"]
    complexes = ["GxB_PLUS", "GxB_TIMES", "GxB_ANY"]
    name = monoid.name

    if name ∈ booleans
        constname = name * ((isGxB(name) ? "_BOOL_MONOID" : "_MONOID_BOOL"))
        monoid.typedops[Bool] = TypedMonoid(load_global(constname, libgb.GrB_Monoid))
    end

    if name ∈ integers
        monoid.typedops[Int8] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_INT8_MONOID" : "_MONOID_INT8"), libgb.GrB_Monoid))
        monoid.typedops[Int16] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_INT16_MONOID" : "_MONOID_INT16"), libgb.GrB_Monoid))
        monoid.typedops[Int32] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_INT32_MONOID" : "_MONOID_INT32"), libgb.GrB_Monoid))
        monoid.typedops[Int64] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_INT64_MONOID" : "_MONOID_INT64"), libgb.GrB_Monoid))
    end

    if name ∈ unsignedintegers
        monoid.typedops[UInt8] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_UINT8_MONOID" : "_MONOID_UINT8"), libgb.GrB_Monoid))
        monoid.typedops[UInt16] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_UINT16_MONOID" : "_MONOID_UINT16"), libgb.GrB_Monoid))
        monoid.typedops[UInt32] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_UINT32_MONOID" : "_MONOID_UINT32"), libgb.GrB_Monoid))
        monoid.typedops[UInt64] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_UINT64_MONOID" : "_MONOID_UINT64"), libgb.GrB_Monoid))
    end

    if name ∈ floats
        monoid.typedops[Float32] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_FP32_MONOID" : "_MONOID_FP32"), libgb.GrB_Monoid))
        monoid.typedops[Float64] =
            TypedMonoid(load_global(name * (isGxB(name) ? "_FP64_MONOID" : "_MONOID_FP64"), libgb.GrB_Monoid))
    end
    name = "GxB_" * name[5:end]
    if name ∈ complexes
        #Complex monoids are always GxB, so "_MONOID" is always at the end.
        monoid.typedops[ComplexF32] = TypedMonoid(load_global(name * "_FC32_MONOID", libgb.GrB_Monoid))
        monoid.typedops[ComplexF64] = TypedMonoid(load_global(name * "_FC64_MONOID", libgb.GrB_Monoid))
    end
end


ztype(::TypedMonoid{X, Y, Z}) where {X, Y, Z} = Z
xtype(::TypedMonoid{X, Y, Z}) where {X, Y, Z} = X
ytype(::TypedMonoid{X, Y, Z}) where {X, Y, Z} = Y

"""
Minimum monoid: `f(x::ℝ, y::ℝ)::ℝ = min(x, y)`
* Identity: +∞
* Terminal: -∞
"""
Monoids.MIN_MONOID
"""
Max monoid: `f(x::ℝ, y::ℝ)::ℝ = max(x, y)`
* Identity: -∞
* Terminal: +∞
"""
Monoids.MAX_MONOID
"""
Plus monoid: `f(x::T, y::T)::T = x + y`
* Identity: 0
* Terminal: nothing
"""
Monoids.PLUS_MONOID
"""
Times monoid: `f(x::T, y::T)::T = xy`
* Identity: 1
* Terminal: 0 for non Floating-point numbers.
"""
Monoids.TIMES_MONOID
"""
Any monoid: `f(x::T, y::T)::T = x or y`
* Identity: any
* Terminal: any
"""
Monoids.ANY_MONOID
"""
Logical OR monoid: `f(x::Bool, y::Bool)::Bool = x ∨ y`
* Identity: false
* Terminal: true
"""
Monoids.LOR_MONOID
"""
Logical AND monoid: `f(x::Bool, y::Bool)::Bool = x ∧ y`
* Identity: true
* Terminal: false
"""
Monoids.LAND_MONOID
"""
Logical XOR monoid: `f(x::Bool, y::Bool)::Bool = x ⊻ y`
* Identity: false
* Terminal: nothing
"""
Monoids.LXOR_MONOID
"""
Logical XNOR monoid: `f(x::Bool, y::Bool)::Bool = x == y`
* Identity: true
* Terminal: nothing
"""
Monoids.LXNOR_MONOID
"""
Equivalent to LXNOR monoid.
"""
Monoids.EQ_MONOID
"""
Bitwise OR monoid: `f(x::ℤ, y::ℤ)::ℤ = x|y`
* Identity: All bits `0`.* Terminal: All bits `1`.
"""
Monoids.BOR_MONOID
"""
Bitwise AND monoid: `f(x::ℤ, y::ℤ)::ℤ = x&y`
* Identity: All bits `1`.
* Terminal: All bits `0`.
"""
Monoids.BAND_MONOID
"""
Bitwise XOR monoid: `f(x::ℤ, y::ℤ)::ℤ = x^y`
* Identity: All bits `0`.
* Terminal: nothing
"""
Monoids.BXOR_MONOID
"""
Bitwise XNOR monoid: `f(x::ℤ, y::ℤ)::ℤ = ~(x^y)`
* Identity: All bits `1`.
* Terminal: nothing
"""
Monoids.BXNOR_MONOID
