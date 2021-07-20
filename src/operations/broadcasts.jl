#Elementwise Broadcasts
#######################

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
