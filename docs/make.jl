using Documenter, SuiteSparseGraphBLAS

makedocs(
    modules     = [SuiteSparseGraphBLAS],
    format      = Documenter.HTML(),
    sitename    = "GraphBLAS.jl",
    doctest     = false,
    pages       = Any[
        "Basic matrix functions"            => "matrix_methods.md",
        "Basic vector functions"            => "vector_methods.md"
    ]
)

deploydocs(
    julia = "nightly",
    repo = "github.com/abhinavmehndiratta/SuiteSparseGraphBLAS.jl.git"
)
