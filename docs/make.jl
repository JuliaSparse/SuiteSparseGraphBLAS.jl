using Documenter
using SuiteSparseGraphBLAS

makedocs(
    modules = [SuiteSparseGraphBLAS],
    sitename="SuiteSparse:GraphBLAS",
    pages = [
        "Introduction" => "index.md",
        "Arrays" => "arrays.md".
        "Operations" => "operations.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaSparse/SuiteSparseGraphBLAS.jl.git",
)
