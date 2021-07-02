using Documenter
using SuiteSparseGraphBLAS
using LinearAlgebra
using SparseArrays
makedocs(
    modules = [SuiteSparseGraphBLAS],
    sitename="SuiteSparseGraphBLAS.jl",
    pages = [
        "Introduction" => "index.md",
        "Arrays" => "arrays.md",
        "Operations" => "operations.md",
        "Operators" => [
            "operators.md",
            "unaryops.md",
            "binaryops.md",
            "monoids.md",
            "semirings.md",
            "selectops.md",
            "udfs.md"
        ]
    ]
)

deploydocs(
    repo = "github.com/JuliaSparse/SuiteSparseGraphBLAS.jl.git",
)
