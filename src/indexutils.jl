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
        return reinterpret(LibGraphBLAS.GrB_Index, I), length(I) #Assume ni = length(I) otherwise
    elseif I isa Integer
        return [UInt64(I)], 1
    elseif I isa CartesianIndex{1}
        return [UInt64(I[1])], 1
    else
        throw(TypeError(:idx,
            Union{UnitRange, StepRange, Vector, Integer}, typeof(I)))
    end
end

# This function assumes that szA and szB are
# technically equal and that
# 1 <= length(szA | szB) <= 2
# size checks should be done elsewhere.
function _combinesizes(A, B)
    if A isa Transpose{<:Any, <:AbstractVector} && B isa Transpose{<:Any, <:AbstractVector}
        return size(A)
    end
    if (A isa AbstractVector && B isa AbstractMatrix) ||
        (B isa AbstractVector && A isa AbstractMatrix)
        return (size(A, 1), size(A, 2))
    else
        return size(A)
    end
end
