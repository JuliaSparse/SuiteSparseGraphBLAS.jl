@enum GxB_Print_Level begin
    GxB_SILENT = 0                  # nothing is printed just check the object
    GxB_SUMMARY = 1                 # print a terse summary
    GxB_SHORT = 2                   # short description about 30 entries of a matrix
    GxB_COMPLETE = 3                # print the entire contents of the object
end

function GxB_fprint(
    A::T,
    name::String,
    pr::GxB_Print_Level
    ) where T <: Union{GrB_Type, GrB_UnaryOp, GrB_BinaryOp, GrB_Monoid, GrB_Semiring, GrB_Matrix, GrB_Vector, GrB_Descriptor}

    function f(path, io)
        FILE = Libc.FILE(io)
        ccall(dlsym(graphblas_lib, fn_name), Cint, (Ptr{Cvoid}, Ptr{UInt8}, Cint, Ptr{Cvoid}), A.p, pointer(name), pr, FILE)
        ccall(:fclose, Cint, (Ptr{Cvoid},), FILE)
        foreach(println, eachline(path))
    end

    fn_name  = "GxB_" *string(T.name)[5:end]* "_fprint"
    mktemp(f)
end

macro GxB_fprint(A, pr = :GxB_COMPLETE)
    varname = string(A)
    return :(GxB_fprint($(esc(A)), $varname, $pr))
end
