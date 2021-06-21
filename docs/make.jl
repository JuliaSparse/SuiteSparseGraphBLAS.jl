using Documenter, SuiteSparseGraphBLAS

makedocs(
    modules = [SuiteSparseGraphBLAS],
    sitename="SuiteSparse:GraphBLAS",
    pages = [
        "Home" => "index.md"
    ]
)

deploydocs(
    repo = "github.com/JuliaSparse/SuiteSparseGraphBLAS.jl.git",
)
