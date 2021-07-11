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
