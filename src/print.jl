function gxbprint(io::IO, x, name = "", level::libgb.GxB_Print_Level = libgb.GxB_SUMMARY)
    #if x isa AbstractGBType
    #    libgb.GxB_Type_fprint(x, name, level, C_NULL)
    #elseif x isa libgb.GrB_UnaryOp
    #    libgb.GxB_UnaryOp_fprint(x, name, level, C_NULL)
    #elseif x isa libgb.GrB_BinaryOp
    #    libgb.GxB_BinaryOp_fprint(x, name, level, C_NULL)
    #elseif x isa libgb.GrB_Monoid
    #    libgb.GxB_Monoid_fprint(x, name, level, C_NULL)
    #elseif x isa SelectUnion
    #    libgb.GxB_SelectOp_fprint(x, name, level, C_NULL)
    #elseif x isa libgb.GrB_Semiring
    #    libgb.GxB_Semiring_fprint(x, name, level, C_NULL)
    #elseif x isa AbstractDescriptor
    #    libgb.GxB_Descriptor_fprint(x, name, level, C_NULL)
    #elseif x isa GBVector
    #    if level == libgb.GxB_SUMMARY
    #        libgb.GxB_Matrix_fprint(x, name, libgb.GxB_SHORT, C_NULL)
    #    else
    #        libgb.GxB_Matrix_fprint(x, name, level, C_NULL)
    #    end
    #elseif x isa GBMatrix
    #    if level == libgb.GxB_SUMMARY
    #        libgb.GxB_Matrix_fprint(x, name, libgb.GxB_SHORT, C_NULL)
    #    else
    #        libgb.GxB_Vector_fprint(x, name, level, C_NULL)
    #    end
    #elseif x isa GBScalar
    #    libgb.GxB_Scalar_fprint(x, name, libgb.GxB_SHORT, C_NULL)
    #end
    print(io, gxbstring(x, name, level))
end

function gxbstring(x, name = "", level::libgb.GxB_Print_Level = libgb.GxB_SUMMARY)
    str = mktemp() do _, f
        cf = Libc.FILE(f)
        if x isa AbstractGBType
            libgb.GxB_Type_fprint(x, name, level, cf)
        elseif x isa libgb.GrB_UnaryOp
            libgb.GxB_UnaryOp_fprint(x, name, level, cf)
        elseif x isa libgb.GrB_BinaryOp
            libgb.GxB_BinaryOp_fprint(x, name, level, cf)
        elseif x isa libgb.GrB_Monoid
            libgb.GxB_Monoid_fprint(x, name, level, cf)
        elseif x isa SelectUnion
            libgb.GxB_SelectOp_fprint(x, name, level, cf)
        elseif x isa libgb.GrB_Semiring
            libgb.GxB_Semiring_fprint(x, name, level, cf)
        elseif x isa AbstractDescriptor
            libgb.GxB_Descriptor_fprint(x, name, level, cf)
        elseif x isa GBVector
            if level == libgb.GxB_SUMMARY
                libgb.GxB_Matrix_fprint(x, name, libgb.GxB_SHORT, cf)
            else
                libgb.GxB_Matrix_fprint(x, name, level, cf)
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
    return str
end

function getdocstring(x)
    str = gxbstring(x)
    return strip(split(str, '\n')[2])
end
