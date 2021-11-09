# INSTRUCTIONS:

# Running this file is fairly straightforward:
# From the terminal call julia with this file as the first argument, as well as one of three other arguments:
# 1. A number, corresponding to the ID of a SuiteSparse: Matrix Collection matrix.
# 2. The path to an .mtx file.
# 3. The path to a file containing either of the above options on each line.

# This would look something like
# >julia benchmarks.jl 1375
# or
# >julia benchmarks.jl ~/mymtx.mtx

# CHANGING THE SHARED LIBRARY.
# Further instructions on changing the shared library programmatically can be found in the docs.
# However, simply changing the LocalPreferences.toml file will suffice for this benchmark script.

# Some options can be found further down under SETTINGS
using Pkg
Pkg.activate(".")
Pkg.instantiate()
using SuiteSparseMatrixCollection
using MatrixMarket
using SuiteSparseGraphBLAS
using BenchmarkTools
using SparseArrays
using LinearAlgebra

#OPTIONS SET 1:
# Maximum number of samples taken for each benchmark
BenchmarkTools.DEFAULT_PARAMETERS.samples = 10
# Total amount of time allowed for each benchmark, minimum of 1 sample taken.
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 60

# Change this to change the size of the dense RHS of csrtimesfull and csctimesfull
const sizefullrhs = [1,2,20]


const suite = BenchmarkGroup()
const ssmc = ssmc_db()

function AxB_allbycol(S, G, nthreads, sizerhs)
    printstyled("\nCSC = CSC * Full\n", color=:green)
    GC.gc()
    m = rand(size(S, 2), sizerhs)
    m2 = GBMatrix(m)
    println("Size of dense matrix is $(size(m))")

    gbset(m2, :format, :bycol)
    gbset(G, :format, :bycol) #set to CSC

    C = GBMatrix{eltype(G)}(size(G, 1), size(m2, 2))
    gbset(C, :format, :bycol)

    printstyled("\nSparseMatrixCSC:\n", bold=true)
    A = @benchmark $S * $m
    show(stdout, MIME("text/plain"), A)

    printstyled("\nGBMatrix:\n", bold=true)
    for n ∈ nthreads
        printstyled("\nC = S * F with $n threads: \n", bold=true, color=:green)
        gbset(:nthreads, n)
        #print burble for checking
        gbset(:burble, true)
        mul!(C, G, m2)
        gbset(:burble, false)
        B = @benchmark mul!($C, $G, $m2)
        show(stdout, MIME("text/plain"), B)
        tratio = ratio(median(A), median(B))
        color = tratio.time >= 1.0 ? :green : :red
        printstyled("\nMedian speedup over SparseArrays using $n threads is: $(string(tratio))\n"; bold=true, color)
    end
    gbset(G, :format, :byrow) #set back to CSR
end

function AxB_allbyrow(S, G, nthreads, sizerhs)
    printstyled("\nCSR = CSR * Full\n", color=:green)
    GC.gc()
    m = rand(size(S, 2), sizerhs)
    m2 = GBMatrix(m)
    println("Size of dense matrix is $(size(m))")

    gbset(m2, :format, :byrow)
    gbset(G, :format, :byrow)

    printstyled("\nSparseMatrixCSC:\n", bold=true)
    A = @benchmark $S * $m
    show(stdout, MIME("text/plain"), A)

    printstyled("\nGBMatrix:\n", bold=true)
    for n ∈ nthreads
        printstyled("\nC' = S' * F' with $n threads: \n", bold=true, color=:green)
        gbset(:nthreads, n)
        #print burble for checking
        gbset(:burble, true)
        mul(G, m2)
        gbset(:burble, false)
        B = @benchmark mul($G, $m2)
        show(stdout, MIME("text/plain"), B)
        tratio = ratio(median(A), median(B))
        color = tratio.time >= 1.0 ? :green : :red
        printstyled("\nMedian speedup over SparseArrays using $n threads is: $(string(tratio))\n"; bold=true, color)
    end
end

function AxB_ColxRow(S, G, nthreads, sizerhs)
    printstyled("\nByRow = CSC * Full_byrow\n", color=:green)
    GC.gc()
    m = rand(size(S, 2), sizerhs)
    m2 = GBMatrix(m)
    println("Size of dense matrix is $(size(m))")

    gbset(m2, :format, :byrow)
    gbset(G, :format, :bycol)

    printstyled("\nSparseMatrixCSC:\n", bold=true)
    A = @benchmark $S * $m
    show(stdout, MIME("text/plain"), A)

    printstyled("\nGBMatrix:\n", bold=true)

    for n ∈ nthreads
        printstyled("\nC' = S * F' with $n threads: \n", bold=true, color=:green)
        gbset(:nthreads, n)
        #print burble for checking
        gbset(:burble, true)
        mul(G, m2)
        gbset(:burble, false)
        B = @benchmark mul($G, $m2)
        show(stdout, MIME("text/plain"), B)
        tratio = ratio(median(A), median(B))
        color = tratio.time >= 1.0 ? :green : :red
        printstyled("\nMedian speedup over SparseArrays using $n threads is: $(string(tratio))\n"; bold=true, color)
    end
    gbset(G, :format, :byrow) #set back to CSR
