# Operations

GraphBLAS operations cover most of the typical linear algebra operations on arrays in Julia.

## Correspondence of GraphBLAS C functions and Julia functions
| GraphBLAS           | Operation                                                        | Julia                                      |
|:--------------------|:---------------------------------------------------------------: |----------------------------------------:   |
|`mxm`, `mxv`, `vxm`  |``\bf C \langle M \rangle = C \odot AB``                          |`mul!` or `*`                             |
|`eWiseMult`          |``\bf C \langle M \rangle = C \odot (A \otimes B)``               |`emul[!]` or `.` broadcasting               |
|`eWiseAdd`           |``\bf C \langle M \rangle = C \odot (A \oplus  B)``               |`eadd[!]`                                   |
|`extract`            |``\bf C \langle M \rangle = C \odot A(I,J)``                      |`extract[!]`, `getindex`                    |
|`subassign`          |``\bf C (I,J) \langle M \rangle = C(I,J) \odot A``                |`subassign[!]` or `setindex!`               |
|`assign`             |``\bf C \langle M \rangle (I,J) = C(I,J) \odot A``                |`assign[!]`                                 |
|`apply`              |``{\bf C \langle M \rangle = C \odot} f{\bf (A)}``                |`apply[!]`, `map[!]` or `.` broadcasting    |
|                     |``{\bf C \langle M \rangle = C \odot} f({\bf A},y)``              |                                            |
|                     |``{\bf C \langle M \rangle = C \odot} f(x,{\bf A})``              |                                            |
|`select`             |``{\bf C \langle M \rangle = C \odot} f({\bf A},k)``              |`select[!]`                                 |
|`reduce`             |``{\bf w \langle m \rangle = w \odot} [{\oplus}_j {\bf A}(:,j)]`` |`reduce[!]`                                 |
|                     |``s = s \odot [{\oplus}_{ij}  {\bf A}(i,j)]``                     |                                            |
|`transpose`          |``\bf C \langle M \rangle = C \odot A^{\sf T}``                   |`gbtranspose[!]`, lazy: `transpose`, `'`    |
|`kronecker`          |``\bf C \langle M \rangle = C \odot \text{kron}(A, B)``           |`kron[!]`                                   |


where ``\bf M`` is a `GBArray` mask, ``\odot`` is a binary operator for accumulating into ``\bf C``, and ``\otimes`` and ``\oplus`` are binary operators or monoids. 

!!! note "assign vs subassign"
    `subassign` is equivalent to `assign` except that the mask in `subassign` has the dimensions of ``\bf C(I,J)`` vs the dimensions of ``C`` for `assign`. Elements outside of the mask will also never be modified by `subassign`. See the [GraphBLAS User Guide](https://github.com/DrTimothyAldenDavis/GraphBLAS/blob/stable/Doc/GraphBLAS_UserGuide.pdf) for more details.

## Common arguments

The operations typically accept one of the following types in the `op` argument.

### `op` - `Function`:

This argument determines ``\oplus``, ``\otimes``, or ``f`` in the table above as well as the semiring used in `mul`. See [Operators](@ref) for more information.

### `desc` - `Descriptor`:

The descriptor argument allows the user to modify the operation in some fashion. A new `Descriptor` can be created with default settings as: `d = Descriptor()`. The most common options are:

- `desc.[transpose_input1 | transpose_input2] == [true | false]`:

Typically you should use Julia's built-in transpose functionality.

- `desc.complement_mask == [true | false]`: 

If `complement_mask` is set the presence/truth value of the mask is complemented. See [`SuiteSparseGraphBLAS.Complement`](@ref) for a wrapper that sets this flag.

- `desc.structural_mask == [true | false]`:
    
If `structural_mask` is set the presence of a value in the mask determines the presence of values in the output, rather than the actual value of the mask.
See [`SuiteSparseGraphBLAS.Structural`](@ref) for a wrapper that sets this flag.

- `desc.replace_output == [true | false]`:

If this option is set the operation will replace all values in the output matrix **after** the accumulation step. 
If an index is found in the output matrix, but not in the results of the operation it will be set to `nothing`. 


### `accum` - `Function`:

The `accum` keyword argument provides a binary operation to accumulate results into the result array. 
The accumulation step is performed **before** masking.

### `mask` - `GBArray`:

The `mask` keyword argument determines whether each index from the result of an operation appears in the output. 
The mask may be structural, where the presence of a value indicates the mask is `true`, or valued where the value of the mask indicates its truth value. `mask = SuiteSparseGraphBLAS.Structural(A)` will use a structural mask.

The mask may also be complemented. `mask = SuiteSparseGraphBLAS.Complement(A)` or `mask = ~A` will complement a mask. These two options may be combined, for example `mask = ~SuiteSparseGraphBLAS.Structural(A)`.


## Operation Documentation

All non-mutating operations below support a mutating form by adding an output array as the first argument as well as the `!` function suffix. 

```@docs
*
emul
emul!
eadd
eadd!
eunion
eunion!
extract
extract!
subassign!
assign!
apply
apply!
select
select!
Base.reduce
gbtranspose
gbtranspose!
LinearAlgebra.kron
LinearAlgebra.kron!
mask
mask!
```

## Order of Operations

A GraphBLAS operation semantically occurs in the following order:

1. Calculate `T = <operation>(args...)`
2. Elementwise accumulate `Z[i,j] = accum(C[i,j], T[i,j])`
3. Optionally masked assignment `C[i,j] = mask[i,j] ? Z[i,j] : [nothing | C[i,j]]`

If `replace_output` is set the option in step 3. is `nothing`, otherwise it is `C[i,j]`.
