# [BenchmarkProfiles.jl documentation](@id Home)

A simple package to plot performance and data profiles.

This package containts Julia translations of original scripts by Elizabeth Dolan, Jorge Moré and Stefan Wild.
See http://www.mcs.anl.gov/~wild/dfo/benchmarking.

The original code was not accompanied by an open-source license. Jorge Moré and Stefan Wild have kindly provided their consent in writing to allow distribution of this Julia translation. See [here](https://github.com/JuliaSmoothOptimizers/BenchmarkProfiles.jl/tree/master/consent) for a full transcription.

Watch out for the [pitfalls](http://dl.acm.org/citation.cfm?id=2950048) of profiles!

## How to Install

```julia
pkg> add BenchmarkProfiles
```

No plotting backend is loaded by default so the user can choose among several available plotting backends.
Currently, [Plots.jl](https://github.com/JuliaPlots/Plots.jl) and [UnicodePlots.jl](https://github.com/Evizero/UnicodePlots.jl) are supported.
Backends become available when the corresponding package is imported.
## Example

```julia
julia> using BenchmarkProfiles
julia> T = 10 * rand(25,3);  # 25 problems, 3 solvers
julia> performance_profile(PlotsBackend(), T, ["Solver 1", "Solver 2", "Solver 3"], title="Celebrity Deathmatch")
ERROR: ArgumentError: The backend PlotsBackend() is not loaded. Please load the corresponding AD package.
julia> using Plots
julia> performance_profile(PlotsBackend(), T, ["Solver 1", "Solver 2", "Solver 3"], title="Celebrity Deathmatch")  # Success!
```

![Performance Profile](assets/random_profile.png)

## Adding a New Backend

In order to add a new backend,

1. edit `src/BenchmarkProfiles.jl` to define the backend and make it available:
    ```julia
    struct SomeNewPlotBackend <: AbstractBackend end
    const bp_backends = [:PlotsBackend, :UnicodePlotsBackend, :SomeNewPlotBackend]
    ```
2. edit `src/requires.jl` to define how to produce the plot from the data:
    ```julia
    @require SomeNewPlot = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
      function performance_profile(::SomeNewPlotBackend,
                                  T :: Matrix{Float64},
                                  labels :: Vector{S}=String[];
                                  logscale :: Bool = true,
                                  title :: AbstractString = "",
                                  sampletol :: Float64 = 0.0,
                                  drawtol :: Float64 = 0.0,
                                  kwargs...) where S <: AbstractString
        ns = size(T, 2)
        xlabel, ylabel, labels = performance_profile_axis_labels(labels, ns, logscale; kwargs...)
        (x_plot, y_plot, max_ratio) = performance_profile_data(T, logscale=logscale, sampletol=sampletol, drawtol=drawtol)
        kwargs = Dict{Symbol,Any}(kwargs)
        #
        # now produce the plot and return the plot object
        #
      end

      function data_profile(::SomeNewPlotBackend,
                            H :: Array{Float64,3},
                            N :: Vector{Float64},
                            labels :: Vector{S}=String[];
                            τ :: Float64=1.0e-3,
                            operations :: AbstractString="function evaluations",
                            title :: AbstractString="",
                            kwargs...) where S <: AbstractString
        (T, max_data) = data_ratios(H, N, τ=τ)
        (np, ns) = size(T)
        (xlabel, ylabel, labels) = data_profile_axis_labels(labels, ns, operations, τ; kwargs...)
        xs = [1:np;] / np
        #
        # do the same here
        #
      end
    end
    ```

## References

E. Dolan and J. Moré, *Benchmarking Optimization Software with Performance Profiles*, Mathematical Programming 91, pages 201--213, 2002. DOI [10.1007/s101070100263](http://dx.doi.org/10.1007/s101070100263).

J. J. Moré and S. M. Wild, *Benchmarking Derivative-Free Optimization Algorithms*, SIAM Journal on Optimization, 20(1), pages 172--191, 2009. DOI [10.1137/080724083](http://dx.doi.org/10.1137/080724083).
