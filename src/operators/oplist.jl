#Unary Operators
"""
Identity: `z=x`
"""
UnaryOps.IDENTITY
juliaop(::typeof(UnaryOps.IDENTITY)) = identity
UnaryOps.UnaryOp(::typeof(identity)) = UnaryOps.IDENTITY
"""
Additive Inverse: `z=-x`
"""
UnaryOps.AINV
juliaop(::typeof(UnaryOps.AINV)) = -
UnaryOps.UnaryOp(::typeof(-)) = UnaryOps.AINV
"""
Logical Negation

`z=¬x::Bool`

`Real`:  `z=¬(x::ℝ ≠ 0)`
"""
UnaryOps.LNOT
juliaop(::typeof(UnaryOps.LNOT)) = !
UnaryOps.UnaryOp(::typeof(!)) = UnaryOps.LNOT
"""
Multiplicative Inverse: `z=1/x`
"""
UnaryOps.MINV
juliaop(::typeof(UnaryOps.MINV)) = /
UnaryOps.UnaryOp(::typeof(/)) = UnaryOps.MINV
"""
One: `z=one(x)`
"""
UnaryOps.ONE
juliaop(::typeof(UnaryOps.ONE)) = one
UnaryOps.UnaryOp(::typeof(one)) = UnaryOps.ONE
"""
Absolute Value: `z=|x|`
"""
UnaryOps.ABS
juliaop(::typeof(UnaryOps.ABS)) = abs
UnaryOps.UnaryOp(::typeof(abs)) = UnaryOps.ABS
"""
Bitwise Negation: `z=¬x`
"""
UnaryOps.BNOT
juliaop(::typeof(UnaryOps.BNOT)) = ~
UnaryOps.UnaryOp(::typeof(~)) = UnaryOps.BNOT
"""
Square Root: `z=√(x)`
"""
UnaryOps.SQRT
juliaop(::typeof(UnaryOps.SQRT)) = sqrt
UnaryOps.UnaryOp(::typeof(sqrt)) = UnaryOps.SQRT
"""
Natural Logarithm: `z=logₑ(x)`
"""
UnaryOps.LOG
juliaop(::typeof(UnaryOps.LOG)) = log
UnaryOps.UnaryOp(::typeof(log)) = UnaryOps.LOG
"""
Natural Base Exponential: `z=eˣ`
"""
UnaryOps.EXP
juliaop(::typeof(UnaryOps.EXP)) = exp
UnaryOps.UnaryOp(::typeof(exp)) = UnaryOps.EXP
"""
Log Base 2: `z=log₂(x)`
"""
UnaryOps.LOG2
juliaop(::typeof(UnaryOps.LOG2)) = log2
UnaryOps.UnaryOp(::typeof(log2)) = UnaryOps.LOG2
"""
Sine: `z=sin(x)`
"""
UnaryOps.SIN
juliaop(::typeof(UnaryOps.SIN)) = sin
UnaryOps.UnaryOp(::typeof(sin)) = UnaryOps.SIN
"""
Cosine: `z=cos(x)`
"""
UnaryOps.COS
juliaop(::typeof(UnaryOps.COS)) = cos
UnaryOps.UnaryOp(::typeof(cos)) = UnaryOps.COS
"""
Tangent: `z=tan(x)`
"""
UnaryOps.TAN
juliaop(::typeof(UnaryOps.TAN)) = tan
UnaryOps.UnaryOp(::typeof(tan)) = UnaryOps.TAN
"""
Inverse Cosine: `z=cos⁻¹(x)`
"""
UnaryOps.ACOS
juliaop(::typeof(UnaryOps.ACOS)) = acos
UnaryOps.UnaryOp(::typeof(acos)) = UnaryOps.ACOS
"""
Inverse Sine: `z=sin⁻¹(x)`
"""
UnaryOps.ASIN
juliaop(::typeof(UnaryOps.ASIN)) = asin
UnaryOps.UnaryOp(::typeof(asin)) = UnaryOps.ASIN
"""
Inverse Tangent: `z=tan⁻¹(x)`
"""
UnaryOps.ATAN
juliaop(::typeof(UnaryOps.ATAN)) = atan
UnaryOps.UnaryOp(::typeof(atan)) = UnaryOps.ATAN
"""
Hyperbolic Sine: `z=sinh(x)`
"""
UnaryOps.SINH
juliaop(::typeof(UnaryOps.SINH)) = sinh
UnaryOps.UnaryOp(::typeof(sinh)) = UnaryOps.SINH
"""
Hyperbolic Cosine: `z=cosh(x)`
"""
UnaryOps.COSH
juliaop(::typeof(UnaryOps.COSH)) = cosh
UnaryOps.UnaryOp(::typeof(cosh)) = UnaryOps.COSH
"""
Hyperbolic Tangent: `z=tanh(x)`
"""
UnaryOps.TANH
juliaop(::typeof(UnaryOps.TANH)) = tanh
UnaryOps.UnaryOp(::typeof(tanh)) = UnaryOps.TANH
"""
Inverse Hyperbolic Sine: `z=sinh⁻¹(x)`
"""
UnaryOps.ASINH
juliaop(::typeof(UnaryOps.ASINH)) = asinh
UnaryOps.UnaryOp(::typeof(asinh)) = UnaryOps.ASINH
"""
Inverse Hyperbolic Cosine: `z=cosh⁻¹(x)`
"""
UnaryOps.ACOSH
juliaop(::typeof(UnaryOps.ACOSH)) = acosh
UnaryOps.UnaryOp(::typeof(acosh)) = UnaryOps.ACOSH
"""
Inverse Hyperbolic Tangent: `z=tanh⁻¹(x)`
"""
UnaryOps.ATANH
juliaop(::typeof(UnaryOps.ATANH)) = atanh
UnaryOps.UnaryOp(::typeof(atanh)) = UnaryOps.ATANH
"""
Sign Function: `z=signum(x)`
"""
UnaryOps.SIGNUM
juliaop(::typeof(UnaryOps.SIGNUM)) = sign
UnaryOps.UnaryOp(::typeof(sign)) = UnaryOps.SIGNUM
"""
Ceiling Function: `z=⌈x⌉`
"""
UnaryOps.CEIL
juliaop(::typeof(UnaryOps.CEIL)) = ceil
UnaryOps.UnaryOp(::typeof(ceil)) = UnaryOps.CEIL
"""
Floor Function: `z=⌊x⌋`
"""
UnaryOps.FLOOR
juliaop(::typeof(UnaryOps.FLOOR)) = floor
UnaryOps.UnaryOp(::typeof(floor)) = UnaryOps.FLOOR
"""
Round to nearest: `z=round(x)`
"""
UnaryOps.ROUND
juliaop(::typeof(UnaryOps.ROUND)) = round
UnaryOps.UnaryOp(::typeof(round)) = UnaryOps.ROUND
"""
Truncate: `z=trunc(x)`
"""
UnaryOps.TRUNC
juliaop(::typeof(UnaryOps.TRUNC)) = trunc
UnaryOps.UnaryOp(::typeof(trunc)) = UnaryOps.TRUNC
"""
Base-2 Exponential: `z=2ˣ`
"""
UnaryOps.EXP2
juliaop(::typeof(UnaryOps.EXP2)) = exp2
UnaryOps.UnaryOp(::typeof(exp2)) = UnaryOps.EXP2
"""
Natural Exponential - 1: `z=eˣ - 1`
"""
UnaryOps.EXPM1
juliaop(::typeof(UnaryOps.EXPM1)) = expm1
UnaryOps.UnaryOp(::typeof(expm1)) = UnaryOps.EXPM1
"""
Log Base 10: `z=log₁₀(x)`
"""
UnaryOps.LOG10
juliaop(::typeof(UnaryOps.LOG10)) = log10
UnaryOps.UnaryOp(::typeof(log10)) = UnaryOps.LOG10
"""
Natural Log of x + 1: `z=logₑ(x + 1)`
"""
UnaryOps.LOG1P
juliaop(::typeof(UnaryOps.LOG1P)) = log1p
UnaryOps.UnaryOp(::typeof(log1p)) = UnaryOps.LOG1P
"""
Log of Gamma Function: `z=log(|Γ(x)|)`
"""
UnaryOps.LGAMMA
juliaop(::typeof(UnaryOps.LGAMMA)) = lgamma
UnaryOps.UnaryOp(::typeof(lgamma)) = UnaryOps.LGAMMA
"""
Gamma Function: `z=Γ(x)`
"""
UnaryOps.TGAMMA
juliaop(::typeof(UnaryOps.TGAMMA)) = gamma
UnaryOps.UnaryOp(::typeof(gamma)) = UnaryOps.TGAMMA
"""
Error Function: `z=erf(x)`
"""
UnaryOps.ERF
juliaop(::typeof(UnaryOps.ERF)) = erf
UnaryOps.UnaryOp(::typeof(erf)) = UnaryOps.ERF
"""
Complimentary Error Function: `z=erfc(x)`
"""
UnaryOps.ERFC
juliaop(::typeof(UnaryOps.ERFC)) = erfc
UnaryOps.UnaryOp(::typeof(erfc)) = UnaryOps.ERFC

