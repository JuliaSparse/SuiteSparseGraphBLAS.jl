using Clang.Generators
using SSGraphBLAS_jll

cd(@__DIR__)

const HEADER_BASE = joinpath(SSGraphBLAS_jll.artifact_dir, "include")
const GRAPHBLAS = "/home/will/GraphBLAS/Include/GraphBLAS.h"

headers = [GRAPHBLAS]

options = load_options(joinpath(@__DIR__, "generator.toml"))
args = get_default_args()
push!(args, "-fparse-all-comments")
push!(args, "-I$HEADER_BASE")

ctx = create_context(headers, args, options)

build!(ctx)
