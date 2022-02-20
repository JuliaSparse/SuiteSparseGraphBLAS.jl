
# exceptions: 

struct UninitializedObjectError <: Exception end
struct InvalidObjectError <: Exception end
struct NullPointerError <: Exception end
struct InvalidValueError <: Exception end
struct InvalidIndexError <: Exception end
struct OutputNotEmptyError <: Exception end
struct InsufficientSpaceError <: Exception end
struct PANIC <: Exception end

macro wraperror(code)
    MacroTools.@q begin
        info = $(esc(code))
        if info == LibGraphBLAS.GrB_SUCCESS
        elseif info == LibGraphBLAS.GrB_NO_VALUE
            return nothing
        else
            if info == LibGraphBLAS.GrB_UNINITIALIZED_OBJECT
                throw(UninitializedObjectError)
            elseif info == LibGraphBLAS.GrB_INVALID_OBJECT
                throw(InvalidObjectError)
            elseif info == LibGraphBLAS.GrB_NULL_POINTER
                throw(NullPointerError)
            elseif info == LibGraphBLAS.GrB_INVALID_VALUE
                throw(InvalidValueError)
            elseif info == LibGraphBLAS.GrB_INVALID_INDEX
                throw(InvalidIndexError)
            elseif info == LibGraphBLAS.GrB_DOMAIN_MISMATCH
                throw(DomainError(nothing, "GraphBLAS Domain Mismatch"))
            elseif info == LibGraphBLAS.GrB_DIMENSION_MISMATCH
                throw(DimensionMismatch())
            elseif info == LibGraphBLAS.GrB_OUTPUT_NOT_EMPTY
                throw(OutputNotEmptyError)
            elseif info == LibGraphBLAS.GrB_OUT_OF_MEMORY
                throw(OutOfMemoryError())
            elseif info == LibGraphBLAS.GrB_INSUFFICIENT_SPACE
                throw(InsufficientSpaceError)
            elseif info == LibGraphBLAS.GrB_INDEX_OUT_OF_BOUNDS
                throw(BoundsError())
            elseif info == LibGraphBLAS.GrB_PANIC
                throw(PANIC)
            else
                throw(ErrorException("Unreachable Reached."))
            end
        end
    end
end


function decrement(I)
    I isa Vector && (return I .- 1)
    I isa Integer && (return I - 1)
end

function increment(I)
    I isa Vector && (return I .+ 1)
    I isa Integer && (return I + 1)
    return I
end

function decrement!(I)
    I isa Vector && (return I .-= 1)
end
function increment!(I)
    I isa Vector && (return I .+= 1)
end

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