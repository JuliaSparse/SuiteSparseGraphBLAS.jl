[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliasparse.github.io/SuiteSparseGraphBLAS.jl/dev/)

# SuiteSparseGraphBLAS.jl
A fast, general sparse linear algebra and graph computation package, based on SuiteSparse:GraphBLAS.

## v1.0
v1.0 is currently planned to release on Monday August 2nd. Check back then for benchmarks, a more Julian interface, and better integrations with the wider ecosystem!

### Installation
```julia
using Pkg
Pkg.add("SuiteSparseGraphBLAS")
```

## Benchmarks

```julia
julia> s = sprand(Float64, 100000, 100000, 0.05);
julia> v = sprand(Float64, 100000, 1000, 0.1);
julia> @btime s * v
  157.211 s (8 allocations: 1.49 GiB)
julia> s = GBMatrix(s); v = GBMatrix(v); GC.gc();
# Single-threaded
julia> @btime s * v
  241.806 s (26 allocations: 1.49 GiB)
# 2 threads
julia> @btime s * v
  126.153 s (26 allocations: 1.50 GiB)
# 16 threads
julia> @btime s * v
  64.622 s (26 allocations: 1.54 GiB)
```

## Acknowledgements
Original author: Abhinav Mehndiratta

Current maintainer: William Kimmerer

SuiteSparse author: Tim Davis

Mentors: Viral B Shah, Miha Zgubic
