module CorporateFinance

using LinearAlgebra, Statistics

export capm, wacc, beta_regression, unlever_beta, relever_beta,
       perpetuity, terminal_value, dcf_valuation, equity_value

include("checks.jl")
include("cost_of_capital.jl")
include("valuation.jl")

end # module
