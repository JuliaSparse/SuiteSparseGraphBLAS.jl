#Unary Operators
"""
Identity: `z=x`
"""
UnaryOps.IDENTITY
juliaop(::typeof(UnaryOps.IDENTITY)) = identity
gbop(::typeof(identity)) = UnaryOps.IDENTITY
"""
Additive Inverse: `z=-x`
"""
UnaryOps.AINV
juliaop(::typeof(UnaryOps.AINV)) = -
gbop(::typeof(-)) = UnaryOps.AINV
"""
Logical Negation

`z=¬x::Bool`

`Real`:  `z=¬(x::ℝ ≠ 0)`
"""
UnaryOps.LNOT
juliaop(::typeof(UnaryOps.LNOT)) = !
gbop(::typeof(!)) = UnaryOps.LNOT
"""
Multiplicative Inverse: `z=1/x`
"""
UnaryOps.MINV
juliaop(::typeof(UnaryOps.MINV)) = /
gbop(::typeof(/)) = UnaryOps.MINV
"""
One: `z=one(x)`
"""
UnaryOps.ONE
juliaop(::typeof(UnaryOps.ONE)) = one
gbop(::typeof(one)) = UnaryOps.ONE
"""
Absolute Value: `z=|x|`
"""
UnaryOps.ABS
juliaop(::typeof(UnaryOps.ABS)) = abs
gbop(::typeof(abs)) = UnaryOps.ABS
"""
Bitwise Negation: `z=¬x`
"""
UnaryOps.BNOT
juliaop(::typeof(UnaryOps.BNOT)) = ~
gbop(::typeof(~)) = UnaryOps.BNOT
"""
Square Root: `z=√(x)`
"""
UnaryOps.SQRT
juliaop(::typeof(UnaryOps.SQRT)) = sqrt
gbop(::typeof(sqrt)) = UnaryOps.SQRT
"""
Natural Logarithm: `z=logₑ(x)`
"""
UnaryOps.LOG
juliaop(::typeof(UnaryOps.LOG)) = log
gbop(::typeof(log)) = UnaryOps.LOG
"""
Natural Base Exponential: `z=eˣ`
"""
UnaryOps.EXP
juliaop(::typeof(UnaryOps.EXP)) = exp
gbop(::typeof(exp)) = UnaryOps.EXP
"""
Log Base 2: `z=log₂(x)`
"""
UnaryOps.LOG2
juliaop(::typeof(UnaryOps.LOG2)) = log2
gbop(::typeof(log2)) = UnaryOps.LOG2
"""
Sine: `z=sin(x)`
"""
UnaryOps.SIN
juliaop(::typeof(UnaryOps.SIN)) = sin
gbop(::typeof(sin)) = UnaryOps.SIN
"""
Cosine: `z=cos(x)`
"""
UnaryOps.COS
juliaop(::typeof(UnaryOps.COS)) = cos
gbop(::typeof(cos)) = UnaryOps.COS
"""
Tangent: `z=tan(x)`
"""
UnaryOps.TAN
juliaop(::typeof(UnaryOps.TAN)) = tan
gbop(::typeof(tan)) = UnaryOps.TAN
"""
Inverse Cosine: `z=cos⁻¹(x)`
"""
UnaryOps.ACOS
juliaop(::typeof(UnaryOps.ACOS)) = acos
gbop(::typeof(acos)) = UnaryOps.ACOS
"""
Inverse Sine: `z=sin⁻¹(x)`
"""
UnaryOps.ASIN
juliaop(::typeof(UnaryOps.ASIN)) = asin
gbop(::typeof(asin)) = UnaryOps.ASIN
"""
Inverse Tangent: `z=tan⁻¹(x)`
"""
UnaryOps.ATAN
juliaop(::typeof(UnaryOps.ATAN)) = atan
gbop(::typeof(atan)) = UnaryOps.ATAN
"""
Hyperbolic Sine: `z=sinh(x)`
"""
UnaryOps.SINH
juliaop(::typeof(UnaryOps.SINH)) = sinh
gbop(::typeof(sinh)) = UnaryOps.SINH
"""
Hyperbolic Cosine: `z=cosh(x)`
"""
UnaryOps.COSH
juliaop(::typeof(UnaryOps.COSH)) = cosh
gbop(::typeof(cosh)) = UnaryOps.COSH
"""
Hyperbolic Tangent: `z=tanh(x)`
"""
UnaryOps.TANH
juliaop(::typeof(UnaryOps.TANH)) = tanh
gbop(::typeof(tanh)) = UnaryOps.TANH
"""
Inverse Hyperbolic Sine: `z=sinh⁻¹(x)`
"""
UnaryOps.ASINH
juliaop(::typeof(UnaryOps.ASINH)) = asinh
gbop(::typeof(asinh)) = UnaryOps.ASINH
"""
Inverse Hyperbolic Cosine: `z=cosh⁻¹(x)`
"""
UnaryOps.ACOSH
juliaop(::typeof(UnaryOps.ACOSH)) = acosh
gbop(::typeof(acosh)) = UnaryOps.ACOSH
"""
Inverse Hyperbolic Tangent: `z=tanh⁻¹(x)`
"""
UnaryOps.ATANH
juliaop(::typeof(UnaryOps.ATANH)) = atanh
gbop(::typeof(atanh)) = UnaryOps.ATANH
"""
Sign Function: `z=signum(x)`
"""
UnaryOps.SIGNUM
juliaop(::typeof(UnaryOps.SIGNUM)) = sign
gbop(::typeof(sign)) = UnaryOps.SIGNUM
"""
Ceiling Function: `z=⌈x⌉`
"""
UnaryOps.CEIL
juliaop(::typeof(UnaryOps.CEIL)) = ceil
gbop(::typeof(ceil)) = UnaryOps.CEIL
"""
Floor Function: `z=⌊x⌋`
"""
UnaryOps.FLOOR
juliaop(::typeof(UnaryOps.FLOOR)) = floor
gbop(::typeof(floor)) = UnaryOps.FLOOR
"""
Round to nearest: `z=round(x)`
"""
UnaryOps.ROUND
juliaop(::typeof(UnaryOps.ROUND)) = round
gbop(::typeof(round)) = UnaryOps.ROUND
"""
Truncate: `z=trunc(x)`
"""
UnaryOps.TRUNC
juliaop(::typeof(UnaryOps.TRUNC)) = trunc
gbop(::typeof(trunc)) = UnaryOps.TRUNC
"""
Base-2 Exponential: `z=2ˣ`
"""
UnaryOps.EXP2
juliaop(::typeof(UnaryOps.EXP2)) = exp2
gbop(::typeof(exp2)) = UnaryOps.EXP2
"""
Natural Exponential - 1: `z=eˣ - 1`
"""
UnaryOps.EXPM1
juliaop(::typeof(UnaryOps.EXPM1)) = expm1
gbop(::typeof(expm1)) = UnaryOps.EXPM1
"""
Log Base 10: `z=log₁₀(x)`
"""
UnaryOps.LOG10
juliaop(::typeof(UnaryOps.LOG10)) = log10
gbop(::typeof(log10)) = UnaryOps.LOG10
"""
Natural Log of x + 1: `z=logₑ(x + 1)`
"""
UnaryOps.LOG1P
juliaop(::typeof(UnaryOps.LOG1P)) = log1p
gbop(::typeof(log1p)) = UnaryOps.LOG1P
"""
Log of Gamma Function: `z=log(|Γ(x)|)`
"""
UnaryOps.LGAMMA
juliaop(::typeof(UnaryOps.LGAMMA)) = lgamma
gbop(::typeof(lgamma)) = UnaryOps.LGAMMA
"""
Gamma Function: `z=Γ(x)`
"""
UnaryOps.TGAMMA
juliaop(::typeof(UnaryOps.TGAMMA)) = gamma
gbop(::typeof(gamma)) = UnaryOps.TGAMMA
"""
Error Function: `z=erf(x)`
"""
UnaryOps.ERF
juliaop(::typeof(UnaryOps.ERF)) = erf
gbop(::typeof(erf)) = UnaryOps.ERF
"""
Complimentary Error Function: `z=erfc(x)`
"""
UnaryOps.ERFC
juliaop(::typeof(UnaryOps.ERFC)) = erfc
gbop(::typeof(erfc)) = UnaryOps.ERFC