#There is no exact equivalent here, since Julia's frexp returns (frexpx, frexpe).
"""
Normalized Exponent: `z=frexpe(x)`
"""
UnaryOps.FREXPE
function frexpe end
juliaop(::typeof(UnaryOps.FREXPE)) = frexpe
UnaryOps.UnaryOp(::typeof(frexpe)) = UnaryOps.FREXPE
"""
Normalized Fraction: `z=frexpx(x)`
"""
UnaryOps.FREXPX
function frexpx end
juliaop(::typeof(UnaryOps.FREXPX)) = frexpx
UnaryOps.UnaryOp(::typeof(frexpx)) = UnaryOps.frexpx

"""
Complex Conjugate: `z=x̄`
"""
UnaryOps.CONJ
juliaop(::typeof(UnaryOps.CONJ)) = conj
UnaryOps.UnaryOp(::typeof(conj)) = UnaryOps.CONJ
"""
Real Part: `z=real(x)`
"""
UnaryOps.CREAL
juliaop(::typeof(UnaryOps.CREAL)) = real
UnaryOps.UnaryOp(::typeof(real)) = UnaryOps.CREAL
"""
Imaginary Part: `z=imag(x)`
"""
UnaryOps.CIMAG
juliaop(::typeof(UnaryOps.CIMAG)) = imag
UnaryOps.UnaryOp(::typeof(imag)) = UnaryOps.CIMAG
"""
Angle: `z=carg(x)`
"""
UnaryOps.CARG
juliaop(::typeof(UnaryOps.CARG)) = angle
UnaryOps.UnaryOp(::typeof(angle)) = UnaryOps.CARG
"""
isinf: `z=(x == ±∞)`
"""
UnaryOps.ISINF
juliaop(::typeof(UnaryOps.ISINF)) = isinf
UnaryOps.UnaryOp(::typeof(isinf)) = UnaryOps.ISINF
"""
isnan: `z=(x == NaN)`
"""
UnaryOps.ISNAN
juliaop(::typeof(UnaryOps.ISNAN)) = isnan
UnaryOps.UnaryOp(::typeof(isnan)) = UnaryOps.ISNAN
"""
isfinite: `z=isfinite(x)`
"""
UnaryOps.ISFINITE
juliaop(::typeof(UnaryOps.ISFINITE)) = isfinite
UnaryOps.UnaryOp(::typeof(isfinite)) = UnaryOps.ISFINITE
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
UnaryOps.UnaryOp(::typeof(positioni)) = UnaryOps.POSITIONI1
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
UnaryOps.UnaryOp(::typeof(positionj)) = UnaryOps.POSITIONJ1

