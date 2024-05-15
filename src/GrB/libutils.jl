struct UninitializedObjectError <: Exception
    typedsyms::Tuple
end
function Base.showerror(io::IO, e::UninitializedObjectError) 
    print(io, "Uninitialized object(s) " * 
        reduce(*, "$(pair.first)::$(pair.second), " for pair in e.typedsyms[begin:end - 1]; init="") * 
        "$(e.typedsyms[end].first)::$(e.typedsyms[end].second)"
    )
end
macro uninitializedobject(info, objs...)
    MacroTools.@q begin
        if $(esc(info)) == LibGraphBLAS.GrB_UNINITIALIZED_OBJECT
            throw(UninitializedObjectError($(objs) .=> typeof.(tuple($(esc.(objs)...)))))
        end
    end
end

struct InvalidValueError <: Exception
    msg::String
end
Base.showerror(io::IO, e::InvalidValueError) = print(io, "invalid value: $(e.msg)")
macro invalidvalue(info, msg)
    MacroTools.@q begin
        if $(esc(info)) == LibGraphBLAS.GrB_INVALID_VALUE
            throw(InvalidValueError($(esc(msg))))
        end
    end
end

struct InvalidIndicesError <: Exception
    object
    objectname::Symbol
    syms::Tuple
end
function Base.showerror(io::IO, e::InvalidIndicesError)
    if length(e.syms) > 0
        print(io, "An index in $(e.syms[begin])" *
            reduce(*, " or $(sym)" for sym in e.syms[(begin + 1):end]; init="") *
            " is out of bounds for $(size(e.object)[1])×$(size(e.object)[2]) 
            $(typeof(e.object)) $(e.object) or previous pending operations."
        )
    else
        print(io, "An index in a pending operation is out of bounds when 
        waiting for $(e.objectname)::$(typeof(e.object)).")
    end
end
# Use standard BoundsError for this.
macro invalidindex(info, mat, indices...)
    MacroTools.@q begin
        if $(esc(info)) == LibGraphBLAS.GrB_INDEX_OUT_OF_BOUNDS || 
                $(esc(info)) == LibGraphBLAS.GrB_INVALID_INDEX
            if length(indices) < 1 || !($(esc(indices[1])) isa Number)
                throw(InvalidIndicesError($(esc(mat)), $(Meta.quot(mat)), $(indices)))
            else
                throw(BoundsError($(esc(mat)), tuple($(esc.(indices)...))))
            end
        end
    end
end

struct DomainMismatchError <: Exception
    typedsyms::Tuple
end
function Base.showerror(io::IO, e::DomainMismatchError) 
    print(io, "domain mismatch between " * 
        reduce(*, "$(pair.first)::$(pair.second), " for pair in e.typedsyms[begin:end - 1]; init="") * 
        "$(e.typedsyms[end].first)::$(e.typedsyms[end].second)"
    )
end

macro dimensionmismatch(info, msg)
    MacroTools.@q begin
        if $(esc(info)) == LibGraphBLAS.GrB_DIMENSION_MISMATCH
            throw(DomainMismatchError($(esc(msg))))
        end
    end
end

# Domains is an eltype except for operators where it is the domain types of the operator.
domains(x) = eltype(x)
domains(::Ptr{Nothing}) = ()
macro domainmismatch(info, objs...)
    MacroTools.@q begin
        if $(esc(info)) == LibGraphBLAS.GrB_DOMAIN_MISMATCH
            throw(DomainMismatchError($(objs) .=> domains.(tuple($(esc.(objs)...)))))
        end
    end
end

struct OutputNotEmptyError <: Exception
    sym::Symbol
end
function Base.showerror(io::IO, e::OutputNotEmptyError)
    print(io, "Output object $(e.sym) must be empty before this operation.")
end
macro outputnotempty(info, sym)
    MacroTools.@q begin
        if $(esc(info)) == LibGraphBLAS.GrB_OUTPUT_NOT_EMPTY
            throw(OutputNotEmptyError($(Meta.quot(sym))))
        end
    end
end

struct InsufficientSpaceError <: Exception end
function Base.showerror(io::IO, ::InsufficientSpaceError)
    print(io, "Insufficient space in an output array.")
end
macro insufficientspace(info)
    MacroTools.@q begin
        if $(esc(info)) == LibGraphBLAS.GrB_INSUFFICIENT_SPACE
            throw(InsufficientSpaceError())
        end
    end
end
struct AlreadySetError <: Exception
    object
    objectname::Symbol
    field::Symbol
end
function Base.showerror(io::IO, e::AlreadySetError)
    print(io, "Field $(e.field) of $(e.objectname)::$(typeof(object)) has already been set.")
end
macro alreadyset(info, obj, field)
    MacroTools.@q begin
        if $(esc(info)) == LibGraphBLAS.GrB_ALREADY_SET
            throw(AlreadySetError($(esc(obj)), $(Meta.quot(obj)), $((esc(field)))))
        end
    end
end

struct InvalidObjectError <: Exception end
function Base.showerror(io::IO, ::InvalidObjectError)
    print(io, "An invalid GraphBLAS object due to a previous execution error 
    was encountered.")
end
struct OutOfMemoryError <: Exception end
struct ExhaustedError <: Exception end
struct PanicError <: Exception end
struct NullPointerError <: Exception end
# null pointers are not possible, so we will check only in the fallback.

macro fallbackerror(info)
    MacroTools.@q begin
        info = $(esc(info))
        if info == LibGraphBLAS.GrB_INVALID_OBJECT
            throw(InvalidObjectError())
        elseif info == LibGraphBLAS.GrB_OUT_OF_MEMORY
            throw(OutOfMemoryError())
        elseif info == LibGraphBLAS.GrB_NULL_POINTER
            throw(NullPointerError())
        elseif info == LibGraphBLAS.GrB_PANIC
            throw(PanicError())
        else
            throw(ErrorException("Unknown GraphBLAS error code: $info"))
        end
    end
end

macro checkfree(info)
    MacroTools.@q begin
        if $(esc(info)) == LibGraphBLAS.GrB_PANIC
            throw(PanicError())
        end
    end
end

# Increment and decrement functions to be used *ONLY* for
# incrementing and decrementing input indices.
# for this reason CIndices are not incremented or decremented.
@inline decrement(I) = I .- 1
@inline decrement(I::CIndex) = I
@inline decrement(I::AbstractArray{<:CIndex}) = I

@inline increment(I) = I .+ 1
@inline increment(I::CIndex) = I
@inline increment(I::AbstractArray{<:CIndex}) = I

@inline decrement!(I::Number) = I - 1
@inline decrement!(I::AbstractArray) = I .-= 1
@inline decrement!(I) = I # don't need to modify here, likely an All().
@inline decrement!(I::AbstractArray{<:CIndex}) = I

@inline increment!(I::Number) = I + 1
@inline increment!(I::AbstractArray) = I .+= 1
@inline increment!(I) = I # don't need to modify here, likely an All().
@inline increment!(I::AbstractArray{<:CIndex}) = I

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
    elseif T === :Any
        return "UDT"
    else
        return uppercase(string(T))
    end
end

"Return the GxB type suffix of a Julia datatype as a String."
function suffix(T)
    return suffix(Symbol(T))
end

"Load a global constant from SSGrB, optionally specify the resulting pointer type."
function load_global(str, type::Core.Type{Ptr{T}} = Ptr{Nothing}) where {T}
    x =
    try
        Libdl.dlsym(libgraphblas_handle[], str)
    catch e
        @warn "Symbol $str not available "
        return type(C_NULL)
    end
    return unsafe_load(cglobal(x, type))
end

load_global(str, type) = load_global(str, Ptr{type})

isGxB(name) = occursin("GxB", name)
isGrB(name) = occursin("GrB", name)
