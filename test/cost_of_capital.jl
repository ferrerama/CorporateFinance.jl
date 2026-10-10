@testset "Cost of capital" begin

    # -----------------------------
    # CAPM
    # -----------------------------
    @testset "capm" begin
        # Hand-calculated value: 0.04 + 1.2 * 0.055 + 0.02
        @test capm(rf=0.04, beta=1.2, erp=0.055, crp=0.02) ≈ 0.126

        # Without country risk premium it is the classic CAPM
        @test capm(rf=0.04, beta=1.0, erp=0.05, crp=0.0) ≈ 0.09

        # Beta = 0 returns the risk-free rate plus country risk
        @test capm(rf=0.04, beta=0.0, erp=0.05, crp=0.01) ≈ 0.05

        # Boundaries of the beta range are accepted
        @test capm(rf=0.04, beta=5.0, erp=0.05, crp=0.0) ≈ 0.29
        @test capm(rf=0.04, beta=-5.0, erp=0.05, crp=0.0) ≈ -0.21

        # Integer inputs
        @test capm(rf=0, beta=1, erp=0, crp=0) == 0

        # Invalid inputs
        @test_throws ArgumentError capm(rf=-0.01, beta=1.0, erp=0.05, crp=0.02)
        @test_throws ArgumentError capm(rf=0.04, beta=5.1, erp=0.05, crp=0.02)
        @test_throws ArgumentError capm(rf=0.04, beta=-5.1, erp=0.05, crp=0.02)
        @test_throws ArgumentError capm(rf=0.04, beta=1.0, erp=-0.05, crp=0.02)
        @test_throws ArgumentError capm(rf=0.04, beta=1.0, erp=0.05, crp=-0.02)
    end

    # -----------------------------
    # WACC
    # -----------------------------
    @testset "wacc" begin
        # Hand-calculated value: 0.8 * 0.126 + 0.2 * 0.06 * (1 - 0.30)
        @test wacc(ke=0.126, kd=0.06, tax=0.30, E=800.0, D=200.0) ≈ 0.1092

        # All equity: WACC equals the cost of equity
        @test wacc(ke=0.12, kd=0.06, tax=0.30, E=1000.0, D=0.0) ≈ 0.12

        # All debt: WACC equals the after-tax cost of debt
        @test wacc(ke=0.12, kd=0.06, tax=0.30, E=0.0, D=1000.0) ≈ 0.042

        # No taxes: simple weighted average
        @test wacc(ke=0.12, kd=0.06, tax=0.0, E=500.0, D=500.0) ≈ 0.09

        # Only the proportions matter, not the scale
        @test wacc(ke=0.12, kd=0.06, tax=0.30, E=8.0, D=2.0) ≈
              wacc(ke=0.12, kd=0.06, tax=0.30, E=8_000_000.0, D=2_000_000.0)

        # WACC lies between the after-tax cost of debt and the cost of equity
        w = wacc(ke=0.12, kd=0.06, tax=0.30, E=600.0, D=400.0)
        @test 0.06 * (1 - 0.30) < w < 0.12

        # Invalid inputs
        @test_throws ArgumentError wacc(ke=0.1, kd=0.05, tax=-0.1, E=100, D=200)
        @test_throws ArgumentError wacc(ke=0.1, kd=0.05, tax=1.5, E=100, D=200)
        @test_throws ArgumentError wacc(ke=0.1, kd=0.05, tax=0.3, E=-100, D=200)
        @test_throws ArgumentError wacc(ke=0.1, kd=0.05, tax=0.3, E=100, D=-200)
        @test_throws ArgumentError wacc(ke=0.1, kd=0.05, tax=0.3, E=0, D=0)
    end

    # -----------------------------
    # Beta Regression
    # -----------------------------
    @testset "beta_regression" begin
        market = [0.04, 0.01, 0.00, 0.03, 0.02, -0.01]

        # Asset moves exactly like the market: beta = 1
        @test beta_regression(market, market) ≈ 1.0

        # Asset moves twice the market: beta = 2
        @test beta_regression(2 .* market, market) ≈ 2.0

        # A constant spread over the market does not change beta
        @test beta_regression(market .+ 0.01, market) ≈ 1.0

        # Asset moves opposite to the market: beta = -1
        @test beta_regression(-market, market) ≈ -1.0

        # Hand-calculated value against cov / var
        asset = [0.05, 0.02, -0.01, 0.04, 0.03, 0.00]
        m = sum(market) / length(market)
        a = sum(asset) / length(asset)
        expected = sum((asset .- a) .* (market .- m)) / sum((market .- m) .^ 2)
        @test beta_regression(asset, market) ≈ expected

        # Invalid inputs
        @test_throws ArgumentError beta_regression([0.05, 0.02], [0.04])
        @test_throws ArgumentError beta_regression([0.05], [0.04])
        @test_throws ArgumentError beta_regression([0.05, NaN], [0.04, 0.01])
        @test_throws ArgumentError beta_regression([0.05, 0.02], [0.04, Inf])
        @test_throws ArgumentError beta_regression([0.05, 0.02, 0.01], [0.03, 0.03, 0.03])

        # Views and ranges are accepted, not only Vector
        @test beta_regression(view(2 .* market, 1:6), view(market, 1:6)) ≈ 2.0
        @test beta_regression(2.0:2.0:10.0, 1.0:5.0) ≈ 2.0
    end

    # -----------------------------
    # Unlevered and Relevered Beta (Hamada)
    # -----------------------------
    @testset "unlever_beta / relever_beta" begin
        # Hand-calculated value: 1.3 / (1 + 0.7 * 1)
        @test unlever_beta(beta=1.3, tax=0.30, E=500.0, D=500.0) ≈ 1.3 / 1.7

        # Hand-calculated value: 0.8 * (1 + 0.7 * 0.25)
        @test relever_beta(beta=0.8, tax=0.30, E=800.0, D=200.0) ≈ 0.94

        # No debt: levered and unlevered beta are the same
        @test unlever_beta(beta=1.2, tax=0.30, E=600.0, D=0.0) ≈ 1.2
        @test relever_beta(beta=1.2, tax=0.30, E=600.0, D=0.0) ≈ 1.2

        # Round trip with the same structure returns the original beta
        bu = unlever_beta(beta=1.2, tax=0.30, E=600.0, D=400.0)
        @test relever_beta(beta=bu, tax=0.30, E=600.0, D=400.0) ≈ 1.2

        # Unlevered beta is lower than levered beta when there is debt
        @test bu < 1.2

        # More debt means a higher levered beta
        @test relever_beta(beta=0.8, tax=0.30, E=500.0, D=500.0) >
              relever_beta(beta=0.8, tax=0.30, E=800.0, D=200.0)

        # Invalid inputs (both functions share the same validation)
        for f in (unlever_beta, relever_beta)
            @test_throws ArgumentError f(beta=1.2, tax=-0.1, E=600.0, D=400.0)
            @test_throws ArgumentError f(beta=1.2, tax=1.1, E=600.0, D=400.0)
            @test_throws ArgumentError f(beta=1.2, tax=0.30, E=0.0, D=400.0)
            @test_throws ArgumentError f(beta=1.2, tax=0.30, E=-600.0, D=400.0)
            @test_throws ArgumentError f(beta=1.2, tax=0.30, E=600.0, D=-400.0)
        end
    end
end