#Binary Operators
"""
First argument: `f(x::T,y::T)::T = x`
"""
BinaryOps.FIRST
juliaop(::typeof(BinaryOps.FIRST)) = first
BinaryOps.BinaryOp(::typeof(first)) = BinaryOps.FIRST
"""
Second argument: `f(x::T,y::T)::T = y`
"""
BinaryOps.SECOND
function second end
juliaop(::typeof(BinaryOps.SECOND)) = second
BinaryOps.BinaryOp(::typeof(second)) = BinaryOps.SECOND
"""
Power: `f(x::T,y::T)::T = xʸ`
"""
BinaryOps.POW
juliaop(::typeof(BinaryOps.POW)) = ^
BinaryOps.BinaryOp(::typeof(^)) = BinaryOps.POW
"""
Addition: `f(x::T,y::T)::T = x + y`
"""
BinaryOps.PLUS
juliaop(::typeof(BinaryOps.PLUS)) = +
BinaryOps.BinaryOp(::typeof(+)) = BinaryOps.PLUS
"""
Subtraction: `f(x::T,y::T)::T = x - y`
"""
BinaryOps.MINUS
juliaop(::typeof(BinaryOps.MINUS)) = -
BinaryOps.BinaryOp(::typeof(-)) = BinaryOps.MINUS
"""
Multiplication: `f(x::T,y::T)::T = xy`
"""
BinaryOps.TIMES
juliaop(::typeof(BinaryOps.TIMES)) = *
BinaryOps.BinaryOp(::typeof(*)) = BinaryOps.TIMES
"""
Division: `f(x::T,y::T)::T = x / y`
"""
BinaryOps.DIV
juliaop(::typeof(BinaryOps.DIV)) = /
BinaryOps.BinaryOp(::typeof(/)) = BinaryOps.DIV
"""
Reverse Subtraction: `f(x::T,y::T)::T = y - x`
"""
BinaryOps.RMINUS
function rminus end
juliaop(::typeof(BinaryOps.RMINUS)) = rminus
BinaryOps.BinaryOp(::typeof(rminus)) = BinaryOps.RMINUS
"""
Reverse Division: `f(x::T,y::T)::T = y / x`
"""
BinaryOps.RDIV
juliaop(::typeof(BinaryOps.RDIV)) = \
BinaryOps.BinaryOp(::typeof(\)) = BinaryOps.RDIV
"""
One when both x and y exist: `f(x::T,y::T)::T = 1`
"""
BinaryOps.PAIR
function pair end
juliaop(::typeof(BinaryOps.PAIR)) = pair
BinaryOps.BinaryOp(::typeof(pair)) = BinaryOps.PAIR
"""
Pick x or y arbitrarily: `f(x::T,y::T)::T = x or y`
"""
BinaryOps.ANY
#This is sort of incorrect
juliaop(::typeof(BinaryOps.ANY)) = any
BinaryOps.BinaryOp(::typeof(any)) = BinaryOps.ANY
"""
Equal: `f(x::T,y::T)::T = x == y``
"""
BinaryOps.ISEQ
function iseq end
juliaop(::typeof(BinaryOps.ISEQ)) = iseq
BinaryOps.BinaryOp(::typeof(iseq)) = BinaryOps.ISEQ
"""
Not Equal: `f(x::T,y::T)::T = x ≠ y`
"""
BinaryOps.ISNE
function isne end
juliaop(::typeof(BinaryOps.ISNE)) = isne
BinaryOps.BinaryOp(::typeof(isne)) = BinaryOps.ISNE
"""
Greater Than: `f(x::ℝ,y::ℝ)::ℝ = x > y`
"""
BinaryOps.ISGT
function isgt end
juliaop(::typeof(BinaryOps.ISGT)) = isgt
BinaryOps.BinaryOp(::typeof(isgt)) = BinaryOps.ISGT
"""
Less Than: `f(x::ℝ,y::ℝ)::ℝ = x < y`
"""
BinaryOps.ISLT
function islt end
juliaop(::typeof(BinaryOps.ISLT)) = islt
BinaryOps.BinaryOp(::typeof(islt)) = BinaryOps.ISLT
"""
Greater Than or Equal: `f(x::ℝ,y::ℝ)::ℝ = x ≥ y`
"""
BinaryOps.ISGE
function isge end
juliaop(::typeof(BinaryOps.ISGE)) = isge
BinaryOps.BinaryOp(::typeof(isge)) = BinaryOps.ISGE
"""
Less Than or Equal: `f(x::ℝ,y::ℝ)::ℝ = x ≤ y`
"""
BinaryOps.ISLE
function isle end
juliaop(::typeof(BinaryOps.ISLE)) = isle
BinaryOps.BinaryOp(::typeof(isle)) = BinaryOps.ISLE
"""
Minimum: `f(x::ℝ,y::ℝ)::ℝ = min(x, y)`
"""
BinaryOps.MIN
juliaop(::typeof(BinaryOps.MIN)) = min
BinaryOps.BinaryOp(::typeof(min)) = BinaryOps.MIN
"""
Maximum: `f(x::ℝ,y::ℝ)::ℝ = max(x, y)`
"""
BinaryOps.MAX
juliaop(::typeof(BinaryOps.MAX)) = max
BinaryOps.BinaryOp(::typeof(max)) = BinaryOps.MAX
"""
Logical OR: `f(x::ℝ,y::ℝ)::ℝ = (x ≠ 0) ∨ (y ≠ 0)`
"""
BinaryOps.LOR
function ∨ end
juliaop(::typeof(BinaryOps.LOR)) = ∨
BinaryOps.BinaryOp(::typeof(∨)) = BinaryOps.LOR
"""
Logical AND: `f(x::ℝ,y::ℝ)::ℝ = (x ≠ 0) ∧ (y ≠ 0)`
"""
BinaryOps.LAND
function ∧ end
juliaop(::typeof(BinaryOps.LAND)) = ∧
BinaryOps.BinaryOp(::typeof(∧)) = BinaryOps.LAND
"""
Logical AND: `f(x::ℝ,y::ℝ)::ℝ = (x ≠ 0) ⊻ (y ≠ 0)`
"""
BinaryOps.LXOR
function lxor end
juliaop(::typeof(BinaryOps.LXOR)) = lxor
BinaryOps.BinaryOp(::typeof(lxor)) = BinaryOps.LXOR
"""
4-Quadrant Arc Tangent: `f(x::F, y::F)::F = tan⁻¹(y/x)`
"""
BinaryOps.ATAN2
juliaop(::typeof(BinaryOps.ATAN2)) = atan
BinaryOps.BinaryOp(::typeof(atan)) = BinaryOps.ATAN2
"""
Hypotenuse: `f(x::F, y::F)::F = √(x² + y²)`
"""
BinaryOps.HYPOT
juliaop(::typeof(BinaryOps.HYPOT)) = hypot
BinaryOps.BinaryOp(::typeof(hypot)) = BinaryOps.HYPOT
"""
Float remainder of x / y rounded towards zero.
"""
BinaryOps.FMOD
#Is this available?
function fmod end
juliaop(::typeof(BinaryOps.FMOD)) = fmod
BinaryOps.BinaryOp(::typeof(fmod)) = BinaryOps.FMOD
"""
Float remainder of x / y rounded towards nearest integral value.
"""
BinaryOps.REMAINDER
juliaop(::typeof(BinaryOps.REMAINDER)) = rem
BinaryOps.BinaryOp(::typeof(rem)) = BinaryOps.REMAINDER
"""
LDEXP: `f(x::F, y::F)::F = x × 2ⁿ`
"""
BinaryOps.LDEXP
juliaop(::typeof(BinaryOps.LDEXP)) = ldexp
BinaryOps.BinaryOp(::typeof(ldexp)) = BinaryOps.LDEXP
"""
Copysign: Value with magnitude of x and sign of y.
"""
BinaryOps.COPYSIGN
juliaop(::typeof(BinaryOps.COPYSIGN)) = copysign
BinaryOps.BinaryOp(::typeof(copysign)) = BinaryOps.COPYSIGN
"""
Bitwise OR: `f(x::ℤ, y::ℤ)::ℤ = x | y`
"""
BinaryOps.BOR
juliaop(::typeof(BinaryOps.BOR)) = |
BinaryOps.BinaryOp(::typeof(|)) = BinaryOps.BOR
"""
Bitwise AND: `f(x::ℤ, y::ℤ)::ℤ = x & y`
"""
BinaryOps.BAND
juliaop(::typeof(BinaryOps.BAND)) = &
BinaryOps.BinaryOp(::typeof(&)) = BinaryOps.BAND
"""
Bitwise XOR: `f(x::ℤ, y::ℤ)::ℤ = x ^ y`
"""
BinaryOps.BXOR
juliaop(::typeof(BinaryOps.BXOR)) = ⊻
BinaryOps.BinaryOp(::typeof(⊻)) = BinaryOps.BXOR
"""
Bitwise XNOR: : `f(x::ℤ, y::ℤ)::ℤ = ~(x ^ y)`
"""
BinaryOps.BXNOR
juliaop(::typeof(BinaryOps.BXNOR)) = !⊻
BinaryOps.BinaryOp(::typeof(!⊻)) = BinaryOps.BXNOR
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
juliaop(::typeof(BinaryOps.EQ)) = ==
BinaryOps.BinaryOp(::typeof(==)) = BinaryOps.EQ
"""
Not Equals: `f(x::T, y::T)::Bool = x ≠ y`
"""
BinaryOps.NE
juliaop(::typeof(BinaryOps.NE)) = !=
BinaryOps.BinaryOp(::typeof(!=)) = BinaryOps.NE
"""
Greater Than: `f(x::T, y::T)::Bool = x > y`
"""
BinaryOps.GT
juliaop(::typeof(BinaryOps.GT)) = >
BinaryOps.BinaryOp(::typeof(>)) = BinaryOps.GT
"""
Less Than: `f(x::T, y::T)::Bool = x < y`
"""
BinaryOps.LT
juliaop(::typeof(BinaryOps.LT)) = <
BinaryOps.BinaryOp(::typeof(<)) = BinaryOps.LT
"""
Greater Than or Equal: `f(x::T, y::T)::Bool = x ≥ y`
"""
BinaryOps.GE
juliaop(::typeof(BinaryOps.GE)) = >=
BinaryOps.BinaryOp(::typeof(>=)) = BinaryOps.GE
"""
Less Than or Equal: `f(x::T, y::T)::Bool = x ≤ y`
"""
BinaryOps.LE
juliaop(::typeof(BinaryOps.LE)) = <=
BinaryOps.BinaryOp(::typeof(<=)) = BinaryOps.LE
"""
Complex: `f(x::F, y::F)::Complex = x + y × i`
"""
BinaryOps.CMPLX
juliaop(::typeof(BinaryOps.CMPLX)) = complex
BinaryOps.BinaryOp(::typeof(complex)) = BinaryOps.CMPLX
"""
0-Based row index of a: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = i`
"""
BinaryOps.FIRSTI
"""
1-Based row index of a: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = i + 1`
"""
BinaryOps.FIRSTI1
function firsti end
juliaop(::typeof(BinaryOps.FIRSTI1)) = firsti
BinaryOps.BinaryOp(::typeof(firsti)) = BinaryOps.FIRSTI1
"""
0-Based column index of a: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = j`
"""
BinaryOps.FIRSTJ
"""
1-Based column index of a: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = j + 1`
"""
BinaryOps.FIRSTJ1
function firstj end
juliaop(::typeof(BinaryOps.FIRSTJ1)) = firstj
BinaryOps.BinaryOp(::typeof(firstj)) = BinaryOps.FIRSTJ1
"""
0-Based row index of b: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = k`
"""
BinaryOps.SECONDI
"""
0-Based row index of b: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = k + 1`
"""
BinaryOps.SECONDI1
function secondi end
juliaop(::typeof(BinaryOps.SECONDI1)) = secondi
BinaryOps.BinaryOp(::typeof(secondi)) = BinaryOps.SECONDI1
"""
0-Based column index of b: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = l`
"""
BinaryOps.SECONDJ
"""
1-Based column index of b: `f(aᵢⱼ::T, bₖₗ::T)::Int64 = l + 1`
"""
BinaryOps.SECONDJ1
function secondj end
juliaop(::typeof(BinaryOps.SECONDJ1)) = secondj
BinaryOps.BinaryOp(::typeof(secondj)) = BinaryOps.SECONDJ1

