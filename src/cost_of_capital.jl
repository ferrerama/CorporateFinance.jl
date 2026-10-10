# -----------------------------
# CAPM: Cost of Equity
# -----------------------------
"""
    capm(; rf::Real, beta::Real, erp::Real, crp::Real)

Calculates the Cost of Equity using the Capital Asset Pricing Model (CAPM).

# Keyword Arguments
- `rf`: Risk-free rate. Can be negative.
- `beta`: Systematic risk measure. Must be between -5 and 5.
- `erp`: Equity Risk Premium. Cannot be negative.
- `crp`: Country Risk Premium. Cannot be negative.
"""
function capm(; rf::Real, beta::Real, erp::Real, crp::Real)
    check_finite(rf = rf, beta = beta, erp = erp, crp = crp)
    if beta < -5 || beta > 5
        throw(ArgumentError("beta is outside a reasonable financial range (-5 to 5)."))
    end
    if erp < 0
        throw(ArgumentError("erp (equity risk premium) cannot be negative."))
    end
    if crp < 0
        throw(ArgumentError("crp (country risk premium) cannot be negative."))
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
    check_finite(ke = ke, kd = kd, tax = tax, E = E, D = D)
    if tax < 0 || tax > 1
        throw(ArgumentError("Tax rate must be between 0 and 1."))
    end
    if E < 0 || D < 0
        throw(ArgumentError("Equity (E) and Debt (D) cannot be negative."))
    end
    if E + D == 0
        throw(ArgumentError("Total capital (E + D) cannot be zero."))
    end

    return (E / (E + D)) * ke + (D / (E + D)) * kd * (1 - tax)
end

# -----------------------------
# Beta Regression
# -----------------------------
"""
    beta_regression(asset_returns::AbstractVector{<:Real}, market_returns::AbstractVector{<:Real})

Calculates the beta of an asset relative to the market:
`cov(asset_returns, market_returns) / var(market_returns)`.

# Arguments
- `asset_returns`: Periodic returns of the asset.
- `market_returns`: Periodic returns of the market index, same length and periods as `asset_returns`.
"""
function beta_regression(asset_returns::AbstractVector{<:Real}, market_returns::AbstractVector{<:Real})
    if length(asset_returns) != length(market_returns)
        throw(ArgumentError("Series must have the same length."))
    end
    if length(market_returns) < 2
        throw(ArgumentError("At least two observations are needed."))
    end
    if any(.!isfinite.(asset_returns)) || any(.!isfinite.(market_returns))
        throw(ArgumentError("Returns contain invalid or non-finite values."))
    end
    if iszero(var(market_returns))
        throw(ArgumentError("Market returns have zero variance; beta is undefined."))
    end
    cov_am = cov(asset_returns, market_returns)
    var_m  = var(market_returns)
    return cov_am / var_m
end

# -----------------------------
# Unlevered and Relevered Beta (Hamada / Conine)
# -----------------------------
"""
    check_leverage(tax::Real, E::Real, D::Real)

Internal helper. Validates the inputs shared by `unlever_beta` and `relever_beta`.

# Arguments
- `tax`: Corporate tax rate, between 0 and 1.
- `E`: Value of equity. Must be positive.
- `D`: Value of debt. Cannot be negative.
"""
function check_leverage(tax::Real, E::Real, D::Real)
    if tax < 0 || tax > 1
        throw(ArgumentError("Tax rate must be between 0 and 1."))
    end
    if E <= 0
        throw(ArgumentError("Equity (E) must be positive."))
    end
    if D < 0
        throw(ArgumentError("Debt (D) cannot be negative."))
    end
end

"""
    unlever_beta(; beta::Real, tax::Real, E::Real, D::Real, beta_debt::Real = 0)

Removes the effect of debt from a levered beta:
`(beta + beta_debt * k) / (1 + k)`, with `k = (1 - tax) * D / E`.

With `beta_debt = 0` this is the Hamada equation. A positive `beta_debt`
(Conine formula) is more realistic for highly leveraged companies, whose debt
carries part of the business risk.

# Keyword Arguments
- `beta`: Levered (observed) beta.
- `tax`: Corporate tax rate, between 0 and 1.
- `E`: Market value of equity.
- `D`: Market value of debt.
- `beta_debt`: Beta of the debt. Defaults to 0 (risk-free debt).
"""
function unlever_beta(; beta::Real, tax::Real, E::Real, D::Real, beta_debt::Real = 0)
    check_finite(beta = beta, tax = tax, E = E, D = D, beta_debt = beta_debt)
    check_leverage(tax, E, D)
    k = (1 - tax) * D / E
    return (beta + beta_debt * k) / (1 + k)
end

"""
    relever_beta(; beta::Real, tax::Real, E::Real, D::Real, beta_debt::Real = 0)

Applies a target capital structure to an unlevered beta:
`beta + (beta - beta_debt) * k`, with `k = (1 - tax) * D / E`.
It is the inverse of [`unlever_beta`](@ref).

# Keyword Arguments
- `beta`: Unlevered beta.
- `tax`: Corporate tax rate, between 0 and 1.
- `E`: Target value of equity.
- `D`: Target value of debt.
- `beta_debt`: Beta of the debt. Defaults to 0 (risk-free debt).
"""
function relever_beta(; beta::Real, tax::Real, E::Real, D::Real, beta_debt::Real = 0)
    check_finite(beta = beta, tax = tax, E = E, D = D, beta_debt = beta_debt)
    check_leverage(tax, E, D)
    k = (1 - tax) * D / E
    return beta + (beta - beta_debt) * k
end
