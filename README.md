[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://graphblas.juliasparse.org/dev/)

# SuiteSparseGraphBLAS.jl
A fast, general sparse linear algebra and graph computation package, based on SuiteSparse:GraphBLAS.

## v0.5
v0.5 is planned to release in August, after the entire GraphBLAS interface is available and some memory pressure issues have been sorted out. Check back then for more benchmarks, a more Julian interface, automatic differentiation support with ChainRules.jl and better integration with the wider ecosystem!

If you're fine with sharp edges then give v0.4 a try, and let me know of any issues you find.
The docs should provide enough information to run virtually the entire set of GraphBLAS functions.

### Installation
```julia
using Pkg
Pkg.add("SuiteSparseGraphBLAS")
```

## Benchmarks

```julia
julia> using SuiteSparseGraphBLAS
# Standard arithmetic semiring (+, *) matrix multiplication
julia> s = sprand(Float64, 100000, 100000, 0.05);
julia> v = sprand(Float64, 100000, 1000, 0.1);
julia> @btime s * v
  157.211 s (8 allocations: 1.49 GiB)
julia> s = GBMatrix(s); v = GBMatrix(v);
# Single-threaded
julia> @btime s * v
  241.806 s (26 allocations: 1.49 GiB)
# 2 threads
julia> @btime s * v
  126.153 s (26 allocations: 1.50 GiB)
# 4 threads
julia> @btime s * v
  64.622 s (26 allocations: 1.54 GiB)

# Indexing
julia> s = sprand(Float64, 100000, 100000, 0.05);
julia> @btime s[1:10:end, end:-10:1]
  947.438 ms (11 allocations: 76.34 MiB)
julia> s = GBMatrix(s);
julia> @btime s[1:10:end, end:-10:1]
  626.943 ms (33 allocations: 1.14 KiB)
```

## Acknowledgements
This work was funded as part of Google Summer of Code over 3 summers, 2 of which were for Abhinav Mehndiratta and the last of which was for William Kimmerer.

Current maintainer: William Kimmerer

Original author: Abhinav Mehndiratta

SuiteSparse author: Tim Davis

Mentors: Viral B Shah, Miha Zgubic
