"""
    GrB_Matrix_new(A, type, nrows, ncols)

Create a new matrix with specified domain and dimensions.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0
```
"""
function GrB_Matrix_new(A::GrB_Matrix{T}, type::GrB_Type{T}, nrows::U, ncols::U) where {U <: GrB_Index, T <: valid_types}
    A_ptr = pointer_from_objref(A)
    
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_new"),
                Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Cuintmax_t),
                A_ptr, type.p, nrows, ncols
            )
        )
end

"""
    GrB_Matrix_build(C, I, J, X, nvals, dup)

Store elements from tuples into a matrix.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 2, 2, 3]; J = [1, 2, 1, 3, 3]; X = Int8[2, 3, 4, 5, 6]; n = 5;

julia> GrB_Matrix_build(MAT, I, J, X, n, GrB_FIRST_INT8)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_Matrix_fprint(MAT, GxB_COMPLETE)

GraphBLAS matrix: MAT
nrows: 4 ncols: 4 max # entries: 5
format: standard CSR vlen: 4 nvec_nonempty: 3 nvec: 4 plen: 4 vdim: 4
hyper_ratio 0.0625
GraphBLAS type:  int8_t size: 1
number of entries: 5
row: 1 : 1 entries [0:0]
    column 1: int8 2
row: 2 : 3 entries [1:3]
    column 1: int8 4
    column 2: int8 3
    column 3: int8 5
row: 3 : 1 entries [4:4]
    column 3: int8 6


```
"""
function GrB_Matrix_build(C::GrB_Matrix{T}, I::Vector{U}, J::Vector{U}, X::Vector{T}, nvals::U, dup::GrB_BinaryOp) where{U <: GrB_Index, T <: valid_types}
    I_ptr = pointer(I)
    J_ptr = pointer(J)
    X_ptr = pointer(X)
    fn_name = "GrB_Matrix_build_" * suffix(T)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Ptr{U}, Ptr{U}, Ptr{T}, Cuintmax_t, Ptr{Cvoid}),
                C.p, I_ptr, J_ptr, X_ptr, nvals, dup.p
            )
        )
end

"""
    GrB_Matrix_nrows(A)

Return the number of rows in a matrix if successful.
Else return value of type GrB Info.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_nrows(MAT)
4
```
"""
function GrB_Matrix_nrows(A::GrB_Matrix)
    nrows = Ref(UInt64(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_nrows"),
                        Cint,
                        (Ptr{UInt64}, Ptr{Cvoid}),
                        nrows, A.p
                    )
                )
    result != GrB_SUCCESS && return result
    return _GrB_Index(nrows[])
end

"""
    GrB_Matrix_ncols(A)

Return the number of columns in a matrix if successful.
Else return value of type GrB Info.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_ncols(MAT)
4
```
"""
function GrB_Matrix_ncols(A::GrB_Matrix)
    ncols = Ref(UInt64(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_ncols"),
                        Cint,
                        (Ptr{UInt64}, Ptr{Cvoid}),
                        ncols, A.p
                    )
                )
    result != GrB_SUCCESS && return result
    return _GrB_Index(ncols[])
end

"""
    GrB_Matrix_nvals(A)

Return the number of stored elements in a matrix if successful.
Else return value of type GrB Info.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 2, 2, 3]; J = [1, 2, 1, 3, 3]; X = Int8[2, 3, 4, 5, 6]; n = 5;

julia> GrB_Matrix_build(MAT, I, J, X, n, GrB_FIRST_INT8)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_nvals(MAT)
5
```
"""
function GrB_Matrix_nvals(A::GrB_Matrix)
    nvals = Ref(UInt64(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, "GrB_Matrix_nvals"),
                        Cint,
                        (Ptr{UInt64}, Ptr{Cvoid}),
                        nvals, A.p
                    )
                )
    result != GrB_SUCCESS && return result
    return _GrB_Index(nvals[])
end

"""
    GrB_Matrix_dup(C, A)

Create a new matrix with the same domain, dimensions, and contents as another matrix.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 2, 2, 3]; J = [1, 2, 1, 3, 3]; X = Int8[2, 3, 4, 5, 6]; n = 5;

julia> GrB_Matrix_build(MAT, I, J, X, n, GrB_FIRST_INT8)
GrB_SUCCESS::GrB_Info = 0

julia> B = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_dup(B, MAT)
GrB_SUCCESS::GrB_Info = 0

julia> @GxB_Matrix_fprint(B, GxB_SHORT)

GraphBLAS matrix: B
nrows: 4 ncols: 4 max # entries: 5
format: standard CSR vlen: 4 nvec_nonempty: 3 nvec: 4 plen: 4 vdim: 4
hyper_ratio 0.0625
GraphBLAS type:  int8_t size: 1
number of entries: 5
row: 1 : 1 entries [0:0]
    column 1: int8 2
row: 2 : 3 entries [1:3]
    column 1: int8 4
    column 2: int8 3
    column 3: int8 5
row: 3 : 1 entries [4:4]
    column 3: int8 6

```
"""
function GrB_Matrix_dup(C::GrB_Matrix{T}, A::GrB_Matrix{T}) where T <: valid_types
    C_ptr = pointer_from_objref(C)

    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_dup"),
                Cint,
                (Ptr{Cvoid}, Ptr{Cvoid}),
                C_ptr, A.p
            )
        )
end

