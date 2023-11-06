using BenchmarkProfiles
using LaTeXStrings
using Test
using TikzPictures

@testset "powertick" begin
  @test BenchmarkProfiles.powertick("15") == "2¹⁵"
  @test BenchmarkProfiles.powertick("2.1") == "2²⋅¹"
  @test BenchmarkProfiles.powertick("\$15\$") == "\$2^{15}\$"
  @test BenchmarkProfiles.powertick("\$2.1\$") == "\$2^{2.1}\$"
  @test BenchmarkProfiles.powertick(L"$15$") == L"$2^{15}$"
  @test BenchmarkProfiles.powertick(L"$2.1$") == L"$2^{2.1}$"
end

@testset "No backend" begin
  T = 10 * rand(25, 3)
  labels = ["a", "b", "c"]
  @test_throws ArgumentError performance_profile(PlotsBackend(), T, labels)
  @test_throws ArgumentError performance_profile(UnicodePlotsBackend(), T, labels)
  H = rand(25, 4, 3)
  T = ones(10)
  @test_throws ArgumentError data_profile(PlotsBackend(), H, T, labels)
  @test_throws ArgumentError data_profile(PlotsBackend(), H, T, labels)
end

@testset "UnicodePlots" begin
  using UnicodePlots
  T = 10 * rand(25, 3)
  labels = ["a", "b", "c"]
  profile = performance_profile(UnicodePlotsBackend(), T, labels)
  @test isa(
    profile,
    UnicodePlots.Plot{BrailleCanvas{typeof(identity), typeof(identity)}, Val{false}, Bool},
  )
  H = rand(25, 4, 3)
  T = ones(10)
  profile = data_profile(UnicodePlotsBackend(), H, T, labels)
  @test isa(profile, Plot{BrailleCanvas{typeof(identity), typeof(identity)}, Val{false}, Bool})
end

if !Sys.isfreebsd() # GR_jll not available, so Plots won't install
  @testset "Plots" begin
    using Plots
    T = 10 * rand(25, 3)
    labels = ["a", "b", "c"]
    profile = performance_profile(PlotsBackend(), T, labels, linestyles = [:solid, :dash, :dot])
    @test isa(profile, Plots.Plot)
    H = rand(25, 4, 3)
    T = ones(10)
    profile = data_profile(PlotsBackend(), H, T, labels)
    @test isa(profile, Plots.Plot)
  end

  @testset "PGFPlotsX" begin
    T = 10 * rand(25, 3)
    labels = ["a", "b", "c"]
    pgfplotsx()
    profile = performance_profile(PGFPlotsXBackend(), T, labels, linestyles = [:solid, :dash, :dot])
    @test isa(profile, Plots.Plot)
    H = rand(25, 4, 3)
    T = ones(10)
    profile = data_profile(PGFPlotsXBackend(), H, T, labels)
    @test isa(profile, Plots.Plot)
  end

  @testset "csv export" begin
    T = 10 * rand(25, 3)
    filename = "data.csv"
    export_performance_profile(T, filename)
    @test isfile(filename)
    rm(filename)
    export_performance_profile(T, filename, header = ["" for _ = 1:(size(T, 2) * 2)])
    @test isfile(filename)
    rm(filename)
  end

  @testset "tikz export" begin
    T = 10 * rand(25, 3)
    filename = "tikz_fig"
    export_performance_profile_tikz(T, filename)
    @test isfile(filename * ".tikz")
    rm(filename * ".tikz")
    export_performance_profile_tikz(T, filename, file_type = TEX)
    @test isfile(filename * ".tex")
    rm(filename * ".tex")
    export_performance_profile_tikz(T, filename, file_type = SVG)
    @test isfile(filename * ".svg")
    rm(filename * ".svg")
    export_performance_profile_tikz(T, filename, file_type = PDF)
    @test isfile(filename * ".pdf")
    rm(filename * ".pdf")
  end
end
