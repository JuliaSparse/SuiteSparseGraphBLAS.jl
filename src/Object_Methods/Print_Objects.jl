function GxB_Matrix_fprint(A::GrB_Matrix, name::String, pr::GxB_Print_Level)
    function fn(path, io)
        FILE = Libc.FILE(io)
        ccall(dlsym(graphblas_lib, "GxB_Matrix_fprint"), Cint, (Ptr{Cvoid}, Ptr{UInt8}, Cint, Ptr{Cvoid}), A.p, pointer(name), pr, FILE)
        ccall(:fclose, Cint, (Ptr{Cvoid},), FILE)
        foreach(println, eachline(path))
    end
    mktemp(fn)
end

macro GxB_Matrix_fprint(A, pr)
    name = string(A)
    return :(GxB_Matrix_fprint($(esc(A)), $name, $pr))
end

function GxB_Vector_fprint(v::GrB_Vector, name::String, pr::GxB_Print_Level)
    function fn(path, io)
        FILE = Libc.FILE(io)
        ccall(dlsym(graphblas_lib, "GxB_Vector_fprint"), Cint, (Ptr{Cvoid}, Ptr{UInt8}, Cint, Ptr{Cvoid}), v.p, pointer(name), pr, FILE)
        ccall(:fclose, Cint, (Ptr{Cvoid},), FILE)
        foreach(println, eachline(path))
    end
    mktemp(fn)
end

macro GxB_Vector_fprint(v, pr)
    name = string(v)
    return :(GxB_Vector_fprint($(esc(v)), $name, $pr))
end
