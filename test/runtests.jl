using BenchmarkProfiles
using DataFrames
using Test

@testset "No backend" begin
  T = 10 * rand(25, 3)
  labels = ["a", "b", "c"]
  @test_throws ArgumentError performance_profile(PlotsBackend(), T, labels)
  @test_throws ArgumentError performance_profile(UnicodePlotsBackend(), T, labels)
  dfs  = DataFrame[]
  for col in eachcol(T)
    push!(dfs, DataFrame(:perf_measure => col))
  end
  cost(df) = df.perf_measure
  stats = Dict([:a, :b, :c] .=> dfs)
  @test_throws ArgumentError performance_profile(PlotsBackend(), stats, cost)    
  @test_throws ArgumentError performance_profile(UnicodePlotsBackend(), stats, cost)    
  H = rand(25, 4, 3)
  T = ones(10)
  @test_throws ArgumentError data_profile(PlotsBackend(), H, T, labels)
  @test_throws ArgumentError data_profile(UnicodePlotsBackend(), H, T, labels)
end


@testset "UnicodePlots" begin
  using UnicodePlots
  T = 10 * rand(25, 3)
  labels = ["a", "b", "c"]
  profile = performance_profile(UnicodePlotsBackend(), T, labels)
  @test isa(profile, UnicodePlots.Plot{BrailleCanvas})
  dfs  = DataFrame[]
  for col in eachcol(T)
    push!(dfs, DataFrame(:perf_measure => col))
  end
  cost(df) = df.perf_measure
  stats = Dict([:a, :b, :c] .=> dfs)
  profile = performance_profile(UnicodePlotsBackend(), stats, cost)
  @test isa(profile, UnicodePlots.Plot{BrailleCanvas})
  H = rand(25, 4, 3)
  T = ones(10)
  profile = data_profile(UnicodePlotsBackend(), H, T, labels)
  @test isa(profile, UnicodePlots.Plot{BrailleCanvas})
end


if !Sys.isfreebsd() # GR_jll not available, so Plots won't install
  @testset "Plots" begin
    using Plots
    T = 10 * rand(25, 3)
    labels = ["a", "b", "c"]
    profile = performance_profile(PlotsBackend(), T, labels, linestyles = [:solid, :dash, :dot])
    @test isa(profile, Plots.Plot)
    dfs  = DataFrame[]
    for col in eachcol(T)
      push!(dfs, DataFrame(:perf_measure => col))
    end
    cost(df) = df.perf_measure
    stats = Dict([:a, :b, :c] .=> dfs)
    profile = performance_profile(PlotsBackend(), stats, cost, linestyles=[:solid, :dash, :dot])
    @test isa(profile, Plots.Plot)
    H = rand(25, 4, 3)
    T = ones(10)
    profile = data_profile(PlotsBackend(), H, T, labels, linestyles=[:solid, :dash, :dot])
    @test isa(profile, Plots.Plot)
  end
end