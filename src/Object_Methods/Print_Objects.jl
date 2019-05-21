function GxB_Matrix_fprint(A::GrB_Matrix, name::String, pr::GxB_Print_Level)
    function fn(path, io)
        FILE = Libc.FILE(io)
        ccall(dlsym(hdl, "GxB_Matrix_fprint"), Cint, (Ptr{Cvoid}, Ptr{UInt8}, Cint, Ptr{Cvoid}), A.p, pointer(name), pr, FILE)
        ccall(:fclose, Cint, (Ptr{Cvoid},), FILE)
        foreach(println, eachline(path))
    end
    mktemp(fn)
end

macro GxB_Matrix_fprint(A, pr)
    name = string(A)
    return :(GxB_Matrix_fprint($A, $name, $pr))
end