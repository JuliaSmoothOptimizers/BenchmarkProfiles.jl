using Documenter, BenchmarkProfiles
# defines `export_performance_profile_tikz`, so that its docstring is in the reference
using TikzPictures

makedocs(
  modules = [BenchmarkProfiles],
  doctest = true,
  linkcheck = true,
  strict = true,
  format = Documenter.HTML(
    assets = ["assets/style.css"],
    prettyurls = get(ENV, "CI", nothing) == "true",
  ),
  sitename = "BenchmarkProfiles.jl",
  pages = ["Home" => "index.md", "Tutorial" => "tutorial.md", "Reference" => "reference.md"],
)

deploydocs(
  repo = "github.com/JuliaSmoothOptimizers/BenchmarkProfiles.jl.git",
  push_preview = true,
  devbranch = "main",
)
