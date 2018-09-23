# The functions in this module are a direct translation of the original
# Matlab functions by J. J. Moré and S. M. Wild.
# See http://www.mcs.anl.gov/~more/dfo.
#
# D. Orban, 2016.

"""Compute data ratios used to produce a data profile.

There is normally no need to call this function directly.
See the documentation of `data_profile()` for more information.
"""
function data_ratios(H :: Array{Float64,3}, N :: Vector{Float64}; τ :: Float64=1.0e-3)

  (nf, np, ns) = size(H)
  H[isinf.(H)] .= NaN;
  H[H .< 0] .= NaN;
  for j = 1 : ns
    for i = 2 : nf
      H[i, :, j] .= min.(H[i, :, j], H[i-1, :, j])
    end
  end

  prob_min = minimum(minimum(H, dims=1), dims=3)  # min for each problem
  prob_max = H[1, :, 1]      # starting value for each problem

  # For each problem and solver, determine the number of costly operations
  # (e.g, objective evaluations) required to reach the cutoff value.
  T = zeros(np, ns)
  for p = 1 : np
    cutoff = prob_min[p] + τ * (prob_max[p] - prob_min[p])
    for s = 1 : ns
      nfevs = findfirst(H[:, p, s] .≤ cutoff)
      T[p, s] = nfevs == nothing ? NaN : nfevs/N[p]
    end
  end

  # Replace all NaNs with twice the max ratio and sort.
  max_data = maximum(T)
  T[isnan.(T)] .= 2 * max_data
  T .= sort(T, dims=1)
  return (T, max_data)
end

data_ratios(H :: Array{TH,3}, N :: Vector{TN}; τ :: Tt=convert(Tt, 1.0e-3)) where {TH <: Number, TN <: Number, Tt <: Number} = data_ratios(convert(Array{Float64,3}, H), convert(Vector{Float64}, N), τ=convert(Float64, τ))


"""Produce a data profile.

The 3-dimensional array `H` gives the performance data for each solver
and each problem (smaller is better). `H[k,p,s]` is the `k`-th costly
operation (e.g., function evaluation) for problem `p` and solver `s`.
Failures on a given problem are represented by a negative value, an
infinite value, or `NaN`.

The vector `N` gives a scaling associated to each problem. If the number
of simplex gradients is being measured, `N[p]` should be `n(p) + 1`
where `n(p)` is the number of variables of problem `p`.

The threshold `τ` determines the tolerance in the convergence criterion

  f(x) ≤ fL + τ (f0 - fL),

where for each problem f(x) is a measure recorded (e.g., the objective
value), f0 is the measure at the initial point, and fL is the best measure
obtained by any solver.
"""
function data_profile(H :: Array{Float64,3}, N :: Vector{Float64},
                      labels :: Vector{AbstractString}=AbstractString[];
                      τ :: Float64=1.0e-3,
                      operations :: AbstractString="function evaluations",
                      title :: AbstractString="",
                      kwargs...)

  (T, max_data) = data_ratios(H, N, τ=τ)
  (np, ns) = size(T)
  xs = [1:np;] / np
  length(labels) == 0 && (labels = [@sprintf("column %d", col) for col = 1 : ns])
  profile = Plots.plot()  # initial empty plot
  for s = 1 : ns
    Plots.plot!(T[:, s], xs, t=:steppost, label=labels[s]; kwargs...)
  end
  Plots.xlims!(0.0, 1.1 * max_data)
  Plots.ylims!(0, 1.1)
  Plots.xlabel!("Number of " * strip(operations) * @sprintf(" (thresh %7.1e)", τ))
  Plots.ylabel!("Proportion of problems")
  Plots.title!(title)
  return profile
end

data_profile(H :: Array{TH,3}, N :: Vector{TN}, labels :: Vector{S}; kwargs...) where {TH <: Number, TN <: Number, S <: AbstractString} = data_profile(convert(Array{Float64,3}, H), convert(Vector{Float64}, N), convert(Vector{AbstractString}, labels); kwargs...)
