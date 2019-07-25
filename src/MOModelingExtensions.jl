module MOModelingExtensions

using JuMP
import Base: max, min

function _check_var_has_bounds(var::AbstractVariableRef)
    if ! has_lower_bound(var)
        error("Variable $(var) has no lower bound")
    end
    if ! has_upper_bound(var)
        error("Variable $(var) has no upper bound")
    end
end

function max(a::AbstractVariableRef, b::AbstractVariableRef)::AbstractVariableRef
    # Return a new variable, x. This function uses an internal binary variable, z.
    # Model: x <= a + z * M, x <= b + (1 - z) * M,   x >= a, x >= b
    #        \_________ x <= max{a, b} _________/ \_ x >= max{a, b} _/
    # Interpretation: z = 0 if a is the maximum, 1 if it is b.
    model = owner_model(a)
    check_belongs_to_model(b, model)

    for var in [a, b]
        _check_var_has_bounds(var)
    end

    x_lower_bound = maximum([lower_bound(a), lower_bound(b)])
    x_upper_bound = maximum([upper_bound(a), upper_bound(b)])
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

function min(a::AbstractVariableRef, b::AbstractVariableRef)::AbstractVariableRef
    # Return a new variable, x. This function uses an internal binary variable, z.
    # Model: x >= a + z * M, x >= b + (1 - z) * M,   x >= a, x >= b
    #        \_________ x >= min{a, b} _________/ \_ x >= min{a, b} _/
    # Interpretation: z = 0 if a is the minimum, 1 if it is b.
    model = owner_model(a)
    check_belongs_to_model(b, model)

    for var in [a, b]
        _check_var_has_bounds(var)
    end

    x_lower_bound = minimum(lower_bound_index(a), lower_bound_index(b))
    x_upper_bound = minimum(upper_bound_index(a), upper_bound_index(b))
    # Maximum difference between a and b.
    M = maximum(abs(lower_bound_index(a) - upper_bound_index(b)), abs(lower_bound_index(b) - upper_bound_index(a)))

    x = @variable(model, lower_bound=x_lower_bound, upper_bound=x_upper_bound)
    z = @variable(model, binary=true)

    @constraint(model, x >= a + M * z)
    @constraint(model, x >= b + M * (1 - z))
    @constraint(model, x <= a)
    @constraint(model, x <= b)

    return x
end

end
