module SuiteSparseGraphBLAS
using Libdl
import Base.show

const depsjl_path = joinpath(@__DIR__, "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("SuiteSparseGraphBLAS not installed properly, run Pkg.build(\"SuiteSparseGraphBLAS\"), restart Julia and try again")
end
include(depsjl_path)

struct GrB_Type
    p::Ptr{Cvoid}
end
Base.show(io::IO, ::GrB_Type) = print("GrB_Type")

const types = ["BOOL", "INT8", "UINT8", "INT16", "UINT16",
                "INT32", "UINT32", "INT64", "UINT64", "FP32", "FP64"]

function __init__()
    check_deps()

    global libgraphblas
    hdl = dlopen(libgraphblas)

    function load_global(str)
        x = dlsym(hdl, str)
        return unsafe_load(cglobal(x, Ptr{Cvoid}))
    end

    for t in types
        x = GrB_Type(load_global("GrB_"*t))
        @eval const $(Symbol(:GrB_, t)) = $x
    end
end

export GrB_BOOL, GrB_INT8, GrB_UINT8, GrB_INT16, GrB_UINT16, GrB_INT32, 
       GrB_UINT32, GrB_INT64, GrB_UINT64, GrB_FP32, GrB_FP64

end
