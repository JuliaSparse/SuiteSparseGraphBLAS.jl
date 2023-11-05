using Clang.Generators

cd(@__DIR__)

const HEADER_BASE = "/Users/raykimm/GraphBLAS/Source"
const INTERNAL = joinpath(HEADER_BASE, "GB.h")
const GRAPHBLAS = joinpath(HEADER_BASE, "../Include/GraphBLAS.h")

headers = [INTERNAL, GRAPHBLAS]

options = load_options(joinpath(@__DIR__, "gb_generator.toml"))
args = get_default_args()
push!(args, "-I$HEADER_BASE")
push!(args, "-I$HEADER_BASE/Shared")
push!(args, "-I$HEADER_BASE/Template")
push!(args, "-I$HEADER_BASE/Factories")
push!(args, "-I/Users/raykimm/GraphBLAS/Include")
push!(args, "-I/Users/raykimm/GraphBLAS/cpu_features/include")
push!(args, "-I$HEADER_BASE/Template")
push!(args, "-fparse-all-comments")

ctx = create_context(headers, args, options)

build!(ctx)
