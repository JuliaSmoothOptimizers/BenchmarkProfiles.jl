# Tutorial

This tutorial is essentially a collection of examples.

## Performance Profile

Performance profiles are straightforward to use. The input is a matrix `T` with entries `T[i,j]` indicating the cost to solve problem `i` using solver `j`. Cost can be, for instance, elapsed time, or number of evaluations. The cost should be positive. Otherwise, and values will be transposed by 1.

Basic usage:

```@example ex1
using BenchmarkProfiles, Plots, Random
pyplot()

Random.seed!(0)

T = 10 * rand(25, 3)
performance_profile(T, ["Solver 1", "Solver 2", "Solver 3"])
```

To signify that some problems failed, using a negative or infinite value is possible:

```@example ex1
T[2:20,1] .= Inf
performance_profile(T, ["Solver 1", "Solver 2", "Solver 3"])
```

Here's an example with a strongly superior solver.

```@example ex1
T[:,2] = 2T[:,3]
performance_profile(T, ["Solver 1", "Solver 2", "Solver 3"])
```

Notice that some arguments can be passed to the performance profile, as well as used as usual.
In the example below, we pass `xlabel` to `performance_profile` and set `ylabel` through `ylabel!`.

```@example ex1
T = 10 * rand(25, 3)
performance_profile(T, ["Solver 1", "Solver 2", "Solver 3"],
      lw=2, c=:black, linestyles=[:solid, :dash, :dot], xlabel="τ")
ylabel!("ρ(τ)")
```

