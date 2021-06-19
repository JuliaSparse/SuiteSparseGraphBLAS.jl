"""
    idx(I)

Handle different indexing types (ALL, scalar, range-based, and vector). Returns the
proper format for GraphBLAS indexing. Should *not* be used for functions that take a single
scalar index like [`extractElement`].
"""
function idx(I)
    if I == ALL
        return I, 0 #ni doesn't matter if I=ALL
    elseif I isa UnitRange
        return [I.start, I.stop], libgb.GxB_RANGE #Simple ranges
    elseif I isa StepRange
        #The step must survive tozerobased(I), so we add 1 to it.
        if I.step > 0
            return [I.start, I.stop, I.step + 1], libgb.GxB_STRIDE #Normal stried ranges
        elseif I.step < 0
            #Strided ranges with negative increment
            return [I.start, I.stop, -I.step + 1], libgb.GxB_BACKWARDS
        end
    elseif I isa Vector
        return Vector{libgb.GrB_Index}(I), length(I) #Assume ni = length(I) otherwise
    elseif I isa Integer
        return UInt64(I), 1
    else
        throw(TypeError(idx, "Invalid index type",
            Union{UnitRange, StepRange, Vector, Integer}, typeof(I)))
    end
end
