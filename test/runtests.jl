using JuMP, MOModelingExtensions
using Test, GLPK

@testset "Modeling extensions" begin
    @testset "Maximum" begin
        @testset "max" begin
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

        @testset "maximum" begin
            @testset "maximum([x, y])" begin
                m = Model(with_optimizer(GLPK.Optimizer))
                @variable(m, 0 <= x <= 5)
                @variable(m, 0 <= y <= 5)
                @constraint(m, maximum([x, y]) <= 4)
                @objective(m, Max, x + y)
                optimize!(m)

                @test value(x) ≈ 4.0
                @test value(y) ≈ 4.0
            end

            @testset "maximum([x, y, z])" begin
                m = Model(with_optimizer(GLPK.Optimizer))
                @variable(m, 0 <= x <= 5)
                @variable(m, 0 <= y <= 5)
                @variable(m, 4 <= z <= 5)
                @constraint(m, maximum([x, y, z]) <= 4)
                @objective(m, Max, x + y + z)
                optimize!(m)

                @test value(x) ≈ 4.0
                @test value(y) ≈ 4.0
                @test value(y) ≈ 4.0
            end
        end
    end

    @testset "Minimum" begin
        @testset "min" begin
            @testset "Both variables nonnegative" begin
                m = Model(with_optimizer(GLPK.Optimizer))
                @variable(m, 0 <= x <= 5)
                @variable(m, 0 <= y <= 5)
                @constraint(m, min(x, y) <= 4)
                @objective(m, Max, x + y)
                optimize!(m)

                if value(x) ≈ 4.0
                    @test value(x) ≈ 4.0
                    @test value(y) ≈ 5.0
                else
                    @test value(x) ≈ 5.0
                    @test value(y) ≈ 4.0
                end
            end

            @testset "First variable nonpositive" begin
                m = Model(with_optimizer(GLPK.Optimizer))
                @variable(m, -5 <= x <= 0)
                @variable(m, 0 <= y <= 5)
                @constraint(m, min(x, y) <= 4)
                @objective(m, Max, x + y)
                optimize!(m)

                @test value(x) ≈ 0.0
                @test value(y) ≈ 5.0
            end

            @testset "Second variable nonpositive" begin
                m = Model(with_optimizer(GLPK.Optimizer))
                @variable(m, 0 <= x <= 5)
                @variable(m, -5 <= y <= 0)
                @constraint(m, min(x, y) <= 4)
                @objective(m, Max, x + y)
                optimize!(m)

                @test value(x) ≈ 5.0
                @test value(y) ≈ 0.0
            end

            @testset "Both variables mixed sign" begin
                m = Model(with_optimizer(GLPK.Optimizer))
                @variable(m, -5 <= x <= 5)
                @variable(m, -5 <= y <= 5)
                @constraint(m, min(x, y) <= 4)
                @objective(m, Max, x + y)
                optimize!(m)

                if value(x) ≈ 4.0
                    @test value(x) ≈ 4.0
                    @test value(y) ≈ 5.0
                else
                    @test value(x) ≈ 5.0
                    @test value(y) ≈ 4.0
                end
            end
        end

        @testset "minimum" begin
            @testset "minimum([x, y])" begin
                m = Model(with_optimizer(GLPK.Optimizer))
                @variable(m, 0 <= x <= 5)
                @variable(m, 0 <= y <= 5)
                @constraint(m, minimum([x, y]) <= 4)
                @objective(m, Max, x + y)
                optimize!(m)

                if value(x) ≈ 4.0
                    @test value(x) ≈ 4.0
                    @test value(y) ≈ 5.0
                else
                    @test value(x) ≈ 5.0
                    @test value(y) ≈ 4.0
                end
            end

            @testset "minimum([x, y, z])" begin
                m = Model(with_optimizer(GLPK.Optimizer))
                @variable(m, 0 <= x <= 5)
                @variable(m, 0 <= y <= 5)
                @variable(m, 4 <= z <= 5)
                @constraint(m, minimum([x, y, z]) <= 4)
                @objective(m, Max, x + y + z)
                optimize!(m)

                if value(x) ≈ 4.0
                    @test value(x) ≈ 4.0
                    @test value(y) ≈ 5.0
                    @test value(z) ≈ 5.0
                elseif value(y) ≈ 4.0
                    @test value(x) ≈ 5.0
                    @test value(y) ≈ 4.0
                    @test value(z) ≈ 5.0
                else
                    @test value(x) ≈ 5.0
                    @test value(y) ≈ 5.0
                    @test value(z) ≈ 4.0
                end
            end
        end
    end
end
