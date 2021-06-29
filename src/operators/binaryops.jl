baremodule BinaryOps
    using ..Types
end
const BinaryUnion = Union{AbstractBinaryOp, libgb.GrB_BinaryOp}

function _binarynames(name)

end

#TODO: Rewrite
function _createbinaryops()
    builtins = [
    "GrB_FIRST",
    "GrB_SECOND",
    "GxB_POW",
    "GrB_PLUS",
    "GrB_MINUS",
    "GrB_TIMES",
    "GrB_DIV",
    "GxB_RMINUS",
    "GxB_RDIV",
    "GxB_PAIR",
    "GxB_ANY",
    "GxB_ISEQ",
    "GxB_ISNE",
    "GxB_ISGT",
    "GxB_ISLT",
    "GxB_ISGE",
    "GxB_ISLE",
    "GrB_MIN",
    "GrB_MAX",
    "GxB_LOR",
    "GxB_LAND",
    "GxB_LXOR",
    "GxB_ATAN2",
    "GxB_HYPOT",
    "GxB_FMOD",
    "GxB_REMAINDER",
    "GxB_LDEXP",
    "GxB_COPYSIGN",
    "GrB_BOR",
    "GrB_BAND",
    "GrB_BXOR",
    "GrB_BXNOR",
    "GxB_BGET",
    "GxB_BSET",
    "GxB_BCLR",
    "GxB_BSHIFT",
    "GrB_EQ",
    "GrB_NE",
    "GrB_GT",
    "GrB_LT",
    "GrB_GE",
    "GrB_LE",
    "GxB_CMPLX",
    "GxB_FIRSTI",
    "GxB_FIRSTI1",
    "GxB_FIRSTJ",
    "GxB_FIRSTJ1",
    "GxB_SECONDI",
    "GxB_SECONDI1",
    "GxB_SECONDJ",
    "GxB_SECONDJ1",
    ]
    for name ∈ builtins
        BinaryOp(name)
    end
end

function BinaryOp(name)
    if isGxB(name) || isGrB(name)
        simplifiedname = name[5:end]
    else
        simplifiedname = name
    end
    containername = Symbol(simplifiedname, "_T")
    exportedname = Symbol(simplifiedname)
    if isGxB(name) || isGrB(name)
        structquote = quote
            struct $containername <: AbstractBinaryOp
                pointers::Dict{DataType, libgb.GrB_BinaryOp}
                name::String
                $containername() = new(Dict{DataType, libgb.GrB_BinaryOp}(), $name)
            end
        end
    else
        structquote = quote
            mutable struct $containername <: AbstractBinaryOp
                pointers::Dict{DataType, libgb.GrB_BinaryOp}
                name::String
                function $containername()
                    b = new(Dict{DataType, libgb.GrB_BinaryOp}(), $name)
                    function f(binaryop)
                        for k ∈ keys(binaryop.pointers)
                            libgb.GrB_BinaryOp_free(Ref(binaryop.pointers[k]))
                            delete!(binaryop.pointers, k)
                        end
                    end
                    return finalizer(f, b)
                end
            end
        end
    end
    @eval(Types, $structquote)
    constquote = quote
        const $exportedname = Types.$containername()
        export $exportedname
    end
    @eval(BinaryOps, $constquote)
    return getproperty(BinaryOps, exportedname)
end

#This is adapted from the fork by cvdlab.
function _addbinaryop(
    op::AbstractBinaryOp,
    fn::Function,
    ztype::GBType{T},
    xtype::GBType{U},
    ytype::GBType{V}
) where {T,U,V}
    println(T)
    function binaryopfn(z, x, y)
        unsafe_store!(z, fn(x, y))
        return nothing
    end
    opref = Ref{libgb.GrB_BinaryOp}()
    binaryopfn_C = @cfunction($binaryopfn, Cvoid, (Ptr{T}, Ref{U}, Ref{V}))
    libgb.GB_BinaryOp_new(opref, binaryopfn_C, ztype, xtype, ytype, op.name)
    op.pointers[U] = opref[]
    return nothing
end

function BinaryOp(name::String, fn::Function, ztype, xtype, ytype)
    op = BinaryOp(name)
    _addbinaryop(op, fn, toGBType(ztype), toGBType(xtype), toGBType(ytype))
    return op
