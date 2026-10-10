module CorporateFinance

using LinearAlgebra, Statistics

export capm, wacc, beta_regression, perpetuity

# -----------------------------
# CAPM: Cost of Equity
# -----------------------------
"""
    capm(; rf::Real, beta::Real, erp::Real, crp::Real)

Calculates the Cost of Equity using the Capital Asset Pricing Model (CAPM).

# Keyword Arguments
- `rf`: Risk-free rate. Cannot be negative.
- `beta`: Systematic risk measure. Must be between -5 and 5.
- `erp`: Equity Risk Premium. Must be positive.
- `crp`: Country Risk Premium. Must be positive.
"""
function capm(; rf::Real, beta::Real, erp::Real, crp::Real)
    if rf < 0
        error("rf (risk-free rate) cannot be negative.")
    end
    if beta < -5 || beta > 5
        error("beta is outside a reasonable financial range (-5 to 5).")
    end
    if erp < 0
        error("erp (equity risk premium) must be positive.")
    end
    if crp < 0
        error("crp (country risk premium) must be positive.")
    end

    return rf + beta * erp + crp
end

# -----------------------------
# WACC: Weighted Average Cost of Capital
# -----------------------------
"""
    wacc(; ke::Real, kd::Real, tax::Real, E::Real, D::Real)

Calculates the Weighted Average Cost of Capital (WACC).

# Keyword Arguments
- `ke`: Cost of Equity.
- `kd`: Cost of Debt.
- `tax`: Corporate tax rate, between 0 and 1.
- `E`: Market value of equity.
- `D`: Market value of debt.
"""
function wacc(; ke::Real, kd::Real, tax::Real, E::Real, D::Real)
    if tax < 0 || tax > 1
        error("Tax rate must be between 0 and 1.")
    end
    if E < 0 || D < 0
        error("Equity (E) and Debt (D) values must be positive.")
    end
    if E + D == 0
        error("Total capital (E + D) cannot be zero.")
    end

    return (E / (E + D)) * ke + (D / (E + D)) * kd * (1 - tax)
end

# -----------------------------
# Beta Regression
# -----------------------------
"""
    beta_regression(asset_returns, market_returns)

Calculates the beta of an asset relative to the market using covariance and variance.
"""
function beta_regression(asset_returns::Vector{<:Real}, market_returns::Vector{<:Real})
    if length(asset_returns) != length(market_returns)
        error("Series must have the same length.")
    end
    cov_am = cov(asset_returns, market_returns)
    var_m  = var(market_returns)
    return cov_am / var_m
end

# -----------------------------
# Perpetuity
# -----------------------------
"""
    perpetuity(cashflow::Real, rate::Real)

Calculates the present value of a constant perpetuity given a cash flow and a discount rate.
"""
function perpetuity(cashflow::Real, rate::Real)
    if rate <= 0
        error("Discount rate must be positive.")
    end
    return cashflow / rate
end

end # module