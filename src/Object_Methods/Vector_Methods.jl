import GraphBLASInterface:
        GrB_Vector_new, GrB_Vector_build, GrB_Vector_dup, GrB_Vector_clear, GrB_Vector_size,
        GrB_Vector_nvals, GrB_Vector_setElement, GrB_Vector_extractElement, GrB_Vector_extractTuples

function GrB_Vector_new(v::GrB_Vector{T}, type::GrB_Type{T}, n::U) where {T, U <: GrB_Index}
    v_ptr = pointer_from_objref(v)
    
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Vector_new"),
                Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t),
                v_ptr, type.p, n
            )
        )
end

function GrB_Vector_dup(w::GrB_Vector{T}, u::GrB_Vector{T}) where T
    w_ptr = pointer_from_objref(w)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Vector_dup"),
                Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}),
                w_ptr, u.p
            )
        )
end

function GrB_Vector_clear(v::GrB_Vector)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Vector_clear"),
                Cint,
                (Ptr{Cvoid}, ),
                v.p
            )
        )
end

function GrB_Vector_size(v::GrB_Vector)
    n = Ref(UInt64(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_size"),
                        Cint,
                        (Ptr{UInt64}, Ptr{Cvoid}),
                        n, v.p
                    )
                )
    result != GrB_SUCCESS && return result
    return _GrB_Index(n[])
end

function GrB_Vector_nvals(v::GrB_Vector)
    nvals = Ref(UInt64(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Vector_nvals"),
                        Cint,
                        (Ptr{UInt64}, Ptr{Cvoid}),
                        nvals, v.p
                    )
                )
    result != GrB_SUCCESS && return result
    return _GrB_Index(nvals[])
end

function GrB_Vector_build(w::GrB_Vector{T}, I::Vector{U}, X::Vector{T}, nvals::U, dup::GrB_BinaryOp) where {T, U <: GrB_Index}
    I_ptr = pointer(I)
    X_ptr = pointer(X)
    fn_name = "GrB_Vector_build_" * suffix(T)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Ptr{U}, Ptr{T}, Cuintmax_t, Ptr{Cvoid}),
                w.p, I_ptr, X_ptr, nvals, dup.p
            )
        )
end

function GrB_Vector_setElement(w::GrB_Vector{T}, x::T, i::U) where {T, U <: GrB_Index}
    fn_name = "GrB_Vector_setElement_" * suffix(T)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cintmax_t, Cuintmax_t),
                w.p, x, i
            )
        )
end

function GrB_Vector_setElement(w::GrB_Vector{UInt64}, x::UInt64, i::U) where U <: GrB_Index
    fn_name = "GrB_Vector_setElement_UINT64"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cuintmax_t, Cuintmax_t),
                w.p, x, i
            )
        )
end

function GrB_Vector_setElement(w::GrB_Vector{Float32}, x::Float32, i::U) where U <: GrB_Index
    fn_name = "GrB_Vector_setElement_FP32"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cfloat, Cuintmax_t),
                w.p, x, i
            )
        )
end

function GrB_Vector_setElement(w::GrB_Vector{Float64}, x::Float64, i::U) where U <: GrB_Index
    fn_name = "GrB_Vector_setElement_FP64"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cdouble, Cuintmax_t),
                w.p, x, i
            )
        )
end

function GrB_Vector_extractElement(v::GrB_Vector{T}, i::U) where {T, U <: GrB_Index}
    fn_name = "GrB_Vector_extractElement_" * suffix(T)

    element = Ref(T(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t),
                        element, v.p, i
                    )
                )
    result != GrB_SUCCESS && return result
    return element[]
end

function GrB_Vector_extractTuples(v::GrB_Vector{T}) where T
    nvals = GrB_Vector_nvals(v)
    if typeof(nvals) == GrB_Info
        return nvals
    end
    I = Vector{typeof(nvals)}(undef, nvals)
    X = Vector{T}(undef, nvals)
    n = Ref(UInt64(nvals))

    fn_name = "GrB_Vector_extractTuples_" * suffix(T)
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{UInt64}, Ptr{Cvoid}),
                        pointer(I), pointer(X), n, v.p
                    )
                )
    result != GrB_SUCCESS && return result
    return I, X
end
