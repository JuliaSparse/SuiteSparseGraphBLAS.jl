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
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 180

# Comment or uncomment this line to disable or enable MKLSparse respectively.
# This will only work for SpMM and SpMV and only operates on CSC.
#using MKLSparse

const threadlist = [1, 16]

const suite = BenchmarkGroup()
const ssmc = ssmc_db()

function mxm(A::SparseMatrixCSC, B)
    printstyled(stdout, "\nC = A::SparseMatrixCSC($(size(A))) * B::$(typeof(B))($(size(B)))\n")
    result = @benchmark $A * $B
    show(stdout, MIME("text/plain"), result)
    flush(stdout)
    return median(result)
end

function mxm(A::SuiteSparseGraphBLAS.GBArray, B::SuiteSparseGraphBLAS.GBArray; accumdenseoutput=false)
    Ao = storageorder(A) == ColMajor() ? "C" : "R"
    Bo = storageorder(B) == ColMajor() ? "C" : "R"
    if !accumdenseoutput
        printstyled(stdout, "\nC::GBArray = A::GBArray($Ao, $(size(A))) * B::GBArray($Bo, $(size(B)))\n")
        flush(stdout)
        gbset(:burble, true)
        mul(A, B)
        gbset(:burble, false)
        result = @benchmark mul($A, $B)
    else
        printstyled(stdout, "\nC::GBArray += A::GBArray($Ao, $(size(A))) * B::GBArray($Bo, $(size(B)))\n")
        C = GBMatrix(zeros(eltype(A), size(A, 1), size(B, 2)))
        flush(stdout)
        gbset(:burble, true)
        mul!(C, A, B; accum=+)
        gbset(:burble, false)
        result = @benchmark mul!($C, $A, $B; accum=+)
    end
    show(stdout, MIME("text/plain"), result)
    flush(stdout)
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
    printstyled(stdout, "\n#################################################################################\n"; bold=true, color=:green)
    printstyled(stdout, "Benchmarking $name:\n"; bold=true, color=:green)
    printstyled(stdout, "#################################################################################\n"; bold=true, color=:green)
    printstyled(stdout, "Sparse * Vec\n"; bold=true)
    flush(stdout)
    B = rand(eltype(A), size(A, 2))
    B = GBVector(B)

    gbresultsR = runthreaded(A, B; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, B; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Vector(B))
    printstyled(stdout, "RESULTS, Sparse * DenseVec: \n"; bold=true, color=:green)
    println(stdout, "A by row: $gbresultsR")
    println(stdout, "A by col: $gbresultsC")
    println(stdout, "SparseArrays: $SAresults")
    flush(stdout)

    B = GBMatrix(rand(eltype(A), size(A, 2), 2))
    gbset(A, :format, SuiteSparseGraphBLAS.BYROW)
    diag(A)
    gbresultsR = runthreaded(A, B; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, B; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Matrix(B))
    printstyled(stdout, "RESULTS, Sparse * n x 2 Dense: \n"; bold=true, color=:green)
    println(stdout, "A by row: $gbresultsR")
    println(stdout, "A by col: $gbresultsC")
    println(stdout, "SparseArrays: $SAresults")
    flush(stdout)

    B = GBMatrix(rand(eltype(A), size(A, 2), 32))
    gbset(A, :format, SuiteSparseGraphBLAS.BYROW)
    diag(A)
    gbresultsR = runthreaded(A, B; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, B; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Matrix(B))
    printstyled(stdout, "RESULTS, Sparse * n x 32 Dense: \n"; bold=true, color=:green)
    println(stdout, "A by row: $gbresultsR")
    println(stdout, "A by col: $gbresultsC")
    println(stdout, "SparseArrays: $SAresults")
    flush(stdout)


    gbset(A, :format, SuiteSparseGraphBLAS.BYROW)
    diag(A)
    gbresultsR = runthreaded(A, transpose(A))
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, transpose(A))
    A2 = SparseMatrixCSC(A)
    SAresults = mxm(A2, transpose(A2))
    println(stdout, )
    printstyled(stdout, "\n\nRESULTS, Sparse * Sparse: \n"; bold=true, color=:green)
    println(stdout, "A by row: $gbresultsR")
    println(stdout, "A by col: $gbresultsC")
    println(stdout, "SparseArrays: $SAresults")
    flush(stdout)
    return nothing
end

function runthreaded(A, B; accumdenseoutput=false)
    v = []
    for t ∈ threadlist
        printstyled(stdout, "\nRunning GraphBLAS with $t threads\n"; bold=true)
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