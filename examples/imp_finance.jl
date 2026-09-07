# Imp_finance.jl
# -------------------------------------------------------------
# Local script for the CorporateFinance suite
# -------------------------------------------------------------

using CorporateFinance

println("🚀 Starting corporate finance ...")

# 1. CAPM: Cost of Equity
risk_free_rate = 0.045   # 4.5% (rf)
industry_beta  = 1.15    # Levered industry beta
market_premium = 0.060   # 6.0% (erp)
country_risk   = 0.020   # 2.0% (crp)

equity_cost = capm(
    rf   = risk_free_rate, 
    beta = industry_beta, 
    erp  = market_premium, 
    crp  = country_risk
)
println("-> Cost of Equity (CAPM): ", round(equity_cost * 100, digits=2), "%")

# 2. WACC: Weighted Average Cost of Capital
debt_cost   = 0.070      # 7.0% (kd)
tax_rate    = 0.30       # 30% (tax)
equity_val  = 600_000.0  # Equity (E)
debt_val    = 400_000.0  # Debt (D)

wacc_cost = wacc(
    ke  = equity_cost, 
    kd  = debt_cost, 
    tax = tax_rate, 
    E   = equity_val, 
    D   = debt_val
)
println("-> Weighted Average Cost of Capital (WACC): ", round(wacc_cost * 100, digits=2), "%")

# 3. DCF: Discounted Cash Flow valuation
cash_flows = [150000.0, 180000.0, 210000.0, 240000.0, 300000.0]
total_present_value = dcf_value(cash_flows, wacc_cost)
println("-> Project Present Value (DCF): \$", round(total_present_value, digits=2))

# 4. NPV: Net Present Value
npv_val = npv(cash_flows, 0.08; initial_investment=500000.0)
println("-> Net Present Value (NPV): \$", round(npv_val, digits=2))

# 5. IRR: Internal Rate of Return
irr_flows = [400.0, 400.0, 400.0]
irr_val = irr(irr_flows; initial_investment=1000.0)
println("-> Internal Rate of Return (IRR): ", round(irr_val * 100, digits=2), "%")

# 6. Payback Period
pb_flows = [200.0, 300.0, 600.0]
pb_period = payback(pb_flows, 500.0)
println("-> Payback Period: ", pb_period, " years")

# 7. Perpetuity
perp_val = perpetuity(100.0, 0.05)
println("-> Perpetuity Value: \$", perp_val)

