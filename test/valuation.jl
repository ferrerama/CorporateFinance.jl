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

        # Invalid inputs
        @test_throws ArgumentError equity_value(ev=1000.0, debt=-1.0)
        @test_throws ArgumentError equity_value(ev=1000.0, debt=300.0, cash=-1.0)
    end
end
