function with(f; op = nothing, mask = nothing, accum = nothing, desc = nothing)
    ctxargs = []
    if op !== nothing
        push!(ctxargs, ctxop => op)
    end
    if mask !== nothing
        push!(ctxargs, ctxmask => mask)
    end
    if accum !== nothing
        push!(ctxargs, ctxaccum => accum)
    end
    if desc !== nothing
        push!(ctxargs, ctxdesc => desc)
    end
    with_context(f, ctxargs...)
end
