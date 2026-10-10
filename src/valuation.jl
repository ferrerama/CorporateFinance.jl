# -----------------------------
# Perpetuity
# -----------------------------
"""
    perpetuity(cashflow::Real, rate::Real)

Calculates the present value of a constant perpetuity: `cashflow / rate`.

# Arguments
- `cashflow`: Constant cash flow received each period.
- `rate`: Discount rate. Must be positive.
"""
function perpetuity(cashflow::Real, rate::Real)
    check_finite(cashflow = cashflow, rate = rate)
    if rate <= 0
        throw(ArgumentError("Discount rate must be positive."))
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
    check_finite(fcf = fcf, wacc = wacc, g = g)
    if wacc <= g
        throw(ArgumentError("WACC must be greater than the growth rate g."))
    end
    return fcf * (1 + g) / (wacc - g)
end

# -----------------------------
# Fade Stage: Growth Declining to g
# -----------------------------
"""
    fade_forecast(; fcf::Real, g_start::Real, g::Real, years::Integer)

Extends a forecast with a transition stage in which growth declines from
`g_start` to the long-term rate `g` in linear increments. Returns `years` free
cash flows, the growth rate of year `k` being `g_start + (g - g_start) * k / years`,
so the last year of the stage already grows at `g`.

For example, `g_start = 0.30`, `g = 0.05` and `years = 5` give growth rates of
25%, 20%, 15%, 10% and 5%.

Append the result to the explicit forecast to build a three-stage DCF:
`dcf_valuation(vcat(fcf, fade_forecast(...)); wacc, g)`.

# Keyword Arguments
- `fcf`: Free cash flow of the last explicit forecast year.
- `g_start`: Growth rate of the high-growth stage (the last explicit forecast year).
- `g`: Long-term growth rate, reached in the last year of the stage.
- `years`: Length of the stage. Must be at least 1.
"""
function fade_forecast(; fcf::Real, g_start::Real, g::Real, years::Integer)
    check_finite(fcf = fcf, g_start = g_start, g = g)
    if years < 1
        throw(ArgumentError("years must be at least 1."))
    end
    growth = [g_start + (g - g_start) * k / years for k in 1:years]
    return fcf .* cumprod(1 .+ growth)
end

# -----------------------------
# DCF Valuation: Forecast + Terminal Value
# -----------------------------
"""
    dcf_valuation(fcf::AbstractVector{<:Real}; wacc::Real, g = nothing,
                  exit_multiple = nothing, ebitda = nothing, midyear::Bool = false)

Values a company with a discounted cash flow model: the forecast free cash flows
plus a terminal value after the last year. The terminal value is calculated
either with the Gordon growth model (pass `g`) or with an exit multiple
(pass `exit_multiple` and `ebitda`), but not both.

With `midyear = true` the cash flows are discounted at `t - 0.5`, as if they
were received in the middle of each year. A Gordon terminal value is then also
discounted at `n - 0.5`, while an exit-multiple terminal value stays at `n`,
since it represents a sale price at the end of the last year.

Returns a named tuple with `pv_fcf`, `pv_terminal` and `enterprise_value`.

# Arguments
- `fcf`: Forecast free cash flows, one per year (year 1 to n).

# Keyword Arguments
- `wacc`: Discount rate. Must be greater than -1, and greater than `g` if given.
- `g`: Long-term growth rate after the forecast period.
- `exit_multiple`: EV/EBITDA multiple applied at the end of the forecast. Cannot be negative.
- `ebitda`: EBITDA of the last forecast year, used with `exit_multiple`.
- `midyear`: Use the mid-year discounting convention. Defaults to `false`.
"""
function dcf_valuation(fcf::AbstractVector{<:Real}; wacc::Real,
                       g::Union{Real, Nothing} = nothing,
                       exit_multiple::Union{Real, Nothing} = nothing,
                       ebitda::Union{Real, Nothing} = nothing,
                       midyear::Bool = false)
    if isempty(fcf)
        throw(ArgumentError("The cash flow vector cannot be empty."))
    end
    if any(.!isfinite.(fcf))
        throw(ArgumentError("The cash flow vector contains invalid or non-finite values."))
    end
    check_finite(wacc = wacc)
    if wacc <= -1
        throw(ArgumentError("WACC must be greater than -1."))
    end
    if isnothing(g) == isnothing(exit_multiple)
        throw(ArgumentError("Provide either g (Gordon growth) or exit_multiple, not both."))
    end
    if isnothing(exit_multiple) != isnothing(ebitda)
        throw(ArgumentError("exit_multiple and ebitda must be given together."))
    end

    n = length(fcf)
    t = midyear ? (1:n) .- one(wacc) / 2 : (1:n)

    if isnothing(g)
        check_finite(exit_multiple = exit_multiple, ebitda = ebitda)
        if exit_multiple < 0
            throw(ArgumentError("exit_multiple cannot be negative."))
        end
        tv = exit_multiple * ebitda
        pv_terminal = tv / (1 + wacc)^n
    else
        tv = terminal_value(fcf = fcf[end], wacc = wacc, g = g)
        pv_terminal = tv / (1 + wacc)^t[end]
    end

    pv_fcf = sum(fcf ./ (1 + wacc) .^ t)

    return (pv_fcf = pv_fcf, pv_terminal = pv_terminal,
            enterprise_value = pv_fcf + pv_terminal)
