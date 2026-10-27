# Binary Operators

```@meta
DocTestSetup = :(using SuiteSparseGraphBLAS)
DocTestFilters = [r"memory: \d+ bytes", r"Ptr{.*}\(0x[0-9a-f]+\)"]
```

Binary operators are defined on three domains $D_1 \times D_2 \rightarrow D_3$.
However, the vast majority of binary operators are defined on a single domain.

`BinaryOp`s are in almost every GraphBLAS operation. They are the primary `op` argument for [`emul`](@ref), [`eadd`](@ref), and [`apply`](@ref). `BinaryOp`s which are also monoids may be used in [`reduce`](@ref). And every GraphBLAS operation which takes an `accum` keyword argument accepts a `BinaryOp`.

In almost all cases you should pass Julia functions, which will be mapped to built-in operators, or used to create a new user-defined operator.

```jldoctest
julia> x = GBMatrix([[1,2] [3,4]])
2x2 GraphBLAS int64_t matrix, full by col
  4 entries, memory: 272 bytes

    (1,1)   1
    (2,1)   2
    (1,2)   3
    (2,2)   4

julia> x .+ x
2x2 GraphBLAS int64_t matrix, full by row
  4 entries, memory: 272 bytes

    (1,1)   2
    (1,2)   6
    (2,1)   4
    (2,2)   8

julia> eadd(x, x, +)
2x2 GraphBLAS int64_t matrix, full by row
  4 entries, memory: 272 bytes

    (1,1)   2
    (1,2)   6
    (2,1)   4
    (2,2)   8

julia> x .^ x
2x2 GraphBLAS int64_t matrix, full by row
  4 entries, memory: 272 bytes

    (1,1)   1
    (1,2)   27
    (2,1)   4
    (2,2)   256

julia> emul(x, x, ^)
2x2 GraphBLAS int64_t matrix, full by row
  4 entries, memory: 272 bytes

    (1,1)   1
    (1,2)   27
    (2,1)   4
    (2,2)   256

julia> x2 = Float64.(x)
2x2 GraphBLAS double matrix, full by col
  4 entries, memory: 272 bytes

    (1,1)    1
    (2,1)    2
    (1,2)    3
    (2,2)    4

julia> eadd!(x2, x, x, +; accum=/)
2x2 GraphBLAS double matrix, full by col
  4 entries, memory: 272 bytes

    (1,1)    0.5
    (2,1)    0.5
    (1,2)    0.5
    (2,2)    0.5
```

Internally functions are lowered like this:

```jldoctest
julia> typedop = binaryop(+, Int64, Int64)
SuiteSparseGraphBLAS.TypedBinaryOperator{typeof(+), Int64, Int64, Int64}(true, true, "GrB_PLUS_INT64", Ptr{SuiteSparseGraphBLAS.LibGraphBLAS.GB_BinaryOp_opaque}(0x0000736051461e20), +, nothing)

julia> eadd(GBVector([1,2]), GBVector([3,4]), typedop)
2x1 GraphBLAS int64_t matrix, full by col
  2 entries, memory: 256 bytes

    (1,1)   4
    (2,1)   6
```

## Built-Ins

All built-in binary operators can be found below:

| Julia Function | GraphBLAS Name | Notes                                                     |
|:----------------|----------------:|------------------------------------------------------   |
| `first`           | `FIRST`          | `first(x, y) = x`                                    |
| `second`          | `SECOND`         | `second(x, y) = y`                                   |
| `any`             | `ANY`            | `any(x, y)` can return either `x` or `y`. The result is non-deterministic.|
| `pair`            | `PAIR`           | `pair(x, y) = 1` if `x` **and** `y` are stored values|
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
