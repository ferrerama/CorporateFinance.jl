@testset "Valuation" begin

    # -----------------------------
    # Perpetuity
    # -----------------------------
    @testset "perpetuity" begin
        @test perpetuity(100.0, 0.05) ≈ 2000.0
        @test perpetuity(50_000, 0.08) ≈ 625_000.0

        # Higher rate means lower value
        @test perpetuity(100.0, 0.10) < perpetuity(100.0, 0.05)

        # Invalid inputs
        @test_throws ArgumentError perpetuity(100.0, 0.0)
        @test_throws ArgumentError perpetuity(100.0, -0.05)
    end

    # -----------------------------
    # Terminal Value (Gordon Growth)
    # -----------------------------
    @testset "terminal_value" begin
        # Hand-calculated value: 100 * 1.02 / 0.08
        @test terminal_value(fcf=100.0, wacc=0.10, g=0.02) ≈ 1275.0

        # With zero growth it is a perpetuity of the same cash flow
        @test terminal_value(fcf=100.0, wacc=0.10, g=0.0) ≈ perpetuity(100.0, 0.10)

        # Negative growth is accepted
        @test terminal_value(fcf=100.0, wacc=0.10, g=-0.02) ≈ 100.0 * 0.98 / 0.12

        # Higher growth means higher value
        @test terminal_value(fcf=100.0, wacc=0.10, g=0.03) >
              terminal_value(fcf=100.0, wacc=0.10, g=0.02)

        # Invalid inputs (wacc must be greater than g)
        @test_throws ArgumentError terminal_value(fcf=100.0, wacc=0.02, g=0.02)
        @test_throws ArgumentError terminal_value(fcf=100.0, wacc=0.02, g=0.05)
    end

    # -----------------------------
    # DCF Valuation
    # -----------------------------
    @testset "dcf_valuation" begin
        fcf = [100.0, 110.0, 120.0]
        r = dcf_valuation(fcf; wacc=0.10, g=0.02)

        # Each part against the hand-calculated formula
        @test r.pv_fcf ≈ 100/1.1 + 110/1.1^2 + 120/1.1^3
        @test r.pv_terminal ≈ (120 * 1.02 / 0.08) / 1.1^3
        @test r.enterprise_value ≈ r.pv_fcf + r.pv_terminal

        # Result fields
        @test keys(r) == (:pv_fcf, :pv_terminal, :enterprise_value)

        # Single forecast year
        r1 = dcf_valuation([100.0]; wacc=0.10, g=0.02)
        @test r1.enterprise_value ≈ 100/1.1 + (100 * 1.02 / 0.08) / 1.1

        # Cash flows already growing at g: the whole value is a Gordon
        # perpetuity of the first cash flow, whatever the forecast length
        w, g = 0.09, 0.03
        for n in (1, 5, 10)
            growing = [100.0 * (1 + g)^(t - 1) for t in 1:n]
            @test dcf_valuation(growing; wacc=w, g=g).enterprise_value ≈ 100.0 / (w - g)
        end

        # Higher WACC means lower value
        @test dcf_valuation(fcf; wacc=0.12, g=0.02).enterprise_value <
              r.enterprise_value

        # Integer cash flows
        @test dcf_valuation([100, 110, 120]; wacc=0.10, g=0.02).enterprise_value ≈
              r.enterprise_value

        # Invalid inputs
        @test_throws ArgumentError dcf_valuation(Float64[]; wacc=0.10, g=0.02)
        @test_throws ArgumentError dcf_valuation([100.0, NaN]; wacc=0.10, g=0.02)
        @test_throws ArgumentError dcf_valuation([100.0, Inf]; wacc=0.10, g=0.02)
        @test_throws ArgumentError dcf_valuation(fcf; wacc=0.02, g=0.02)
        @test_throws ArgumentError dcf_valuation(fcf; wacc=-1.0, exit_multiple=8.0, ebitda=200.0)
    end

    # -----------------------------
    # DCF: mid-year convention
    # -----------------------------
    @testset "dcf_valuation midyear" begin
        fcf = [100.0, 110.0, 120.0]
        r = dcf_valuation(fcf; wacc=0.10, g=0.02, midyear=true)

        # Cash flows and Gordon terminal value discounted half a year earlier
        @test r.pv_fcf ≈ 100/1.1^0.5 + 110/1.1^1.5 + 120/1.1^2.5
        @test r.pv_terminal ≈ (120 * 1.02 / 0.08) / 1.1^2.5

        # The whole value is the year-end value grown by half a year
        @test r.enterprise_value ≈
              dcf_valuation(fcf; wacc=0.10, g=0.02).enterprise_value * 1.1^0.5

        # Exit-multiple terminal value is not shifted
        m = dcf_valuation(fcf; wacc=0.10, exit_multiple=8.0, ebitda=200.0, midyear=true)
        @test m.pv_terminal ≈ 1600 / 1.1^3

        # Default is year-end discounting
        @test dcf_valuation(fcf; wacc=0.10, g=0.02, midyear=false) ==
              dcf_valuation(fcf; wacc=0.10, g=0.02)
    end

    # -----------------------------
    # DCF: exit multiple
    # -----------------------------
    @testset "dcf_valuation exit multiple" begin
        fcf = [100.0, 110.0, 120.0]
        r = dcf_valuation(fcf; wacc=0.10, exit_multiple=8.0, ebitda=200.0)

        @test r.pv_fcf ≈ dcf_valuation(fcf; wacc=0.10, g=0.02).pv_fcf
        @test r.pv_terminal ≈ 8 * 200 / 1.1^3
        @test r.enterprise_value ≈ r.pv_fcf + r.pv_terminal

        # The multiple does not need wacc > g
        @test dcf_valuation(fcf; wacc=0.0, exit_multiple=8.0, ebitda=200.0).enterprise_value ≈
              330 + 1600

        # Invalid combinations
        @test_throws ArgumentError dcf_valuation(fcf; wacc=0.10)
        @test_throws ArgumentError dcf_valuation(fcf; wacc=0.10, g=0.02, exit_multiple=8.0, ebitda=200.0)
        @test_throws ArgumentError dcf_valuation(fcf; wacc=0.10, exit_multiple=8.0)
        @test_throws ArgumentError dcf_valuation(fcf; wacc=0.10, g=0.02, ebitda=200.0)
        @test_throws ArgumentError dcf_valuation(fcf; wacc=0.10, exit_multiple=-1.0, ebitda=200.0)
        @test_throws ArgumentError dcf_valuation(fcf; wacc=0.10, exit_multiple=NaN, ebitda=200.0)
    end

    # -----------------------------
    # Fade stage
    # -----------------------------
    @testset "fade_forecast" begin
        # From 30% down to 5% in linear increments: 25%, 20%, 15%, 10%, 5%
        f = fade_forecast(fcf=100.0, g_start=0.30, g=0.05, years=5)
        @test f ≈ 100.0 .* cumprod([1.25, 1.20, 1.15, 1.10, 1.05])

        # Growth of the last year of the stage is exactly g
        @test f[end] / f[end-1] ≈ 1.05

        # One year: the stage grows directly at g
        @test fade_forecast(fcf=100.0, g_start=0.10, g=0.02, years=1) ≈ [102.0]

        # If g_start equals g the stage is plain Gordon growth
        @test fade_forecast(fcf=100.0, g_start=0.02, g=0.02, years=4) ≈
              [100.0 * 1.02^t for t in 1:4]

        # Three-stage DCF: forecast + fade + Gordon
        fcf = [100.0, 110.0, 120.0]
        r3 = dcf_valuation(vcat(fcf, fade_forecast(fcf=120.0, g_start=0.08, g=0.02, years=5));
                           wacc=0.10, g=0.02)
        @test r3.enterprise_value > dcf_valuation(fcf; wacc=0.10, g=0.02).enterprise_value

        # Invalid inputs
        @test_throws ArgumentError fade_forecast(fcf=100.0, g_start=0.08, g=0.02, years=0)
        @test_throws ArgumentError fade_forecast(fcf=NaN, g_start=0.08, g=0.02, years=3)
    end

    # -----------------------------
    # Sensitivity WACC × g
    # -----------------------------
    @testset "dcf_sensitivity" begin
        fcf = [100.0, 110.0, 120.0]
        waccs = [0.08, 0.10, 0.12]
        gs = [0.01, 0.02, 0.03]
        s = dcf_sensitivity(fcf; waccs=waccs, gs=gs)

        @test size(s) == (3, 3)
        @test s[2, 2] ≈ dcf_valuation(fcf; wacc=0.10, g=0.02).enterprise_value
        @test s[3, 1] ≈ dcf_valuation(fcf; wacc=0.12, g=0.01).enterprise_value

        # Value falls with WACC and rises with g
        @test all(diff(s, dims=1) .< 0)
        @test all(diff(s, dims=2) .> 0)

        # Mid-year option is passed through
        @test dcf_sensitivity(fcf; waccs=[0.10], gs=[0.02], midyear=true)[1, 1] ≈
              dcf_valuation(fcf; wacc=0.10, g=0.02, midyear=true).enterprise_value

        # Invalid cells are NaN, the rest is still computed
        t = dcf_sensitivity(fcf; waccs=[0.02, 0.10], gs=[0.02, 0.03])
        @test isnan(t[1, 1]) && isnan(t[1, 2])
        @test !any(isnan, t[2, :])

        # Float32 in, Float32 out
        @test dcf_sensitivity(Float32[100, 110]; waccs=[0.1f0], gs=[0.02f0]) isa Matrix{Float32}

        # Cash flows are validated even if no cell is valid
        @test_throws ArgumentError dcf_sensitivity(Float64[]; waccs=[0.02], gs=[0.03])
        @test_throws ArgumentError dcf_sensitivity([100.0, NaN]; waccs=[0.02], gs=[0.03])

        @test_throws ArgumentError dcf_sensitivity(fcf; waccs=[NaN], gs=gs)
        @test_throws ArgumentError dcf_sensitivity(fcf; waccs=waccs, gs=[Inf])
    end

    # -----------------------------
    # Equity Value
    # -----------------------------
    @testset "equity_value" begin
        @test equity_value(ev=1000.0, debt=300.0, cash=50.0) ≈ 750.0

        # Cash defaults to zero
        @test equity_value(ev=1000.0, debt=300.0) ≈ 700.0

        # Debt larger than enterprise value gives negative equity
        @test equity_value(ev=100.0, debt=300.0) ≈ -200.0

        # Full chain: DCF result into equity value
        r = dcf_valuation([100.0, 110.0, 120.0]; wacc=0.10, g=0.02)
        @test equity_value(ev=r.enterprise_value, debt=200.0, cash=20.0) ≈
              r.enterprise_value - 180.0

        # Full bridge: 1000 - 300 + 50 - 40 - 30 - 60 + 25
        @test equity_value(ev=1000.0, debt=300.0, cash=50.0, minority_interest=40.0,
                           preferred=30.0, leases=60.0, non_operating=25.0) ≈ 645.0

        # Invalid inputs
        @test_throws ArgumentError equity_value(ev=1000.0, debt=-1.0)
        @test_throws ArgumentError equity_value(ev=1000.0, debt=300.0, cash=-1.0)
        for kw in (:minority_interest, :preferred, :leases, :non_operating)
            @test_throws ArgumentError equity_value(; ev=1000.0, debt=300.0, kw => -1.0)
            @test_throws ArgumentError equity_value(; ev=1000.0, debt=300.0, kw => NaN)
        end
    end
end
