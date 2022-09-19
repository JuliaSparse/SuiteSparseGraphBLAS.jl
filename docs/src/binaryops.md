# Binary Operators

Binary operators are defined on three domains $D_1 \times D_2 \rightarrow D_3$.
However, the vast majority of binary operators are defined on a single domain.

`BinaryOp`s are in almost every GraphBLAS operation. They are the primary `op` argument for [`emul`](@ref), [`eadd`](@ref), and [`apply`](@ref). `BinaryOp`s which are also monoids may be used in [`reduce`](@ref). And every GraphBLAS operation which takes an `accum` keyword argument accepts a `BinaryOp`.

In almost all cases you should pass Julia functions, which will be mapped to built-in operators, or used to create a new user-defined operator.

```@repl
using SuiteSparseGraphBLAS

x = GBMatrix([[1,2] [3,4]])

x .+ x
eadd(x, x, +)

x .^ x
emul(x, x, ^)

x2 = Float64.(x)
eadd!(x2, x, x, +; accum=/)
```

Internally functions are lowered like this:

```@repl
using SuiteSparseGraphBLAS

typedop = binaryop(+, Int64, Int64)

eadd(GBVector([1,2]), GBVector([3,4]), typedop)
```

## Built-Ins

All built-in binary operators can be found below:

| Julia Function | GraphBLAS Name | Notes                                                     |
|:----------------|----------------:|------------------------------------------------------   |
| `first`           | `FIRST`          | `first(x, y) = x`                                    |
| `second`          | `SECOND`         | `second(x, y) = y`                                   |
| `any`             | `ANY`            | `any(x, y) = 1` if `x` **or** `y` are stored values  |
| `pair`            | `PAIR`           | `any(x, y) = 1` if `x` **and** `y` are stored values |
| `+`               | `PLUS`           |                                                      |
| `-`               | `MINUS`          |                                                      |
| `rminus`          | `RMINUS`         |                                                      |
| `*`               | `TIMES`          |                                                      |
| `/`               | `DIV`            |                                                      |
| `\`               | `RDIV`           |                                                      |
| `^`               | `POW`            |                                                      |
| `iseq`            | `ISEQ`           | `iseq(x::T, y::T) = T(x == y)`                       |
| `isne`            | `ISNE`           | `isne(x::T, y::T) = T(x != y)`                       |
| `min`             | `MIN`            |                                                      |
| `max`             | `MAX`            |                                                      |
| `isgt`            | `ISGT`           | `isgt(x::T, y::T) = T(x > y)`                        |
| `islt`            | `ISLT`           | `islt(x::T, y::T) = T(x < y)`                        |
| `isge`            | `ISGE`           | `isge(x::T, y::T) = T(x >= y)`                       |
| `isle`            | `ISLE`           | `isle(x::T, y::T) = T(x <= y)`                       |
| `∨`               | `LOR`            |                                                      |
| `∧`               | `LAND`           |                                                      |
| `lxor`            | `LXOR`           |                                                      |
| `==`              | `EQ`             |                                                      |
| `!=`              | `NE`             |                                                      |
| `>`               | `GT`             |                                                      |
| `<`               | `LT`             |                                                      |
| `>=`              | `GE`             |                                                      |
| `<=`              | `LE`             |                                                      |
| `xnor`            | `LXNOR`          |                                                      |
| `atan`            | `ATAN2`          |                                                      |
| `hypot`           | `HYPOT`          |                                                      |
| `fmod`            | `FMOD`           |                                                      |
| `rem`             | `REMAINDER`      |                                                      |
| `ldexp`           | `LDEXP`          |                                                      |
| `copysign`        | `COPYSIGN`       |                                                      |
| `complex`         | `CMPLX`          |                                                      |
| `\|`              | `BOR`            |                                                      |
| `&`               | `BAND`           |                                                      |
| `⊻`               | `BXOR`           |                                                      |
| `bget`            | `BGET`           |                                                      |
| `bset`            | `BSET`           |                                                      |
| `bclr`            | `BCLR`           |                                                      |
| `>>`              | `BSHIFT`         |                                                      |
| `firsti0`         | `FIRSTI`         | `firsti0(A[i,j], B[k,l]) = i - 1`                    |
| `firsti`          | `FIRSTI1`        | `firsti(A[i,j], B[k,l]) = i`                         |
| `firstj0`         | `FIRSTJ`         | `firstj0(A[i,j], B[k,l]) = j - 1`                    |
| `firstj`          | `FIRSTJ1`        | `firstj(A[i,j], B[k,l]) = j`                         |
| `secondi0`        | `SECONDI`        | `secondi0(A[i,j], B[k,l]) = k - 1`                   |
| `secondi`         | `SECONDI1`       | `secondi(A[i,j], B[k,l]) = k`                        |
| `secondj0`        | `SECONDJ`        | `secondj0(A[i,j], B[k,l]) = l - 1`                   |
| `secondj`         | `SECONDJ1`       | `secondj(A[i,j], B[k,l]) = l`                        |