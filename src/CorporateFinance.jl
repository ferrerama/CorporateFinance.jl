module CorporateFinance

using LinearAlgebra, Statistics

export capm, wacc, dcf_value, beta_regression,
       npv, irr, payback, perpetuity

# -----------------------------
# CAPM: Cost of Equity
# -----------------------------
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
# DCF: Discounted Cash Flow
# -----------------------------
function dcf_value(fcf::Vector{T}, wacc::Real) where T<:Real
    if any(.!isfinite.(fcf))
        error("The cash flow vector contains invalid or non-finite values.")
    end
    if wacc <= -1
        error("WACC must be strictly greater than -1.")
    end

    t = 1:length(fcf)
    return sum(fcf ./ (1 .+ wacc) .^ t)
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
# NPV: Net Present Value
# -----------------------------
function npv(cashflows::Vector{<:Real}, rate::Real; initial_investment::Real=0.0)
    t = 1:length(cashflows)
    return -initial_investment + sum(cashflows ./ (1 .+ rate) .^ t)
end

# -----------------------------
# IRR: Internal Rate of Return
# -----------------------------
function irr(cashflows::Vector{<:Real}; initial_investment::Real=0.0)
    f(rate) = npv(cashflows, rate; initial_investment=initial_investment)
    # Simple Newton-Raphson iteration
    rate = 0.1
    for _ in 1:100
        f_val = f(rate)
        f_der = sum((-t * cashflows[t]) / (1 + rate)^(t + 1) for t in 1:length(cashflows))
        rate -= f_val / f_der
        if abs(f_val) < 1e-6
            return rate
        end
    end
    error("IRR did not converge")
end

# -----------------------------
# Payback Period
# -----------------------------
function payback(cashflows::Vector{<:Real}, initial_investment::Real)
    cumulative = cumsum(cashflows)
    idx = findfirst(>=(initial_investment), cumulative)
    return isnothing(idx) ? Inf : idx
end

# -----------------------------
# Perpetuity
# -----------------------------
function perpetuity(cashflow::Real, rate::Real)
    if rate <= 0
        error("Discount rate must be positive.")
    end
    return cashflow / rate
end

end # module
