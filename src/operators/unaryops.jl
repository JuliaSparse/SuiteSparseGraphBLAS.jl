
baremodule UnaryOps
    using ..Types
end

const UnaryUnion = Union{AbstractUnaryOp, libgb.GrB_UnaryOp}

function _unarynames(name)
    simple = splitconstant(name)[2]
    containername = Symbol(simple, "_UNARY_T")
    exportedname = Symbol(simple)
    return containername, exportedname
end

#TODO: Rewrite
function _createunaryops()
    builtins = [
    "GrB_IDENTITY",
    "GrB_AINV",
    "GxB_LNOT",
    "GrB_MINV",
    "GxB_ONE",
    "GrB_ABS",
    "GrB_BNOT",
    "GxB_SQRT",
    "GxB_LOG",
    "GxB_EXP",
    "GxB_LOG2",
    "GxB_SIN",
    "GxB_COS",
    "GxB_TAN",
    "GxB_ACOS",
    "GxB_ASIN",
    "GxB_ATAN",
    "GxB_SINH",
    "GxB_COSH",
    "GxB_TANH",
    "GxB_ASINH",
    "GxB_ACOSH",
    "GxB_ATANH",
    "GxB_SIGNUM",
    "GxB_CEIL",
    "GxB_FLOOR",
    "GxB_ROUND",
    "GxB_TRUNC",
    "GxB_EXP2",
    "GxB_EXPM1",
    "GxB_LOG10",
    "GxB_LOG1P",
    "GxB_LGAMMA",
    "GxB_TGAMMA",
    "GxB_ERF",
    "GxB_ERFC",
    "GxB_FREXPE",
    "GxB_FREXPX",
    "GxB_CONJ",
    "GxB_CREAL",
    "GxB_CIMAG",
    "GxB_CARG",
    "GxB_ISINF",
    "GxB_ISNAN",
    "GxB_ISFINITE",
    "GxB_POSITIONI",
    "GxB_POSITIONI1",
    "GxB_POSITIONJ",
    "GxB_POSITIONJ1",
]
    for name ∈ builtins
        containername, exportedname = _unarynames(name)
        structquote = quote
            struct $containername <: AbstractUnaryOp
                pointers::Dict{DataType, libgb.GrB_UnaryOp}
                name::String
                $containername() = new(Dict{DataType, libgb.GrB_UnaryOp}(), $name)
            end
        end
        @eval(Types, $structquote)
        constquote = quote
            const $exportedname = Types.$containername()
            export $exportedname
        end
        @eval(UnaryOps, $constquote)
    end
end

function _load(unaryop::AbstractUnaryOp)
    booleans = ["GrB_IDENTITY", "GrB_AINV", "GrB_MINV", "GxB_LNOT", "GxB_ONE", "GrB_ABS"]
    integers = [
        "GrB_IDENTITY",
        "GrB_AINV",
        "GrB_MINV",
        "GxB_LNOT",
        "GxB_ONE",
        "GrB_ABS",
        "GrB_BNOT",
    ]
    unsignedintegers = [
        "GrB_IDENTITY",
        "GrB_AINV",
        "GrB_MINV",
        "GxB_LNOT",
        "GxB_ONE",
        "GrB_ABS",
        "GrB_BNOT",
    ]
    floats = [
        "GrB_IDENTITY",
        "GrB_AINV",
        "GrB_MINV",
        "GxB_LNOT",
        "GxB_ONE",
        "GrB_ABS",
        "GxB_SQRT",
        "GxB_LOG",
        "GxB_EXP",
        "GxB_LOG2",
        "GxB_SIN",
        "GxB_COS",
        "GxB_TAN",
        "GxB_ACOS",
        "GxB_ASIN",
        "GxB_ATAN",
        "GxB_SINH",
        "GxB_COSH",
        "GxB_TANH",
        "GxB_ASINH",
        "GxB_ACOSH",
        "GxB_ATANH",
        "GxB_SIGNUM",
        "GxB_CEIL",
        "GxB_FLOOR",
        "GxB_ROUND",
        "GxB_TRUNC",
        "GxB_EXP2",
        "GxB_EXPM1",
        "GxB_LOG10",
        "GxB_LOG1P",
        "GxB_LGAMMA",
        "GxB_TGAMMA",
        "GxB_ERF",
        "GxB_ERFC",
        "GxB_FREXPE",
        "GxB_FREXPX",
        "GxB_ISINF",
        "GxB_ISNAN",
        "GxB_ISFINITE",
    ]
    positionals = ["GxB_POSITIONI", "GxB_POSITIONI1", "GxB_POSITIONJ", "GxB_POSITIONJ1"]
    name = unaryop.name
    if name ∈ booleans
        constname = name * "_BOOL"
        unaryop.pointers[Bool] = load_global(constname)
    end

    if name ∈ integers
        unaryop.pointers[Int8] = load_global(name * "_INT8")
        unaryop.pointers[Int16] = load_global(name * "_INT16")
        unaryop.pointers[Int32] = load_global(name * "_INT32")
        unaryop.pointers[Int64] = load_global(name * "_INT64")
    end

    if name ∈ unsignedintegers
        unaryop.pointers[UInt8] = load_global(name * "_UINT8")
        unaryop.pointers[UInt16] = load_global(name * "_UINT16")
        unaryop.pointers[UInt32] = load_global(name * "_UINT32")
        unaryop.pointers[UInt64] = load_global(name * "_UINT64")
    end

    if name ∈ floats
        unaryop.pointers[Float32] = load_global(name * "_FP32")
        unaryop.pointers[Float64] = load_global(name * "_FP64")
    end
    if name ∈ positionals
        unaryop.pointers[Any] = load_global(name)
    end