end
function BinaryOp(name::String, fn::Function, type::DataType)
    return BinaryOp(name, fn, type, type, type)
end
function BinaryOp(
    name::String,
    fn::Function,
    ztype::Vector{DataType},
    xtype::Vector{DataType},
    ytype::Vector{DataType}
)
    op = BinaryOp(name)
    length(ztype) == length(xtype) == length(ytype) ||
        error("Lengths of ztype, xtype, and ytype must match")
    for i ∈ 1:length(ztype)
        _addbinaryop(op, fn, toGBType(ztype[i]), toGBType(xtype[i]), toGBType(ytype[i]))
    end
    return op
end
function BinaryOp(name::String, fn::Function, type::Vector{DataType})
    return BinaryOp(name, fn, type, type, type)
end
function BinaryOp(name::String, fn::Function)
    return BinaryOp(name, fn, valid_vec)
end
function _load(binary::AbstractBinaryOp)
    booleans = [
        "GrB_FIRST",
        "GrB_SECOND",
        "GxB_POW",
        "GrB_PLUS",
        "GrB_MINUS",
        "GrB_TIMES",
        "GrB_DIV",
        "GxB_RMINUS",
        "GxB_RDIV",
        "GxB_PAIR",
        "GxB_ANY",
        "GxB_ISEQ",
        "GxB_ISNE",
        "GxB_ISGT",
        "GxB_ISLT",
        "GxB_ISGE",
        "GxB_ISLE",
        "GrB_MIN",
        "GrB_MAX",
        "GxB_LOR",
        "GxB_LAND",
        "GxB_LXOR",
        "GrB_EQ",
        "GrB_NE",
        "GrB_GT",
        "GrB_LT",
        "GrB_GE",
        "GrB_LE",
    ]
    integers = [
        "GrB_FIRST",
        "GrB_SECOND",
        "GxB_POW",
        "GrB_PLUS",
        "GrB_MINUS",
        "GrB_TIMES",
        "GrB_DIV",
        "GxB_RMINUS",
        "GxB_RDIV",
        "GxB_PAIR",
        "GxB_ANY",
        "GxB_ISEQ",
        "GxB_ISNE",
        "GxB_ISGT",
        "GxB_ISLT",
        "GxB_ISGE",
        "GxB_ISLE",
        "GrB_MIN",
        "GrB_MAX",
        "GxB_LOR",
        "GxB_LAND",
        "GxB_LXOR",
        "GrB_BOR",
        "GrB_BAND",
        "GrB_BXOR",
        "GrB_BXNOR",
        "GxB_BGET",
        "GxB_BSET",
        "GxB_BCLR",
        "GxB_BSHIFT",
        "GrB_EQ",
        "GrB_NE",
        "GrB_GT",
        "GrB_LT",
        "GrB_GE",
        "GrB_LE",
    ]
    unsignedintegers = [
        "GrB_FIRST",
        "GrB_SECOND",
        "GxB_POW",
        "GrB_PLUS",
        "GrB_MINUS",
        "GrB_TIMES",
        "GrB_DIV",
        "GxB_RMINUS",
        "GxB_RDIV",
        "GxB_PAIR",
        "GxB_ANY",
        "GxB_ISEQ",
        "GxB_ISNE",
        "GxB_ISGT",
        "GxB_ISLT",
        "GxB_ISGE",
        "GxB_ISLE",
        "GrB_MIN",
        "GrB_MAX",
        "GxB_LOR",
        "GxB_LAND",
        "GxB_LXOR",
        "GrB_BOR",
        "GrB_BAND",
        "GrB_BXOR",
        "GrB_BXNOR",
        "GxB_BGET",
        "GxB_BSET",
        "GxB_BCLR",
        "GxB_BSHIFT",
        "GrB_EQ",
        "GrB_NE",
        "GrB_GT",
        "GrB_LT",
        "GrB_GE",
        "GrB_LE",
    ]
    floats = [
        "GrB_FIRST",
        "GrB_SECOND",
        "GxB_POW",
        "GrB_PLUS",
        "GrB_MINUS",
        "GrB_TIMES",
        "GrB_DIV",
        "GxB_RMINUS",
        "GxB_RDIV",
        "GxB_PAIR",
        "GxB_ANY",
        "GxB_ISEQ",
        "GxB_ISNE",
        "GxB_ISGT",
        "GxB_ISLT",
        "GxB_ISGE",
        "GxB_ISLE",
        "GrB_MIN",
        "GrB_MAX",
        "GxB_LOR",
        "GxB_LAND",
        "GxB_LXOR",
        "GxB_ATAN2",
        "GxB_HYPOT",
        "GxB_FMOD",
        "GxB_REMAINDER",
        "GxB_LDEXP",
        "GxB_COPYSIGN",
        "GrB_EQ",
        "GrB_NE",
        "GrB_GT",
        "GrB_LT",
        "GrB_GE",
        "GrB_LE",
        "GxB_CMPLX",
    ]

    positionals = [
        "GxB_FIRSTI",
        "GxB_FIRSTI1",
        "GxB_FIRSTJ",
        "GxB_FIRSTJ1",
        "GxB_SECONDI",
        "GxB_SECONDI1",
        "GxB_SECONDJ",
        "GxB_SECONDJ1",
    ]

    name = binary.name
    if name ∈ booleans
        binary.pointers[Bool] = load_global(name * "_BOOL")
    end

    if name ∈ integers
        binary.pointers[Int8] = load_global(name * "_INT8")
        binary.pointers[Int16] = load_global(name * "_INT16")
        binary.pointers[Int32] = load_global(name * "_INT32")
        binary.pointers[Int64] = load_global(name * "_INT64")
    end

    if name ∈ unsignedintegers
        binary.pointers[UInt8] = load_global(name * "_UINT8")
        binary.pointers[UInt16] = load_global(name * "_UINT16")
        binary.pointers[UInt32] = load_global(name * "_UINT32")
        binary.pointers[UInt64] = load_global(name * "_UINT64")
    end

    if name ∈ floats
        binary.pointers[Float32] = load_global(name * "_FP32")
        binary.pointers[Float64] = load_global(name * "_FP64")
    end
    if name ∈ positionals
        binary.pointers[Any] = load_global(name * "_INT64")
    end
