# Semirings

A [semiring](https://mathworld.wolfram.com/Semiring.html) in GraphBLAS is a set of three domains $D_1$, $D_2$, and $D_3$, along with two binary operators and an identity element $\mathbb{0}$. 

The first operator, $\oplus$ or "add" is a commutative and associative [monoid](https://mathworld.wolfram.com/Monoid.html) defined on $D_3 \times D_3 \rightarrow D_3$. The identity of the monoid is $\mathbb{0}$. See [Monoids](@ref) for more information.

The second, $\otimes$ or "multiply", is a binary operator defined on $D_1 \times D_2 \rightarrow D_3$. See [Binary Operators](@ref) for more information. 

A semiring is denoted by a tuple $(D_1, D_2, D_3, \oplus, \otimes, \mathbb{0})$. However in the vast majority of cases $D_1 = D_2 = D_3$ so this is often shortened to $(\oplus, \otimes)$.

Semirings are used in a single GraphBLAS operation, [`mul[!]`](@ref mul).

## Built-Ins
There are over 200 built-in semirings available as constants in the `Semirings` submodule. These are named `<ADD>_<MULTIPLY>` and include many of the most commonly used semirings such as:

- Arithmetic semiring $(+, \times)$, available as `Semirings.PLUS_TIMES` and as the default operator for `mul[!]`.
- Tropical semirings $(\max, +)$, available as `Semirings.MAX_PLUS`, and $(\min, +)$, available as `Semirings.MIN_PLUS`).
- Boolean semiring $(\vee, \wedge)$ available as `Semirings.LOR_LAND`. 
- GF2, the two-element Galois Field $(\text{xor}, \wedge)$, available as `Semirings.LXOR_LAND`.

Below are the built-in semirings available, along with their associated monoids, binary operators, and types.
For common semirings where the binary operator and monoid have equivalent julia functions, those functions are listed.


!!! note
    In all cases the input and output types of the semirings are the same, **except** for cases where the "add" types and "multiply" output output types are boolean, such as in `LAND_GE`.

```@eval
using Pkg
Pkg.activate("..")
cd("..")
using SuiteSparseGraphBLAS
using Latexify
head = ["Semiring", "⊕", "⊗", "Types"]
v1 = filter((x) -> getproperty(Semirings, x) isa SuiteSparseGraphBLAS.AbstractSemiring, names(Semirings))
ops = getproperty.(Ref(Semirings), v1)
v2 = convert(Vector{Any}, SuiteSparseGraphBLAS.addop.(ops))
v3 = convert(Vector{Any}, SuiteSparseGraphBLAS.mulop.(ops))
for i in 1:length(v2)
    if v2[i] === nothing
        x = 
        v2[i] = replace(summary(SuiteSparseGraphBLAS.monoid(ops[i])), "SuiteSparseGraphBLAS.Monoids." => "")[1:end-2]
    end
    if v3[i] === nothing
        v3[i] = replace(summary(SuiteSparseGraphBLAS.binop(ops[i])), "SuiteSparseGraphBLAS.BinaryOps." => "")[1:end-2]
    end
end
v4 = SuiteSparseGraphBLAS.validtypes.(ops)

v1 = "`" .* string.(v1) .* "`"
v2 = "`" .* string.(v2) .* "`"
v3 = "`" .* string.(v3) .* "`"
Latexify.mdtable(hcat(v1,v2,v3,v4); head, latex=false)
```