# Cost of capital

## CAPM

```math
k_e = r_f + \beta \cdot ERP + CRP
```

```@docs
capm
```

## WACC

```math
WACC = \frac{E}{E + D}\, k_e + \frac{D}{E + D}\, k_d\, (1 - t)
```

```@docs
wacc
```

## Beta regression

```math
\beta = \frac{\operatorname{cov}(r_a, r_m)}{\operatorname{var}(r_m)}
```

```@docs
beta_regression
```

## Unlevered and relevered beta

Hamada equation:

```math
\beta_U = \frac{\beta_L}{1 + (1 - t)\, D/E}
\qquad
\beta_L = \beta_U \left[ 1 + (1 - t)\, D/E \right]
```

```@docs
unlever_beta
relever_beta
```
