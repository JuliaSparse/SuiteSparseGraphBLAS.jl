#EXPERIMENTAL

macro with(exp...)
    kargs = []
    for arg ∈ exp[1:end - 1]
        if @capture(arg, argval_=newval_)
            if argval == :mask
                push!(kargs, :mask=>newval)
            elseif argval == :accum
                push!(kargs, :accum=>newval)
            elseif argval == :desc
                push!(kargs, :desc=>newval)
            elseif argval == :op
                push!(kargs, :op=>newval)
            end
        end
    end
    withop = NamedTuple(kargs)
    noop = NamedTuple([p for p ∈ kargs if p[1] != :op])
    if @capture(exp[end], f_(args__))
        print(f)
        println(noop)
        if f ∈ [:apply, :apply!]
            :($f($(map(esc, args)...); $(noop)...))
        elseif f ∈ [:mul, :mul!, :eadd, :emul, :eadd!, :emul!]
            :($f($(map(esc, args)...); mask=$mask, accum=$accum, desc=$desc, op=$op))
        end
    end
    #if @capture(exp[end], apply!(args__))
    #    :(apply!($(map(esc, args)...); mask=$mask, accum=$accum, desc=$desc))
    #end

    #postwalk(exp) do ex
    #    #println(ex)
    #    if @capture(ex, apply(args__) | apply!(args__))
    #        print("gottem")
    #        :(apply($(map(esc, args)...); mask=$mask, accum=$accum, desc=$desc))
    #    end
    #end
end