end

Base.show(io::IO, ::MIME"text/plain", u::libgb.GrB_BinaryOp) = gxbprint(io, u)

xtype(op::BinaryUnion) = tojuliatype(ptrtogbtype[libgb.GxB_BinaryOp_xtype(op)])
ytype(op::BinaryUnion) = tojuliatype(ptrtogbtype[libgb.GxB_BinaryOp_ytype(op)])
ztype(op::BinaryUnion) = tojuliatype(ptrtogbtype[libgb.GxB_BinaryOp_ztype(op)])

"""
First argument: `f(x::T,y::T)::T = x`
"""
BinaryOps.FIRST
"""
Second argument: `f(x::T,y::T)::T = y`
"""
BinaryOps.SECOND
"""
Power: `f(x::T,y::T)::T = xʸ`
"""
BinaryOps.POW
"""
Addition: `f(x::T,y::T)::T = x + y`
"""
BinaryOps.PLUS
"""
Subtraction: `f(x::T,y::T)::T = x - y`
"""
BinaryOps.MINUS
"""
Multiplication: `f(x::T,y::T)::T = xy`
"""
BinaryOps.TIMES
"""
Division: `f(x::T,y::T)::T = x / y`
"""
BinaryOps.DIV
"""
Reverse Subtraction: `f(x::T,y::T)::T = y - x`
"""
BinaryOps.RMINUS
"""
Reverse Division: `f(x::T,y::T)::T = y / x`
"""
BinaryOps.RDIV
"""
One when both x and y exist: `f(x::T,y::T)::T = 1`
"""
BinaryOps.PAIR
"""
Pick x or y arbitrarily: `f(x::T,y::T)::T = x or y`
"""
BinaryOps.ANY
"""
Equal: `f(x::T,y::T)::T = x == y``
"""
BinaryOps.ISEQ
"""
Not Equal: `f(x::T,y::T)::T = x ≠ y`
"""
BinaryOps.ISNE
"""
Greater Than: `f(x::ℝ,y::ℝ)::ℝ = x > y`
"""
BinaryOps.ISGT
"""
Less Than: `f(x::ℝ,y::ℝ)::ℝ = x < y`
"""
BinaryOps.ISLT
"""
Greater Than or Equal: `f(x::ℝ,y::ℝ)::ℝ = x ≥ y`
"""
BinaryOps.ISGE
"""
Less Than or Equal: `f(x::ℝ,y::ℝ)::ℝ = x ≤ y`
"""
BinaryOps.ISLE
"""
Minimum: `f(x::ℝ,y::ℝ)::ℝ = min(x, y)`
"""
BinaryOps.MIN
"""
Maximum: `f(x::ℝ,y::ℝ)::ℝ = max(x, y)`
"""
BinaryOps.MAX
"""
Logical OR: `f(x::ℝ,y::ℝ)::ℝ = (x ≠ 0) ∨ (y ≠ 0)`
"""
BinaryOps.LOR
"""
Logical AND: `f(x::ℝ,y::ℝ)::ℝ = (x ≠ 0) ∧ (y ≠ 0)`
"""
BinaryOps.LAND
"""
Logical AND: `f(x::ℝ,y::ℝ)::ℝ = (x ≠ 0) ⊻ (y ≠ 0)`
"""
BinaryOps.LXOR
"""
4-Quadrant Arc Tangent: `f(x::F, y::F)::F = tan⁻¹(y/x)`
"""
BinaryOps.ATAN2
"""
Hypotenuse: `f(x::F, y::F)::F = √(x² + y²)`
"""
BinaryOps.HYPOT
"""
Float remainder of x / y rounded towards zero.
"""
BinaryOps.FMOD
"""
Float remainder of x / y rounded towards nearest integral value.
"""
BinaryOps.REMAINDER
"""
LDEXP: `f(x::F, y::F)::F = x × 2ⁿ`
"""
BinaryOps.LDEXP
"""
Copysign: Value with magnitude of x and sign of y.
"""
BinaryOps.COPYSIGN
"""
Bitwise OR: `f(x::ℤ, y::ℤ)::ℤ = x | y`
"""
BinaryOps.BOR
"""
Bitwise AND: `f(x::ℤ, y::ℤ)::ℤ = x & y`
"""
BinaryOps.BAND
"""
Bitwise XOR: `f(x::ℤ, y::ℤ)::ℤ = x ^ y`
"""
BinaryOps.BXOR
"""
Bitwise XNOR: : `f(x::ℤ, y::ℤ)::ℤ = ~(x ^ y)`
"""
BinaryOps.BXNOR
"""
BGET: `f(x::ℤ, y::ℤ)::ℤ = get bit y of x.`
"""
BinaryOps.BGET
"""
BSET: `f(x::ℤ, y::ℤ)::ℤ = set bit y of x.`
"""
BinaryOps.BSET
"""
BCLR: `f(x::ℤ, y::ℤ)::ℤ = clear bit y of x.`
"""
BinaryOps.BCLR
"""
BSHIFT: `f(x::ℤ, y::Int8)::ℤ = bitshift(x, y)`
"""
BinaryOps.BSHIFT
"""
Equals: `f(x::T, y::T)::Bool = x == y`
"""
BinaryOps.EQ
"""
Not Equals: `f(x::T, y::T)::Bool = x ≠ y`
"""
BinaryOps.NE
"""
Greater Than: `f(x::T, y::T)::Bool = x > y`
"""
BinaryOps.GT
"""
Less Than: `f(x::T, y::T)::Bool = x < y`
"""
BinaryOps.LT
"""
Greater Than or Equal: `f(x::T, y::T)::Bool = x ≥ y`
"""
BinaryOps.GE
"""
Less Than or Equal: `f(x::T, y::T)::Bool = x ≤ y`
"""
BinaryOps.LE
"""
Complex: `f(x::F, y::F)::Complex = x + y × i`
"""
BinaryOps.CMPLX
"""
0-Based row index of a: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = i`
"""
BinaryOps.FIRSTI
"""
1-Based row index of a: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = i + 1`
"""
BinaryOps.FIRSTI1
"""
0-Based column index of a: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = j`
"""
BinaryOps.FIRSTJ
"""
1-Based column index of a: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = j + 1`
"""
BinaryOps.FIRSTJ1
"""
0-Based row index of b: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = k`
"""
BinaryOps.SECONDI
"""
0-Based row index of b: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = k + 1`
"""
BinaryOps.SECONDI1
"""
0-Based column index of b: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = l`
"""
BinaryOps.SECONDJ
"""
1-Based column index of b: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = l + 1`
"""
BinaryOps.SECONDJ1
