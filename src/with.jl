#EXPERIMENTAL
const kwargfunctions = [
    :apply,
    :apply!,
    :eadd,
    :emul,
    :eadd!,
    :emul!,
    :kron,
    :kron!,
    :mul,
    :mul!,
    :reduce,
    :reduce!,
    :select,
    :select!,
    :transpose,
    :transpose!,
]

const opfunctions = [
    :eadd,
    :eadd!,
    :emul,
    :emul!,
    :mul,
    :mul!,
]
macro with(exp...)
    kargs = Symbol[]
    returnexp = []
    for arg ∈ exp[1:end - 1]
        if @capture(arg, argname_=newval_)
            if argname == :mask
                push!(kargs, :mask)
            elseif argname == :accum
                push!(kargs, :accum)
            elseif argname == :desc
                push!(kargs, :desc)
            elseif argname == :op
                push!(kargs, :op)
            end
            push!(returnexp, :($argname=$newval))
        end
    end
    if @capture(exp[end], f_(args__; kwargs__))
        if f ∈ kwargfunctions
            temp = []
            # Check to see if the arg is already in the kwargs, if yes remove it temporarily
            for i ∈ kwargs
                loc = findfirst(x -> x == i.args[1], kargs)
                if loc !== nothing
                    deleteat!(kargs, loc)
                    push!(temp, i)
                end
            end
            # We don't want :op if the function doesn't accept it.
            if f ∉ opfunctions
                loc = findfirst(x -> x == :op, kargs)
                if loc !== nothing
                    deleteat!(kargs, loc)
                    push!(temp, i)
                end
            end
            o = :($f($(map(esc, args)...); $(kwargs...), $(kargs...)))
        end
    elseif @capture(exp[end], f_(args__))
        if f ∈ kwargfunctions
            temp = []
            # We shouldn't care about duplicate kwargs, it should be caught above.
            # We do need to ensure we don't use :op in a function that doesn't accept it.
            if f ∉ opfunctions
                loc = findfirst(x -> x == :op, kargs)
                if loc !== nothing
                    deleteat!(kargs, loc)
                    push!(temp, i)
                end
            end
            o = :($f($(map(esc, args)...); $(kargs...)))
        end
    end
    return quote
        $(returnexp...)
        $o
    end
end
#macro with(exp...)
#    kargs = []
#    oparg = []
#    for arg ∈ exp[1:end - 1]
#        if @capture(arg, argval_=newval_)
#            if argval == :mask
#                push!(kargs, Expr(mask=$newval))
#            elseif argval == :accum
#                push!(kargs, Expr(accum=$newval))
#            elseif argval == :desc
#                push!(kargs, Expr(desc=$newval))
#            elseif argval == :op
#                push!(oparg, Expr(op=$newval))
#            end
#        end
#    end
#    if @capture(exp[end], f_(args__))
#        print(f)
#        if f ∈ [:apply, :apply!]
#            :($f($(map(esc, args)...); $(kargs...)))
#        elseif f ∈ [:mul, :mul!, :eadd, :emul, :eadd!, :emul!]
#            append!(kargs, oparg)
#            :($f($(map(esc, args)...); $(kargs...)))
#        end
#    end
#    #if @capture(exp[end], apply!(args__))
#    #    :(apply!($(map(esc, args)...); mask=$mask, accum=$accum, desc=$desc))
#    #end
#
#    #postwalk(exp) do ex
#    #    #println(ex)
#    #    if @capture(ex, apply(args__) | apply!(args__))
#    #        print("gottem")
#    #        :(apply($(map(esc, args)...); mask=$mask, accum=$accum, desc=$desc))
#    #    end
#    #end
#end

