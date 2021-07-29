#Broadcasting machinery
#######################

#This is directly from the Broadcasting interface docs
struct GBVectorStyle <: Broadcast.AbstractArrayStyle{1} end
struct GBMatrixStyle <: Broadcast.AbstractArrayStyle{2} end
Base.BroadcastStyle(::Type{<:GBVector}) = GBVectorStyle()
Base.BroadcastStyle(::Type{<:GBMatrix}) = GBMatrixStyle()
#
GBVectorStyle(::Val{0}) = GBVectorStyle()
GBVectorStyle(::Val{1}) = GBVectorStyle()
GBVectorStyle(::Val{2}) = GBMatrixStyle()
GBVectorStyle(::Val{N}) where N = Broadcast.DefaultArrayStyle{N}()
GBMatrixStyle(::Val{0}) = GBMatrixStyle()
GBMatrixStyle(::Val{1}) = GBMatrixStyle()
GBMatrixStyle(::Val{2}) = GBMatrixStyle()
GBMatrixStyle(::Val{N}) where N = Broadcast.DefaultArrayStyle{N}()
Broadcast.BroadcastStyle(::GBMatrixStyle, ::GBVectorStyle) = GBMatrixStyle()

#Elementwise Broadcasts
#####################
function Base.broadcasted(::typeof(*), A::GBArray, B::GBArray)
    emul(A, B, BinaryOps.TIMES)
end

function Base.broadcasted(::typeof(+), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.PLUS)
end

function Base.broadcasted(::typeof(-), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.MINUS)
end

#TODO: fix tricky gotchas, this will do type-specific (ie sometimes integer) division.
function Base.broadcasted(::typeof(/), A::GBArray, B::GBArray)
    emul(A, B, BinaryOps.DIV)
end

#TODO: fix tricky gotchas, this will do type-specific (ie sometimes integer) division.
function Base.broadcasted(::typeof(\), A::GBArray, B::GBArray)
    emul(A, B, BinaryOps.RDIV)
end

function Base.broadcasted(::typeof(==), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.EQ)
end

function Base.broadcasted(::typeof(!=), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.NE)
end

function Base.broadcasted(::typeof(<), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.LT)
end

function Base.broadcasted(::typeof(>), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.GT)
end

function Base.broadcasted(::typeof(<=), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.LE)
end

function Base.broadcasted(::typeof(>=), A::GBArray, B::GBArray)
    eadd(A, B, BinaryOps.GE)
end

function Base.broadcasted(::typeof(^), A::GBArray, B::GBArray)
    emul(A, B, BinaryOps.POW)
end

#Map Broadcasts
#######################
function Base.broadcasted(::typeof(*), u::GBArray, x::valid_union)
    map(BinaryOps.TIMES, u, x)
end
function Base.broadcasted(::typeof(*), x::valid_union, u::GBArray)
    map(BinaryOps.TIMES, x, u)
end

function Base.broadcasted(::typeof(/), u::GBArray, x::valid_union)
    map(BinaryOps.DIV, u, x)
end
function Base.broadcasted(::typeof(/), x::valid_union, u::GBArray)
    map(BinaryOps.DIV, x, u;)
end

function Base.broadcasted(::typeof(^), u::GBArray, x::valid_union)
    map(BinaryOps.POW, u, x)
end
function Base.broadcasted(::typeof(^), x::valid_union, u::GBArray)
    map(BinaryOps.POW, x, u)
end


function Base.broadcasted(::typeof(-), u::GBArray, x::valid_union)
    map(BinaryOps.MINUS, u, x)
end
function Base.broadcasted(::typeof(-), x::valid_union, u::GBArray)
    map(BinaryOps.MINUS, x, u)
end
function Base.broadcasted(::typeof(+), u::GBArray, x::valid_union)
    map(BinaryOps.PLUS, u, x)
end
function Base.broadcasted(::typeof(+), x::valid_union, u::GBArray)
    map(BinaryOps.PLUS, x, u)
end
