using Documenter
using CorporateFinance

makedocs(;
    modules = [CorporateFinance],
    sitename = "CorporateFinance.jl",
    authors = "Miguel Ferrera",
    format = Documenter.HTML(;
        canonical = "https://ferrerama.github.io/CorporateFinance.jl/stable/",
        prettyurls = get(ENV, "CI", "false") == "true",
    ),
    checkdocs = :exports,
    pages = [
        "Home" => "index.md",
        "Cost of capital" => "cost_of_capital.md",
        "Valuation" => "valuation.md",
    ],
)

deploydocs(;
    repo = "github.com/ferrerama/CorporateFinance.jl",
    devbranch = "main",
)
