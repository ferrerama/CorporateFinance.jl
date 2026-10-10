using Test
using CorporateFinance
using Aqua

@testset "Aqua" begin
    Aqua.test_all(CorporateFinance)
end

@testset "CorporateFinance Tests" begin
    # CAPM valid
    @test capm(rf=0.045, beta=1.15, erp=0.060, crp=0.020) ≈ 0.045 + 1.15*0.060 + 0.020

    # CAPM invalid (negative rf)
    @test_throws ErrorException capm(rf=-0.01, beta=1.0, erp=0.05, crp=0.02)

    # WACC valid
    ke = capm(rf=0.045, beta=1.15, erp=0.060, crp=0.020)
    @test wacc(ke=ke, kd=0.070, tax=0.30, E=600_000.0, D=400_000.0) ≈
          (600_000/(600_000+400_000))*ke + (400_000/(600_000+400_000))*0.070*(1-0.30)

    # WACC invalid (tax out of range)
    @test_throws ErrorException wacc(ke=0.1, kd=0.05, tax=1.5, E=100, D=200)

    # Beta Regression valid
    asset_returns  = [0.05, 0.02, -0.01, 0.04, 0.03]
    market_returns = [0.04, 0.01, 0.00, 0.03, 0.02]
    beta_calc = beta_regression(asset_returns, market_returns)
    @test isa(beta_calc, Real)

    # Beta Regression invalid (different lengths)
    @test_throws ErrorException beta_regression([0.05, 0.02], [0.04])

    # Perpetuity valid
    @test perpetuity(100.0, 0.05) ≈ 2000.0

    # Perpetuity invalid (rate <= 0)
    @test_throws ErrorException perpetuity(100.0, 0.0)

    # Unlever / relever beta (Hamada)
    bu = unlever_beta(beta=1.2, tax=0.30, E=600.0, D=400.0)
    @test bu ≈ 1.2 / (1 + 0.70 * 400 / 600)
    @test relever_beta(beta=bu, tax=0.30, E=600.0, D=400.0) ≈ 1.2
    @test relever_beta(beta=bu, tax=0.30, E=600.0, D=0.0) ≈ bu

    # Unlever beta invalid (equity must be positive)
    @test_throws ErrorException unlever_beta(beta=1.2, tax=0.30, E=0.0, D=400.0)

    # Terminal value (Gordon growth)
    @test terminal_value(fcf=100.0, wacc=0.10, g=0.02) ≈ 100.0 * 1.02 / 0.08

    # Terminal value invalid (wacc <= g)
    @test_throws ErrorException terminal_value(fcf=100.0, wacc=0.02, g=0.02)

    # DCF valuation: forecast + terminal value
    fcf = [100.0, 110.0, 120.0]
    r = dcf_valuation(fcf; wacc=0.10, g=0.02)
    @test r.pv_fcf ≈ 100/1.1 + 110/1.1^2 + 120/1.1^3
    @test r.pv_terminal ≈ (120 * 1.02 / 0.08) / 1.1^3
    @test r.enterprise_value ≈ r.pv_fcf + r.pv_terminal

    # DCF valuation invalid (empty cash flows)
    @test_throws ErrorException dcf_valuation(Float64[]; wacc=0.10, g=0.02)

    # Equity value
    @test equity_value(ev=1000.0, debt=300.0, cash=50.0) ≈ 750.0
    @test_throws ErrorException equity_value(ev=1000.0, debt=-1.0)
end