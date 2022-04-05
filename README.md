[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://graphblas.juliasparse.org/dev/)
[![](https://img.shields.io/badge/docs-stable-green.svg)](https://graphblas.juliasparse.org/stable/)
# SuiteSparseGraphBLAS.jl
A fast, general sparse linear algebra and graph computation package, based on SuiteSparse:GraphBLAS.

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
## Citing SuiteSparse:GraphBLAS

If you use SuiteSparseGraphBLAS.jl in your research please cite the serial SuiteSparse:GraphBLAS [paper](https://doi.org/10.1145/3322125):

```bibtex
    @article{10.1145/3322125,
    author = {Davis, Timothy A.},
    title = {Algorithm 1000: SuiteSparse:GraphBLAS: Graph Algorithms in the Language of Sparse Linear Algebra},
    year = {2019},
    issue_date = {December 2019},
    publisher = {Association for Computing Machinery},
    address = {New York, NY, USA},
    volume = {45},
    number = {4},
    issn = {0098-3500},
    url = {https://doi.org/10.1145/3322125},
    doi = {10.1145/3322125},
    journal = {ACM Trans. Math. Softw.},
    month = {dec},
    articleno = {44},
    numpages = {25},
    keywords = {GraphBLAS, Graph algorithms, sparse matrices}
    }
```

and the parallel SuiteSparse:GraphBLAS [paper](https://github.com/DrTimothyAldenDavis/GraphBLAS/blob/stable/Doc/toms_parallel_grb2.pdf):

```bibtex
    @article{DavisTOMS2022,
    author = {Davis, Timothy A.},
    title = {Algorithm 10xx: SuiteSparse:GraphBLAS: Parallel Graph Algorithms in the Language of Sparse Linear Algebra},
    year = {2022},
    publisher = {Association for Computing Machinery},
    address = {New York, NY, USA},
    url = {https://doi.org/10.1145/3322125},
    journal = {ACM Trans. Math. Softw.},
    numpages = {29},
    keywords = {GraphBLAS, Graph algorithms, sparse matrices}
    }
```


## Acknowledgements
This work was funded as part of Google Summer of Code over 3 summers, 2 of which were for Abhinav Mehndiratta and the last of which was for William Kimmerer.

Current maintainer: William Kimmerer

Original author: Abhinav Mehndiratta

SuiteSparse author: Tim Davis

Mentors: Viral B Shah, Miha Zgubic
