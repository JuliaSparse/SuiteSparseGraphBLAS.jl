using Documenter, SuiteSparseGraphBLAS

makedocs(
    modules     = [SuiteSparseGraphBLAS],
    format      = Documenter.HTML(),
    sitename    = "SuiteSparseGraphBLAS",
    doctest     = false,
    pages       = Any[
		"Introduction"						=> "index.md",
        "Basic matrix & vector methods"     => "matrix_and_vector_methods.md",
		"Operators & algebraic structures"	=> "algebra_methods.md",
		"Descriptors"						=> "desc_methods.md",
		"Freeing objects"					=> "free_methods.md"
    ]
)

deploydocs(
    target = "build",
    deps   = nothing,
    make   = nothing,
    repo   = "github.com/abhinavmehndiratta/SuiteSparseGraphBLAS.jl.git"
)
