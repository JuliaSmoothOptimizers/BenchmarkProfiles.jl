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

Plotting in handled by [`Plots.jl`](http://docs.juliaplots.org/latest/) so the user can choose among several available plotting backends.

## Example

```julia
julia> using BenchmarkProfiles
julia> T = 10 * rand(25, 3) # 25 problems, 3 solvers
julia> performance_profile(T, ["Solver 1", "Solver 2", "Solver 3"], title="Celebrity Deathmatch")
```

![Performance Profile](assets/random_profile.png)

## References

E. Dolan and J. Moré, *Benchmarking Optimization Software with Performance Profiles*, Mathematical Programming 91, pages 201--213, 2002. DOI [10.1007/s101070100263](http://dx.doi.org/10.1007/s101070100263).

J. J. Moré and S. M. Wild, *Benchmarking Derivative-Free Optimization Algorithms*, SIAM Journal on Optimization, 20(1), pages 172--191, 2009. DOI [10.1137/080724083](http://dx.doi.org/10.1137/080724083).
