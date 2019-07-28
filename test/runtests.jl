using JuMP, MOModelingExtensions
using Test, GLPK

@testset "Modeling extensions" begin
    @testset "Maximum" begin
        @testset "Both variables nonnegative" begin
            m = Model(with_optimizer(GLPK.Optimizer))
            @variable(m, 0 <= x <= 5)
            @variable(m, 0 <= y <= 5)
            @constraint(m, max(x, y) <= 4)
            @objective(m, Max, x + y)
            optimize!(m)

            @test value(x) ≈ 4.0
            @test value(y) ≈ 4.0
        end

        @testset "First variable nonpositive" begin
            m = Model(with_optimizer(GLPK.Optimizer))
            @variable(m, -5 <= x <= 0)
            @variable(m, 0 <= y <= 5)
            @constraint(m, max(x, y) <= 4)
            @objective(m, Max, x + y)
            optimize!(m)

            @test value(x) ≈ 0.0
            @test value(y) ≈ 4.0
        end

        @testset "Second variable nonpositive" begin
            m = Model(with_optimizer(GLPK.Optimizer))
            @variable(m, 0 <= x <= 5)
            @variable(m, -5 <= y <= 0)
            @constraint(m, max(x, y) <= 4)
            @objective(m, Max, x + y)
            optimize!(m)

            @test value(x) ≈ 4.0
            @test value(y) ≈ 0.0
        end

        @testset "Both variables mixed sign" begin
            m = Model(with_optimizer(GLPK.Optimizer))
            @variable(m, -5 <= x <= 5)
            @variable(m, -5 <= y <= 5)
            @constraint(m, max(x, y) <= 4)
            @objective(m, Max, x + y)
            optimize!(m)

            @test value(x) ≈ 4.0
            @test value(y) ≈ 4.0
        end
    end

    @testset "Minimum" begin
        @testset "Both variables nonnegative" begin
            m = Model(with_optimizer(GLPK.Optimizer))
            @variable(m, 0 <= x <= 5)
            @variable(m, 0 <= y <= 5)
            @constraint(m, min(x, y) <= 4)
            @objective(m, Max, x + y)
            optimize!(m)

            println(termination_status(m))

            # if value(x) ≈ 4.0
            #     @test value(x) ≈ 4.0
            #     @test value(y) ≈ 5.0
            # else
            #     @test value(x) ≈ 5.0
            #     @test value(y) ≈ 4.0
            # end
        end

        @testset "First variable nonpositive" begin
            m = Model(with_optimizer(GLPK.Optimizer))
            @variable(m, -5 <= x <= 0)
            @variable(m, 0 <= y <= 5)
            @constraint(m, min(x, y) <= 4)
            @objective(m, Max, x + y)
            optimize!(m)

            println(termination_status(m))

            # @test value(x) ≈ 0.0
            # @test value(y) ≈ 4.0
        end

        @testset "Second variable nonpositive" begin
            m = Model(with_optimizer(GLPK.Optimizer))
            @variable(m, 0 <= x <= 5)
            @variable(m, -5 <= y <= 0)
            @constraint(m, min(x, y) <= 4)
            @objective(m, Max, x + y)
            optimize!(m)

            println(termination_status(m))

            # @test value(x) ≈ 4.0
            # @test value(y) ≈ 0.0
        end

        @testset "Both variables mixed sign" begin
            m = Model(with_optimizer(GLPK.Optimizer))
            @variable(m, -5 <= x <= 5)
            @variable(m, -5 <= y <= 5)
            @constraint(m, min(x, y) <= 4)
            @objective(m, Max, x + y)
            optimize!(m)

            println(termination_status(m))

            # @test value(x) ≈ 4.0
            # @test value(y) ≈ 4.0
        end
    end
end
