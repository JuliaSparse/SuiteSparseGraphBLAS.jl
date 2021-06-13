"""
    clear!(v::GBVector)
    clear!(A::GBMatrix)

Clear all the entries from the GBArray, setting them to the implicit value.
Does not modify the type or dimensions.
"""
function clear! end
