function getoperator(op, t)
    #Default Semiring should be LOR_LAND for boolean
    if op == Semirings.PLUS_TIMES
        if t == Bool
            op = Semirings.LOR_LAND
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
        return op
    end
end

_isloaded(o::AbstractOp) = !isempty(o.pointers)

"""
    validtypes(operator::AbstractOp)::Vector{DataType}
    validtypes(operator::SelectOp)::Nothing

Determine the types available as a domain for a particular operator.
Each operator is defined on a specific set of types, for instance the [`LAND_LOR`](@ref)
    semiring is only defined for `Boolean` arguments.

When applied to an `AbstractSelectOp` this will return `nothing`.
When applied to certain operators like positional semirings it will return `[Any]`.
"""
function validtypes(o::AbstractOp)
    if !_isloaded(o)
        _load(o)
    end
    return collect(keys(o.pointers))
end

function Base.getindex(o::AbstractOp, t::DataType)
    _isloaded(o) || _load(o)
    if Any ∈ keys(o.pointers)
        getindex(o.pointers, Any)
    else
        getindex(o.pointers, t)
    end
end

function Base.show(io::IO, ::MIME"text/plain", o::AbstractOp)
    print(io, o.name, ": ", validtypes(o))
end
