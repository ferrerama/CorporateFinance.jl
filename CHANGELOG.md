# Changelog

All notable changes to CorporateFinance.jl are documented in this file.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [0.1.0] - 2026-10-11

First tagged release.

### Added

- Cost of capital: `capm` (with country risk premium), `wacc`, `beta_regression`, `unlever_beta` and `relever_beta`.
- Valuation: `perpetuity`, `terminal_value`, `fade_forecast`, `dcf_valuation` (Gordon growth or exit multiple, optional mid-year convention), `dcf_sensitivity` (WACC × g table) and `equity_value` (bridge from enterprise value to equity value).
- Input validation with `ArgumentError`, including rejection of `NaN` and `Inf`.

### Notes

- Development versions before this release also had `npv`, `irr`, `payback` and `dcf_value`.
  They were removed because present value, NPV and IRR are provided by [FinanceCore.jl](https://github.com/JuliaActuary/FinanceCore.jl) and payback by [ActuaryUtilities.jl](https://github.com/JuliaActuary/ActuaryUtilities.jl).

[Unreleased]: https://github.com/ferrerama/CorporateFinance.jl/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/ferrerama/CorporateFinance.jl/releases/tag/v0.1.0
