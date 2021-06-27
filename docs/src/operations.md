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

## Order of Operations

A GraphBLAS operation occurs in the following order (steps are skipped when possible):

1. Calculate `T = <operation>(args...)`
2. Elementwise accumulate `Z[i,j] = accum(C[i,j], T[i,j])`
3. Optionally masked assignment `C[i,j] = mask[i,j] ? Z[i,j] : [nothing | C[i,j]]`

If `REPLACE` is set the option in step 3. is `nothing`, otherwise it is `C[i,j]`.

## Operation Documentation

```@docs
mul
emul
eadd
extract
extract!
subassign!
assign!
map
select
reduce
gbtranspose
kron
```
