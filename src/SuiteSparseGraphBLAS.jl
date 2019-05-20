module SuiteSparseGraphBLAS

const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("SuiteSparseGraphBLAS not installed properly, run Pkg.build(\"SuiteSparseGraphBLAS\"), restart Julia and try again")
end
include(depsjl_path)

function __init__()
    check_deps()
end

end
