module CorporateFinance

using Statistics

export capm, wacc, beta_regression, unlever_beta, relever_beta,
       perpetuity, terminal_value, fade_forecast, dcf_valuation, dcf_sensitivity,
       equity_value

include("checks.jl")
include("cost_of_capital.jl")
include("valuation.jl")

end # module
