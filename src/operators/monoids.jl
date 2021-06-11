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

function load(monoid::AbstractMonoid)
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
"""
Monoids.MIN_MONOID
"""
"""
Monoids.MAX_MONOID
"""
"""
Monoids.PLUS_MONOID
"""
"""
Monoids.TIMES_MONOID
"""
"""
Monoids.ANY_MONOID
"""
"""
Monoids.LOR_MONOID
"""
"""
Monoids.LAND_MONOID
"""
"""
Monoids.LXOR_MONOID
"""
"""
Monoids.LXNOR_MONOID
"""
"""
Monoids.EQ_MONOID
"""
"""
Monoids.BOR_MONOID
"""
"""
Monoids.BAND_MONOID
"""
"""
Monoids.BXOR_MONOID
"""
"""
Monoids.BXNOR_MONOID
