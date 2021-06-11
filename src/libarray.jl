"""
    clear!(v::GBVector)
    clear!(A::GBMatrix)

Clear all the entries from the vector or matrix, setting them to the implicit value.
Does not modify the type or dimensions.
"""
function clear! end


"""
"""
function extract! end

"""
"""
function extract end

"""
"""
function subassign! end

"""
"""
function assign! end