end

function CaccumAxB_allbycol(S, G, nthreads, sizerhs)
    printstyled("\nFull += CSC * Full\n", color=:green)
    GC.gc()
    m = rand(size(S, 2), sizerhs)
    m2 = GBMatrix(m)
    println("Size of dense matrix is $(size(m))")

    gbset(m2, :format, :bycol)
    gbset(G, :format, :bycol) #set to CSC

    printstyled("\nSparseMatrixCSC:\n", bold=true)
    A = @benchmark $S * $m
    show(stdout, MIME("text/plain"), A)

    C = GBMatrix(size(G, 1), size(m2, 2), 0.0)
    gbset(C, :sparsity_control, :full)
    gbset(C, :format, :bycol)

    printstyled("\nGBMatrix:\n", bold=true)
    #print burble for checking

    for n ∈ nthreads
        printstyled("\nF += S * F with $n threads: \n", bold=true, color=:green)
        gbset(:nthreads, n)
        gbset(:burble, true)
        mul!(C, G, m2; accum=+)
        gbset(:burble, false)
        B = @benchmark mul!($C, $G, $m2; accum=+)
        show(stdout, MIME("text/plain"), B)
        tratio = ratio(median(A), median(B))
        color = tratio.time >= 1.0 ? :green : :red
        printstyled("\nMedian speedup over SparseArrays using $n threads is: $(string(tratio))\n"; bold=true, color)
    end
    gbset(G, :format, :byrow) #set back to CSR
end

function CaccumAxB_allbyrow(S, G, nthreads, sizerhs)
    printstyled("\nFull_byrow += CSR * Full_byrow\n", color=:green)
    GC.gc()
    m = rand(size(S, 2), sizerhs)
    m2 = GBMatrix(m)
    println("Size of dense matrix is $(size(m))")

    gbset(m2, :format, :byrow)
    gbset(G, :format, :byrow)

    printstyled("\nSparseMatrixCSC:\n", bold=true)
    A = @benchmark $S * $m
    show(stdout, MIME("text/plain"), A)
    gbset(:burble, true)
    C = GBMatrix(size(G, 1), size(m2, 2), 0.0)
    gbset(C, :sparsity_control, :full)
    gbset(C, :format, :byrow)

    printstyled("\nGBMatrix:\n", bold=true)
    #print burble for checking
    gbset(:burble, false)
    for n ∈ nthreads
        printstyled("\nF' += S' * F' with $n threads: \n", bold=true, color=:green)
        gbset(:nthreads, n)
        gbset(:burble, true)
        mul!(C, G, m2; accum=+)
        gbset(:burble, false)
        B = @benchmark mul!($C, $G, $m2; accum=+)
        show(stdout, MIME("text/plain"), B)
        tratio = ratio(median(A), median(B))
        color = tratio.time >= 1.0 ? :green : :red
        printstyled("\nMedian speedup over SparseArrays using $n threads is: $(string(tratio))\n"; bold=true, color)
    end
end

# OPTIONS SET 2:
# run these functions for benchmarking:
const functorun = [AxB_allbycol, AxB_ColxRow, CaccumAxB_allbycol, CaccumAxB_allbyrow]
#= The choices are:
AxB_allbycol - S * F
AxB_ColxRow - S' * F
CaccumAxB_allbycol - F += S * F
CaccumAxB_allbyrow - F' += S' * F'
Please open an issue or message me for further functions to add here.
=#

# run with these nthread settings, add or remove to/from vector.
const threadlist = [1, 4, 8, Sys.CPU_THREADS ÷ 2, Sys.CPU_THREADS]

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
    mmpath = @time MatrixMarket.mmread(path)
    S = convert(SparseMatrixCSC{Float64}, mmpath)
    G = GBMatrix(S)
    gbset(G, :format, :byrow)
    diag(G)
    printstyled("Benchmarking $name:\n"; bold=true, color=:green)
    for i ∈ sizefullrhs
        printstyled("\nUsing a size $i B matrix"; bold=true, color=:red)
        for f ∈ functorun
            f(S, G, threadlist, i)
        end
    end
end

if length(ARGS) != 0
    if isfile(ARGS[1])
        if splitext(ARGS[1])[2] == ".mtx"
            singlebench(ARGS[1])
        else
            singlebench.(readlines(ARGS[1]))
        end
    elseif tryparse(Int64, ARGS[1]) !== nothing
        singlebench(ARGS[1])
    else
        throw(ArgumentError("The first argument must a file with a list of SuiteSparse ID numbers or paths to MatrixMarket files"))
    end
end
