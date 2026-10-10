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

# -----------------------------
# Terminal Value (Gordon Growth)
# -----------------------------
"""
    terminal_value(; fcf::Real, wacc::Real, g::Real)

Calculates the terminal value at the end of the forecast period using the
Gordon growth model: `fcf * (1 + g) / (wacc - g)`.

# Keyword Arguments
- `fcf`: Free cash flow of the last forecast year.
- `wacc`: Discount rate. Must be greater than `g`.
- `g`: Long-term growth rate.
"""
function terminal_value(; fcf::Real, wacc::Real, g::Real)
    if wacc <= g
        error("WACC must be greater than the growth rate g.")
    end
    return fcf * (1 + g) / (wacc - g)
end

# -----------------------------
# DCF Valuation: Forecast + Terminal Value
# -----------------------------
"""
    dcf_valuation(fcf::Vector{<:Real}; wacc::Real, g::Real)

Values a company with a discounted cash flow model in two stages: the forecast
free cash flows and a terminal value (Gordon growth) after the last year.

Returns a named tuple with `pv_fcf`, `pv_terminal` and `enterprise_value`.

# Keyword Arguments
- `wacc`: Discount rate. Must be greater than `g`.
- `g`: Long-term growth rate after the forecast period.
"""
function dcf_valuation(fcf::Vector{<:Real}; wacc::Real, g::Real)
    if isempty(fcf)
        error("The cash flow vector cannot be empty.")
    end
    if any(.!isfinite.(fcf))
        error("The cash flow vector contains invalid or non-finite values.")
    end

    n = length(fcf)
    tv = terminal_value(fcf = fcf[end], wacc = wacc, g = g)

    pv_fcf      = sum(fcf ./ (1 + wacc) .^ (1:n))
    pv_terminal = tv / (1 + wacc)^n

    return (pv_fcf = pv_fcf, pv_terminal = pv_terminal,
            enterprise_value = pv_fcf + pv_terminal)
end

# -----------------------------
# Equity Value: from Enterprise Value
# -----------------------------
"""
    equity_value(; ev::Real, debt::Real, cash::Real = 0)

Calculates the equity value from the enterprise value: `ev - debt + cash`.

# Keyword Arguments
- `ev`: Enterprise value.
- `debt`: Total financial debt. Cannot be negative.
- `cash`: Cash and equivalents. Cannot be negative.
"""
function equity_value(; ev::Real, debt::Real, cash::Real = 0)
    if debt < 0 || cash < 0
        error("Debt and cash cannot be negative.")
    end
    return ev - debt + cash
end
