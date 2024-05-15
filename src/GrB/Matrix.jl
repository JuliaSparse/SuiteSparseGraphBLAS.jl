Base.unsafe_convert(::Core.Type{LibGraphBLAS.GrB_Matrix}, A::Matrix) = A.p

function Matrix{T}(
    dims::Dims{2};
    shallow = false,
    storageorders = (RowMajor(), ColMajor())
) where {T}
    r = Ref{LibGraphBLAS.GrB_Matrix}()
    t = Type(T)
    info = LibGraphBLAS.GrB_Matrix_new(r, t, dims[1], dims[2])
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info t
        GrB.@invalidvalue info "$nrows or $ncols is outside the range of GrB_Index (likely too large)"
        GrB.@fallbackerror info
    end
    storageorders = storageorders == SparseBase.RuntimeOrder() ? (RowMajor(), ColMajor()) : storageorders
    return finalizer(Matrix{T}(r[], Set(storageorders), shallow, [])) do A
        @checkfree LibGraphBLAS.GrB_Matrix_free(Ref(A.p))
    end
end
Matrix{T}(
    nrows, ncols;
    shallow = false,
    storageorders = (RowMajor(), ColMajor())
) where T = Matrix{T}((nrows, ncols); shallow, storageorders)

function _dup(A::Matrix)
    r = Ref{LibGraphBLAS.GrB_Matrix}()
    info = LibGraphBLAS.GrB_Matrix_dup(r, A)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return r[]
end

function _deshallow!(A::Matrix)
    !(A.shallow) && (return A)
    r = _dup(A)
    @checkfree LibGraphBLAS.GrB_Matrix_free(Ref(A.p))
    A.p = r
    A.shallow = false; empty!(A.keepalives)
    return A
end

"""
    dup(A::GrB.Matrix{T}; storageorders = A.storageorders) -> GrB.Matrix{T}

Duplicate matrix `A``, with the same type and values.

If `storageorders`` is not specified it defaults to the storageorders of `A`.
"""
function dup(A::Matrix{T}; storageorders = (RowMajor(), ColMajor())) where T
    r = _dup(A)
    return finalizer(Matrix{T}(r[], Set(storageorders)), false, []) do A
        @checkfree LibGraphBLAS.GrB_Matrix_free(Ref(A.p))
    end
end

nothrow_wait!(A::Matrix, mode) = LibGraphBLAS.GrB_Matrix_wait(A.p, mode)

SparseBase.storedeltype(::Core.Type{Matrix{T}}) where T = T

function clear!(A::Matrix)
    _deshallow!(A)
    info = LibGraphBLAS.GrB_Matrix_clear(A)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return A
end

function nrows(A::Matrix)
    r = Ref{LibGraphBLAS.GrB_Index}()
    info = LibGraphBLAS.GrB_Matrix_nrows(r, A)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return Int64(r[])
end
function ncols(A::Matrix)
    r = Ref{LibGraphBLAS.GrB_Index}()
    info = LibGraphBLAS.GrB_Matrix_ncols(r, A)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return Int64(r[])
end
Base.size(A::Matrix) = (nrows(A), ncols(A))
Base.size(A::Matrix, i::Integer) = i == 1 ? nrows(A) : (i == 2 ? ncols(A) : 1)

function nvals(A::Matrix)
    r = Ref{LibGraphBLAS.GrB_Index}()
    info = LibGraphBLAS.GrB_Matrix_nvals(r, A)
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
    # Build functions
    func = Symbol(prefix, :_Matrix_build_, suffix(T))
    @eval begin
        function nothrow_build!(
            A::Matrix{$T}, 
            I, J, X::Vector{$T}, combine
        )
            return LibGraphBLAS.$func(
                A, I, J, X, length(X), combine
            )
        end
    end
    # Setindex functions
    func = Symbol(prefix, :_Matrix_setElement_, suffix(T))
    @eval begin
        function nothrow_setElement!(A::Matrix{$T}, x::$T, i, j)
            LibGraphBLAS.$func(A, x, decrement!(i), decrement!(j))
        end
    end
    # Getindex functions
    func = Symbol(prefix, :_Matrix_extractElement_, suffix(T))
    @eval begin
        function nothrow_getElement!(x::Ref{$T}, A::Matrix{$T}, i, j)
            return LibGraphBLAS.$func(x, A, decrement!(i), decrement!(j))
        end
    end
    # findnz functions
    func = Symbol(prefix, :_Matrix_extractTuples_, suffix(T))
    @eval begin
        function nothrow_extractTuples!(
            I::Union{Ptr{Cvoid}, Vector{<:Union{Int64, UInt64, CIndex{<:Union{Int64, UInt64}}}}}, 
            J::Union{Ptr{Cvoid}, Vector{<:Union{Int64, UInt64, CIndex{<:Union{Int64, UInt64}}}}}, 
            X::Union{Ptr{Cvoid}, Vector{$T}}, 
            A::Matrix{$T}, nstored::Integer
        )
            return LibGraphBLAS.$func(I, J, X, Ref(nstored), A)
        end
    end