#All binary ops will default to emul
defaultadd(f) = emul
# Default to eadd. This list is somewhat annoying. May require iteration.
for op ∈ [
    :+,
    :∨,
    :min,
    :max,
    :any,
]
    funcquote = quote
        defaultadd(::typeof($op)) = eadd
    end
    @eval($funcquote)
end


#Monoid operators
"""
Minimum monoid: `f(x::ℝ, y::ℝ)::ℝ = min(x, y)`
* Identity: +∞
* Terminal: -∞
"""
Monoids.MIN_MONOID
op(::typeof(Monoids.MIN_MONOID)) = BinaryOps.MIN
Monoids.Monoid(::typeof(min)) = Monoids.MIN_MONOID
"""
Max monoid: `f(x::ℝ, y::ℝ)::ℝ = max(x, y)`
* Identity: -∞
* Terminal: +∞
"""
Monoids.MAX_MONOID
op(::typeof(Monoids.MAX_MONOID)) = BinaryOps.MAX
Monoids.Monoid(::typeof(max)) = Monoids.MAX_MONOID
"""
Plus monoid: `f(x::T, y::T)::T = x + y`
* Identity: 0
* Terminal: nothing
"""
Monoids.PLUS_MONOID
op(::typeof(Monoids.PLUS_MONOID)) = BinaryOps.PLUS
Monoids.Monoid(::typeof(+)) = Monoids.PLUS_MONOID
"""
Times monoid: `f(x::T, y::T)::T = xy`
* Identity: 1
* Terminal: 0 for non Floating-point numbers.
"""
Monoids.TIMES_MONOID
op(::typeof(Monoids.TIMES_MONOID)) = BinaryOps.TIMES
Monoids.Monoid(::typeof(*)) = Monoids.TIMES_MONOID
"""
Any monoid: `f(x::T, y::T)::T = x or y`
* Identity: any
* Terminal: any
"""
Monoids.ANY_MONOID
op(::typeof(Monoids.ANY_MONOID)) = BinaryOps.ANY
Monoids.Monoid(::typeof(any)) = Monoids.ANY_MONOID
"""
Logical OR monoid: `f(x::Bool, y::Bool)::Bool = x ∨ y`
* Identity: false
* Terminal: true
"""
Monoids.LOR_MONOID
op(::typeof(Monoids.LOR_MONOID)) = BinaryOps.LOR
Monoids.Monoid(::typeof(∨)) = Monoids.LOR_MONOID
"""
Logical AND monoid: `f(x::Bool, y::Bool)::Bool = x ∧ y`
* Identity: true
* Terminal: false
"""
Monoids.LAND_MONOID
op(::typeof(Monoids.LAND_MONOID)) = BinaryOps.LAND
Monoids.Monoid(::typeof(∧)) = Monoids.LAND_MONOID
"""
Logical XOR monoid: `f(x::Bool, y::Bool)::Bool = x ⊻ y`
* Identity: false
* Terminal: nothing
"""
Monoids.LXOR_MONOID
op(::typeof(Monoids.LXOR_MONOID)) = BinaryOps.LXOR
Monoids.Monoid(::typeof(lxor)) = Monoids.LXOR_MONOID
"""
Logical XNOR monoid: `f(x::Bool, y::Bool)::Bool = x == y`
* Identity: true
* Terminal: nothing
"""
Monoids.LXNOR_MONOID
#Don't care, this is ==.
"""
Boolean Equality `f(x::Bool, y::Bool)::Bool = x == y`.
"""
Monoids.EQ_MONOID
op(::typeof(Monoids.EQ_MONOID)) = BinaryOps.EQ
Monoids.Monoid(::typeof(==)) = Monoids.EQ_MONOID
"""
Bitwise OR monoid: `f(x::ℤ, y::ℤ)::ℤ = x|y`
* Identity: All bits `0`.* Terminal: All bits `1`.
"""
Monoids.BOR_MONOID
op(::typeof(Monoids.BOR_MONOID)) = BinaryOps.BOR
Monoids.Monoid(::typeof(|)) = Monoids.BOR_MONOID
"""
Bitwise AND monoid: `f(x::ℤ, y::ℤ)::ℤ = x&y`
* Identity: All bits `1`.
* Terminal: All bits `0`.
"""
Monoids.BAND_MONOID
op(::typeof(Monoids.BAND_MONOID)) = BinaryOps.BAND
Monoids.Monoid(::typeof(&)) = Monoids.BAND_MONOID
"""
Bitwise XOR monoid: `f(x::ℤ, y::ℤ)::ℤ = x^y`
* Identity: All bits `0`.
* Terminal: nothing
"""
Monoids.BXOR_MONOID
op(::typeof(Monoids.BXOR_MONOID)) = BinaryOps.BXOR
Monoids.Monoid(::typeof(⊻)) = Monoids.BXOR_MONOID
"""
Bitwise XNOR monoid: `f(x::ℤ, y::ℤ)::ℤ = ~(x^y)`
* Identity: All bits `1`.
* Terminal: nothing
"""
Monoids.BXNOR_MONOID
op(::typeof(Monoids.BXNOR_MONOID)) = BinaryOps.BXNOR
Monoids.Monoid(::typeof(!⊻)) = Monoids.BXNOR_MONOID

