Base.unsafe_convert(::Core.Type{LibGraphBLAS.GrB_Scalar}, A::Scalar) = A.p

function Scalar{T}() where T
    r = Ref{LibGraphBLAS.GrB_Scalar}()
    t = Type(T)
    info = LibGraphBLAS.GrB_Scalar_new(r)
    if info != LibGraphBLAS.GrB_SUCCESS
        @uninitializedobject info t
        @fallbackerror info
    end
    return finalizer(Scalar{T}(r[])) do A
        @checkfree LibGraphBLAS.GrB_Scalar_free(Ref(A.p))
    end
end
function Scalar{T}(x) where T
    s = Scalar{T}()
    s[] = convert(T, x)
    return s
end
function Scalar(x::T) where T
    s = Scalar{T}()
    s[] = x
    return s
end

function dup(A::Scalar{T}) where T
    r = Ref{LibGraphBLAS.GrB_Scalar}()
    info =  LibGraphBLAS.GrB_Scalar_dup(r, A)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return finalizer(Scalar{T}(r[])) do A
        @checkfree LibGraphBLAS.GrB_Scalar_free(Ref(A.p))
    end
end

function clear!(A::Scalar)
    info =  LibGraphBLAS.GrB_Scalar_clear(A)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return A
end

function nvals(A::Scalar)
    r = Ref{LibGraphBLAS.GrB_Index}()
    info = LibGraphBLAS.GrB_Scalar_nvals(r, A)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return Int64(r[])
end

# Type dependent functions build, setindex, getindex, and findnz:
for T ∈ builtin_vec
    if T ∈ gxb_vec
        prefix = :GxB
    else
        prefix = :GrB
    end
    # Setindex functions
    func = Symbol(prefix, :_Scalar_setElement_, suffix(T))
    @eval begin
        function nothrow_setElement!(A::Scalar{$T}, x::$T)
            LibGraphBLAS.$func(A, x)
            return x
        end
    end
    # Getindex functions
    func = Symbol(prefix, :_Scalar_extractElement_, suffix(T))
    @eval begin
        function nowthrow_getElement!(x::Ref{$T}, A::Scalar{$T})
            return LibGraphBLAS.$func(x, A)
        end
    end
end

function nothrow_setElement!(A::Scalar{T}, x::T) where T
    LibGraphBLAS.GrB_Scalar_setElement_UDT(A, Ref(x))
    return x
end
function nothrow_getElement!(x::Ref{T}, A::Scalar{T}) where T
    return LibGraphBLAS.GrB_Scalar_extractElement_UDT(x, A)
end

function setElement!(A::Scalar{T}, x) where T
    info = nothrow_setElement!(A, convert(T, x))
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return x
end
function Base.setindex!(A::Scalar{T}, x) where T
    return setElement!(A, x)
end

function getElement!(x::Ref{T}, A::Matrix{T}, i, j) where T
    info = nothrow_getElement!(x, A, i, j)
    if info == LibGraphBLAS.GrB_SUCCESS
        return true
    elseif info == LibGraphBLAS.GrB_NO_VALUE
        return false
    else
        GrB.@uninitializedobject info A x
        GrB.@fallbackerror info
    end
end
function Base.getindex(A::Scalar{T}; default = novalue) where T
    x = Ref{T}()
    return getElement!(x, A) ? x[] : default
end

wait!(A::Scalar, mode) = LibGraphBLAS.GrB_Scalar_wait(A, mode)

function GrB.GxB_fprint(x::Scalar, name, level, file)
    info = LibGraphBLAS.GxB_Scalar_fprint(x, name, level, file)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info x
        GrB.@fallbackerror info
    end
end
function Base.show(io::IO, ::MIME"text/plain", t::Scalar{T}) where T
    print(io, "GrB_Scalar{" * string(T) * "}: ")
    gxbprint(io, t)
end
