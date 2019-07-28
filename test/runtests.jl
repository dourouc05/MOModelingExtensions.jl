using JuMP, Test, GLPK

@testset "Test suite" begin
    @testset "Minimum" begin
        m = Model(with_optimizer(GLPK.Optimizer))
        @variable(m, 0 <= x <= 5)
        @variable(m, 0 <= y <= 5)
        # @variable(m, 0 <= z <= 5)
        # @constraint(m, x + y <= 9)
        @constraint(m, max(x, y) <= 4)
        @objective(m, Max, x + y)
        optimize!(m)

        @test value(x) ≈ 4.0
        @test value(y) ≈ 4.0
    end
end
