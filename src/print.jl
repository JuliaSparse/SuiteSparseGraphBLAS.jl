function gxbprint(io::IO, x, name = "", level::libgb.GxB_Print_Level = libgb.GxB_SUMMARY)
    str = mktemp() do _, f
        cf = Libc.FILE(f)
        if x isa AbstractGBType
            libgb.GxB_Type_fprint(x, name, level, cf)
        elseif x isa libgb.GrB_UnaryOp
            libgb.GxB_UnaryOp_fprint(x, name, level, cf)
        elseif x isa libgb.GrB_BinaryOp
            libgb.GxB_BinaryOp_fprint(x, name, level, cf)
        elseif x isa SelectUnion
            libgb.GxB_SelectOp_fprint(x, name, level, cf)
        elseif x isa libgb.GrB_Semiring
            libgb.GxB_Semiring_fprint(x, name, level, cf)
        elseif x isa AbstractDescriptor
            libgb.GxB_Descriptor_fprint(x, name, level, cf)
        elseif x isa GBVector
            if level == libgb.GxB_SUMMARY
                libgb.GxB_Vector_fprint(x, name, libgb.GxB_SHORT, cf)
            else
                libgb.GxB_Vector_fprint(x, name, level, cf)
            end
        elseif x isa GBMatrix
            if level == libgb.GxB_SUMMARY
                libgb.GxB_Matrix_fprint(x, name, libgb.GxB_SHORT, cf)
            else
                libgb.GxB_Vector_fprint(x, name, level, cf)
            end
        elseif x isa GBScalar
            libgb.GxB_Scalar_fprint(x, name, libgb.GxB_SHORT, cf)
        end
        flush(f)
        seekstart(f)
        x = read(f, String)
        close(cf)
        x
    end
    replace(str, "\n" => "")
    print(io, str[4:end])
end

function Base.isstored(A::GBArray, i::Integer, j::Integer)
    @boundscheck checkbounds(A, i, j)
    if A[i, j] === nothing
        return false
    else
        return true
    end
end

#Help wanted: This isn't really centered for a lot of eltypes.
function Base.replace_in_print_matrix(A::GBArray, i::Integer, j::Integer, s::AbstractString)
    Base.isstored(A, i, j) ? s : Base.replace_with_centered_mark(s)
end
