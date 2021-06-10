"Return the GxB type suffix of a Julia datatype as a String."
function suffix(T)
    if T == Bool
        return "BOOL"
    elseif T == Int8
        return "INT8"
    elseif T == UInt8
        return "UINT8"
    elseif T == Int16
        return "INT16"
    elseif T == UInt16
        return "UINT16"
    elseif T == Int32
        return "INT32"
    elseif T == UInt32
        return "UINT32"
    elseif T == Int64
        return "INT64"
    elseif T == UInt64
        return "UINT64"
    elseif  T == Float32
        return "FP32"
    elseif T == Float64
        return "FP64"
    elseif T == ComplexF32
        return "FC32"
    elseif T == ComplexF64
        return "FC64"
    else
        error("Not a valid GrB data type")
    end
end

"Return the GrB_Type equivalent to a Julia Type"
function toGrB_Type(T)
    if T == Bool
        return BOOL
    elseif T == Int8
        return INT8
    elseif T == UInt8
        return UINT8
    elseif T == Int16
        return INT16
    elseif T == UInt16
        return UINT16
    elseif T == Int32
        return INT32
    elseif T == UInt32
        return UINT32
    elseif T == Int64
        return INT64
    elseif T == UInt64
        return UINT64
    elseif  T == Float32
        return FP32
    elseif T == Float64
        return FP64
    elseif  T == ComplexF32
        return FC32
    elseif T == ComplexF64
        return FC64
    else
        error("Not a valid GrB data type")
    end
end

"Load a global constant from SSGrB, optionally specify the resulting pointer type."
function load_global(str, type = Cvoid)
    x =
    try
        dlsym(SSGraphBLAS_jll.libgraphblas_handle, str)
    catch e
        print("Symbol not available: " * str * "\n $e")
        return C_NULL
    end
    return unsafe_load(cglobal(x, Ptr{type}))
end

isGxB(name) = name[1:3] == "GxB"

"""
    _print_unsigned_as_signed()

The SuiteSparseGraphBLAS index, GrB_Index, is an alias for UInt64. Julia prints values of
this type in hex, so this can be used to change the printing method to decimal.

This is not recommended for general use and will likely be removed once better printing is
added to this package.
"""
function _print_unsigned_as_signed()
    eval(:(Base.show(io::IO, a::Unsigned) = print(io, Int(a))))
end

"Avoid repeating these extremely common keyword arguments."
macro kwargs(ex)
    if @capture(
        ex, 
        (f_(xs__; xs2__) = body_) | 
        (function f_(xs__; xs2__) body_ end) |
        (f_(xs__) = body_) | 
        (function f_(xs__) body_ end)
    )
        xs2 === nothing ? xs2 = [] : xs2 = map(esc, xs2)
        result = quote
            function $(esc(f))(
                $(map(esc, xs)...);
                mask = C_NULL, accum = C_NULL, desc = Descriptors.NULL, $(xs2...)
            )
            $(esc(body))
            end
        end
    elseif @capture(
        ex, 
        (f_(xs__; xs2__) where {T_} = body_) |
        (function f_(xs__; xs2__) where {T_} body_ end) |
        (f_(xs__) where {T_} = body_) |
        (function f_(xs__) where {T_} body_ end)
    )
        xs2 === nothing ? xs2 = [] : xs2 = map(esc, xs2)
        result = quote
            function $(esc(f))(
                $(map(esc, xs)...);
                mask = C_NULL, accum = C_NULL, desc= Descriptors.NULL, $(xs2...)
            ) where {$(esc(T))}
            $(esc(body))
            end
        end
    end
    #This is not necessarily a good idea. It makes @which and stacktraces correct,
    # but isn't well-tested or recommended.
    result.args[2].args[2].args[1] = __source__
    result.args[2].args[2].args[2] = __source__
    return result
end
