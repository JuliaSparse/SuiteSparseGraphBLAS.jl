using Documenter
using SuiteSparseGraphBLAS
using LinearAlgebra
using SparseArrays
makedocs(
    modules = [SuiteSparseGraphBLAS],
    sitename="SuiteSparseGraphBLAS.jl",
    pages = [
        "Introduction" => "index.md",
        "Array Types" => "arrays.md",
        "Operations" => "operations.md",
        "Operators" => [
            "operators.md",
            "unaryops.md",
            "binaryops.md",
            "monoids.md",
            "semirings.md",
            "selectops.md",
            "udfs.md"
        ],
        "Utilities" => "utilities.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaSparse/SuiteSparseGraphBLAS.jl.git",
)
