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
# Unlevered and Relevered Beta (Hamada)
# -----------------------------
function check_leverage(tax::Real, E::Real, D::Real)
    if tax < 0 || tax > 1
        error("Tax rate must be between 0 and 1.")
    end
    if E <= 0
        error("Equity (E) must be positive.")
    end
    if D < 0
        error("Debt (D) cannot be negative.")
    end
end

"""
    unlever_beta(; beta::Real, tax::Real, E::Real, D::Real)

Removes the effect of debt from a levered beta using the Hamada equation:
`beta / (1 + (1 - tax) * D / E)`.

# Keyword Arguments
- `beta`: Levered (observed) beta.
- `tax`: Corporate tax rate, between 0 and 1.
- `E`: Market value of equity.
- `D`: Market value of debt.
"""
function unlever_beta(; beta::Real, tax::Real, E::Real, D::Real)
    check_leverage(tax, E, D)
    return beta / (1 + (1 - tax) * D / E)
end

"""
    relever_beta(; beta::Real, tax::Real, E::Real, D::Real)

Applies a target capital structure to an unlevered beta using the Hamada equation:
`beta * (1 + (1 - tax) * D / E)`.

# Keyword Arguments
- `beta`: Unlevered beta.
- `tax`: Corporate tax rate, between 0 and 1.
- `E`: Target value of equity.
- `D`: Target value of debt.
"""
function relever_beta(; beta::Real, tax::Real, E::Real, D::Real)
    check_leverage(tax, E, D)
    return beta * (1 + (1 - tax) * D / E)
end
