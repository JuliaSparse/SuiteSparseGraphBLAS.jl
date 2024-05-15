function Serialization.serialize(s::AbstractSerializer, A::GBVecOrMat)
    Serialization.writetag(s.io, Serialization.OBJECT_TAG)
    Serialization.serialize(s, typeof(A))
    v = Vector{UInt8}(undef, serialize_sizehint(A))
    sz = Ref{LibGraphBLAS.GrB_Index}()
    @wraperror LibGraphBLAS.GrB_Matrix_serialize(v, sz, A)
    resize!(v, sz[])
    serialize(s, v)
    return nothing
end

function _gbdeserialize(s::AbstractSerializer, ::Type{T}) where {T} # Only for internal use, we assume we've already got a GB<Something> here.
    refA = _newGrBRef() # Everything is a GrB_Matrix in the end.
    v = deserialize(s)
    @wraperror LibGraphBLAS.GrB_Matrix_deserialize(refA, gbtype(T), v, LibGraphBLAS.GrB_Index(length(v)))
    return refA
end

function Serialization.deserialize(s::AbstractSerializer, ::Type{GBMatrix{T}}) where {T}
    return GBMatrix{T}(_gbdeserialize(s, T)...)
end
function Serialization.deserialize(s::AbstractSerializer, ::Type{GBVector{T}}) where {T}
    return GBVector{T}(_gbdeserialize(s, T)...)
end

function serialize_sizehint(A::GBVecOrMat)
    sz = Ref{LibGraphBLAS.GrB_Index}()
    @wraperror LibGraphBLAS.GrB_Matrix_serializeSize(sz, A)
    return sz[]
end
