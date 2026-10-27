# Examples

```@meta
DocTestSetup = quote
    using SuiteSparseGraphBLAS
    for f in ("Cohen", "Sandia", "BFSParents", "BellmanFord")
        include(joinpath(pkgdir(SuiteSparseGraphBLAS), "examples", "$f.jl"))
    end
end
DocTestFilters = [r"memory: \d+ bytes"]
```

The [`examples`](https://github.com/JuliaSparse/SuiteSparseGraphBLAS.jl/tree/v11/examples) directory of the repository contains graph algorithms written with SuiteSparseGraphBLAS.jl.
They are not part of the package API: `include` a file to use the functions it defines.
Each file links to a paper or reference describing the algorithm, and all of them are tested in `test/examples.jl`.

Unless noted otherwise `A` is the adjacency matrix of an undirected graph with `n` vertices.

| Algorithm | File | Function | Notes |
|:----------|:-----|:---------|:------|
| Triangle counting (Cohen) | `Cohen.jl` | `cohen(A)` | |
| Triangle counting (Sandia) | `Sandia.jl` | `sandia(A)` | |
| Triangle counting (CMU) | `CMU.jl` | `cmu(A, n)` | |
| Triangles per vertex | `NodeWiseTriangleCount.jl` | `nodewise_tc(A)` | |
| Triangle centrality | `triangle_centrality.jl` | `triangle_centrality(A)`, `triangle_centrality1(A)` | `A` has unit weights. |
| k-truss | `KTruss.jl` | `ktruss(A, k)` | Returns the truss with edge supports as values. |
| BFS parents | `BFSParents.jl` | `bfs_parents(A, s, n)` | The parent of the source is `0`. |
| Multi-source BFS parents | `BFSParentsMultiSource.jl` | `ms_bfsp(A, S, n, s)` | Row `i` of the `s × n` matrix `S` marks source `i`. |
| Multi-source BFS levels | `BFSLevelsMultiSource.jl` | `ms_bfsl(A, S, n, s)` | `A` and `S` are `Bool`. Sources are level `1`, unreachable vertices `0`. |
| Bellman-Ford | `BellmanFord.jl` | `bellmanford(A, s, n)` | `A[i,j]` is the weight of edge `i → j`, with explicit zeros on the diagonal. |
| Floyd-Warshall | `FloydWarshall.jl` | `floydwarshall(A, n)` | Same input as Bellman-Ford. |
| Prim's minimum spanning tree | `BasicPrim.jl`, `AdvancedPrim.jl` | `b_prim(A, n, zeros(n))`, `a_prim(A, n, zeros(n))` | `A` is dense, with `Inf` where there is no edge and zeros on the diagonal. |
| PageRank | `pagerank.jl` | `pagerank(A)` | `A[i,j]` is the edge `i → j`. Returns `(ranks, iterations)`. Ranks of dangling vertices are not redistributed. |
| Community detection by label propagation | `CDLP.jl` | `cdlp(A, n, t)` | Runs `t` iterations. Every vertex must have a neighbour. |

The graph below has edges `1-2`, `1-3`, `2-3`, `2-4`, `3-4` and `4-5`, and two triangles, `{1,2,3}` and `{2,3,4}`.

```jldoctest examples
julia> src = [1, 1, 2, 2, 3, 4]; dst = [2, 3, 3, 4, 4, 5];

julia> A = GBMatrix([src; dst], [dst; src], 1, 5, 5);

julia> cohen(A), sandia(A)
(2, 2)

julia> bfs_parents(A, 1, 5)
5x1 GraphBLAS int64_t matrix, bitmap by col
  5 entries, memory: 288 bytes
  fill value:  nothing

    (1,1)   0
    (2,1)   1
    (3,1)   1
    (4,1)   2
    (5,1)   4
```

With edge weights, and the explicit zero diagonal that Bellman-Ford expects:

```jldoctest examples
julia> w = [1.0, 4.0, 2.0, 7.0, 3.0, 1.0];

julia> W = GBMatrix([src; dst; 1:5], [dst; src; 1:5], [w; w; zeros(5)]);

julia> bellmanford(W, 1, 5)
5x1 GraphBLAS double matrix, full by col
  5 entries, memory: 280 bytes

    (1,1)    0
    (2,1)    1
    (3,1)    3
    (4,1)    6
    (5,1)    7
```
