module MOModelingExtensions

using JuMP
import Base: max, min, maximum, minimum, &, |

function _check_var_has_bounds(var::AbstractVariableRef)
    if ! has_lower_bound(var)
        error("Variable $(var) has no lower bound")
    end
    if ! has_upper_bound(var)
        error("Variable $(var) has no upper bound")
    end
end

function _check_var_is_binary(var::AbstractVariableRef)
    if ! is_binary(var)
        error("Variable $(var) is not binary")
    end
end

# Minimum and maximum.

function max(a::AbstractVariableRef, b::AbstractVariableRef)::AbstractVariableRef
    # Return a new variable, x. This function uses an internal binary variable, z.
    # Model: x <= a + z * M, x <= b + (1 - z) * M,   x >= a, x >= b
    #        \_________ x <= max{a, b} _________/ \_ x >= max{a, b} _/
    # Interpretation: z = 0 if a is the maximum, 1 if it is b.
    model = owner_model(a)
    check_belongs_to_model(b, model)

    _check_var_has_bounds(a)
    _check_var_has_bounds(b)

    x_lower_bound = max(lower_bound(a), lower_bound(b))
    x_upper_bound = max(upper_bound(a), upper_bound(b))
    # Maximum difference between a and b.
    M = max(abs(lower_bound(a) - upper_bound(b)), abs(lower_bound(b) - upper_bound(a)))

    x = @variable(model, lower_bound=x_lower_bound, upper_bound=x_upper_bound)
    z = @variable(model, binary=true)

    @constraint(model, x <= a + M * z)
    @constraint(model, x <= b + M * (1 - z))
    @constraint(model, x >= a)
    @constraint(model, x >= b)

    return x
end

function maximum(vars::AbstractVector{<:AbstractVariableRef})::AbstractVariableRef
    # Same model as max, but with one binary variable per input variable.
    model = owner_model(vars[1])
    for var in vars # TODO: Only check for first variable.
        check_belongs_to_model(var, model)
    end

    for var in vars
        _check_var_has_bounds(var)
    end

    x_lower_bound = maximum(lower_bound.(vars))
    x_upper_bound = maximum(upper_bound.(vars))
    # Maximum difference between two variables.
    M = maximum(abs.(lower_bound(v1) - upper_bound(v2) for v1 in vars, v2 in vars))

    x = @variable(model, lower_bound=x_lower_bound, upper_bound=x_upper_bound)
    z = @variable(model, [eachindex(vars)], binary=true)

    @constraint(model, [var in eachindex(vars)], x <= vars[var] + M * (1 - z[var]))
    @constraint(model, [var in eachindex(vars)], x >= vars[var])
    @constraint(model, sum(z) == 1)

    return x
end

function min(a::AbstractVariableRef, b::AbstractVariableRef)::AbstractVariableRef
    # Return a new variable, x. This function uses an internal binary variable, z.
    # Model: x >= a + z * M, x >= b + (1 - z) * M,   x <= a, x <= b
    #        \_________ x >= min{a, b} _________/ \_ x <= min{a, b} _/
    # Interpretation: z = 0 if a is the minimum, 1 if it is b.
    model = owner_model(a)
    check_belongs_to_model(b, model)

    _check_var_has_bounds(a)
    _check_var_has_bounds(b)

    x_lower_bound = min(lower_bound(a), lower_bound(b))
    x_upper_bound = min(upper_bound(a), upper_bound(b))
    # Maximum difference between a and b.
    M = max(abs(lower_bound(a) - upper_bound(b)), abs(lower_bound(b) - upper_bound(a)))

    x = @variable(model, lower_bound=x_lower_bound, upper_bound=x_upper_bound)
    z = @variable(model, binary=true)

    @constraint(model, x >= a - M * z)
    @constraint(model, x >= b - M * (1 - z))
    @constraint(model, x <= a)
    @constraint(model, x <= b)

    return x
end

function minimum(vars::AbstractVector{<:AbstractVariableRef})::AbstractVariableRef
    # Same model as min, but with one binary variable per input variable.
    model = owner_model(vars[1])
    for var in vars # TODO: Only check for first variable.
        check_belongs_to_model(var, model)
    end

    for var in vars
        _check_var_has_bounds(var)
    end

    x_lower_bound = maximum(lower_bound.(vars))
    x_upper_bound = maximum(upper_bound.(vars))
    # Maximum difference between two variables.
    M = maximum(abs.(lower_bound(v1) - upper_bound(v2) for v1 in vars, v2 in vars))

    x = @variable(model, lower_bound=x_lower_bound, upper_bound=x_upper_bound)
    z = @variable(model, [eachindex(vars)], binary=true)

    @constraint(model, [var in eachindex(vars)], x >= vars[var] - M * (1 - z[var]))
    @constraint(model, [var in eachindex(vars)], x <= vars[var])
    @constraint(model, sum(z) == 1)

    return x
end

end