for oplus ∈ [(:max, "MAX"), (:min, "MIN"), (:+, "PLUS"), (:*, "TIMES"), (:any, "ANY")]
    for otimes ∈ [
        (:/, "DIV"),
        (:\, "RDIV"),
        (:first, "FIRST"),
        (:firsti, "FIRSTI1"),
        (:firstj, "FIRSTJ1"),
        (:iseq, "ISEQ"),
        (:isge, "ISGE"),
        (:isgt, "ISGT"),
        (:isle, "ISLE"),
        (:islt, "ISLT"),
        (:isne, "ISNE"),
        (:∧, "LAND"),
        (:∨, "LOR"),
        (:lxor, "LXOR"),
        (:max, "MAX"),
        (:min, "MIN"),
        (:-, "MINUS"),
        (:rminus, "RMINUS"),
        (:second, "SECOND"),
        (:secondi, "SECONDI1"),
        (:secondj, "SECONDJ1"),
        (:*, "TIMES"),
        (:+, "PLUS"),
    ]
        rig = Symbol(oplus[2], "_", otimes[2])
        funcquote = quote
            Semirings.Semiring(::typeof($(oplus[1])), ::typeof($(otimes[1]))) = $rig
        end
        @eval($funcquote)
    end
end

#Select Ops

"""
    select(TRIL, A, k=0)

Select the entries on or below the `k`th diagonal of A.
"""
TRIL
SelectOp(::typeof(LinearAlgebra.tril)) = TRIL
"""
    select(TRIU, A, k=0)

Select the entries on or above the `k`th diagonal of A.

See also: `LinearAlgebra.tril`
"""
TRIU
SelectOp(::typeof(LinearAlgebra.triu)) = TRIU
"""
    select(DIAG, A, k=0)

Select the entries on the `k`th diagonal of A.

See also: `LinearAlgebra.triu`
"""
DIAG
SelectOp(::typeof(LinearAlgebra.diag)) = DIAG
"""
    select(OFFDIAG, A, k=0)

Select the entries **not** on the `k`th diagonal of A.
"""
OFFDIAG
function offdiag end #I don't know of a function which does this already.
SelectOp(::typeof(offdiag)) = OFFDIAG
"""
    select(NONZERO, A)

Select all entries in A with nonzero value.
"""
NONZERO
SelectOp(::typeof(nonzeros)) = NONZERO

