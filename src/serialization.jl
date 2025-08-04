function Serialization.serialize(s::AbstractSerializer, A::GBVecOrMat)
    Serialization.writetag(s.io, Serialization.OBJECT_TAG)
    Serialization.serialize(s, typeof(A))
    Serialization.serialize(s, A.fill)
    hint = serialize_sizehint(A)
    v = Vector{UInt8}(undef, hint)
    sz = Ref{LibGraphBLAS.GrB_Index}(hint)
    @wraperror LibGraphBLAS.GrB_Matrix_serialize(v, sz, A)
    resize!(v, sz[])
    serialize(s, v)
    return nothing
end

function _gbdeserialize_matrix(v, ::Type{T}) where {T} # Only for internal use, we assume we've already got a GB<Something> here.
    refA = Ref{LibGraphBLAS.GrB_Matrix}() # Everything is a GrB_Matrix in the end.
    @wraperror LibGraphBLAS.GrB_Matrix_deserialize(refA, T === Nothing ? C_NULL : gbtype(T), v, LibGraphBLAS.GrB_Index(length(v)))
    return refA
end

function _gbdeserialize_fill(s::AbstractSerializer) # Only for internal use, we assume we've already got a GB<Something> here.
    return deserialize(s)
end

function Serialization.deserialize(s::AbstractSerializer, ::Type{GBMatrix{T, Tf}}) where {T, Tf}
    fill = _gbdeserialize_fill(s)
    v = deserialize(s)
    return GBMatrix{T, Tf}(_gbdeserialize_matrix(v, T), fill)
end
function Serialization.deserialize(s::AbstractSerializer, ::Type{GBVector{T, Tf}}) where {T, Tf}
    fill = _gbdeserialize_fill(s)
    v = deserialize(s)
    return GBVector{T, Tf}(_gbdeserialize_matrix(v, T), fill)
end

function serialize_sizehint(A::GBVecOrMat)
    sz = Ref{LibGraphBLAS.GrB_Index}()
    @wraperror LibGraphBLAS.GrB_Matrix_serializeSize(sz, A)
    return sz[]
end

"""
    gbwrite(filename::AbstractString, A::GBVecOrMat)
    gbwrite(io::IO, A::GBVecOrMat)

Write `A` as a `GrB_Matrix` to a file or IO object. This function uses the
`GrB_Matrix_serialize` routine from the C GraphBLAS library, and *does not* serialize
the full Julia object. To read this serialized matrix you must use [`gbread`](@ref) with
a type or [`gbread_matrix`](@ref) / [`gbread_vector`](@ref) to use serialized element type.
"""
gbwrite(filename::AbstractString, A::GBVecOrMat) = open(io->gbwrite(io, A), filename, "w")

function gbwrite(io::IO, A::GBVecOrMat)
    hint = serialize_sizehint(A)
    v = Vector{UInt8}(undef, hint)
    sz = Ref{LibGraphBLAS.GrB_Index}(hint)
    @wraperror LibGraphBLAS.GrB_Matrix_serialize(v, sz, A)
    resize!(v, sz[])
    write(io, v)
end

"""
    gbread(filename::AbstractString, ::Type{GBMatrix{T, Tf}}; fill)
    gbread(io::IO, ::Type{GBMatrix{T, Tf}}; fill)

Read a `GrB_Matrix` from a file or IO object. This function uses the
`GrB_Matrix_deserialize` routine from the C GraphBLAS library directly, and constructs the
passed in type. It does not use Julia's Serialization standard library.
"""
gbread(filename::AbstractString, ::Type{T}; fill = defaultfill(Tf)) where {Te, Tf, T<:GBVecOrMat{Te, Tf}} =
    open(io->gbread(io, T; fill), filename, "r")

# TODO: I don't love how this works with fill. Rewrite for 1.0 with SparseBase
function gbread(io::IO, ::Type{GBMatrix{T, Tf}}; fill = defaultfill(Tf)) where {T, Tf}
    v = read(io)
    gb = _gbdeserialize_matrix(v, T)
    GBMatrix{T, Tf}(gb, fill)
end
function gbread(io::IO, ::Type{GBVector{T, Tf}}; fill = defaultfill(Tf)) where {T, Tf}
    v = read(io)
    gb = _gbdeserialize_matrix(v, T)
    GBVector{T, Tf}(gb, fill)
end

"""
    gbread_matrix(filename::AbstractString; fill)
    gbread_matrix(io::IO; fill)

Read a `GrB_Matrix` from a file or IO object. This function uses the
`GrB_Matrix_deserialize` routine from the C GraphBLAS library directly, and constructs
a [`GBMatrix`](@ref) using the deserialized element type. The default fill for the deserialized
element type is used unless one is passed in as the keyword argument `fill`.
"""
gbread_matrix(filename::AbstractString; fill = Nothing) =
    open(io->gbread_matrix(io; fill), filename, "r")

function gbread_matrix(io::IO; fill = Nothing)
    v = read(io)
    gb = _gbdeserialize_matrix(v, Nothing) # we don't know the eltype pass nothing
    type = Ref{LibGraphBLAS.GrB_Type}()
    LibGraphBLAS.GxB_Matrix_type(type, gb[])
    T = juliatype(ptrtogbtype[type[]])
    fill = fill === Nothing ? defaultfill(T) : fill
    return GBMatrix{T}(gb; fill)
end
"""
    gbread_matrix(filename::AbstractString; fill)
    gbread_matrix(io::IO; fill)

Read a `GrB_Matrix` from a file or IO object. This function uses the
`GrB_Matrix_deserialize` routine from the C GraphBLAS library directly, and constructs
a [`GBMatrix`](@ref) using the deserialized element type. The default fill for the deserialized
element type is used unless one is passed in as the keyword argument `fill`.
"""
gbread_vector(filename::AbstractString; fill = Nothing) =
    open(io->gbread_vector(io; fill), filename, "r")
function gbread_vector(io::IO; fill = Nothing)
    v = read(io)
    gb = _gbdeserialize_matrix(v, Nothing) # we don't know the eltype pass nothing
    type = Ref{LibGraphBLAS.GrB_Type}()
    LibGraphBLAS.GxB_Matrix_type(type, gb)
    T = juliatype(ptrtogbtype[type[]])
    fill = fill === Nothing ? defaultfill(T) : fill
    return GBVector{T}(gb; fill)
end
