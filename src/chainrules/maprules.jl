# Per Lyndon. Needs adaptation, and/or needs redefinition of apply to use functions rather
# than AbstractOp.
#function rrule(apply, f, xs)
#    # Rather than 3 applys really want 1 multiapply
#    ys_and_pullbacks = apply(x->rrule(f, x), xs) #Take this to ys = apply(f, x)
#    ys = apply(first, ys_and_pullbacks)
#    pullbacks = apply(last, ys_and_pullbacks)
#    function apply_pullback(dys)
#        _call(f, x) = f(x)
#        dfs_and_dxs = apply(_call, pullbacks, dys)
#        # but in your case you know it will be NoTangent() so can  skip
#        df = sum(first, dfs_and_dxs)
#        dxs = apply(last, dfs_and_dxs)
#        return NoTangent(), df, dxs
#    end
#    return ys, apply_pullback
#end
macro scalarapplyrule(func, derivative)
    return ChainRulesCore.@strip_linenos quote
        function ChainRulesCore.frule(
            (_, _, $(esc(:ΔA)))::Tuple,
            ::typeof(apply),
            ::typeof($(func)),
            $(esc(:A))::AbstractGBArray
        )
            $(esc(:Ω)) = apply($(esc(func)), $(esc(:A)))
            return $(esc(:Ω)), $(esc(derivative)) .* unthunk($(esc(:ΔA)))
        end
        function ChainRulesCore.rrule(
            ::typeof(apply),
            ::typeof($(func)),
            $(esc(:A))::AbstractGBArray
        )
            $(esc(:Ω)) = apply($(esc(func)), $(esc(:A)))
            function applyback($(esc(:ΔA)))
                NoTangent(), NoTangent(), $(esc(derivative)) .* $(esc(:ΔA))
            end
            return $(esc(:Ω)), applyback
        end
    end
end

function ChainRulesCore.frule(
    (_,_,ΔA)::Tuple,
    ::typeof(apply),
    ::typeof(sqrt),
    A::Array
)
    Ω = apply(sqrt, A)
    return Ω, inv.(2 .* Ω)
end

#Trig
@scalarapplyrule sin cos.(A)
@scalarapplyrule cos -sin.(A)
@scalarapplyrule tan @. 1 + (Ω ^ 2)

#Hyperbolic Trig
@scalarapplyrule sinh cosh.(A)
@scalarapplyrule cosh sinh.(A)
@scalarapplyrule tanh @. 1 - (Ω ^ 2)

@scalarapplyrule inv -(Ω .^ 2)
@scalarapplyrule exp Ω

@scalarapplyrule abs sign.(A)
#Anything that uses MINV fails the isapprox tests :().
# Since in the immortal words of Miha - "FiniteDiff is smarter than you", these shouldn't be enabled.
#@scalarapplyrule UnaryOps.ASIN @. inv(sqrt.(1 - A ^ 2))
#@scalarapplyrule UnaryOps.ACOS @. inv(sqrt.(1 - A ^ 2))
#@scalarapplyrule UnaryOps.ATAN @. inv(1 + A ^ 2)
#@scalarapplyrule UnaryOps.SQRT inv.(2 .* Ω)

function frule(
    (_, _, ΔA)::Tuple,
    ::typeof(apply),
    ::typeof(identity),
    A::AbstractGBArray
)
    return (A, ΔA)
end
function rrule(::typeof(apply), ::typeof(identity), A::AbstractGBArray)
    return A, (ΔΩ) -> (NoTangent(), NoTangent(), ΔΩ)
end
