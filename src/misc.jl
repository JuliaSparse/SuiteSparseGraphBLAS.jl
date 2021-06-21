"""
    _⛔()

Print UInts as decimal instead of hex.
This is type piracy, but shouldn't be a huge deal since it's just `show`.
"""
function _⛔()
    @eval Base.show(io::IO, x::T) where {T<:Union{UInt, UInt128, UInt64,
    UInt32, UInt16, UInt8}} = Base.print(io, x)
end
