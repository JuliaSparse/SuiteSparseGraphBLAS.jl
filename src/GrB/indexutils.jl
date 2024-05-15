# This is stuck here in lieu of somewhere else,
# The (:) colon operator for array access.
"""
    All()

Singleton struct to represent the `:` operator in array access.
Considered internal and should only be constructed using `GrB.All()`.
"""
mutable struct All
    p::Ptr{LibGraphBLAS.GrB_Index}
end
Base.unsafe_convert(::Core.Type{Ptr{LibGraphBLAS.GrB_Index}}, s::All) = s.p
const ALL = All(Ptr{LibGraphBLAS.GrB_Index}())
All() = ALL
Base.length(::All) = 0 #Allow indexing with ALL

"""
    idx(I)

Handle different indexing types (ALL, scalar, range-based, and vector). Returns the
proper format for GraphBLAS indexing. Should *not* be used for functions that take a single
scalar index like [`extractElement`].
"""
function idx(I)
    # TODO. Do better here, and minimize manual idx management in rest of library.
    if I isa Colon
        I = ALL
    end
    if I == ALL
        return I, 0 #ni doesn't matter if I=ALL
    elseif I isa UnitRange
        return [I.start, I.stop], LibGraphBLAS.GxB_RANGE #Simple ranges
    elseif I isa StepRange
        #The step must survive tozerobased(I), so we add 1 to it.
        if I.step > 0
            return [I.start, I.stop, I.step + 1], LibGraphBLAS.GxB_STRIDE #Normal stried ranges
        elseif I.step < 0
            #Strided ranges with negative increment
            return [I.start, I.stop, -I.step + 1], LibGraphBLAS.GxB_BACKWARDS
        end
    elseif I isa Vector
        if eltype(I) <: CIndex{<:Union{Int64, UInt64}}
            return I, length(I)
        elseif eltype(I) === Int64
            return I, length(I)
        else
            convert(Vector{UInt64}, I), length(I) #Assume ni = length(I) otherwise
        end
    elseif I isa Integer
        return [UInt64(I)], 1
    elseif I isa CartesianIndex{1}
        return [UInt64(I[1])], 1
    else
        throw(TypeError(:idx,
            Union{UnitRange, StepRange, Vector, Integer}, typeof(I)))
    end
end

fix_indexlist!(i::Number) = [decrement(i)], 1
fix_indexlist!(I::CIndex) = [I], 1
fix_indexlist!(::Colon) = All(), 0
fix_indexlist!(i::Ptr{Cvoid}) = i 
unfix_indexlist!(::All) = (:)
fix_indexlist!(I::UnitRange) = [I.start - 1, I.stop - 1], LibGraphBLAS.GxB_RANGE
# no need for unfix, it'll be covered by vector.
function fix_indexlist!(I::StepRange)
    I.step > 0 && (return [I.start - 1, I.stop - 1, I.step], LibGraphBLAS.GxB_STRIDE)
    return [I.start - 1, I.stop - 1, -I.step], LibGraphBLAS.GxB_BACKWARDS
end
fix_indexlist!(I::Vector{<:Union{Int64, UInt64, CIndex{Int64}, CIndex{UInt64}}}) = 
    decrement!(I), length(I)
fix_indexlist!(I::AbstractVector) = eltype(I) isa CIndex ? fix_indexlist!(convert(CIndex{Int64}, I)) :
    fix_indexlist!(convert(Vector{Int64}, I))
unfix_indexlist!(I::AbstractVector) = increment!(I)
# just passthrough.
unfix_indexlist!(i::Ptr{Cvoid}) = i
unfix_indexlist!(i::Number) = i

function fix_indexlist!(I, J)
    if I === J
        I, l = fix_indexlist!(I)
        return I, I, l, l
    else
        I, i = fix_indexlist!(I)
        J, j = fix_indexlist!(J)
        return I, J, i, j
    end
end
function unfix_indexlist!(I, J)
    if I === J
        unfix_indexlist!(I)
        return I, I
    else
        return unfix_indexlist!(I), unfix_indexlist!(J)
    end
end



# Combine sizes for bcasting purposes
# This is quite inelegant :(, does this already exist somewhere?
# function _combinesizes(A::AbstractGBVector, B::AbstractGBVector)
#     size(A) == size(B) && (return size(A)) # same size
#     size(A, 1) == 1 && (return size(B)) # bcast A into B
#     size(B, 1) == 1 && (return size(A)) # bcast B into A
#     throw(DimensionMismatch("Got mismatched dimensions $(size(A)), $(size(B))"))
# end
# function _combinesizes(A::Transpose{<:Any, <:AbstractGBVector}, B::Transpose{<:Any, <:AbstractGBVector})
#     size(A) == size(B) && (return size(A)) # same size 
#     size(A, 2) == 1 && (return size(B)) # bcast A into B
#     size(B, 2) == 1 && (return size(A)) # bcast B into A
#     throw(DimensionMismatch("Got mismatched dimensions $(size(A)), $(size(B))"))
# end
# # Outer products (dot is done by mul[!])
# function _combinesizes(A::AbstractGBVector, B::Transpose{<:Any, <:AbstractGBVector})
#     return (size(A, 1), size(B, 2))
# end
# function _combinesizes(A::Transpose{<:Any, <:AbstractGBVector}, B::AbstractGBVector)
#     return (size(B, 1), size(A, 2))
# end
# 
# function _combinesizes(A::GBMatrixOrTranspose, v::AbstractGBVector)
#     length(v)
#     size(A, 1) == size(v, 1) && (return size(A))
#     throw(DimensionMismatch("Got mismatched dimensions $(size(A, 1)) and $(size(v, 1))"))
# end
# function _combinesizes(v::AbstractGBVector, A::GBMatrixOrTranspose)
#     size(A, 1) == size(v, 1) && (return size(A))
#     throw(DimensionMismatch("Got mismatched dimensions $(size(v, 1)) and $(size(A, 1))"))
# end
# 
# function _combinesizes(A::GBMatrixOrTranspose, v::Transpose{<:Any, <:AbstractGBVector})
#     size(A, 2) == size(v, 2) && (return size(A))
#     throw(DimensionMismatch("Got mismatched dimensions $(size(A, 2)) and $(size(v, 2))"))
# end
# function _combinesizes(v::Transpose{<:Any, <:AbstractGBVector}, A::GBMatrixOrTranspose)
#     size(A, 2) == size(v, 2) && (return size(A))
#     throw(DimensionMismatch("Got mismatched dimensions $(size(v, 2)) and $(size(A, 2))"))
# end
# 
# _combinesizes(A::GBMatrixOrTranspose, B::GBMatrixOrTranspose) = size(A) == size(B) ? size(A) : 
#     throw(DimensionMismatch("Got mismatched dimensions: $(size(A)) and $(size(B))"))
