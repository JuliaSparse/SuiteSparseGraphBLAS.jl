# Monoids

A monoid is made up of a set or domain $T$ and a binary operator $z = f(x, y)$ operating on the same domain, $T \times T \rightarrow T$.
This binary operator must be associative, that is $f(a, f(b, c)) = f(f(a, b), c)$ is always true. Associativity is important for operations like `reduce` and the multiplication step of `mul!`.

The operator is also be equipped with an identity such that $f(x, 0) = f(0, x) = x$. Some monoids are equipped with a terminal or annihilator such that $z = f(z, x) \forall x$.

Monoids are used primarily in the `reduce`(@ref) operation. Their other use is as a component of semirings in the [`mul!`](@ref) operation.

## Built-Ins

| Julia Function | GraphBLAS Name | Notes                                                                 |
|----------------|----------------|-----------------------------------------------------------------------|
| `max`          | `MAX_MONOID`   | identity: `typemax`, terminal: `typemin`                              |
| `min`          | `MIN_MONOID`   | identity: `typemin`, terminal: `typemax`                              |
| `+`            | `PLUS_MONOID`  | identity: `zero`                                                      |
| `*`            | `TIMES_MONOID` | identity: `one`, terminal: `zero` (terminal only for non-Float types) |
| `any`          | `ANY_MONOID`   | identity, terminal: any value in domain                               |
| `&`            | `BAND_MONOID`  | identity: `typemax`, terminal: `zero`                                 |
| `\|`           | `BOR_MONOID`   | identity: `zero`, terminal: `typemax`                                 |
| `⊻`            | `BXOR_MONOID`  | identity: `zero`                                                      |
| `lxor`         | `LXOR_MONOID`  | identity: `false`                                                     |
| `==`           | `LXNOR_MONOID` | identity: `true`                                                      |
| `∨`            | `LOR_MONOID`   | identity: `false`, term: `true`                                       |
| `∧`            | `LAND_MONOID`  | identity: `true`, term: `false`                                       |
|                |                |                                                                       |
|                |                |                                                                       |
|                |                |                                                                       |