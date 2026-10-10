using Test
using CorporateFinance

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
end