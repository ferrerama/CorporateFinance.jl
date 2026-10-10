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

Hamada equation, extended with an optional debt beta ``\beta_D`` (Conine).
With ``\beta_D = 0`` (the default) it reduces to the classic Hamada formula.

```math
k = (1 - t)\, D/E
\qquad
\beta_U = \frac{\beta_L + \beta_D\, k}{1 + k}
\qquad
\beta_L = \beta_U + (\beta_U - \beta_D)\, k
```

```@docs
unlever_beta
relever_beta
```
