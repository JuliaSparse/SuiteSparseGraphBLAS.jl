using Pkg
using SuiteSparseMatrixCollection
using MatrixMarket
using SuiteSparseGraphBLAS
SuiteSparseGraphBLAS.gbset(SuiteSparseGraphBLAS.FORMAT, SuiteSparseGraphBLAS.BYROW)
using BenchmarkTools
using DelimitedFiles
using SparseArrays
using LinearAlgebra
Pkg.activate(".")
Pkg.instantiate()
ssmc = ssmc_db()
matrices = filter(row ->  10000 <= row.nnz <= 15000, ssmc)
paths = fetch_ssmc(matrices, format="MM")
open("results.txt", "w") do io
    for i ∈ 1:length(paths)
        if !matrices[i, :real]
            continue
        end
        GC.gc()
        S = convert(SparseMatrixCSC{Float64}, MatrixMarket.mmread(joinpath(paths[i], "$(matrices[i,:name]).mtx")))
        G = GBMatrix(S)
        SuiteSparseGraphBLAS.gbset(G, SuiteSparseGraphBLAS.FORMAT, SuiteSparseGraphBLAS.BYROW)
        diag(G)
        m = rand(size(S, 2), 50)
        m2 = GBMatrix(m)
        selfmultimes1 = mean(@benchmark $S * ($S)').time
        selfmultimes2 = mean(@benchmark $G * ($G)').time

        densemattimes1 = mean(@benchmark $S * $m).time
        densemattimes2 = mean(@benchmark $G * $m2).time
        println(io, "$selfmultimes1\t$selfmultimes2\t$densemattimes1\t$densemattimes2")
        println("Progress: $i")
    end
end
