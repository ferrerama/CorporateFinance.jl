# CorporateFinance.jl

[![docs dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://ferrerama.github.io/CorporateFinance.jl/dev/)
[![CI](https://github.com/ferrerama/CorporateFinance.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/ferrerama/CorporateFinance.jl/actions/workflows/CI.yml)
[![codecov](https://codecov.io/gh/ferrerama/CorporateFinance.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/ferrerama/CorporateFinance.jl)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Julia](https://img.shields.io/badge/Julia-1.10%2B-9558B2?logo=julia)](https://julialang.org)

A small Julia package for corporate valuation: from the cost of capital to the equity value of a company.

## Scope of CorporateFinance.jl

`CorporateFinance.jl` covers the main steps of a corporate valuation:

| Step | Functions |
|---|---|
| Cost of capital | `capm`, `wacc`, `beta_regression`, `unlever_beta`, `relever_beta` |
| Valuation | `perpetuity`, `terminal_value`, `dcf_valuation`, `equity_value` |

## Not covered by this package

Present value, NPV and IRR are provided by [FinanceCore.jl](https://github.com/JuliaActuary/FinanceCore.jl) (`pv`, `irr`).

Payback is provided by [ActuaryUtilities.jl](https://github.com/JuliaActuary/ActuaryUtilities.jl) (`breakeven`).

This package does not attempt to model market microstructure, portfolio optimization, or derivatives pricing — for that, see packages like [FinanceModels.jl](https://github.com/JuliaActuary/FinanceModels.jl) or [InterestRates.jl](https://github.com/felipenoris/InterestRates.jl).

## Installation

Once registered in the General registry, install it from the Julia REPL by entering package mode (press `]`):

```julia
pkg> add CorporateFinance
```

Alternatively, before registration completes (or to track the latest development version), install it directly from GitHub:

```julia
using Pkg
Pkg.add(url="https://github.com/ferrerama/CorporateFinance.jl")
```

## Quick example

```julia
using CorporateFinance

# --- Beta: unlever a comparable company, relever to the target structure ---
bu = unlever_beta(beta = 1.3, tax = 0.30, E = 500_000, D = 500_000)
bl = relever_beta(beta = bu, tax = 0.30, E = 800_000, D = 200_000)

# --- Cost of equity (CAPM), including a country risk premium ---
ke = capm(rf = 0.04, beta = bl, erp = 0.055, crp = 0.02)

# --- Weighted Average Cost of Capital ---
w = wacc(ke = ke, kd = 0.06, tax = 0.30, E = 800_000, D = 200_000)

# --- DCF: forecast free cash flows + terminal value (2% growth) ---
fcf = [120_000, 135_000, 150_000, 160_000, 170_000]
r = dcf_valuation(fcf; wacc = w, g = 0.02)
r.enterprise_value

# --- Equity value ---
equity = equity_value(ev = r.enterprise_value, debt = 200_000, cash = 30_000)
```

## Running the tests

```julia
using Pkg
Pkg.activate(".")
Pkg.test()
```

## Contributing

Issues and pull requests are welcome — for example, a bug fix or an improvement to input validation. Please include a test for any new function in `test/runtests.jl`.

## License

CorporateFinance.jl is licensed under the [MIT License](LICENSE).
