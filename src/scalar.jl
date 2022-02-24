# Constructors:
###############
function GBScalar{T}() where {T}
    s = Ref{LibGraphBLAS.GxB_Scalar}()
    @wraperror LibGraphBLAS.GxB_Scalar_new(s, gbtype(T))
    return GBScalar{T}(s[])
end

function GBScalar(v::T) where {T}
    x = GBScalar{T}()
    x[] = v
    return x
end

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################
Base.unsafe_convert(::Type{LibGraphBLAS.GxB_Scalar}, s::GBScalar) = s.p

function Base.copy(s::GBScalar{T}) where {T}
    s2 = Ref{LibGraphBLAS.GxB_Scalar}()
    @wraperror LibGraphBLAS.GxB_Scalar_dup(s2, s)
    return GBScalar{T}(s2[])
end

function clear!(s::GBScalar)
    @wraperror LibGraphBLAS.GxB_Scalar_clear(s)
end

# Type dependent functions setindex and getindex:
for T ∈ valid_vec
    func = Symbol(:GxB_Scalar_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(value::GBScalar{$T}, s::$T)
            @wraperror LibGraphBLAS.$func(value, s)
            return s
        end
    end
    func = Symbol(:GxB_Scalar_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(value::GBScalar{$T})
            x = Ref{$T}()
            @wraperror LibGraphBLAS.$func(x, value)
            return x[]
        end
    end
end

Base.eltype(::Type{GBScalar{T}}) where{T} = T

function Base.show(io::IO, ::MIME"text/plain", s::GBScalar)
    gxbprint(io, s)
end

function SparseArrays.nnz(v::GBScalar)
    n = Ref{LibGraphBLAS.GrB_Index}()
    @wraperror LibGraphBLAS.GrB_Scalar_nvals(n, v)
    return n[]
end
