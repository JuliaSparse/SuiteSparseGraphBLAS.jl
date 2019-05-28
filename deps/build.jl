using BinaryProvider # requires BinaryProvider 0.3.0 or later

const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
const path = joinpath(@__DIR__, "usr/lib64")
products = [
    LibraryProduct(path, "libgraphblas", :libgraphblas),
]
bin_prefix = "https://raw.githubusercontent.com/abhinavmehndiratta/GB_bin/master"

download_info = Dict(
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GraphBLAS.v2.2.3.x86_64-linux-gnu-gcc7.tar.gz", "16ff3800e51623f2379f0eebf999964c18e4c38efa5430008a51d4ddbc527cd2"),
    Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GraphBLAS.v2.2.3.x86_64-linux-gnu-gcc8.tar.gz", "1379bc3198d145a56945f276ddf71320336f1af9df46292e2704f0e538f8938e"),
)

if any(!satisfied(p; verbose=verbose) for p in products)
    try
        url, tarball_hash = choose_download(download_info)
        install(url, tarball_hash; prefix=prefix, force=true, verbose=true)
    catch e
        if typeof(e) <: ArgumentError
            error("Your platform $(Sys.MACHINE) is not supported by this package!")
        else
            rethrow(e)
        end
    end
    write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
end
