# CorporateFinance.jl

A Julia package for corporate valuation: from the cost of capital to the
equity value of a company.

| Step | Functions |
|---|---|
| [Cost of capital](@ref) | [`capm`](@ref), [`wacc`](@ref), [`beta_regression`](@ref), [`unlever_beta`](@ref), [`relever_beta`](@ref) |
| [Valuation](@ref) | [`perpetuity`](@ref), [`terminal_value`](@ref), [`fade_forecast`](@ref), [`dcf_valuation`](@ref), [`dcf_sensitivity`](@ref), [`equity_value`](@ref) |

## Installation

```julia
using Pkg
Pkg.add(url = "https://github.com/ferrerama/CorporateFinance.jl")
```

## Example: from beta to equity value

The example below runs when the documentation is built, so the results shown
are produced by the package itself.

```@example walkthrough
using CorporateFinance

# Beta: unlever a comparable company, relever to the target structure
bu = unlever_beta(beta = 1.3, tax = 0.30, E = 500_000, D = 500_000)
bl = relever_beta(beta = bu, tax = 0.30, E = 800_000, D = 200_000)
```

```@example walkthrough
# Cost of equity (CAPM), including a country risk premium
ke = capm(rf = 0.04, beta = bl, erp = 0.055, crp = 0.02)
```

```@example walkthrough
# Weighted Average Cost of Capital
w = wacc(ke = ke, kd = 0.06, tax = 0.30, E = 800_000, D = 200_000)
```

```@example walkthrough
# DCF: forecast free cash flows + terminal value with 2% growth
fcf = [120_000, 135_000, 150_000, 160_000, 170_000]
r = dcf_valuation(fcf; wacc = w, g = 0.02)
```

```@example walkthrough
# Sensitivity table: WACC (rows) × g (columns)
dcf_sensitivity(fcf; waccs = [0.09, 0.10, 0.11], gs = [0.015, 0.02, 0.025])
```

```@example walkthrough
# Equity value
equity_value(ev = r.enterprise_value, debt = 200_000, cash = 30_000)
```

## Not covered by this package

Present value, NPV, IRR and payback are already provided by
[FinanceCore.jl](https://github.com/JuliaActuary/FinanceCore.jl)
(`pv`, `irr`) and
[ActuaryUtilities.jl](https://github.com/JuliaActuary/ActuaryUtilities.jl)
(`breakeven`).
