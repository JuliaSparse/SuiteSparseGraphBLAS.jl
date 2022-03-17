function Serialization.serialize(s::AbstractSerializer, A::GBVecOrMat)
    Serialization.writetag(s.io, Serialization.OBJECT_TAG)
    Serialization.serialize(s, typeof(A))
    Serialization.serialize(s, A.fill)
    v = Vector{UInt8}(undef, serialize_sizehint(A))
    sz = Ref{LibGraphBLAS.GrB_Index}()
    @wraperror LibGraphBLAS.GrB_Matrix_serialize(v, sz, gbpointer(A))
    resize!(v, sz[])
    serialize(s, v)
    return nothing
end

function Serialization.deserialize(s::AbstractSerializer, ::Type{GBMatrix{T, Tf}}) where {T, Tf}
    fill = deserialize(s)
    refA = Ref{LibGraphBLAS.GrB_Matrix}() # GrB will take care of size and such.
    v = deserialize(s)
    @wraperror LibGraphBLAS.GrB_Matrix_deserialize(refA, gbtype(T), v, LibGraphBLAS.GrB_Index(length(v)))
    A = GBMatrix{T, Tf}(refA[], fill)
    return A
end

function serialize_sizehint(A::GBVecOrMat)
    sz = Ref{LibGraphBLAS.GrB_Index}()
    @wraperror LibGraphBLAS.GrB_Matrix_serializeSize(sz, gbpointer(A))
    return sz[]
end

