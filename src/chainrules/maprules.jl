# Per Lyndon. Needs adaptation, and/or needs redefinition of map to use functions rather
# than AbstractOp.
#function rrule(map, f, xs)
#    # Rather than 3 maps really want 1 multimap
#    ys_and_pullbacks = map(x->rrule(f, x), xs) #Take this to ys = map(f, x)
#    ys = map(first, ys_and_pullbacks)
#    pullbacks = map(last, ys_and_pullbacks)
#    function map_pullback(dys)
#        _call(f, x) = f(x)
#        dfs_and_dxs = map(_call, pullbacks, dys)
#        # but in your case you know it will be NoTangent() so can  skip
#        df = sum(first, dfs_and_dxs)
#        dxs = map(last, dfs_and_dxs)
#        return NoTangent(), df, dxs
#    end
#    return ys, map_pullback
#end
macro scalarmaprule(func, derivative)
    return ChainRulesCore.@strip_linenos quote
        function ChainRulesCore.frule(
            (_, _, $(esc(:ΔA))),
            ::typeof(Base.map),
            ::typeof($(func)),
            $(esc(:A))::GBArray
        )
            $(esc(:Ω)) = map($(esc(func)), $(esc(:A)))
            return $(esc(:Ω)), $(esc(derivative)) .* unthunk($(esc(:ΔA)))
        end
        function ChainRulesCore.rrule(
            ::typeof(Base.map),
            ::typeof($(func)),
            $(esc(:A))::GBArray
        )
            $(esc(:Ω)) = map($(esc(func)), $(esc(:A)))
            function mapback($(esc(:ΔA)))
                NoTangent(), NoTangent(), $(esc(derivative)) .* $(esc(:ΔA))
            end
            return $(esc(:Ω)), mapback
        end
    end
end

#Trig
@scalarmaprule UnaryOps.SIN cos.(A)
@scalarmaprule UnaryOps.COS -sin.(A)
@scalarmaprule UnaryOps.TAN @. 1 + (Ω ^ 2)

#Hyperbolic Trig
@scalarmaprule UnaryOps.SINH cosh.(A)
@scalarmaprule UnaryOps.COSH sinh.(A)
@scalarmaprule UnaryOps.TANH @. 1 - (Ω ^ 2)

#Inverse Trig
@scalarmaprule UnaryOps.ASIN @. inv(sqrt.(1 - A ^ 2))
@scalarmaprule UnaryOps.ACOS @. inv(sqrt.(1 - A ^ 2))
@scalarmaprule UnaryOps.ATAN @. inv(1 + A ^ 2)

#function frule(
#    (_, _, ΔA),
#    ::typeof(map),
#    ::typeof(UnaryOps.SIN),
#    A::GBArray
#)
#    Ω = map(UnaryOps.SIN, A)
#    return Ω, map(UnaryOps.COS, A) .* ΔA
#end

#function frule(
#    (,),
#    ::typeof(map),
#    op::Union{Function, SelectUnion},
#    A::GBArray
#)
#    Ω = map(op, A)
#    ∂Ω =
#end
