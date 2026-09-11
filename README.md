# CorporateFinance.jl

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Julia](https://img.shields.io/badge/Julia-1.10%2B-9558B2?logo=julia)](https://julialang.org)

An open-source, lightweight Corporate Finance toolkit for Julia — cost of capital, discounted cash flow valuation, and investment appraisal, built directly on Julia's `LinearAlgebra` and `Statistics` standard libraries.

## Scope of CorporateFinance.jl

`CorporateFinance.jl` provides straightforward implementations of the calculations most commonly used in corporate finance coursework and practice: estimating the cost of equity and capital, discounting cash flows, and evaluating investment projects.

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

# --- Value a project via discounted free cash flows ---
fcf = [120_000, 135_000, 150_000, 160_000, 500_000]  # last year includes terminal value
value = dcf_value(fcf, w)

# --- Appraise an investment: NPV, IRR, and payback period ---
investment = 400_000
cashflows  = [90_000, 110_000, 125_000, 135_000, 160_000]

npv_result      = npv(cashflows, w; initial_investment = investment)
irr_result      = irr(cashflows; initial_investment = investment)
payback_result  = payback(cashflows, investment)

# --- Value a perpetual cash flow ---
pv = perpetuity(50_000, 0.08)
```

## Running the tests

```julia
using Pkg
Pkg.activate(".")
Pkg.test()
```

## Contributing

Issues and pull requests are welcome — whether it's a bug fix, a new valuation method, or an improvement to input validation. Please include a test for any new function in `test/runtests.jl`.

## License

CorporateFinance.jl is licensed under the [MIT License](LICENSE).
