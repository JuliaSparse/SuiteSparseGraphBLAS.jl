using Documenter
using SuiteSparseGraphBLAS
using LinearAlgebra
makedocs(
    modules = [SuiteSparseGraphBLAS],
    sitename="SuiteSparseGraphBLAS.jl",
    pages = [
        "Introduction" => "index.md",
        "Arrays" => "arrays.md",
        "Operations" => "operations.md",
        "Operators" => [
            "unaryops.md",
            "binaryops.md",
            "monoids.md",
            "semirings.md",
            "selectops.md"
        ]
    ]
)

deploydocs(
    repo = "github.com/JuliaSparse/SuiteSparseGraphBLAS.jl.git",
)
