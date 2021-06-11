# Constructors:
###############
"""
    GBScalar{T}()

Create an unassigned GBScalar of type T.
"""
GBScalar{T}() where {T} = GBScalar{T}(libgb.GxB_Scalar_new(toGBType(T)))

"""
    GBScalar(v::T)

Create a GBScalar of type `T` and assign `v` to it.
"""
function GBScalar(v::T) where {T <: valid_union}
    x = GBScalar{T}()
    x[] = v
    return x
end

# Some Base and basic SparseArrays/LinearAlgebra functions:
###########################################################
Base.unsafe_convert(::Type{libgb.GxB_Scalar}, s::GBScalar) = s.p

function Base.copy(s::GBScalar{T}) where {T}
    return GBScalar{T}(libgb.GxB_Scalar_dup(s))
end

clear!(s::GBScalar) = libgb.GxB_Scalar_clear(s)

# Type dependent functions setindex and getindex:
for T ∈ valid_vec
    func = Symbol(:GxB_Scalar_setElement_, suffix(T))
    @eval begin
        function Base.setindex!(value::GBScalar{$T}, s::$T)
            libgb.$func(value, s)
        end
    end
    func = Symbol(:GxB_Scalar_extractElement_, suffix(T))
    @eval begin
        function Base.getindex(value::GBScalar{$T})
            libgb.$func(value)
        end
    end
end

Base.eltype(::Type{GBScalar{T}}) where{T} = T

function Base.show(io::IO, ::MIME"text/plain", s::GBScalar)
    gxbprint(io, s)
end

SparseArrays.nnz(v::GBMatrix) = Int64(libgb.GrB_Scalar_nvals(v))
