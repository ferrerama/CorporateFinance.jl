@testset "Reversibility" begin

    # Every result must lead back to the original input.

    # -----------------------------
    # Cost of capital
    # -----------------------------
    @testset "capm" begin
        # Cost of equity -> beta
        ke = capm(rf=0.035, beta=1.15, erp=0.055, crp=0.012)
        @test (ke - 0.035 - 0.012) / 0.055 ≈ 1.15

        # Also with a negative risk-free rate
        ke = capm(rf=-0.004, beta=0.85, erp=0.06, crp=0.0)
        @test (ke + 0.004) / 0.06 ≈ 0.85
    end

    @testset "wacc" begin
        # WACC -> cost of equity
        E, D, kd, tax = 700.0, 300.0, 0.065, 0.25
        w = wacc(ke=0.118, kd=kd, tax=tax, E=E, D=D)
        @test (w - D / (E + D) * kd * (1 - tax)) * (E + D) / E ≈ 0.118
    end

    @testset "beta_regression" begin
        # Returns built from a known beta -> the same beta
        market = [0.031, -0.012, 0.007, 0.024, -0.018, 0.015, 0.002]
        @test beta_regression(0.003 .+ 1.37 .* market, market) ≈ 1.37
    end

    @testset "unlever_beta / relever_beta" begin
        for beta_debt in (0.0, 0.25)
            # Levered -> unlevered -> levered
            bu = unlever_beta(beta=1.35, tax=0.28, E=650.0, D=350.0, beta_debt=beta_debt)
            @test relever_beta(beta=bu, tax=0.28, E=650.0, D=350.0, beta_debt=beta_debt) ≈ 1.35

            # Unlevered -> levered -> unlevered
            bl = relever_beta(beta=0.82, tax=0.28, E=650.0, D=350.0, beta_debt=beta_debt)
            @test unlever_beta(beta=bl, tax=0.28, E=650.0, D=350.0, beta_debt=beta_debt) ≈ 0.82
        end
    end

    # -----------------------------
    # Valuation
    # -----------------------------
    @testset "perpetuity" begin
        # Present value -> cash flow
        @test perpetuity(130.0, 0.085) * 0.085 ≈ 130.0
    end

    @testset "terminal_value" begin
        # Terminal value -> growth rate: g = (TV * wacc - fcf) / (TV + fcf)
        tv = terminal_value(fcf=140.0, wacc=0.095, g=0.025)
        @test (tv * 0.095 - 140.0) / (tv + 140.0) ≈ 0.025
    end

    @testset "fade_forecast" begin
        # Cash flows -> growth rates and starting cash flow
        f = fade_forecast(fcf=120.0, g_start=0.18, g=0.03, years=5)
        growth = f ./ vcat(120.0, f[1:end-1]) .- 1
        @test growth ≈ [0.18 + (0.03 - 0.18) * k / 5 for k in 1:5]
        @test f[1] / (1 + growth[1]) ≈ 120.0
    end

    @testset "dcf_valuation" begin
        fcf = [95.0, 104.0, 118.0, 126.0]
        n = length(fcf)
        w = 0.092

        # Gordon: compounding the value forward rebuilds the cash flows and terminal value
        r = dcf_valuation(fcf; wacc=w, g=0.022)
        tv = terminal_value(fcf=fcf[end], wacc=w, g=0.022)
        @test r.enterprise_value * (1 + w)^n ≈ sum(fcf .* (1 + w) .^ (n .- (1:n))) + tv
        @test r.pv_terminal * (1 + w)^n ≈ tv

        # Mid-year: the same, half a year earlier
        m = dcf_valuation(fcf; wacc=w, g=0.022, midyear=true)
        @test m.enterprise_value * (1 + w)^(n - 0.5) ≈ sum(fcf .* (1 + w) .^ (n .- (1:n))) + tv

        # Exit multiple: discounted terminal value -> multiple
        x = dcf_valuation(fcf; wacc=w, exit_multiple=7.5, ebitda=210.0)
        @test x.pv_terminal * (1 + w)^n / 210.0 ≈ 7.5
    end

    @testset "dcf_sensitivity" begin
        # Each cell -> the growth rate of its column
        fcf = [95.0, 104.0, 118.0, 126.0]
        n = length(fcf)
        w = 0.092
        gs = [0.01, 0.02, 0.03]
        s = dcf_sensitivity(fcf; waccs=[w], gs=gs)
        pv_fcf = dcf_valuation(fcf; wacc=w, g=0.02).pv_fcf
        for (j, g) in enumerate(gs)
            tv = (s[1, j] - pv_fcf) * (1 + w)^n
            @test (tv * w - fcf[end]) / (tv + fcf[end]) ≈ g
        end
    end

    @testset "equity_value" begin
        # Equity value -> enterprise value
        eq = equity_value(ev=1500.0, debt=420.0, cash=80.0, minority_interest=35.0,
                          preferred=20.0, leases=90.0, non_operating=45.0)
        @test eq + 420.0 - 80.0 + 35.0 + 20.0 + 90.0 - 45.0 ≈ 1500.0
    end
end