end

ztype(op::libgb.GrB_UnaryOp) = tojuliatype(ptrtogbtype[libgb.GxB_UnaryOp_ztype(op)])
xtype(op::libgb.GrB_UnaryOp) = tojuliatype(ptrtogbtype[libgb.GxB_UnaryOp_xtype(op)])

Base.show(io::IO, ::MIME"text/plain", u::libgb.GrB_UnaryOp) = gxbprint(io, u)
function Base.show(io::IO, ::MIME"text/plain", u::AbstractUnaryOp)
    print(io, u.name, ": ", keys(u.pointers))
end

"""
Identity: `z=x`
"""
UnaryOps.IDENTITY
"""
Additive Inverse: `z=-x`
"""
UnaryOps.AINV
"""
Logical Negation

`z=¬x::Bool`

`Real`:  `z=¬(x::ℝ ≠ 0)`
"""
UnaryOps.LNOT
"""
Multiplicative Inverse: `z=1/x`
"""
UnaryOps.MINV
"""
One: `z=one(x)`
"""
UnaryOps.ONE
"""
Absolute Value: `z=|x|`
"""
UnaryOps.ABS
"""
Bitwise Negation: `z=¬x`
"""
UnaryOps.BNOT
"""
Square Root: `z=√(x)`
"""
UnaryOps.SQRT
"""
Natural Logarithm: `z=logₑ(x)`
"""
UnaryOps.LOG
"""
Natural Base Exponential: `z=eˣ`
"""
UnaryOps.EXP
"""
Log Base 2: `z=log₂(x)`
"""
UnaryOps.LOG2
"""
Sine: `z=sin(x)`
"""
UnaryOps.SIN
"""
Cosine: `z=cos(x)`
"""
UnaryOps.COS
"""
Tangent: `z=tan(x)`
"""
UnaryOps.TAN
"""
Inverse Cosine: `z=cos⁻¹(x)`
"""
UnaryOps.ACOS
"""
Inverse Sine: `z=sin⁻¹(x)`
"""
UnaryOps.ASIN
"""
Inverse Tangent: `z=tan⁻¹(x)`
"""
UnaryOps.ATAN
"""
Hyperbolic Sine: `z=sinh(x)`
"""
UnaryOps.SINH
"""
Hyperbolic Cosine: `z=cosh(x)`
"""
UnaryOps.COSH
"""
Hyperbolic Tangent: `z=tanh(x)`
"""
UnaryOps.TANH
"""
Inverse Hyperbolic Sine: `z=sinh⁻¹(x)`
"""
UnaryOps.ASINH
"""
Inverse Hyperbolic Cosine: `z=cosh⁻¹(x)`
"""
UnaryOps.ACOSH
"""
Inverse Hyperbolic Tangent: `z=tanh⁻¹(x)`
"""
UnaryOps.ATANH
"""
Sign Function: `z=signum(x)`
"""
UnaryOps.SIGNUM
"""
Ceiling Function: `z=⌈x⌉`
"""
UnaryOps.CEIL
"""
Floor Function: `z=⌊x⌋`
"""
UnaryOps.FLOOR
"""
Round to nearest: `z=round(x)`
"""
UnaryOps.ROUND
"""
Truncate: `z=trunc(x)`
"""
UnaryOps.TRUNC
"""
Base-2 Exponential: `z=2ˣ`
"""
UnaryOps.EXP2
"""
Natural Exponential - 1: `z=eˣ - 1`
"""
UnaryOps.EXPM1
"""
Log Base 10: `z=log₁₀(x)`
"""
UnaryOps.LOG10
"""
Natural Log of x + 1: `z=logₑ(x + 1)`
"""
UnaryOps.LOG1P
"""
Log of Gamma Function: `z=log(|Γ(x)|)`
"""
UnaryOps.LGAMMA
"""
Gamma Function: `z=Γ(x)`
"""
UnaryOps.TGAMMA
"""
Error Function: `z=erf(x)`
"""
UnaryOps.ERF
"""
Complimentary Error Function: `z=erfc(x)`
"""
UnaryOps.ERFC
"""
Normalized Exponent: `z=frexpe(x)`
"""
UnaryOps.FREXPE
"""
Normalized Fraction: `z=frexpx(x)`
"""
UnaryOps.FREXPX
"""
Complex Conjugate: `z=x̄`
"""
UnaryOps.CONJ
"""
Real Part: `z=real(x)`
"""
UnaryOps.CREAL
"""
Imaginary Part: `z=imag(x)`
"""
UnaryOps.CIMAG
"""
Angle: `z=carg(x)`
"""
UnaryOps.CARG
"""
isinf: `z=(x == ±∞)`
"""
UnaryOps.ISINF
"""
isnan: `z=(x == NaN)`
"""
UnaryOps.ISNAN
"""
isfinite: `z=isfinite(x)`
"""
UnaryOps.ISFINITE
"""
0-based Row Index: `z=i`
"""
UnaryOps.POSITIONI
"""
1-Based Row Index: `z=i + 1`
"""
UnaryOps.POSITIONI1
"""
0-Based Column Index: `z=j`
"""
UnaryOps.POSITIONJ
"""
1-Based Column Index: `z=j + 1`
"""
UnaryOps.POSITIONJ1