end

function nothrow_build!(
    A::Matrix{T}, I, J, X::Vector{T}, combine = C_NULL
) where T
    LibGraphBLAS.GrB_Matrix_build_UDT(
        A, I, J, X, length(X), combine
    )
end
function nothrow_build!(
    A::Matrix{T}, I, J, X::Scalar{T}, combine = C_NULL
) where T
    LibGraphBLAS.GrB_Matrix_build_Scalar(
        A, I, J, X, length(I), combine
    )
end
function build!(A::Matrix{T}, I, J, X, combine = C_NULL) where T
    length(I) == length(J) ||
        DimensionMismatch("I, and J must have the same length")
    if !(X isa Scalar)
        length(I) == length(X) ||
            DimensionMismatch("I, J and X must have the same length")
    end
    I, J, _, _ = fix_indexlist!(I, J)
    info = nothrow_build!(A, I, J, X, combine)
    unfix_indexlist!(I, J)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@invalidindex info A I J
        GrB.@domainmismatch info A X combine
        GrB.@outputnotempty info A
        GrB.@uninitializedobject info A
        GrB.@invalidvalue info "I or J have duplicate indices and combine = $combine. Must pass a valid combine function."
        GrB.@fallbackerror info
    end
    return A
end


function nothrow_setElement!(A::Matrix{T}, x::T, i, j) where T
    LibGraphBLAS.GrB_Matrix_setElement_UDT(A, Ref(x), decrement!(i), decrement!(j))
end
function nothrow_setElement!(A::Matrix{T}, x::Scalar{T}, i, j) where T
    LibGraphBLAS.GrB_Matrix_setElement_Scalar(A, x, decrement!(i), decrement!(j))
end

function unsafe_setElement!(A::Matrix{T}, x, i, j) where T
    x = x isa Scalar ? x : convert(T, x)
    info = nothrow_setElement!(A, x, i, j)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@invalidindex info A i j
        GrB.@domainmismatch info A x
        GrB.@fallbackerror info
    end
    return x
end

function setElement!(A::Matrix{T}, x, i, j) where T
    _deshallow!(A)
    return unsafe_setElement!(A, x, i, j)
end
function Base.setindex!(A::Matrix{T}, x, i, j) where T
    return setElement!(A, x, i, j)
end

function nothrow_getElement!(x::Ref{T}, A::Matrix{T}, i, j) where T
    return LibGraphBLAS.GrB_Matrix_extractElement_UDT(x, A, decrement!(i), decrement!(j))
end
function nothrow_getElement!(x::Scalar{T}, A::Matrix{T}, i, j) where T
    return LibGraphBLAS.GrB_Matrix_extractElement_Scalar(x, A, decrement!(i), decrement!(j))
end

function getElement!(x::Union{Ref{T}, Scalar{T}}, A::Matrix{T}, i, j) where T
    info = nothrow_getElement!(x, A, i, j)
    if info == LibGraphBLAS.GrB_SUCCESS info == LibGraphBLAS.GrB_NO_VALUE
        return true
    elseif info == LibGraphBLAS.GrB_NO_VALUE
        return false
    else
        GrB.@uninitializedobject info A x
        GrB.@invalidindex info A i j
        # GrB.@domainmismatch info A x
        GrB.@fallbackerror info
    end
end

function Base.getindex(A::Matrix{T}, i, j; default = SparseBase.novalue) where T
    x = Ref{T}() # this could also be a Scalar.
    info = nothrow_getElement!(x, A, i, j)
    if info == LibGraphBLAS.GrB_SUCCESS
        return x[]
    elseif info == LibGraphBLAS.GrB_NO_VALUE
        return default
    else
        GrB.@uninitializedobject info A
        GrB.@invalidindex info A i j
        # GrB.@domainmismatch info A x
        GrB.@fallbackerror info
    end
end

function nothrow_isStoredElement(A::Matrix, i, j)
    return LibGraphBLAS.GxB_Matrix_isStoredElement(A, decrement!(i), decrement!(j))
end

function isStoredElement(A::Matrix, i, j)
    result = nothrow_isStoredElement(A, i, j)
    if result == LibGraphBLAS.GrB_SUCCESS
        true
    elseif result == LibGraphBLAS.GrB_NO_VALUE
        false
    else
        @invalidindex result A i j
        @uninitializedobject result A
    end
end

Base.isstored(A::Matrix, i, j) =
    isStoredElement(A, i, j)

