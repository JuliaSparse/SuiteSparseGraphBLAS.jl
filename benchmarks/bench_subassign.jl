using Pkg
Pkg.activate(".")
Pkg.instantiate()
using SuiteSparseMatrixCollection
using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra
using StorageOrders
using StatsBase

macro gbbench(ex)
    return quote
        gbset(:burble, true)
        $(esc(ex))
        gbset(:burble, false)
        local taccum = 0
        for i ∈ 1:3
            local t0 = time_ns()
            $(esc(ex))
            local t1 = time_ns()
            taccum += t1 - t0
        end
        taccum / 1e9
    end
end

macro bench(ex)
    return quote
        local taccum = 0
        for i ∈ 1:3
            local t0 = time_ns()
            $(esc(ex))
            local t1 = time_ns()
            taccum += t1 - t0
        end
        taccum / 1e9
    end
end

# Comment or uncomment this line to disable or enable MKLSparse respectively.
# This will only work for SpMM and SpMV and only operates on CSC.
#using MKLSparse

const threadlist = [1, 2, 16]

function idx(C, A, I, J)
    if C isa SuiteSparseGraphBLAS.AbstractGBArray
        Ao = storageorder(A) == ColMajor() ? "C" : "R"
        Co = storageorder(A) == ColMajor() ? "C" : "R"
        printstyled(stdout, "\nC::GBArray($(Co))[I, J] = A::GBArray($Ao, $(size(A)))\n")
        result = @gbbench begin
            C[I, J] = A
            wait(C)
        end
        println(stdout, result, "s")
        GC.gc()
    else
        printstyled(stdout, "\nC[I, J] = A::SparseMatrixCSC($(size(A)))\n")
        result = @bench C[I, J] = A
        println(stdou, result, "s")
        GC.gc()
    end
    flush(stdout)
    return result
end

function runthreadedidx(C, A, I, J)
    v = []
    for t ∈ threadlist
        printstyled(stdout, "\nRunning GraphBLAS with $t threads\n"; bold=true)
        gbset(:nthreads, t)
        push!(v, idx(C, A, I, J))
    end
    return v
end

function singlebench(szC, szA)
    printstyled(stdout, "\nC($szC)[I, J] = A($szA))"; bold=true)
    println(stdout, "################################")
    C = SuiteSparseGraphBLAS.wait(SuiteSparseGraphBLAS.gbrand(Float64, szC[1:2]..., szC[3]))
    A = SuiteSparseGraphBLAS.wait(SuiteSparseGraphBLAS.gbrand(Float64, szA[1:2]..., szA[3]))
    I = sample(1:size(C, 1), size(A, 1), replace = false)
    J = sample(1:size(C, 2), size(A, 2), replace = false)

    flush(stdout)
    gbset(A, :format, SuiteSparseGraphBLAS.BYROW)
    gbset(C, :format, SuiteSparseGraphBLAS.BYROW)
    SuiteSparseGraphBLAS.wait(A)
    gbresultsR = runthreadedidx(C, A, I, J)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    gbset(C, :format, SuiteSparseGraphBLAS.BYCOL)
    SuiteSparseGraphBLAS.wait(A)
    gbresultsC = runthreadedidx(C, A, I, J)
    A2 = SparseMatrixCSC(A) 
    SAresults = tpose(A2)
    println(stdout, )
    printstyled(stdout, "\nRESULTS, C = copy(transpose(A)): \n"; bold=true, color=:green)
    println(stdout, "################################")
    println(stdout, "A by row (1, 2, 16 thread): $gbresultsR")
    println(stdout, "A by col (1, 2, 16 thread): $gbresultsC")
    println(stdout, "SparseArrays: $SAresults")
    flush(stdout)
    return nothing
end

singlebench((10_000, 10_000, 0.001), (2_000, 2_000, 0.1))
singlebench((1_000_000, 1_000_000, 0.01), (5_000, 5_000, 0.005))
#singlebench((25_000_000, 25_000_000, 1e-7), (5_000, 5_000, 0.002))
#singlebench((50_000_000, 50_000_000, 1e-7), (100_000, 100_000, 0.001))
#
#singlebench((50_000_000, 50_000_000, 1e-7), (1_000, 1_000, 1.0))