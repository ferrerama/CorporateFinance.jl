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

## DCF valuation

Two stages: the forecast free cash flows and the terminal value.

```math
EV = \sum_{t=1}^{n} \frac{FCF_t}{(1 + WACC)^t} + \frac{TV_n}{(1 + WACC)^n}
```

```@docs
dcf_valuation
```

## Equity value

```math
\text{Equity} = EV - \text{Debt} + \text{Cash}
```

```@docs
equity_value
```
