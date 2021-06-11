#EXPERIMENTAL

macro with(ex1, ex2)
    if @capture(ex1, t_tuple)
        @capture(ex2, mul(args__) | mul!(args__))
        return quote
            mul($(map(esc, args)...); $(esc(t))...)
        end
    end
end

macro with(ex)
    return ex
end
