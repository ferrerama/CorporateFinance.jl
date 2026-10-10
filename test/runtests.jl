using Test
using CorporateFinance
using Aqua

@testset "CorporateFinance.jl" begin
    @testset "Aqua" begin
        Aqua.test_all(CorporateFinance)
    end

    include("cost_of_capital.jl")
    include("valuation.jl")
    include("inputs.jl")
end
