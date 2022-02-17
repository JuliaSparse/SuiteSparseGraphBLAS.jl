

function suffix(T::Symbol)
    if T === :Bool
        return "BOOL"
    elseif T === :Int8
        return "INT8"
    elseif T === :UInt8
        return "UINT8"
    elseif T === :Int16
        return "INT16"
    elseif T === :UInt16
        return "UINT16"
    elseif T === :Int32
        return "INT32"
    elseif T === :UInt32
        return "UINT32"
    elseif T === :Int64
        return "INT64"
    elseif T === :UInt64
        return "UINT64"
    elseif  T === :Float32
        return "FP32"
    elseif T === :Float64
        return "FP64"
    elseif T === :ComplexF32
        return "FC32"
    elseif T === :ComplexF64
        return "FC64"
    else
        return uppercase(string(T))
    end
end

"Return the GxB type suffix of a Julia datatype as a String."
function suffix(T)
    return suffix(Symbol(T))
end

"Load a global constant from SSGrB, optionally specify the resulting pointer type."
function load_global(str, type::Type{Ptr{T}} = Ptr{Nothing}) where {T}
    x =
    try
        dlsym(libgraphblas_handle[], str)
    catch e
        @warn "Symbol not available " * str
        return type(C_NULL)
    end
    return unsafe_load(cglobal(x, type))
end

load_global(str, type) = load_global(str, Ptr{type})

isGxB(name) = occursin("GxB", name)
isGrB(name) = occursin("GrB", name)