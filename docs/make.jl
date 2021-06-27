using Documenter
using SuiteSparseGraphBLAS

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
            "semirings.md"
        ]
    ]
)

deploydocs(
    repo = "github.com/JuliaSparse/SuiteSparseGraphBLAS.jl.git",
)
