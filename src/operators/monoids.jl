baremodule Monoids
    using ..Types
end
const MonoidUnion = Union{AbstractMonoid, libgb.GrB_Monoid}

function _monoidnames(name)
    simple = splitconstant(name)[2]
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
        containername, exportedname = _monoidnames(name)
        structquote = quote
            struct $containername <: AbstractMonoid
                pointers::Dict{DataType, libgb.GrB_Monoid}
                name::String
                $containername() = new(Dict{DataType, libgb.GrB_Monoid}(), $name)
            end
        end
        @eval(Types, $structquote)
        constquote = quote
            const $exportedname = Types.$containername()
            export $exportedname
        end
        @eval(Monoids, $constquote)
    end
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
    name = monoid.name

    if name ∈ booleans
        constname = name * ((isGxB(name) ? "_BOOL_MONOID" : "_MONOID_BOOL"))
        monoid.pointers[Bool] = load_global(constname)
    end

    if name ∈ integers
        monoid.pointers[Int8] =
            load_global(name * (isGxB(name) ? "_INT8_MONOID" : "_MONOID_INT8"))
        monoid.pointers[Int16] =
            load_global(name * (isGxB(name) ? "_INT16_MONOID" : "_MONOID_INT16"))
        monoid.pointers[Int32] =
            load_global(name * (isGxB(name) ? "_INT32_MONOID" : "_MONOID_INT32"))
        monoid.pointers[Int64] =
            load_global(name * (isGxB(name) ? "_INT64_MONOID" : "_MONOID_INT64"))
    end

    if name ∈ unsignedintegers
        monoid.pointers[UInt8] =
            load_global(name * (isGxB(name) ? "_UINT8_MONOID" : "_MONOID_UINT8"))
        monoid.pointers[UInt16] =
            load_global(name * (isGxB(name) ? "_UINT16_MONOID" : "_MONOID_UINT16"))
        monoid.pointers[UInt32] =
            load_global(name * (isGxB(name) ? "_UINT32_MONOID" : "_MONOID_UINT32"))
        monoid.pointers[UInt64] =
            load_global(name * (isGxB(name) ? "_UINT64_MONOID" : "_MONOID_UINT64"))
    end

    if name ∈ floats
        monoid.pointers[Float32] =
            load_global(name * (isGxB(name) ? "_FP32_MONOID" : "_MONOID_FP32"))
        monoid.pointers[Float64] =
            load_global(name * (isGxB(name) ? "_FP64_MONOID" : "_MONOID_FP64"))
    end
end
Base.show(io::IO, ::MIME"text/plain", m::libgb.GrB_Monoid) = gxbprint(io, m)
operator(monoid::libgb.GrB_Monoid) = libgb.GxB_Monoid_operator(monoid)
xtype(monoid::libgb.GrB_Monoid) = xtype(operator(monoid))
ytype(monoid::libgb.GrB_Monoid) = ytype(operator(monoid))
ztype(monoid::libgb.GrB_Monoid) = ztype(operator(monoid))

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
