# CorporateFinance.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Julia](https://img.shields.io/badge/Julia-1.10%2B-9558B2?logo=julia)](https://julialang.org)

A small Julia package for cost of capital calculations used in corporate valuation: CAPM, WACC, beta and perpetuity value.

## Scope of CorporateFinance.jl

`CorporateFinance.jl` covers the inputs commonly used in corporate finance coursework and practice: the cost of equity, the cost of capital, beta and the value of a perpetuity.

## Not covered by this package

This package does not cover functions such as DCF, NPV, IRR or payback, because existing Julia packages already provide them:

| Function | Use | Package |
|---|---|---|
| DCF / present value | `pv(rate, cashflows)` | [FinanceCore.jl](https://github.com/JuliaActuary/FinanceCore.jl) |
| NPV | `pv(rate, cashflows)` | [FinanceCore.jl](https://github.com/JuliaActuary/FinanceCore.jl) |
| IRR | `irr(cashflows)` | [FinanceCore.jl](https://github.com/JuliaActuary/FinanceCore.jl) |
| Payback | `breakeven(rate, cashflows, times)` | [ActuaryUtilities.jl](https://github.com/JuliaActuary/ActuaryUtilities.jl) |

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

# --- Cost of equity (CAPM), including a country risk premium ---
ke = capm(rf = 0.04, beta = 1.2, erp = 0.055, crp = 0.02)

# --- Weighted Average Cost of Capital ---
w = wacc(ke = ke, kd = 0.06, tax = 0.30, E = 800_000, D = 200_000)

# --- Beta from asset and market returns ---
b = beta_regression([0.05, 0.02, -0.01, 0.04], [0.04, 0.01, 0.00, 0.03])

# --- Value a perpetual cash flow ---
value = perpetuity(50_000, 0.08)
```

To discount cash flows with the WACC, use FinanceCore.jl:

```julia
using FinanceCore
value = pv(w, [120_000, 135_000, 150_000, 160_000, 500_000])
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