# I don't believe these should have Julia equivalents.
# Instead select(==, A, 0) will find EQ_ZERO internally.
"""
    select(EQ_ZERO, A)

Select all entries in A equal to zero.
"""
EQ_ZERO
"""
    select(GT_ZERO, A)

Select all entries in A greater than zero.
"""
GT_ZERO
"""
    select(GE_ZERO, A)

Select all entries in A greater than or equal to zero.
"""
GE_ZERO
"""
    select(LT_ZERO, A)

Select all entries in A less than zero.
"""
LT_ZERO
"""
    select(LE_ZERO, A)

Select all entries in A less than or equal to zero.
"""
LE_ZERO
"""
    select(NE, A, k)

Select all entries not equal to `k`.
"""
NE
SelectOp(::typeof(!=)) = NE
"""
    select(EQ, A, k)

Select all entries equal to `k`.
"""
EQ
SelectOp(::typeof(==)) = EQ
"""
    select(GT, A, k)

Select all entries greater than `k`.
"""
GT
SelectOp(::typeof(>)) = GT
"""
    select(GE, A, k)

Select all entries greater than or equal to `k`.
"""
GE
SelectOp(::typeof(>=)) = GE
"""
    select(LT, A, k)

Select all entries less than `k`.
"""
LT
SelectOp(::typeof(<)) = LT
"""
    select(LE, A, k)

Select all entries less than or equal to `k`.
"""
LE
SelectOp(::typeof(<=)) = LE
