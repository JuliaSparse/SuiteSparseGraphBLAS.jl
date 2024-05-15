function gxbprint(
    io::IO, x, name = "", 
    level::LibGraphBLAS.GxB_Print_Level = x isa Matrix ? 
    LibGraphBLAS.GxB_SHORT : LibGraphBLAS.GxB_SUMMARY
)
    print(io, gxbstring(x, name, level))
end

function GxB_fprint end
function gxbstring(
    x, name = C_NULL, 
    level::LibGraphBLAS.GxB_Print_Level = x isa Matrix ? 
    LibGraphBLAS.GxB_SHORT : LibGraphBLAS.GxB_SUMMARY
)
    str = mktemp() do _, f
        cf = Libc.FILE(f)
        GxB_fprint(x, name, level, cf)
        flush(f)
        seekstart(f)
        x = read(f, String)
        close(cf)
        lstrip(x)
    end
    return str
end
