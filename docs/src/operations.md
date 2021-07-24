# Operations

GraphBLAS operations cover most of the typical linear algebra operations on arrays in Julia.

## Correspondence of GraphBLAS C functions and Julia functions

| GraphBLAS           | Operation                                                        | Julia                                   |
|:--------------------|:----------------------------------------:                        |----------:                              |
|`mxm`, `mxv`, `vxm`  |``\bf C \langle M \rangle = C \odot AB``                          |`mul[!]`                                 |
|`eWiseMult`          |``\bf C \langle M \rangle = C \odot (A \otimes B)``               |`emul[!]`                                |
|`eWiseAdd`           |``\bf C \langle M \rangle = C \odot (A \oplus  B)``               |`eadd[!]`                                |
|`extract`            |``\bf C \langle M \rangle = C \odot A(I,J)``                      |`extract[!]`, `getindex`                 |
|`subassign`          |``\bf C (I,J) \langle M \rangle = C(I,J) \odot A``                |`subassign[!]`, `setindex!`              |
|`assign`             |``\bf C \langle M \rangle (I,J) = C(I,J) \odot A``                |`assign[!]`                              |
|`apply`              |``{\bf C \langle M \rangle = C \odot} f{\bf (A)}``                |`map[!]`                                 |
|                     |``{\bf C \langle M \rangle = C \odot} f({\bf A},y)``              |                                         |
|                     |``{\bf C \langle M \rangle = C \odot} f(x,{\bf A})``              |                                         |
|`select`             |``{\bf C \langle M \rangle = C \odot} f({\bf A},k)``              |`select[!]`                              |
|`reduce`             |``{\bf w \langle m \rangle = w \odot} [{\oplus}_j {\bf A}(:,j)]`` |`reduce[!]`                              |
|                     |``s = s \odot [{\oplus}_{ij}  {\bf A}(i,j)]``                     |                                         |
|`transpose`          |``\bf C \langle M \rangle = C \odot A^{\sf T}``                   |`gbtranspose[!]`, lazy: `transpose`, `'` |
|`kronecker`          |``\bf C \langle M \rangle = C \odot \text{kron}(A, B)``           |`kron[!]`                                |

where ``\bf M`` is a `GBArray` mask, ``\odot`` is a binary operator for accumulating into ``\bf C``, and ``\otimes`` and ``\oplus`` are a binary operation and commutative monoid respectively. 

!!! note "assign vs subassign"
    `subassign` is equivalent to `assign` except that the mask in `subassign` has the dimensions of ``\bf C(I,J)`` vs the dimensions of ``C`` for `assign`, and elements outside of the mask will never be modified by `subassign`. See the [GraphBLAS User Guide](https://github.com/DrTimothyAldenDavis/GraphBLAS/blob/stable/Doc/GraphBLAS_UserGuide.pdf) for more details.

## Common arguments

The operations above have often accept most or all of the following arguments.

### `op` - `UnaryOp`, `BinaryOp`, `Monoid`, `Semiring`, or `SelectOp`:

This is the most important argument for most of the GraphBLAS operations. It determines ``\oplus``, ``\otimes``, or ``f`` in the table above as well as the semiring used in `mul`.
Most operations are restricted to one type of operator.

!!! tip "Built-Ins"
    The built-in operators can be found in the submodules: `UnaryOps`, `BinaryOps`, `Monoids`, and `Semirings`.

### `desc` - `Descriptor`:

The descriptor argument allows the user to modify the operation in some fashion. The most common options are:

- `desc.[input1 | input2] == [DEFAULT | TRANSPOSE]` 

    Transposes the inputs and can be found in `[T0 | T1 | T0T1]`. 
    Typically you should use Julia's built-in transpose functionality.

- `desc.mask == [DEFAULT | STRUCTURE | COMPLEMENT | STRUCT_COMP]` 

    If `STRUCTURE` is set the operation will use the presence of a value rather than the value itself to determine whether the index is masked. 
    If `COMPLEMENT` is set the presence/truth value is complemented (ie. if **no** value is present or the value is **false** that index is masked).

- `desc.output == [DEFAULT | REPLACE]`

    If `REPLACE` is set the operation will replace all values in the output matrix **after** the accumulation step. 
    If an index is found in the output matrix, but not in the results of the operation it will be set to `nothing`. 


### `accum` - `BinaryOp`:

The `accum` keyword argument provides a binary operation to accumulate results into the result array. 
The accumulation step is performed **before** masking.

### `mask` - `GBArray`:

The `mask` keyword argument determines whether each index from the result of an operation appears in the output. 
The mask may be structural, where the presence of a value indicates the mask is `true`, or valued where the value of the mask indicates its truth value. 
The mask may also be complemented. These options are controlled by the `desc` argument.

## Order of Operations

A GraphBLAS operation occurs in the following order (steps are skipped when possible):

1. Calculate `T = <operation>(args...)`
2. Elementwise accumulate `Z[i,j] = accum(C[i,j], T[i,j])`
3. Optionally masked assignment `C[i,j] = mask[i,j] ? Z[i,j] : [nothing | C[i,j]]`

If `REPLACE` is set the option in step 3. is `nothing`, otherwise it is `C[i,j]`.

## Operation Documentation

All non-mutating operations below support a mutating form by adding an output array as the first argument as well as the `!` function suffix. 

### `mul`
```@docs
mul
```

```@docs
emul
eadd
extract
subassign!
assign!
Base.map
select
Base.reduce
gbtranspose
LinearAlgebra.kron
```
