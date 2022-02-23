# Constructors:
###############
"""
    GBVector{T}(n = LibGraphBLAS.GxB_INDEX_MAX)
"""
function GBVector{T}(n = LibGraphBLAS.GxB_INDEX_MAX) where {T}
    m = Ref{GrB_Matrix}()
    @wraperror LibGraphBLAS.GrB_Matrix_new(m, toGBType(T),nrows, ncols)
    v = GBVector{T}(m[])
    gbset(v, FORMAT, BYCOL)
    return v
end

GBVector{T}(dims::Dims{1}) where {T} = GBVector{T}(dims...)
GBVector{T}(nrows::Base.OneTo) where {T} =
    GBVector{T}(nrows.stop)
GBVector{T}(nrows::Tuple{Base.OneTo,}) where {T} = GBVector{T}(first(nrows))

"""
    GBVector(I::AbstractVector, X::AbstractVector{T})

Create a GBVector from a vector of indices `I` and a vector of values `X`.
"""
function GBVector(I::AbstractVector{U}, X::AbstractVector{T}; dup = +, nrows = maximum(I)) where {U<:Integer, T}
    x = GBVector{T}(nrows)
    build(x, I, X, dup = dup)
    return x
end

#iso valued constructors.
"""
    GBVector(I, x; nrows = maximum(I))

Create an `n` length GBVector `v` such that `M[I[k]] = x`.
The resulting vector is "iso-valued" such that it only stores `x` once rather than once for
each index.
"""
function GBVector(I::AbstractVector{U}, x::T;
    nrows = maximum(I)) where {U<:Integer, T}
    A = GBVector{T}(nrows)
    build(A, I, x)
    return A
end

"""
    GBVector(n, x)

Create an `n` length dense GBVector `v` such that M[I[k]] = x.
The resulting vector is "iso-valued" such that it only stores `x` once rather than once for
each index.
"""
function GBVector(n::Integer, x::T) where {T}
    v = GBVector{T}(n)
    v[:] = x
    return v
end

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################
Base.unsafe_convert(::Type{LibGraphBLAS.GrB_Matrix}, v::GBVector) = v.p

function Base.copy(A::GBVector{T}) where {T}
    C = Ref{LibGraphBLAS.GrB_Matrix}()
    LibGraphBLAS.GrB_Matrix_dup(C, A)
    return GBVector{T}(C[])
end

function Base.size(v::GBVector)
    nrows = Ref{LibGraphBLAS.GrB_Index}()
    @wraperror LibGraphBLAS.GrB_Matrix_nrows(nrows, A)
    return (Int64(nrows[]),)
end

Base.eltype(::Type{GBVector{T}}) where{T} = T

function Base.similar(
    ::GBVector{T}, ::Type{TNew},
    dims::Dims{1}
) where {T, TNew}
    return GBVector{TNew}(dims...)
end

function Base.similar(
    ::GBVector{T}, ::Type{TNew},
    dims::Dims{2}
) where {T, TNew}
    return GBMatrix{TNew}(dims...)
end

function Base.deleteat!(v::GBVector, i)
    @wraperror LibGraphBLAS.GrB_Matrix_removeElement(v, decrement(i), 1)
    return v
end

function Base.resize!(v::GBVector, n)
    @wraperror LibGraphBLAS.GrB_Matrix_resize(v, n, 1)
    return v
end

function LinearAlgebra.diag(A::GBMatOrTranspose{T}, k::Integer = 0; desc = nothing) where {T}
    m, n = size(A)
    if !(k in -m:n)
        s = 0
    elseif k >= 0
        s = min(m, n - k)
    else
        s = min(m + k, n)
    end
    v = GBVector{T}(s)
    desc = _handledescriptor(desc; in1=A)
    if A isa Transpose
        k = -k
    end
    @wraperror LibGraphBLAS.GxB_Vector_diag(LibGraphBLAS.GrB_Vector(v.p), parent(A), k, desc)
    return v
end

#We need these until I can get a SparseArrays.nonzeros implementation
function Base.show(io::IO, ::MIME"text/plain", v::GBVector)
    gxbprint(io, v)
end

function Base.show(io::IO, v::GBVector)
    gxbprint(io, v)
end

function Base.show(io::IOContext, v::GBVector)
    gxbprint(io, v)
end