"""
    GrB_Matrix_clear(A)

Remove all elements from a matrix.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 2, 2, 3]; J = [1, 2, 1, 3, 3]; X = Int8[2, 3, 4, 5, 6]; n = 5;

julia> GrB_Matrix_build(MAT, I, J, X, n, GrB_FIRST_INT8)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_nvals(MAT)
5

julia> GrB_Matrix_clear(MAT)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_nvals(MAT)
0
```
"""
function GrB_Matrix_clear(A::GrB_Matrix)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, "GrB_Matrix_clear"),
                Cint,
                (Ptr{Cvoid}, ),
                A.p
            )
        )
end

"""
    GrB_Matrix_setElement(C, X, I, J)

Set one element of a matrix to a given value, C[I][J] = X.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 2, 2, 3]; J = [1, 2, 1, 3, 3]; X = Int8[2, 3, 4, 5, 6]; n = 5;


julia> GrB_Matrix_build(MAT, I, J, X, n, GrB_FIRST_INT8)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractElement(MAT, 1, 1)
2

julia> GrB_Matrix_setElement(MAT, Int8(7), 1, 1)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractElement(MAT, 1, 1)
7
```
"""
function GrB_Matrix_setElement(C::GrB_Matrix{T}, X::T, I::U, J::U) where {U <: GrB_Index, T <: valid_int_types}
    fn_name = "GrB_Matrix_setElement_" * suffix(T)
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cintmax_t, Cuintmax_t, Cuintmax_t),
                C.p, X, I, J
            )
        )
end

function GrB_Matrix_setElement(C::GrB_Matrix{UInt64}, X::UInt64, I::U, J::U) where U <: GrB_Index
    fn_name = "GrB_Matrix_setElement_UINT64"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cuintmax_t, Cuintmax_t, Cuintmax_t),
                C.p, X, I, J
            )
        )
end

function GrB_Matrix_setElement(C::GrB_Matrix{Float32}, X::Float32, I::U, J::U) where U <: GrB_Index
    fn_name = "GrB_Matrix_setElement_FP32"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cfloat, Cuintmax_t, Cuintmax_t),
                C.p, X, I, J
            )
        )
end

function GrB_Matrix_setElement(C::GrB_Matrix{Float64}, X::Float64, I::U, J::U) where U <: GrB_Index
    fn_name = "GrB_Matrix_setElement_FP64"
    return GrB_Info(
        ccall(
                dlsym(graphblas_lib, fn_name),
                Cint,
                (Ptr{Cvoid}, Cdouble, Cuintmax_t, Cuintmax_t),
                C.p, X, I, J
            )
        )
end

"""
    GrB_Matrix_extractElement(A, row_index, col_index)

Return element of a matrix at a given index (A[row_index][col_index]) if successful.
Else return value of type GrB Info.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 2, 2, 3]; J = [1, 2, 1, 3, 3]; X = Int8[2, 3, 4, 5, 6]; n = 5;

julia> GrB_Matrix_build(MAT, I, J, X, n, GrB_FIRST_INT8)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractElement(MAT, 1, 1)
2
```
"""
function GrB_Matrix_extractElement(A::GrB_Matrix{T}, row_index::U, col_index::U) where {U <: GrB_Index, T <: valid_types}
    fn_name = "GrB_Matrix_extractElement_" * suffix(T)

    element = Ref(T(0))
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Cuintmax_t, Cuintmax_t),
                        element, A.p, row_index, col_index
                    )
                )
    result != GrB_SUCCESS && return result
    return element[]
end

"""
    GrB_Matrix_extractTuples(A)

Return tuples stored in a matrix.

# Examples
```jldoctest
julia> using SuiteSparseGraphBLAS

julia> GrB_init(GrB_NONBLOCKING)
GrB_SUCCESS::GrB_Info = 0

julia> MAT = GrB_Matrix{Int8}()
GrB_Matrix{Int8}

julia> GrB_Matrix_new(MAT, GrB_INT8, 4, 4)
GrB_SUCCESS::GrB_Info = 0

julia> I = [1, 2, 2, 2, 3]; J = [1, 2, 1, 3, 3]; X = Int8[2, 3, 4, 5, 6]; n = 5;

julia> GrB_Matrix_build(MAT, I, J, X, n, GrB_FIRST_INT8)
GrB_SUCCESS::GrB_Info = 0

julia> GrB_Matrix_extractTuples(MAT)
([1, 2, 2, 2, 3], [1, 1, 2, 3, 3], Int8[2, 4, 3, 5, 6])
```
"""
function GrB_Matrix_extractTuples(A::GrB_Matrix{T}) where T <: valid_types
    nvals = GrB_Matrix_nvals(A)
    if typeof(nvals) == GrB_Info
        return nvals
    end
    U = typeof(nvals)
    row_indices = Vector{U}(undef, nvals)
    col_indices = Vector{U}(undef, nvals)
    vals = Vector{T}(undef, nvals)
    n = Ref(UInt64(nvals))

    fn_name = "GrB_Matrix_extractTuples_" * suffix(T)
    result = GrB_Info(
                ccall(
                        dlsym(graphblas_lib, fn_name),
                        Cint,
                        (Ptr{Cvoid}, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{UInt64}, Ptr{Cvoid}),
                        pointer(row_indices), pointer(col_indices), pointer(vals), n, A.p
                    )
                )
    result != GrB_SUCCESS && return result
    return row_indices, col_indices, vals
end