function nothrow_removeElement!(A::Matrix, i, j)
    LibGraphBLAS.GrB_Matrix_removeElement(A, decrement!(i), decrement!(j))
end
function unsafe_removeElement!(A::Matrix, i, j)
    info = nothrow_removeElement!(A, i, j)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@invalidindex info A i j
        GrB.@fallbackerror info
    end
    return A
end
function removeElement!(A::Matrix, i, j)
    _deshallow!(A)
    return unsafe_removeElement!(A, i, j)
end
Base.deleteat!(A::Matrix, i, j) = removeElement!(A, i, j)

function nothrow_extractTuples!(
    I::Union{Ptr{Cvoid}, Vector{<:IType}}, 
    J::Union{Ptr{Cvoid}, Vector{<:IType}}, 
    X::Union{Ptr{Cvoid}, Vector{T}}, 
    A::Matrix{T}, nstored::Integer
) where T
    LibGraphBLAS.GrB_Matrix_extractTuples_UDT(I, J, X, Ref(nstored), A)
end

function extractTuples!(I::Union{Vector, Nothing}, J::Union{Vector, Nothing}, X::Union{Vector, Nothing}, A::Matrix)
    wait(A)
    nvals = nstored(A)
    if isnothing(I)
        I2 = C_NULL
    elseif length(I) != nvals 
        throw(DimensionMismatch("length(I) != nstored(A)"))
    else
        I2 = I
    end
    if isnothing(J)
        J2 = C_NULL
    elseif length(J) != nvals 
        throw(DimensionMismatch("length(J) != nstored(A)"))
    else
        J2 = J
    end
    if isnothing(X)
        X2 = C_NULL
    elseif length(X) != nvals 
        throw(DimensionMismatch("length(X) != nstored(A)"))
    else
        X2 = X
    end
    info = nothrow_extractTuples!(I2, J2, X2, A, nvals)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@insufficientspace info
        GrB.@uninitializedobject info A
        GrB.@domainmismatch info A X
        GrB.@fallbackerror info
    end
    unfix_indexlist!(I2, J2)
    return I, J, X
end
function extractTuples(A::Matrix)
    wait!(A)
    nvals = nstored(A)
    I = Vector{CIndex{Int64}}(undef, nvals)
    J = Vector{CIndex{Int64}}(undef, nvals)
    X = Vector{eltype(A)}(undef, nvals)
    extractTuples!(I, J, X, A, nvals)
    return I, J, X
end

function nothrow_concat!(C::Matrix, tiles::AbstractArray{<:Matrix}; desc = C_NULL)
    LibGraphBLAS.GxB_Matrix_concat(C, permutedims(tiles), size(tiles,2), size(tiles,1), desc)
