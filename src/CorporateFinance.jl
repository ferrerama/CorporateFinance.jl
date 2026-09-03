module CorporateFinance

export capm, wacc, dcf_value

# -----------------------------
# CAPM: Cost of Equity
# -----------------------------
"""
    capm(; rf, beta, erp, crp)

Calculates the Cost of Equity using the adjusted CAPM model:
ke = rf + beta * erp + crp

Parameters:
- rf   : Risk-free rate
- beta : Systematic risk (levered beta)
- erp  : Equity Risk Premium
- crp  : Country Risk Premium
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
    wacc(; ke, kd, tax, E, D)

Calculates the WACC based on:
- ke  : Cost of Equity (from CAPM)
- kd  : Cost of Debt
- tax : Corporate Tax Rate (0–1)
- E   : Market Value of Equity
- D   : Market Value of Debt
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
# DCF: Discounted Cash Flow
# -----------------------------
"""
    dcf_value(fcf::Vector{T}, wacc::Real) where T<:Real

Takes a vector of Free Cash Flows (FCF) and discounts them using a specific WACC.
Returns the total Present Value using high-performance broadcasting operators.
"""
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

end # module
