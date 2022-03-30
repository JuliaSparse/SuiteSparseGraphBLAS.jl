using Pkg
Pkg.activate(".")
Pkg.instantiate()
using SuiteSparseMatrixCollection
using SuiteSparseGraphBLAS
using BenchmarkTools
using SparseArrays
using LinearAlgebra
using StorageOrders

#OPTIONS SET 1:
# Maximum number of samples taken for each benchmark
BenchmarkTools.DEFAULT_PARAMETERS.samples = 3
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1
# Total amount of time allowed for each benchmark, minimum of 1 sample taken.
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1000

# Comment or uncomment this line to disable or enable MKLSparse respectively.
# This will only work for SpMM and SpMV and only operates on CSC.
#using MKLSparse

# Change this to change the size of the dense RHS of csrtimesfull and csctimesfull
const sizefullrhs = [1, 4, 16, 64, 1024]

const threadlist = [1, Sys.CPU_THREADS ÷ 2]

const suite = BenchmarkGroup()
const ssmc = ssmc_db()

function mxm(A::SparseMatrixCSC, B)
    printstyled("\nC = A::SparseMatrixCSC($(size(A))) * B::$(typeof(B))($(size(B)))\n")
    result = @benchmark $A * $B samples=3 evals=1 seconds=2
    show(stdout, MIME("text/plain"), result)
    return median(result)
end

function mxm(A::SuiteSparseGraphBLAS.GBArray, B::SuiteSparseGraphBLAS.GBArray; accumdenseoutput=false)
    Ao = storageorder(A) == ColMajor() ? "C" : "R"
    Bo = storageorder(B) == ColMajor() ? "C" : "R"
    if !accumdenseoutput
        printstyled("\nC::GBArray = A::GBArray($Ao, $(size(A))) * B::GBArray($Bo, $(size(B)))\n")
        gbset(:burble, true)
        mul(A, B)
        gbset(:burble, false)
        result = @benchmark mul($A, $B) samples=3 evals=1 seconds=2
    else
        printstyled("\nC::GBArray += A::GBArray($Ao, $(size(A))) * B::GBArray($Bo, $(size(B)))\n")
        C = GBMatrix(zeros(eltype(A), size(A, 1), size(B, 2)))
        gbset(:burble, true)
        mul!(C, A, B; accum=+)
        gbset(:burble, false)
        result = @benchmark mul!($C, $A, $B; accum=+) samples=3 evals=1 seconds=2
    end
    show(stdout, MIME("text/plain"), result)
    return median(result)
end

function singlebench(pathornum)
    x = tryparse(Int64, pathornum)
    if x !== nothing
        ssmc[x, :real] == true || throw(ArgumentError("SSMC ID must be for a matrix with real values"))
        path = joinpath(fetch_ssmc(ssmc[x, :group], ssmc[x, :name]), "$(ssmc[x, :name]).mtx")
    elseif isfile(pathornum)
        path = pathornum
    else
        throw(ErrorException("Argument is not a path or SuiteSparseMatrixCollection ID number"))
    end
    name = basename(path)
    A = SuiteSparseGraphBLAS.mmread(path)
    printstyled("\n#################################################################################\n"; bold=true, color=:green)
    printstyled("Benchmarking $name:\n"; bold=true, color=:green)
    printstyled("#################################################################################\n"; bold=true, color=:green)
    printstyled("Sparse * Vec\n"; bold=true)
    printstyled("A matrix: \n")
    show(stdout, MIME("text/plain"), A)
    B = rand(eltype(A), size(A, 2))
    B = GBVector(B)
    
    printstyled("B matrix: \n")
    show(stdout, MIME("text/plain"), B)

    gbresultsR = runthreaded(A, B; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, B; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Vector(B))
    printstyled("RESULTS, Sparse * DenseVec: \n"; bold=true, color=:green)
    println("A by row: $gbresultsR")
    println("A by col: $gbresultsC")
    println("SparseArrays: $SAresults")

    B = GBMatrix(rand(eltype(A), size(A, 2), 2))
    printstyled("B matrix: \n")
    show(stdout, MIME("text/plain"), B)
    gbset(A, :format, SuiteSparseGraphBLAS.BYROW)
    diag(A)
    gbresultsR = runthreaded(A, B; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, B; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Matrix(B))
    printstyled("RESULTS, Sparse * n x 2 Dense: \n"; bold=true, color=:green)
    println("A by row: $gbresultsR")
    println("A by col: $gbresultsC")
    println("SparseArrays: $SAresults")

    B = GBMatrix(rand(eltype(A), size(A, 2), 32))
    printstyled("B matrix: \n")
    show(stdout, MIME("text/plain"), B)
    gbset(A, :format, SuiteSparseGraphBLAS.BYROW)
    diag(A)
    gbresultsR = runthreaded(A, B; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, B; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Matrix(B))
    printstyled("RESULTS, Sparse * n x 32 Dense: \n"; bold=true, color=:green)
    println("A by row: $gbresultsR")
    println("A by col: $gbresultsC")
    println("SparseArrays: $SAresults")


    gbset(A, :format, SuiteSparseGraphBLAS.BYROW)
    diag(A)
    gbresultsR = runthreaded(A, transpose(A))
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, transpose(A))
    A2 = SparseMatrixCSC(A)
    SAresults = mxm(A2, transpose(A2))
    println()
    printstyled("\n\nRESULTS, Sparse * Sparse: \n"; bold=true, color=:green)
    println("A by row: $gbresultsR")
    println("A by col: $gbresultsC")
    println("SparseArrays: $SAresults")
    println()
    return nothing
end

function runthreaded(A, B; accumdenseoutput=false)
    v = []
    for t ∈ threadlist
        printstyled("\nRunning GraphBLAS with $t threads\n"; bold=true)
        gbset(:nthreads, t)
        push!(v, mxm(A, B; accumdenseoutput))
    end
    return v
end


if length(ARGS) != 0
    if isfile(ARGS[1])
        if splitext(ARGS[1])[2] == ".mtx"
            singlebench(ARGS[1])
        else
            lines = readlines(ARGS[1])
            filter!((x) -> !occursin("#", x), lines)
            singlebench.(lines)
        end
    elseif tryparse(Int64, ARGS[1]) !== nothing
        singlebench(ARGS[1])
    else
        throw(ArgumentError("The first argument must a file with a list of SuiteSparse ID numbers or paths to MatrixMarket files"))
    end
end