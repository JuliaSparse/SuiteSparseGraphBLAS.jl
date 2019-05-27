using BinaryProvider # requires BinaryProvider 0.3.0 or later

const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
const path = joinpath(@__DIR__, "usr/lib64")
products = [
    LibraryProduct(path, "libgraphblas", :libgraphblas),
]
bin_prefix = "https://raw.githubusercontent.com/abhinavmehndiratta/GB_bin/master"

download_info = Dict(
        Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GraphBLAS.v2.3.2.x86_64-linux-gnu-gcc7.tar.gz", "177e043f840a30efd8e0e3614af41d6c99ab98da198bfda6f6b8c5239eb92785"),
	Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc7)) => ("$bin_prefix/GraphBLAS.v2.3.2.aarch64-linux-gnu-gcc7.tar.gz", "c4de51db6489a2d37f051402deb74a1c7dea7fe6e616a3de621d6f15a3890ae0"),
	Linux(:x86_64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GraphBLAS.v2.3.2.x86_64-linux-gnu-gcc8.tar.gz", "06c0bd7dd0868a9d34f1ef216a805ab4ef1e510b84965fc1e3f193ff105969b5"),
	Linux(:aarch64, libc=:glibc, compiler_abi=CompilerABI(:gcc8)) => ("$bin_prefix/GraphBLAS.v2.3.2.aarch64-linux-gnu-gcc8.tar.gz", "13f5d707b547ee74173f324cafc27620c3fea377b5bf80e176c7869aa022ae3c"),
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
