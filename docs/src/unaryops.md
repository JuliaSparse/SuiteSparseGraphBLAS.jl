# Unary Operators

`UnaryOp`s are fairly straightforward $z = f(x)$ and their meaning should be clear from the name in most cases. 

`UnaryOp`s are used only in the `map` and [`apply`](@ref) functions.

```@repl
using SuiteSparseGraphBLAS

x = GBVector([1.5, 0, pi])

y = map(sin, x)

map(asin, y)
```

Internally functions are lowered like this:

```@repl
using SuiteSparseGraphBLAS

op = unaryop(sin, Float64)

map(op, GBVector([1.5, 0, pi]))
```

## Built-Ins

The following functions are built into SuiteSparse:GraphBLAS. They are, much faster than arbitrary Julia functions and should be used when possible.

| Julia Function             | GraphBLAS Name | Notes |
|:---------------------------|----------------|-------|
| `identity`                 | `IDENTITY`     |       |
| `-`                        | `AINV`         |       |
| `inv`                      | `MINV`         |       |
| `one`                      | `ONE`          |       |
| `!`                        | `LNOT`         |       |
| `abs`                      | `ABS`          |       |
| `~`                        | `BNOT`         |       |
| `positioni`                | `POSITIONI`    |       |
| `positionj`                | `POSITIONJ`    |       |
| `sqrt`                     | `SQRT`         |       |
| `log`                      | `LOG`          |       |
| `exp`                      | `EXP`          |       |
| `log10`                    | `LOG10`        |       |
| `log2`                     | `LOG2`         |       |
| `exp2`                     | `EXP2`         |       |
| `expm1`                    | `EXPM1`        |       |
| `log1p`                    | `LOG1P`        |       |
| `sin`                      | `SIN`          |       |
| `cos`                      | `COS`          |       |
| `tan`                      | `TAN`          |       |
| `asin`                     | `ASIN`         |       |
| `acos`                     | `ACOS`         |       |
| `atan`                     | `ATAN`         |       |
| `sinh`                     | `SINH`         |       |
| `cosh`                     | `COSH`         |       |
| `tanh`                     | `TANH`         |       |
| `asinh`                    | `ASINH`        |       |
| `acosh`                    | `ACOSH`        |       |
| `atanh`                    | `ATANH`        |       |
| `sign`                     | `SIGNUM`       |       |
| `ceil`                     | `CEIL`         |       |
| `floor`                    | `FLOOR`        |       |
| `round`                    | `ROUND`        |       |
| `trunc`                    | `TRUNC`        |       |
| `SpecialFunctions.lgamma`  | `LGAMMA`       |       |
| `SpecialFunctions.gamma`   | `TGAMMA`       |       |
| `erf`                      | `ERF`          |       |
| `erfc`                     | `ERFC`         |       |
| `frexpx`                   | `FREXPX`       |       |
| `frexpe`                   | `FREXPE`       |       |
| `isinf`                    | `ISINF`        |       |
| `isnan`                    | `ISNAN`        |       |
| `isfinite`                 | `ISFINITE`     |       |
| `conj`                     | `CONJ`         |       |
| `real`                     | `CREAL`        |       |
| `imag`                     | `CIMAG`        |       |
| `angle`                    | `CARG`         |       |
