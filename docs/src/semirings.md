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

Below is the list of built-ins with the two binary operators as well as the domains available listed for each semiring.

!!! note
    In all cases the input and output types of the semirings are the same, **except** for cases where the "add" types and "multiply" output output types are boolean, such as in `LAND_GE`.

```@eval
using Pkg
Pkg.activate("..")
cd("..")
using SuiteSparseGraphBLAS
using Latexify
head = ["Semiring", "⊕", "⊗", "Types"]
v1 = filter((x) -> x != "Semirings", string.(names(Semirings)))
v2 = []
v3 = []
for rig in v1
    rigsplit = split(rig, '_')
    monoidname = rigsplit[1] .* "_MONOID"
    push!(v2, "[" .* rigsplit[1] .* "_MONOID](https://juliasparse.github.io/SuiteSparseGraphBLAS.jl/dev/monoids/#SuiteSparseGraphBLAS.Monoids.$monoidname)")
    push!(v3, "[" .* rigsplit[2] .* "](https://juliasparse.github.io/SuiteSparseGraphBLAS.jl/dev/binaryops/#SuiteSparseGraphBLAS.BinaryOps.$(rigsplit[2]))")
end

v4 = []
v1 = "`" .* v1 .* "`"
for op in names(Semirings)
    op == :Semirings && continue
    op = getproperty(Semirings, op)
    push!(v4, SuiteSparseGraphBLAS.tolist(SuiteSparseGraphBLAS.validtypes(op)))
end
Latexify.mdtable(hcat(v1,v2,v3,v4); head, latex=false)
```