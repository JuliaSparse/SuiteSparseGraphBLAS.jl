function gxbprint(io::IO, x, name = "", level::LibGraphBLAS.GxB_Print_Level = LibGraphBLAS.GxB_SUMMARY)
    print(io, gxbstring(x, name, level))
end

function gxbstring(x, name = "", level::LibGraphBLAS.GxB_Print_Level = LibGraphBLAS.GxB_SUMMARY)
    str = mktemp() do _, f
        cf = Libc.FILE(f)
        if x isa AbstractGBType
            @wraperror LibGraphBLAS.GxB_Type_fprint(x, name, level, cf)
        elseif x isa LibGraphBLAS.GrB_UnaryOp
            @wraperror LibGraphBLAS.GxB_UnaryOp_fprint(x, name, level, cf)
        elseif x isa LibGraphBLAS.GrB_BinaryOp
            @wraperror LibGraphBLAS.GxB_BinaryOp_fprint(x, name, level, cf)
        elseif x isa LibGraphBLAS.GrB_Monoid
            @wraperror LibGraphBLAS.GxB_Monoid_fprint(x, name, level, cf)
        elseif x isa SelectUnion
            @wraperror LibGraphBLAS.GxB_SelectOp_fprint(x, name, level, cf)
        elseif x isa LibGraphBLAS.GrB_Semiring
            @wraperror LibGraphBLAS.GxB_Semiring_fprint(x, name, level, cf)
        elseif x isa AbstractDescriptor
            @wraperror LibGraphBLAS.GxB_Descriptor_fprint(x, name, level, cf)
        elseif x isa AbstractGBVector
            if level == LibGraphBLAS.GxB_SUMMARY
                @wraperror LibGraphBLAS.GxB_Matrix_fprint(gbpointer(x), name, LibGraphBLAS.GxB_SHORT, cf)
            else
                @wraperror LibGraphBLAS.GxB_Matrix_fprint(gbpointer(x), name, level, cf)
            end
        elseif x isa AbstractGBMatrix
            if level == LibGraphBLAS.GxB_SUMMARY
                @wraperror LibGraphBLAS.GxB_Matrix_fprint(gbpointer(x), name, LibGraphBLAS.GxB_SHORT, cf)
            else
                @wraperror LibGraphBLAS.GxB_Vector_fprint(gbpointer(x), name, level, cf)
            end
        elseif x isa GBScalar
            @wraperror LibGraphBLAS.GxB_Scalar_fprint(x, name, LibGraphBLAS.GxB_SHORT, cf)
        end
        flush(f)
        seekstart(f)
        x = read(f, String)
        close(cf)
        lstrip(x)
    end
    return str
end

function getdocstring(x)
    str = gxbstring(x)
    return strip(split(str, '\n')[2])
end