end
function concat!(C::Matrix, tiles::AbstractArray{<:Matrix}; desc = C_NULL)
    _deshallow!(C)
    info = nothrow_concat!(C, tiles; desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info C tiles...
        GrB.@dimensionmismatch info "$(size(C)) does not match the sum of the sizes of the tiles"
        GrB.@domainmismatch info C tiles[1]
        GrB.@fallbackerror info
    end
    return C
end

#TODO: does this need permutedims?
#TODO: reenable after fixing the Tile_nrows stuff.
# function nothrow_split!(tiles::AbstractArray{<:Matrix}, A::Matrix; desc = C_NULL)
#     LibGraphBLAS.GxB_Matrix_split(
#         tiles, length(tiles), length(tiles[1]), 
#         Tile_nrows, Tile_ncols, A, desc
#     )
# end
# function unsafe_split!(tiles::AbstractArray{<:Matrix}, A::Matrix; desc = C_NULL)
#     info = nothrow_split!(tiles, A; desc)
#     if info != LibGraphBLAS.GrB_SUCCESS
#         GrB.@uninitializedobject info A tiles...
#         GrB.@dimensionmismatch info "$(size(A)) does not match the sum of the sizes of the tiles"
#         GrB.@domainmismatch info A tiles[1]
#         GrB.@fallbackerror info
#     end
#     return tiles
# end
# function split!(tiles::AbstractArray{<:Matrix}, A::Matrix; desc = C_NULL)
#     _deshallow!.(tiles)
#     return unsafe_split!(tiles, A; desc)
# end

function nothrow_diag!(C::Matrix, v::Matrix, k::Integer=0; desc = C_NULL)
    LibGraphBLAS.GxB_Matrix_diag(C, v, k, desc)
end
function diag!(C::Matrix, v::Matrix, k::Integer=0; desc = C_NULL)
    _deshallow!(C)
    info = nothrow_diag!(C, v, k; desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info C v
        GrB.@dimensionmismatch info "$(size(C)) does not match the size of v at diagonal $k"
        GrB.@domainmismatch info C v
        GrB.@fallbackerror info
    end
    return C
end
function diag(v::Matrix{T}, k::Integer = 0; desc = C_NULL) where T
    C = Matrix{T}(length(v), length(v))
    return diag!(C, v, k; desc)
end

function iso(A::Matrix)
    isiso = Ref{Bool}()
    info = LibGraphBLAS.GxB_Matrix_iso(isiso, A)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return isiso[]
end

function memoryUsage(A::Matrix)
    memory = Ref{Csize_t}()
    info = LibGraphBLAS.GxB_Matrix_memoryUsage(memory, A)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@fallbackerror info
    end
    return Int(memory[])
end

function nothrow_resize!(A::Matrix, nrows_new, ncols_new)
    LibGraphBLAS.GrB_Matrix_resize(A, nrows_new, ncols_new)
end
function resize!(A::Matrix, nrows_new, ncols_new)
    _deshallow!(A)
    info = nothrow_resize!(A, nrows_new, ncols_new)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@invalidvalue info "nrows_new ($nrows_new) or ncols_new ($ncols_new) is outside the range of GrB_Index (likely too large or 0)"
        GrB.@fallbackerror info
    end
    return A
end

function nothrow_reshape!(A::Matrix, nrows_new, ncols_new, bycol; desc = C_NULL)
    LibGraphBLAS.GxB_Matrix_reshape(A, bycol, nrows_new, ncols_new, desc)
end
function reshape!(A::Matrix, nrows_new, ncols_new, bycol; desc = C_NULL)
    _deshallow!(A)
    info = nothrow_reshape!(A, nrows_new, ncols_new, bycol; desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@invalidvalue info "nrows_new ($nrows_new) or ncols_new ($ncols_new) is outside the range of GrB_Index (likely too large or 0)"
        GrB.@fallbackerror info
    end
    return A
end

function reshapeDup(A::Matrix{T}, nrows_new, ncols_new, bycol, desc = C_NULL) where T
    r = Ref{LibGraphBLAS.GrB_Matrix}()
    info = LibGraphBLAS.GxB_Matrix_reshapeDup(r, A, bycol, nrows_new, ncols_new, desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info A
        GrB.@invalidvalue info "nrows_new ($nrows_new) or ncols_new ($ncols_new) is outside the range of GrB_Index (likely too large or 0)"
        GrB.@fallbackerror info
    end
    return finalizer(Matrix{T}(r[])) do C
        @checkfree LibGraphBLAS.GrB_Matrix_free(Ref(C.p))
    end
end

function nothrow_sort!(C, P, A, op; desc = C_NULL)
    return LibGraphBLAS.GxB_Matrix_sort(C, P, op, A, desc)
end
function sort!(
    C::Union{Matrix, Nothing}, 
    P::Union{Matrix, Nothing},
    A::Matrix,
    op;
    desc = C_NULL
)
    _deshallow!(C)
    info = nothrow_sort!(C, P, A, op; desc)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info C P A op
        GrB.@fallbackerror info
    end
    return isnothing(C) ? P : (isnothing(P) ? C : (C, P))
end

function GrB.GxB_fprint(x::Matrix, name, level, file)
    info = LibGraphBLAS.GxB_Matrix_fprint(x, name, level, file)
    if info != LibGraphBLAS.GrB_SUCCESS
        GrB.@uninitializedobject info x
        GrB.@fallbackerror info
    end
end
function Base.show(io::IO, ::MIME"text/plain", t::Matrix{T}) where T
    print(io, "GrB_Matrix{" * string(T) * "}: ")
    gxbprint(io, t)
end

Base.similar(a::Matrix{T}) where {T}                             = Base.similar(a, T)
Base.similar(a::Matrix, ::Core.Type{T}) where {T}                     = Base.similar(a, T, Base.to_shape(axes(a)))
Base.similar(a::Matrix{T}, dims::Tuple) where {T}                = Base.similar(a, T, Base.to_shape(dims))
Base.similar(a::Matrix{T}, dims::Base.DimOrInd...) where {T}          = Base.similar(a, T, Base.to_shape(dims))
Base.similar(a::Matrix, ::Core.Type{T}, dims::Base.DimOrInd...) where {T}  = Base.similar(a, T, Base.to_shape(dims))
Base.similar(a::Matrix, ::Core.Type{T}, dims::Tuple{Union{Integer, Base.OneTo}, Vararg{Union{Integer, Base.OneTo}}}) where {T} = 
    Base.similar(a, T, Base.to_shape(dims))
Base.similar(a::Matrix, ::Core.Type{T}, dims::Tuple{Integer, Vararg{Integer}}) where {T} = 
    Base.similar(a, T, Base.to_shape(dims))
Base.similar(::Matrix, ::Core.Type{T}, dims::Dims{2}) where T = Matrix{T}(dims)
