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

If you use SuiteSparseGraphBLAS.jl in your research please cite the following three papers:

[pdf](https://doi.org/10.1145/3322125):
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

[pdf](https://github.com/DrTimothyAldenDavis/GraphBLAS/blob/stable/Doc/toms_parallel_grb2.pdf):
```bibtex
    @article{GraphBLAS7,
  author = {Davis, Timothy A.},
  title = {Algorithm 10xx: SuiteSparse:GraphBLAS: Graph Algorithms in the Language of Sparse Linear Algebra},
  year = {2022},
  journal = {ACM Trans. Math. Softw.},
  month = {(under revision)},
  note={See GraphBLAS/Doc/toms_parallel_grb2.pdf},
  keywords = {GraphBLAS, Graph algorithms, sparse matrices}
}
```
[pdf](https://ieeexplore.ieee.org/stamp/stamp.jsp?arnumber=9622789&casa_token=VPmmUD8cdFcAAAAA:NYSm3tdjrBwF53rJxo9PqVRWzXY41hE6l1MoKpBqqZC0WESFPGx6PtN1SjVf8M4x01vfPrqU&tag=1)
```bibtex
@INPROCEEDINGS{9622789,
author={Pelletier, Michel and Kimmerer, Will and Davis, Timothy A. and Mattson, Timothy G.},
booktitle={2021 IEEE High Performance Extreme Computing Conference (HPEC)},
title={The GraphBLAS in Julia and Python: the PageRank and Triangle Centralities},
year={2021},
pages={1-7},
doi={10.1109/HPEC49654.2021.9622789},
ISSN={2643-1971},
month={Sep.}
}
```


## Acknowledgements
This work was funded as part of Google Summer of Code over 3 summers, 2 of which were for Abhinav Mehndiratta and the last of which was for William Kimmerer.

Original author: Abhinav Mehndiratta

SuiteSparse author: Tim Davis

Mentors: Viral B Shah, Miha Zgubic, Tim Davis

Current maintainer: William Kimmerer