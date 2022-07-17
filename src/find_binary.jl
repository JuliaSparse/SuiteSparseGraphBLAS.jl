function get_lib()
    default_lib = "/home/will/GraphBLAS/build/libgraphblas.so"

    lib = @load_preference("shared_lib", default_lib)
    if lib != "default" && lib !== nothing
        if !isfile(lib)
            @error("User provided shared library: $lib is not a file.")
            lib = default_lib
        end
    else
        lib = default_lib
    end
    return lib
end

const artifact_or_path = get_lib()

"""
    set_lib!(path; export_prefs::Bool = false)

Set the shared library path for SuiteSparse:GraphBLAS. Set to "default" to use the provided artifact.
"""
function set_lib!(path; export_prefs::Bool = false)
    if path != "default" && path !== nothing
        if !isfile(path)
            @error("User provided shared library: $path is not a file.")
        end
    end
    set_preferences!(@__MODULE__, "shared_lib" => path; export_prefs, force = true)
    if path != artifact_or_path
        path = get_lib()
        @info("SuiteSparse:GraphBLAS shared library changed; restart Julia for this change to take effect", path)
    end
end