#There is no exact equivalent here, since Julia's frexp returns (frexpx, frexpe).
"""
Normalized Exponent: `z=frexpe(x)`
"""
UnaryOps.FREXPE

function frexpe end
juliaop(::typeof(UnaryOps.FREXPE)) = frexpe
gbop(::typeof(frexpe)) = UnaryOps.FREXPE
"""
Normalized Fraction: `z=frexpx(x)`
"""
UnaryOps.FREXPX
function frexpx end
juliaop(::typeof(UnaryOps.FREXPX)) = frexpx
gbop(::typeof(frexpx)) = UnaryOps.frexpx

"""
Complex Conjugate: `z=x̄`
"""
UnaryOps.CONJ
juliaop(::typeof(UnaryOps.CONJ)) = conj
gbop(::typeof(conj)) = UnaryOps.CONJ
"""
Real Part: `z=real(x)`
"""
UnaryOps.CREAL
juliaop(::typeof(UnaryOps.CREAL)) = real
gbop(::typeof(real)) = UnaryOps.CREAL
"""
Imaginary Part: `z=imag(x)`
"""
UnaryOps.CIMAG
juliaop(::typeof(UnaryOps.CIMAG)) = imag
gbop(::typeof(imag)) = UnaryOps.CIMAG
"""
Angle: `z=carg(x)`
"""
UnaryOps.CARG
juliaop(::typeof(UnaryOps.CARG)) = angle
gbop(::typeof(angle)) = UnaryOps.CARG
"""
isinf: `z=(x == ±∞)`
"""
UnaryOps.ISINF
juliaop(::typeof(UnaryOps.ISINF)) = isinf
gbop(::typeof(isinf)) = UnaryOps.ISINF
"""
isnan: `z=(x == NaN)`
"""
UnaryOps.ISNAN
juliaop(::typeof(UnaryOps.ISNAN)) = isnan
gbop(::typeof(isnan)) = UnaryOps.ISNAN
"""
isfinite: `z=isfinite(x)`
"""
UnaryOps.ISFINITE
juliaop(::typeof(UnaryOps.ISFINITE)) = isfinite
gbop(::typeof(isfinite)) = UnaryOps.ISFINITE
"""
0-based Row Index: `z=i`
"""
UnaryOps.POSITIONI #No Julia version since it's 0-based.
"""
1-Based Row Index: `z=i + 1`
"""
UnaryOps.POSITIONI1
function positioni end
juliaop(::typeof(UnaryOps.POSITIONI1)) = positioni
gbop(::typeof(positioni)) = UnaryOps.POSITIONI1
"""
0-Based Column Index: `z=j`
"""
UnaryOps.POSITIONJ #No Julia version since it's 0-based.
"""
1-Based Column Index: `z=j + 1`
"""
UnaryOps.POSITIONJ1
function positionj end
juliaop(::typeof(UnaryOps.POSITIONJ1)) = positionj
gbop(::typeof(positionj)) = UnaryOps.POSITIONJ1

UnaryJuliaOps = Union{typeof(identity),
    typeof(-),
    typeof(!),
    typeof(/),
    typeof(one),
    typeof(abs),
    typeof(~),
    typeof(sqrt),
    typeof(log),
    typeof(exp),
    typeof(log2),
    typeof(sin),
    typeof(cos),
    typeof(tan),
    typeof(acos),
    typeof(asin),
    typeof(atan),
    typeof(sinh),
    typeof(cosh),
    typeof(tanh),
    typeof(asinh),
    typeof(acosh),
    typeof(atanh),
    typeof(sign),
    typeof(ceil),
    typeof(floor),
    typeof(round),
    typeof(trunc),
    typeof(exp2),
    typeof(expm1),
    typeof(log10),
    typeof(log1p),
    typeof(lgamma),
    typeof(gamma),
    typeof(erf),
    typeof(erfc),
    typeof(frexpe),
    typeof(frexpx),
    typeof(conj),
    typeof(real),
    typeof(imag),
    typeof(angle),
    typeof(isinf),
    typeof(isnan),
    typeof(isfinite),
    typeof(positioni),
    typeof(positionj)
}
