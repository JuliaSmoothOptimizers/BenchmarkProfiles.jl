using BenchmarkProfiles
using Test

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
end
