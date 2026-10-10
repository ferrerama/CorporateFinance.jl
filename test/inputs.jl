@testset "Inputs" begin

    # -----------------------------
    # NaN and Inf are rejected in every function
    # -----------------------------
    @testset "non-finite inputs" begin
        for bad in (NaN, Inf, -Inf)
            @test_throws ArgumentError capm(rf=bad, beta=1.0, erp=0.05, crp=0.0)
            @test_throws ArgumentError capm(rf=0.04, beta=bad, erp=0.05, crp=0.0)
            @test_throws ArgumentError capm(rf=0.04, beta=1.0, erp=bad, crp=0.0)
            @test_throws ArgumentError capm(rf=0.04, beta=1.0, erp=0.05, crp=bad)

            @test_throws ArgumentError wacc(ke=bad, kd=0.06, tax=0.3, E=800.0, D=200.0)
            @test_throws ArgumentError wacc(ke=0.12, kd=bad, tax=0.3, E=800.0, D=200.0)
            @test_throws ArgumentError wacc(ke=0.12, kd=0.06, tax=bad, E=800.0, D=200.0)
            @test_throws ArgumentError wacc(ke=0.12, kd=0.06, tax=0.3, E=bad, D=200.0)
            @test_throws ArgumentError wacc(ke=0.12, kd=0.06, tax=0.3, E=800.0, D=bad)

            @test_throws ArgumentError unlever_beta(beta=bad, tax=0.3, E=600.0, D=400.0)
            @test_throws ArgumentError relever_beta(beta=bad, tax=0.3, E=600.0, D=400.0)

            @test_throws ArgumentError perpetuity(bad, 0.05)
            @test_throws ArgumentError perpetuity(100.0, bad)

            @test_throws ArgumentError terminal_value(fcf=bad, wacc=0.10, g=0.02)
            @test_throws ArgumentError terminal_value(fcf=100.0, wacc=bad, g=0.02)
            @test_throws ArgumentError terminal_value(fcf=100.0, wacc=0.10, g=bad)

            @test_throws ArgumentError dcf_valuation([100.0]; wacc=bad, g=0.02)
            @test_throws ArgumentError dcf_valuation([100.0]; wacc=0.10, g=bad)

            @test_throws ArgumentError equity_value(ev=bad, debt=300.0)
            @test_throws ArgumentError equity_value(ev=1000.0, debt=bad)
            @test_throws ArgumentError equity_value(ev=1000.0, debt=300.0, cash=bad)
        end
    end

    # -----------------------------
    # Generic number types: results keep the input precision
    # -----------------------------
    @testset "number types" begin
        # Float32 in, Float32 out
        @test capm(rf=0.04f0, beta=1.2f0, erp=0.055f0, crp=0.02f0) isa Float32
        @test wacc(ke=0.12f0, kd=0.06f0, tax=0.3f0, E=800f0, D=200f0) isa Float32

        # BigFloat keeps high precision
        @test terminal_value(fcf=big"100", wacc=big"0.10", g=big"0.02") isa BigFloat
        @test dcf_valuation(big.([100, 110, 120]); wacc=big"0.10", g=big"0.02").enterprise_value isa BigFloat

        # Rational inputs give exact results
        @test capm(rf=4//100, beta=1//1, erp=5//100, crp=0//1) == 9//100
        @test perpetuity(100//1, 5//100) == 2000//1
        @test wacc(ke=12//100, kd=6//100, tax=0//1, E=1//1, D=1//1) == 9//100
    end
end
