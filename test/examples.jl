module ExamplesTest
using SuiteSparseGraphBLAS, SparseArrays, LinearAlgebra, Test

for f in ["AdvancedPrim", "BasicPrim", "BellmanFord", "BFSLevelsMultiSource", "BFSParents",
          "BFSParentsMultiSource", "CDLP", "CMU", "Cohen", "FloydWarshall", "KTruss",
          "NodeWiseTriangleCount", "Sandia", "pagerank", "triangle_centrality"]
    include(joinpath(@__DIR__, "..", "examples", "$f.jl"))
end

# Undirected graph with edges 1-2, 1-3, 2-3, 2-4, 3-4, 4-5 and triangles {1,2,3}, {2,3,4}.
I = [1, 1, 2, 2, 3, 4]; J = [2, 3, 3, 4, 4, 5]
sym(v) = sparse([I; J], [J; I], [v; v], 5, 5)
A = GBMatrix(sym(ones(Int, 6)))
w = [1.0, 4.0, 2.0, 7.0, 3.0, 1.0]
# Dense weights: Inf where there is no edge, zeros on the diagonal.
W = fill(Inf, 5, 5); W[diagind(W)] .= 0
for (i, j, x) in zip(I, J, w); W[i, j] = W[j, i] = x; end

@testset "triangle counting" begin
    @test cohen(A) == sandia(A) == cmu(A, 5) == 2
    @test Vector(nodewise_tc(A)) == [1, 2, 2, 1, 0]
    # K4 on 1:4 is the 4-truss of K4 plus the pendant edge 4-5.
    K = GBMatrix(sparse([1, 1, 1, 2, 2, 3, 4], [2, 3, 4, 3, 4, 4, 5], 1, 5, 5))
    K = K + K'
    @test nnz(ktruss(A, 3)) == 10 && ktruss(A, 3)[4, 5] == 0
    @test nnz(ktruss(K, 4)) == 12 && nnz(ktruss(K, 5)) == 0
end

@testset "shortest paths" begin
    D = copy(W)
    for k in 1:5, i in 1:5, j in 1:5
        D[i, j] = min(D[i, j], D[i, k] + D[k, j])
    end
    G = GBMatrix(sparse([I; J; 1:5], [J; I; 1:5], [w; w; zeros(5)]))
    @test Matrix(floydwarshall(G, 5)) == D
    @test Vector(bellmanford(G, 1, 5)) == D[1, :] == [0, 1, 3, 6, 7]
    @test Vector(bellmanford(G, 5, 5)) == D[5, :]
end

@testset "Prim" begin
    @test b_prim(GBMatrix(W), 5, zeros(5)) == 7
    @test a_prim(GBMatrix(W), 5, zeros(5)) == (7, [0, 1, 2, 3, 1])
end

@testset "BFS" begin
    @test collect(bfs_parents(A, 1, 5)) == [0, 1, 1, 2, 4]
    @test collect(bfs_parents(A, 5, 5)) == [2, 4, 4, 5, 0]
    S = GBMatrix(sparse([1, 2], [1, 5], 1, 2, 5))
    @test collect(ms_bfsp(A, S, 5, 2)) == [0 1 1 2 4; 2 4 4 5 0]
    B = GBMatrix(sym(trues(6)))
    @test Matrix(ms_bfsl(B, GBMatrix(sparse([1, 2], [1, 5], true, 2, 5)), 5, 2)) ==
        [1 2 2 3 4; 4 3 3 2 1]
end

@testset "CDLP" begin
    # Two disjoint triangles converge to the smallest label in each.
    T = GBMatrix(sparse([1, 1, 2, 4, 4, 5], [2, 3, 3, 5, 6, 6], 1, 6, 6))
    T = T + T'
    @test diag(Matrix(cdlp(T, 6, 2))) == [1, 1, 1, 4, 4, 4]
    @test diag(Matrix(cdlp(A, 5, 1))) == [2, 1, 1, 2, 4]
end

@testset "centrality" begin
    Af = GBMatrix(sym(ones(6)))
    # Vertex 5 is in no triangle and only sees the triangles of its neighbour 4.
    @test collect(triangle_centrality(Af)) ≈ [5/6, 1, 1, 5/6, 1/2]
    @test collect(triangle_centrality1(Af)) ≈ [5/6, 1, 1, 5/6, 1/2]
    # PageRank is uniform on a directed cycle, otherwise compare with dense power iteration.
    @test collect(pagerank(GBMatrix([1, 2, 3, 4], [2, 3, 4, 1], 1.0))[1]) ≈ fill(0.25, 4)
    M = Matrix(sym(ones(6))); x = fill(0.2, 5)
    for _ in 1:100; x = 0.15 / 5 .+ 0.85 .* (M' * (x ./ vec(sum(M, dims=2)))); end
    @test collect(pagerank(Af)[1]) ≈ x atol=1e-5
end
end