end

# -----------------------------
# Sensitivity: WACC × g
# -----------------------------
"""
    dcf_sensitivity(fcf::AbstractVector{<:Real}; waccs::AbstractVector{<:Real},
                    gs::AbstractVector{<:Real}, midyear::Bool = false)

Builds the classic sensitivity table of a DCF: the enterprise value for each
combination of discount rate (rows) and long-term growth rate (columns), using
[`dcf_valuation`](@ref) with a Gordon terminal value.

Combinations where `wacc <= g` have no valid Gordon value and are returned as
`NaN`, so the rest of the table is still produced.

# Arguments
- `fcf`: Forecast free cash flows, one per year (year 1 to n).

# Keyword Arguments
- `waccs`: Discount rates, one per row.
- `gs`: Long-term growth rates, one per column.
- `midyear`: Use the mid-year discounting convention. Defaults to `false`.
"""
function dcf_sensitivity(fcf::AbstractVector{<:Real}; waccs::AbstractVector{<:Real},
                         gs::AbstractVector{<:Real}, midyear::Bool = false)
    if any(.!isfinite.(waccs)) || any(.!isfinite.(gs))
        throw(ArgumentError("waccs and gs must contain finite numbers."))
    end
    T = float(promote_type(eltype(fcf), eltype(waccs), eltype(gs)))
    table = fill(T(NaN), length(waccs), length(gs))
    for (i, w) in enumerate(waccs), (j, g) in enumerate(gs)
        if w > g
            table[i, j] = dcf_valuation(fcf; wacc = w, g = g, midyear = midyear).enterprise_value
        end
    end
    return table
end

# -----------------------------
# Equity Value: from Enterprise Value
# -----------------------------
"""
    equity_value(; ev::Real, debt::Real, cash::Real = 0, minority_interest::Real = 0,
                 preferred::Real = 0, leases::Real = 0, non_operating::Real = 0)

Calculates the equity value from the enterprise value:
`ev - debt + cash - minority_interest - preferred - leases + non_operating`.

Only subtract `leases` (IFRS 16 lease liabilities) if the free cash flows were
calculated before lease payments; otherwise they would be counted twice.

# Keyword Arguments
- `ev`: Enterprise value.
- `debt`: Total financial debt.
- `cash`: Cash and equivalents.
- `minority_interest`: Non-controlling interests in consolidated subsidiaries.
- `preferred`: Preferred stock.
- `leases`: Lease liabilities.
- `non_operating`: Non-operating assets (e.g. investments not included in the cash flows).

All arguments except `ev` cannot be negative and, except `debt`, default to 0.
"""
function equity_value(; ev::Real, debt::Real, cash::Real = 0, minority_interest::Real = 0,
                      preferred::Real = 0, leases::Real = 0, non_operating::Real = 0)
    check_finite(ev = ev, debt = debt, cash = cash, minority_interest = minority_interest,
                 preferred = preferred, leases = leases, non_operating = non_operating)
    if any(<(0), (debt, cash, minority_interest, preferred, leases, non_operating))
        throw(ArgumentError("Debt, cash and the other adjustments cannot be negative."))
    end
    return ev - debt + cash - minority_interest - preferred - leases + non_operating
end
