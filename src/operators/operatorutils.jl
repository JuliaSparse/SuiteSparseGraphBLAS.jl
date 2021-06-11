function getoperator(op, t)
    #Default Semiring should be LOR_LAND for boolean
    if op == Semirings.PLUS_TIMES_SEMIRING
        if t == Bool
            op = Semirings.LOR_LAND_SEMIRING
        end
    end
    #Default BinaryOp should be LAND or LOR for boolean
    if op == BinaryOps.TIMES
        if t == Bool
            op = BinaryOps.LAND
        end
    elseif op == BinaryOps.PLUS
        if t == Bool
            op = BinaryOps.LOR
        end
    end
    #Default monoid should be LAND/LOR
    if op == Monoids.TIMES_MONOID
        if t == Bool
            op = Monoids.LAND_MONOID
        end
    elseif op == Monoids.PLUS_MONOID
        if t == Bool
            op = Monoids.LOR_MONOID
        end
    end

    if op isa AbstractOp
        return op[t]
    elseif op isa GrBOp
        return op
    else
        error("Not a valid GrB op/semiring")
    end
end

isloaded(o::AbstractOp) = !isempty(o.pointers)

function validtypes(o::AbstractOp)
    isloaded(o) || _load(o)
    return keys(o.pointers)
end

function Base.getindex(o::AbstractOp, t::DataType)
    isloaded(o) || _load(o)
    if Any ∈ keys(o.pointers)
        getindex(o.pointers, Any)
    else
        getindex(o.pointers, t)
    end
end

function Base.show(io::IO, ::MIME"text/plain", o::AbstractOp)
    print(io, o.name, ": ", validtypes(o))
end
