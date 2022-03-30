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
BenchmarkTools.DEFAULT_PARAMETERS.samples = 10
# Total amount of time allowed for each benchmark, minimum of 1 sample taken.
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 60

# Comment or uncomment this line to disable or enable MKLSparse respectively.
# This will only work for SpMM and SpMV and only operates on CSC.
#using MKLSparse

# Change this to change the size of the dense RHS of csrtimesfull and csctimesfull
const sizefullrhs = [1, 4, 16, 64, 1024]

const threadlist = [1, Sys.CPU_THREADS ÷ 2]

const suite = BenchmarkGroup()
const ssmc = ssmc_db()

function mxm(A::SparseMatrixCSC, B::Union{SparseMatrixCSC, DenseArray})
    printstyled("\nC = A::SparseMatrixCSC * B::$(typeof(B))\n")
    result = @benchmark $A * $B
    show(stdout, MIME("text/plain"), result)
    return median(result)
end

function mxm(A::SuiteSparseGraphBLAS.GBArray, B::SuiteSparseGraphBLAS.GBArray; accumdenseoutput=false)
    Ao = storageorder(A) == ColMajor() ? "C" : "R"
    Bo = storageorder(B) == ColMajor() ? "C" : "R"
    if !accumdenseoutput
        printstyled("\nC::GBArray = A::GBArray($Ao) * B::GBArray($Bo)\n")
        result = @benchmark mul($A, $B)
    else
        printstyled("\nC::GBArray += A::GBArray($Ao) * B::GBArray($Bo)\n")
        C = GBMatrix(zeros(eltype(A), size(A, 1), size(B, 2)))
        result = @benchmark mul!($C, $A, $B; accum=+)
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
    v = rand(eltype(A), size(A, 2))
    v = GBVector(v)
    printstyled("A matrix: ")
    show(stdout, MIME("text/plain"), A)
    printstyled("B matrix: ")
    show(stdout, MIME("text/plain"), v)
    gbresultsR = runthreaded(A, v; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    show(stdout, MIME("text/plain"), A)
    gbresultsC = runthreaded(A, v; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Vector(v))
    println((gbresultsR, gbresultsC, SAresults))

    B = GBMatrix(rand(eltype(A), size(A, 2), 160))

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