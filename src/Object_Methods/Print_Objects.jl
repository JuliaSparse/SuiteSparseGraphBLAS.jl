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

    s = "Descriptor"
    if T <: GrB_UnaryOp
        s = "UnaryOp"
    elseif T <: GrB_BinaryOp
        s = "BinaryOp"
    elseif T <: GrB_Monoid
        s = "Monoid"
    elseif T <: GrB_Semiring
        s = "Semiring"
    elseif T <: GrB_Vector
        s = "Vector"
    elseif T <: GrB_Matrix
        s = "Matrix"
    end

    fn_name  = "GxB_" * s * "_fprint"
    mktemp(f)
end

macro GxB_Matrix_fprint(A, pr)
    name = string(A)
    return :(GxB_fprint($(esc(A)), $name, $pr))
end

macro GxB_Vector_fprint(v, pr)
    name = string(v)
    return :(GxB_fprint($(esc(v)), $name, $pr))
end

macro GxB_Descriptor_fprint(desc, pr)
    name = string(desc)
    return :(GxB_fprint($(esc(desc)), $name, $pr))
end

macro GxB_UnaryOp_fprint(op, pr)
    name = string(op)
    return :(GxB_fprint($(esc(op)), $name, $pr))
end

macro GxB_BinaryOp_fprint(op, pr)
    name = string(op)
    return :(GxB_fprint($(esc(op)), $name, $pr))
end

macro GxB_Monoid_fprint(monoid, pr)
    name = string(monoid)
    return :(GxB_fprint($(esc(monoid)), $name, $pr))
end

macro GxB_Semiring_fprint(semiring, pr)
    name = string(semiring)
    return :(GxB_fprint($(esc(semiring)), $name, $pr))
end

macro GxB_fprint(A, pr)
    varname = string(A)
    return :(GxB_fprint($(esc(A)), $varname, $pr))
end
