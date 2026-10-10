"""
    check_finite(; kwargs...)

Internal helper. Throws an `ArgumentError` if any input is `NaN` or `Inf`,
naming the first invalid input.
"""
function check_finite(; kwargs...)
    for (name, x) in kwargs
        if !isfinite(x)
            throw(ArgumentError("$name must be a finite number, got $x."))
        end
    end
end
