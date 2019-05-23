function GrB_Vector_new(v::GrB_Vector, type::GrB_Type, n::T) where T <: GrB_Index
    v_ptr = pointer_from_objref(v)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Vector_new"),
                Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}, Cintmax_t),
                v_ptr, type.p, n
            )
        )
end

function GrB_Vector_dup(w::GrB_Vector, u::GrB_Vector)
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

function GrB_Vector_build(w::GrB_Vector, I::Vector{U}, X::Vector{T}, nvals::U, dup::GrB_BinaryOp) where{U <: GrB_Index, T <: valid_types}
    I_ptr = pointer(I)
    X_ptr = pointer(X)
    fn_name = "GrB_Vector_build_" * get_suffix(T)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Ptr{U}, Ptr{T}, Cintmax_t, Ptr{Cvoid}),
                w.p, I_ptr, X_ptr, nvals, dup.p
            )
        )
end

function GrB_Vector_setElement(w::GrB_Vector, x::T, i::U) where {U <: GrB_Index, T <: valid_int_types}
    fn_name = "GrB_Vector_setElement_" * get_suffix(T)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cintmax_t, Cintmax_t),
                w.p, x, i
            )
        )
end

function GrB_Vector_setElement(w::GrB_Vector, x::Float32, i::U) where U <: GrB_Index
    fn_name = "GrB_Vector_setElement_FP32"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cfloat, Cintmax_t),
                w.p, x, i
            )
        )
end

function GrB_Vector_setElement(w::GrB_Vector, x::Float64, i::U) where U <: GrB_Index
    fn_name = "GrB_Vector_setElement_FP64"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cdouble, Cintmax_t),
                w.p, x, i
            )
        )
end

function GrB_Vector_extractElement(v::GrB_Vector, i::U) where U <: GrB_Index
    res, v_type = GxB_Vector_type(v)
    res != GrB_SUCCESS && return res
    suffix, T = get_suffix_and_type(v_type)
    fn_name = "GrB_Vector_extractElement_" * suffix

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

function GrB_Vector_extractTuples(v::GrB_Vector)
    res, v_type = GxB_Vector_type(v)
    res != GrB_SUCCESS && return res
    suffix, T = get_suffix_and_type(v_type)
    nvals = GrB_Vector_nvals(v)
    I = Vector{typeof(nvals)}(undef, nvals)
    X = Vector{T}(undef, nvals)
    n = Ref(UInt64(nvals))

    fn_name = "GrB_Vector_extractTuples_" * suffix
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
