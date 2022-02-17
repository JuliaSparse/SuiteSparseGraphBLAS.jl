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

function ChainRulesCore.frule(
    (_,_,ΔA),
    ::typeof(map),
    ::typeof(sqrt),
    A::Array
)
    Ω = map(sqrt, A)
    return Ω, inv.(2 .* Ω)
end

#Trig
@scalarmaprule sin cos.(A)
@scalarmaprule cos -sin.(A)
@scalarmaprule tan @. 1 + (Ω ^ 2)

#Hyperbolic Trig
@scalarmaprule sinh cosh.(A)
@scalarmaprule cosh sinh.(A)
@scalarmaprule tanh @. 1 - (Ω ^ 2)

@scalarmaprule inv -(Ω .^ 2)
@scalarmaprule exp Ω

@scalarmaprule abs sign.(A)
#Anything that uses MINV fails the isapprox tests :().
# Since in the immortal words of Miha - "FiniteDiff is smarter than you", these shouldn't be enabled.
#@scalarmaprule UnaryOps.ASIN @. inv(sqrt.(1 - A ^ 2))
#@scalarmaprule UnaryOps.ACOS @. inv(sqrt.(1 - A ^ 2))
#@scalarmaprule UnaryOps.ATAN @. inv(1 + A ^ 2)
#@scalarmaprule UnaryOps.SQRT inv.(2 .* Ω)

function frule(
    (_, _, ΔA),
    ::typeof(map),
    ::typeof(identity),
    A::GBArray
)
    return (A, ΔA)
end
function rrule(::typeof(map), ::typeof(identity), A::GBArray)
    return A, (ΔΩ) -> (NoTangent(), NoTangent(), ΔΩ)
end