# Type dependent functions build, setindex, getindex, and findnz:
for T ∈ valid_vec
    if T ∈ gxb_vec
        prefix = :GxB
    else
        prefix = :GrB
    end

    # Build functions
    func = Symbol(prefix, :_Matrix_build_, suffix(T))
    @eval begin
        function build(v::GBVector{$T}, I::Vector, X::Vector{$T}; dup = +)
            nnz(v) == 0 || throw(OutputNotEmptyError("Cannot build vector with existing elements"))
            length(X) == length(I) || DimensionMismatch("I and X must have the same length")
            dup = BinaryOp(dup)($T)
            decrement!(I)
            @wraperror LibGraphBLAS.$func(
                Ptr{LibGraphBLAS.GrB_Vector}(v.p), 
                Vector{LibGraphBLAS.GrB_Index}(I), 
                zeros(LibGraphBLAS.GrB_Index, length(I)), 
                X, 
                length(X), 
                dup
            )
            increment!(I)
        end
    end
    # Setindex functions
    func = Symbol(prefix, :_Matrix_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(v::GBVector{$T}, x, i::Integer)
            x = convert($T, x)
            return LibGraphBLAS.$func(v, x, LibGraphBLAS.GrB_Index(decrement(i)), 0)
        end
    end
    # Getindex functions
    func = Symbol(prefix, :_Matrix_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(v::GBVector{$T}, i::Integer)
            x = Ref{$T}()
            result = LibGraphBLAS.$func(x, v, LibGraphBLAS.GrB_Index(decrement(i)), 0)
            if result == LibGraphBLAS.GrB_SUCCESS
                return x[]
            elseif result == LibGraphBLAS.GrB_NO_VALUE
                return nothing
            else
                @wraperror result
            end
        end
    end
    # findnz functions
    func = Symbol(prefix, :_Matrix_extractTuples_, suffix(T))
    @eval begin
        function SparseArrays.findnz(v::GBVector{$T})
            nvals = Ref{LibGraphBLAS.GrB_Index}(nnz(v))
            I = Vector{LibGraphBLAS.GrB_Index}(undef, nvals[])
            X = Vector{$T}(undef, nvals[])
            @wraperror LibGraphBLAS.$func(I, C_NULL, X, nvals, v)
            nvals[] == length(I) == length(X) || throw(DimensionMismatch("length(I) != length(X)"))
            return increment!(I), X
        end
        function SparseArrays.nonzeros(v::GBVector{$T})
            nvals = Ref{LibGraphBLAS.GrB_Index}(nnz(v))
            X = Vector{$T}(undef, nvals[])
            @wraperror LibGraphBLAS.$func(C_NULL, C_NULL, X, nvals, v)
            nvals[] == length(X) || throw(DimensionMismatch(""))
            return X
        end
        function SparseArrays.nonzeroinds(v::GBVector{$T})
            nvals = Ref{LibGraphBLAS.GrB_Index}(nnz(v))
            I = Vector{LibGraphBLAS.GrB_Index}(undef, nvals[])
            wait(v)
            @wraperror LibGraphBLAS.$func(I, C_NULL, C_NULL, nvals, v)
            nvals[] == length(I) || throw(DimensionMismatch(""))
            return increment!(I)
        end
    end
end

function build(v::GBVector{T}, I::Vector, x::T) where {T}
    nnz(v) == 0 || throw(OutputNotEmptyError("Cannot build vector with existing elements"))
    x = GBScalar(x)
    decrement!(I)
    @wraperror LibGraphBLAS.GxB_Matrix_build_Scalar(
            v,
            Vector{LibGraphBLAS.GrB_Index}(I),
            zeros(LibGraphBLAS.GrB_Index, length(I)),
            x,
            length(I)
        )
    increment!(I)
    return v
end

# Indexing functions:
#####################

function Base.getindex(
    u::GBVector, I;
    mask = nothing, accum = nothing, desc = nothing
)
    return extract(u, I; mask, accum, desc)
end

function Base.getindex(u::GBVector, ::Colon; mask = nothing, accum = nothing, desc = nothing)
    return extract(u, :)
end

function Base.getindex(
    u::GBVector, i::Union{Vector, UnitRange, StepRange};
    mask = nothing, accum = nothing, desc = nothing
)
    return extract(u, i; mask, accum, desc)
end

"""
    subassign(w::GBVector, u::GBVector, I; kwargs...)::GBVector

Assign a subvector of `w` to `u`. Return `u`. Equivalent to the matrix definition.
"""
function subassign!(w::GBVector{T}, u, I; mask = nothing, accum = nothing, desc = nothing) where {T}
    return subassign!(GBMatrix{T}(w), u, I, UInt64[1]; mask, accum, desc)
end

"""
    assign(w::GBVector, u::GBVector, I; kwargs...)::GBVector

Assign a subvector of `w` to `u`. Return `u`. Equivalent to the matrix definition.
"""
function assign!(w::GBVector{T}, u, I; mask = nothing, accum = nothing, desc = nothing) where {T}
    return assign!(GBMatrix{T}(w), u, I, UInt64[1]; mask, accum, desc)
end

function Base.setindex!(
    u::GBVector, x, ::Colon;
    mask = nothing, accum = nothing, desc = nothing
)
    subassign!(u, x, ALL; mask, accum, desc)
    return nothing
end
# silly overload to help a bit with broadcasting.
function Base.setindex!(
    u::GBVector, x, I::Union{Vector, UnitRange, StepRange, Colon}, ::Colon;
    mask = nothing, accum = nothing, desc = nothing
)
    Base.setindex!(u, x, I; mask, accum, desc)
end
function Base.setindex!(
    u::GBVector, x, I::Union{Vector, UnitRange, StepRange};
    mask = nothing, accum = nothing, desc = nothing
)
    subassign!(u, x, I; mask, accum, desc)
    return nothing
end
