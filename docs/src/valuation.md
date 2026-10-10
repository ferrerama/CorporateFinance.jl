# Valuation

## Perpetuity

```math
PV = \frac{CF}{r}
```

```@docs
perpetuity
```

## Terminal value

Gordon growth model, applied to the free cash flow of the last forecast year:

```math
TV_n = \frac{FCF_n\,(1 + g)}{WACC - g}
```

```@docs
terminal_value
```

## Fade stage

A transition stage between the explicit forecast and the terminal value, in
which growth declines from ``g_0`` to ``g`` in linear increments over ``m``
years, reaching ``g`` in the last year of the stage:

```math
g_k = g_0 + (g - g_0)\,\frac{k}{m}, \qquad
FCF_{n+k} = FCF_{n+k-1}\,(1 + g_k), \qquad k = 1, \dots, m
```

```@docs
fade_forecast
```

## DCF valuation

The forecast free cash flows plus the terminal value, either with Gordon growth
or with an exit multiple:

```math
EV = \sum_{t=1}^{n} \frac{FCF_t}{(1 + WACC)^t} + \frac{TV_n}{(1 + WACC)^n},
\qquad TV_n = \text{Multiple} \times \text{EBITDA}_n \;\text{(exit multiple)}
```

With the mid-year convention the exponents become ``t - 0.5`` (and ``n - 0.5``
for a Gordon terminal value).

```@docs
dcf_valuation
```

## Sensitivity table

```@docs
dcf_sensitivity
```

## Equity value

```math
\text{Equity} = EV - \text{Debt} + \text{Cash} - \text{Minority interest}
- \text{Preferred} - \text{Leases} + \text{Non-operating assets}
```

```@docs
equity_value
```
