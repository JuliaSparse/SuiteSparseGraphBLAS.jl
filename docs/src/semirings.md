# Semirings

A [semiring](https://mathworld.wolfram.com/Semiring.html) in GraphBLAS is a set of three domains $D_1$, $D_2$, and $D_3$, along with two binary operators and an identity element $\mathbb{0}$. 

The first operator, $\oplus$ or "add" is a commutative and associative [monoid](https://mathworld.wolfram.com/Monoid.html) defined on $D_3 \times D_3 \rightarrow D_3$. The identity of the monoid is $\mathbb{0}$. See [Monoids](@ref) for more information.

The second, $\otimes$ or "multiply", is a binary operator defined on $D_1 \times D_2 \rightarrow D_3$. See [Binary Operators](@ref) for more information. 

A semiring is denoted by a tuple $(D_1, D_2, D_3, \oplus, \otimes, \mathbb{0})$. However in the vast majority of cases $D_1 = D_2 = D_3$ so this is often shortened to $(\oplus, \otimes)$.

Semirings are used in a single GraphBLAS operation, [`mul[!]`](@ref mul).

## Passing to Functions

`mul[!]` is the only function which accepts semirings, and the best method to do so is a tuple of binary functions like `mul(A, B, (max, +))`. An operator form is also available as `*(min, +)(A, B)`.

Semiring objects may be constructed in a similar fashion: `Semiring(max, +)`.