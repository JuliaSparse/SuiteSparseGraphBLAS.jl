using Documenter, SuiteSparseGraphBLAS

makedocs(
    modules     = [SuiteSparseGraphBLAS],
    format      = Documenter.HTML(),
    sitename    = "SuiteSparseGraphBLAS",
    doctest     = false,
    pages       = Any[
        "Basic matrix functions"            => "matrix_methods.md",
        "Basic vector functions"            => "vector_methods.md"
    ]
)

deploydocs(
    target = "build",
    deps   = nothing,
    make   = nothing,
    repo   = "github.com/abhinavmehndiratta/SuiteSparseGraphBLAS.jl.git"
)
