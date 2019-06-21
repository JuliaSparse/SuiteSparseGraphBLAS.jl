"""
    GrB_Vector_new(v, type, n)

Create a new vector with specified domain and size.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(V, GrB_FP64, 4)
GrB_SUCCESS::GrB_Info = 0
```
"""
function GrB_Vector_new(v::GrB_Vector{T}, type::GrB_Type{T}, n::U) where {U <: GrB_Index, T <: valid_types}
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

"""
    GrB_Vector_dup(w, u)

Create a new vector with the same domain, size, and contents as another vector.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(V, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 4]; X = [2, 32, 4]; n = 3;

julia> GrB_Vector_build(V, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> B = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_dup(B, V)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_Vector_fprint(B, GxB_SHORT)

GraphBLAS vector: B
nrows: 5 ncols: 1 max # entries: 3
format: standard CSC vlen: 5 nvec_nonempty: 1 nvec: 1 plen: 1 vdim: 1
hyper_ratio 0.0625
GraphBLAS type:  int64_t size: 8
number of entries: 3
column: 0 : 3 entries [0:2]
    row 1: int64 2
    row 2: int64 32
    row 4: int64 4

```
"""
function GrB_Vector_dup(w::GrB_Vector{T}, u::GrB_Vector{T}) where T <: valid_types
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

"""
    GrB_Vector_clear(v)

Remove all the elements (tuples) from a vector.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(V, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 4]; X = [2, 32, 4]; n = 3;

julia> GrB_Vector_build(V, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractTuples(V)
([1, 2, 4], [2, 32, 4])

julia> GrB_Vector_clear(V)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractTuples(V)
(Int64[], Int64[])
```
"""
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

"""
    GrB_Vector_size(v)

Return the size of a vector if successful.
Else return value of type GrB Info.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(V, GrB_FP64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 2, 3]; X = [2.1, 3.2, 4.4]; n = 3;

julia> GrB_Vector_build(V, I, X, n, GrB_FIRST_FP64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_size(V)
4
```
"""
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

"""
    GrB_Vector_nvals(v)

Return the number of stored elements in a vector if successful.
Else return value of type GrB Info.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(V, GrB_FP64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 2, 3]; X = [2.1, 3.2, 4.4]; n = 3;

julia> GrB_Vector_build(V, I, X, n, GrB_FIRST_FP64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_nvals(V)
3
```
"""
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

"""
    GrB_Vector_build(w, I, X, nvals, dup)

Store elements from tuples into a vector.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(V, GrB_FP64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 2, 3]; X = [2.1, 3.2, 4.4]; n = 3;

julia> GrB_Vector_build(V, I, X, n, GrB_FIRST_FP64)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_Vector_fprint(V, GxB_SHORT)

GraphBLAS vector: V
nrows: 4 ncols: 1 max # entries: 3
format: standard CSC vlen: 4 nvec_nonempty: 1 nvec: 1 plen: 1 vdim: 1
hyper_ratio 0.0625
GraphBLAS type:  double size: 8
number of entries: 3
column: 0 : 3 entries [0:2]
    row 0: double 2.1
    row 2: double 3.2
    row 3: double 4.4

```
"""
function GrB_Vector_build(w::GrB_Vector{T}, I::Vector{U}, X::Vector{T}, nvals::U, dup::GrB_BinaryOp) where{U <: GrB_Index, T <: valid_types}
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

"""
    GrB_Vector_setElement(w, x, i)

Set one element of a vector to a given value, w[i] = x.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Int64}()
GrB_Vector{Int64}

julia> GrB_Vector_new(V, GrB_INT64, 5)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 4]; X = [2, 32, 4]; n = 3;

julia> GrB_Vector_build(V, I, X, n, GrB_FIRST_INT64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractElement(V, 2)
32

julia> GrB_Vector_setElement(V, 7, 2)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractElement(V, 2)
7
```
"""
function GrB_Vector_setElement(w::GrB_Vector{T}, x::T, i::U) where {U <: GrB_Index, T <: valid_int_types}
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

"""
    GrB_Vector_extractElement(v, i)

Return element of a vector at a given index (v[i]) if successful.
Else return value of type GrB Info.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(V, GrB_FP64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 2, 3]; X = [2.1, 3.2, 4.4]; n = 3;

julia> GrB_Vector_build(V, I, X, n, GrB_FIRST_FP64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractElement(V, 2)
3.2
```
"""
function GrB_Vector_extractElement(v::GrB_Vector{T}, i::U) where {T <: valid_types, U <: GrB_Index}
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

"""
    GrB_Vector_extractTuples(v)

Return tuples stored in a vector.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> V = GrB_Vector{Float64}()
GrB_Vector{Float64}

julia> GrB_Vector_new(V, GrB_FP64, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [0, 2, 3]; X = [2.1, 3.2, 4.4]; n = 3;

julia> GrB_Vector_build(V, I, X, n, GrB_FIRST_FP64)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Vector_extractTuples(V)
([0, 2, 3], [2.1, 3.2, 4.4])
```
"""
function GrB_Vector_extractTuples(v::GrB_Vector{T}) where T <: valid_types
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
