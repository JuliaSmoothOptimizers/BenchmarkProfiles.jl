# Profiles

A simple [Julia](http://julialang.org) package to plot performance and data profiles.

[![Build Status](https://travis-ci.org/JuliaOptimizers/Profiles.jl.svg?branch=master)](https://travis-ci.org/JuliaOptimizers/Profiles.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/u6ycjl8rfatjnofk/branch/master?svg=true)](https://ci.appveyor.com/project/dpo/profiles-jl/branch/master)


Plotting is handled by [`Plots.jl`](https://github.com/tbreloff/Plots.jl) so the user can choose among several available plotting backends.

Watch out for the [pitfalls](http://purl.org/net/epubs/manifestation/20477017) of profiles!

## Example

```julia
julia> using Profiles
julia> T = 10 * rand(25,3);  # 25 problems, 3 solvers
julia> performance_profile(T, labels=["Solver 1", "Solver 2", "Solver 3"], title="Celebrity Deathmatch")
```

## References

E. Dolan and J. Moré, *Benchmarking Optimization Software with Performance Profiles*, Mathematical Programming 91, pages 201--213, 2002. DOI [10.1007/s101070100263](http://dx.doi.org/10.1007/s101070100263).

J. J. Moré and S. M. Wild, *Benchmarking Derivative-Free Optimization Algorithms*, SIAM Journal on Optimization, 20(1), pages 172--191, 2009. DOI [10.1137/080724083](http://dx.doi.org/10.1137/080724083).
