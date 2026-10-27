# Unary Operators

```@meta
DocTestSetup = :(using SuiteSparseGraphBLAS)
DocTestFilters = [r"memory: \d+ bytes", r"Ptr{.*}\(0x[0-9a-f]+\)"]
```

`UnaryOp`s are fairly straightforward $z = f(x)$ and their meaning should be clear from the name in most cases. 

`UnaryOp`s are used only in the `map` and [`apply`](@ref) functions.

```jldoctest
julia> x = GBVector([1.5, 0, pi])
3x1 GraphBLAS double matrix, full by col
  3 entries, memory: 264 bytes

    (1,1)    1.5
    (2,1)    0
    (3,1)    3.14159

julia> y = map(sin, x)
3x1 GraphBLAS double matrix, full by col
  3 entries, memory: 264 bytes

    (1,1)    0.997495
    (2,1)    0
    (3,1)    1.22465e-16

julia> map(asin, y)
3x1 GraphBLAS double matrix, full by col
  3 entries, memory: 264 bytes

    (1,1)    1.5
    (2,1)    0
    (3,1)    1.22465e-16
```

Internally functions are lowered like this:

```jldoctest
julia> op = unaryop(sin, Float64)
SuiteSparseGraphBLAS.TypedUnaryOperator{typeof(sin), Float64, Float64}(true, true, "GxB_SIN_FP64", Ptr{SuiteSparseGraphBLAS.LibGraphBLAS.GB_UnaryOp_opaque}(0x0000736051454500), sin, nothing)

julia> map(op, GBVector([1.5, 0, pi]))
3x1 GraphBLAS double matrix, full by col
  3 entries, memory: 264 bytes

    (1,1)    0.997495
    (2,1)    0
    (3,1)    1.22465e-16
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
| `rowindex`                 | `POSITIONI`    |       |
| `colindex`                 | `POSITIONJ`    |       |
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

Unary functions unique to SuiteSparseGraphBLAS are:
```@docs
SuiteSparseGraphBLAS.rowindex
SuiteSparseGraphBLAS.colindex
```