using Pkg
Pkg.activate(".")
Pkg.instantiate()
using SuiteSparseMatrixCollection
using SuiteSparseGraphBLAS
using SparseArrays
using LinearAlgebra
using StorageOrders

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
const ssmc = ssmc_db()

function mxm(A::SparseMatrixCSC, B)
    printstyled(stdout, "\nC = A::SparseMatrixCSC($(size(A))) * B::$(typeof(B))($(size(B)))\n")
    result = @bench A * B
    println(stdout, result, "s")
    flush(stdout)
    return result
end

function mxm(A::SuiteSparseGraphBLAS.GBArray, B::SuiteSparseGraphBLAS.GBArray; accumdenseoutput=false)
    Ao = storageorder(A) == ColMajor() ? "C" : "R"
    Bo = storageorder(B) == ColMajor() ? "C" : "R"
    if !accumdenseoutput
        printstyled(stdout, "\nC::GBArray = A::GBArray($Ao, $(size(A))) * B::GBArray($Bo, $(size(B)))\n")
        flush(stdout)
        result = @gbbench mul(A, B)
    else
        printstyled(stdout, "\nC::GBArray += A::GBArray($Ao, $(size(A))) * B::GBArray($Bo, $(size(B)))\n")
        C = GBMatrix(zeros(eltype(A), size(A, 1), size(B, 2)))
        flush(stdout)
        result = @gbbench mul!(C, A, B; accum=+)
    end
    println(stdout, result, "s")
    flush(stdout)
    return result
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
    printstyled(stdout, "\nSparse * Vec\n"; bold=true)
    println(stdout, "################################")
    flush(stdout)
    B = rand(eltype(A), size(A, 2))
    B = GBVector(B)

    gbresultsR = runthreaded(A, B; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, B; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Vector(B))
    printstyled(stdout, "\nRESULTS, Sparse * DenseVec: \n"; bold=true, color=:green)
    println(stdout, "################################")
    println(stdout, "A by row (1, 2, 16 thread): $gbresultsR")
    println(stdout, "A by col (1, 2, 16 thread): $gbresultsC")
    println(stdout, "SparseArrays: $SAresults")
    flush(stdout)

    printstyled(stdout, "\nSparse * (n x 2)\n"; bold=true)
    println(stdout, "################################")
    flush(stdout)
    B = GBMatrix(rand(eltype(A), size(A, 2), 2))
    gbset(A, :format, SuiteSparseGraphBLAS.BYROW)
    diag(A)
    gbresultsR = runthreaded(A, B; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, B; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Matrix(B))
    printstyled(stdout, "\nRESULTS, Sparse * n x 2 Dense: \n"; bold=true, color=:green)
    println(stdout, "################################")
    println(stdout, "A by row (1, 2, 16 thread): $gbresultsR")
    println(stdout, "A by col (1, 2, 16 thread): $gbresultsC")
    println(stdout, "SparseArrays: $SAresults")
    flush(stdout)

    printstyled(stdout, "\nSparse * (n x 32)\n"; bold=true)
    println(stdout, "################################")
    flush(stdout)
    B = GBMatrix(rand(eltype(A), size(A, 2), 32))
    gbset(A, :format, SuiteSparseGraphBLAS.BYROW)
    diag(A)
    gbresultsR = runthreaded(A, B; accumdenseoutput=true)
    gbset(A, :format, SuiteSparseGraphBLAS.BYCOL)
    diag(A)
    gbresultsC = runthreaded(A, B; accumdenseoutput=true)
    SAresults = mxm(SparseMatrixCSC(A), Matrix(B))
    printstyled(stdout, "\nRESULTS, Sparse * n x 32 Dense: \n"; bold=true, color=:green)
    println(stdout, "################################")
    println(stdout, "A by row (1, 2, 16 thread): $gbresultsR")
    println(stdout, "A by col (1, 2, 16 thread): $gbresultsC")
    println(stdout, "SparseArrays: $SAresults")
    flush(stdout)

    printstyled(stdout, "\nSparse * Sparse'"; bold=true)
    println(stdout, "################################")
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
    printstyled(stdout, "\nRESULTS, Sparse * Sparse: \n"; bold=true, color=:green)
    println(stdout, "################################")
    println(stdout, "A by row (1, 2, 16 thread): $gbresultsR")
    println(stdout, "A by col (1, 2, 16 thread): $gbresultsC")
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