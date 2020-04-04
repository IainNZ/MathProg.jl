#  Copyright 2017, Iain Dunning, Joey Huchette, Miles Lubin, and contributors
#  This Source Code Form is subject to the terms of the Mozilla Public
#  License, v. 2.0. If a copy of the MPL was not distributed with this
#  file, You can obtain one at http://mozilla.org/MPL/2.0/.
#############################################################################
# JuMP
# An algebraic modeling language for Julia
# See http://github.com/JuliaOpt/JuMP.jl
#############################################################################

using JuMP, SCS, Test

"""
    example_corr_sdp()

Given three random variables A,B,C and given bounds on two of the three
correlation coefficients:
    -0.2 <= ρ_AB <= -0.1
     0.4 <= ρ_BC <=  0.5

We can use the following property of the correlations to determine bounds on
ρ_AC by solving a SDP:
    |  1    ρ_AB  ρ_AC |
    | ρ_AB   1    ρ_BC |  ≽ 0
    | ρ_AC  ρ_BC   1   |
"""
function example_corr_sdp()
    model = Model(with_optimizer(SCS.Optimizer))
    set_silent(model)
    @variable(model, X[1:3, 1:3], PSD)

    # Diagonal is 1s
    @constraint(model, X[1, 1] == 1)
    @constraint(model, X[2, 2] == 1)
    @constraint(model, X[3, 3] == 1)

    # Bounds on the known correlations
    @constraint(model, X[1, 2] >= -0.2)
    @constraint(model, X[1, 2] <= -0.1)
    @constraint(model, X[2, 3] >=  0.4)
    @constraint(model, X[2, 3] <=  0.5)

    # Find upper bound
    @objective(model, Max, X[1, 3])
    JuMP.optimize!(model)
    @test JuMP.value(X[1, 3]) ≈ 0.87195 atol = 1e-4

    # Find lower bound
    @objective(model, Min, X[1, 3])
    JuMP.optimize!(model)
    @test JuMP.value(X[1, 3]) ≈ -0.978 atol = 1e-3
end

example_corr_sdp()
