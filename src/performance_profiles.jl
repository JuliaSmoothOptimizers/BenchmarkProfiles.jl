# The functions in this module are a direct translation of the original
# Matlab functions by E. Doland and J. J. Moré.
# See http://www.mcs.anl.gov/~more/cops.
#
# D. Orban, 2015, 2016.

"""Compute performance ratios used to produce a performance profile.

There is normally no need to call this function directly.
See the documentation of `performance_profile()` for more information.
"""
function performance_ratios(T::Array{Float64, 2}; logscale::Bool = true, drawtol::Float64 = 0.0)
  if any(T .== 0)
    @warn "some measures are zero; shifting all by one"
    T .+= 1
  end
  (np, ns) = size(T)       # Number of problems and number of solvers.

  T[isinf.(T)] .= NaN
  T[T .< 0] .= NaN
  minperf = mapslices(NaNMath.minimum, T, dims = 2) # Minimal (i.e., best) performance per solver

  # Compute ratios and divide by smallest element in each row.
  r = zeros(np, ns)
  for p = 1:np
    r[p, :] = T[p, :] / minperf[p]
  end
  # Use a draw tolerance of `drawtol` (in percentage).
  if (drawtol > 0 && drawtol < 1)
    drawtol += 1.0
    r[r .<= drawtol] .= 1
  end

  logscale && (r = log2.(r))
  max_ratio = NaNMath.maximum(r)

  # Replace failures with twice the max_ratio and sort each column of r.
  failures = isnan.(r)
  r[failures] .= 2 * max_ratio
  r .= sort(r, dims = 1)
  return (r, max_ratio)
end

performance_ratios(
  T::Array{Td, 2};
  logscale::Bool = true,
  drawtol::Float64 = 0.0,
) where {Td <: Number} =
  performance_ratios(convert(Array{Float64, 2}, T), logscale = logscale, drawtol = drawtol)

"""Produce the coordinates for a performance profile.

There is normally no need to call this function directly. See the documentation
of `performance_profile()` for more information.
"""
function performance_profile_data(
  T::Array{Float64, 2};
  logscale::Bool = true,
  sampletol::Float64 = 0.0,
  drawtol::Float64 = 0.0,
)
  (ratios, max_ratio) = performance_ratios(T, logscale = logscale, drawtol = drawtol)
  (np, ns) = size(ratios)

  ratios = [ratios; 2.0 * max_ratio * ones(1, ns)]
  xs = [1:(np + 1);] / np

  x_plot = Vector{Vector{Float64}}(undef, ns)
  y_plot = Vector{Vector{Float64}}(undef, ns)

  for s = 1:ns
    rs = view(ratios, :, s)
    xidx = zeros(Int, length(rs) + 1)
    k = 0
    rv = minimum(rs)
    maxval = maximum(rs)
    while rv < maxval
      k += 1
      xidx[k] = findlast(rs .<= rv)
      rv = max(rs[xidx[k]] + sampletol, rs[xidx[k] + 1])
    end
    xidx[k + 1] = length(rs)
    xidx = xidx[xidx .> 0]
    xidx = unique(xidx) # Needed?

    if rs[1] > 0
      x_plot[s] = [0.0; rs[xidx]]
      y_plot[s] = [0.0; xs[xidx]]
    else
      x_plot[s] = rs[xidx]
      y_plot[s] = xs[xidx]
    end
  end
  return (x_plot, y_plot, max_ratio)
end

function performance_profile_axis_labels(labels, ns, logscale; kwargs...)
  length(labels) == 0 && (labels = ["column $col" for col = 1:ns])
  kwargs = Dict{Symbol, Any}(kwargs)
  xlabel =
    pop!(kwargs, :xlabel, "Within this factor of the best" * (logscale ? " (log scale)" : ""))
  ylabel = pop!(kwargs, :ylabel, "Proportion of problems")
  return (xlabel, ylabel, labels)
end

"""
    performance_profile(b, T, labels; logscale=true, title="", sampletol=0.0, drawtol=0.0; kwargs...)

Produce a performance profile using the specified backend.

## Arguments

* `b :: AbstractBackend`: the backend used to produce the plot.
* `T :: Matrix{Float64}`: each column of `T` defines the performance data for a solver (smaller is better).
  Failures on a given problem are represented by a negative value, an infinite value, or `NaN`.
* `labels :: Vector{AbstractString}`: a vector of labels for each profile used to produce a legend.
  If empty, `labels` will be set to `["column 1", "column 2", ...]`.

## Keyword Arguments

* `logscale :: Bool=true`: produce a logarithmic (base 2) performance plot.
* `title :: AbstractString=""`: set a title for the plot.
* `sampletol :: Float64 = 0.0`: a tolerance used to downsample profiles for performance when using a large number of problems.
* `drawtol :: Float64 = 0.0`: a tolerance to declare a draw between two performance measures.
* `linestyles::Vector{Symbol}`: a vector of line styles to use for the profiles, if supported by the backend.

Other keyword arguments are passed to the plot command for the corresponding backend.
"""
function performance_profile(
  b::AbstractBackend,
  T::Matrix{Float64},
  labels::Vector{S} = String[];
  logscale::Bool = true,
  title::AbstractString = "",
  sampletol::Float64 = 0.0,
  drawtol::Float64 = 0.0,
  kwargs...,
) where {S <: AbstractString}
  xlabel, ylabel, labels = performance_profile_axis_labels(labels, size(T, 2), logscale; kwargs...)
  (x_plot, y_plot, max_ratio) =
    performance_profile_data(T, logscale = logscale, sampletol = sampletol, drawtol = drawtol)
  performance_profile_plot(
    b,
    x_plot,
    y_plot,
    max_ratio,
    xlabel,
    ylabel,
    labels,
    title,
    logscale;
    kwargs...,
  )
end
"""
    performance_profile(b,stats, cost)
Produce a performance profile comparing solvers in `stats` using the `cost` function.
Inputs:
- `b :: AbstractBackend`: the backend used to produce the plot.
- `stats::Dict{Symbol,DataFrame}`: pairs of `:solver => df`;
- `cost::Function`: cost function applyed to each `df`. Should return a vector with the cost of solving the problem at each row;
- if the cost is zero for at least one problem, all costs will be shifted by 1;
- if the solver did not solve the problem, return Inf or a negative number.
Examples of cost functions:
- `cost(df) = df.elapsed_time`: Simple `elapsed_time` cost. Assumes the solver solved the problem.
- `cost(df) = (df.status .!= :first_order) * Inf + df.elapsed_time`: Takes the status of the solver into consideration.
"""
function performance_profile(b::AbstractBackend, stats::Dict{Symbol,DataFrame}, cost, args...; kwargs...)
  solvers = keys(stats)
  dfs = (stats[s] for s in solvers)
  P = hcat([cost(df) for df in dfs]...)
  performance_profile(b, P, string.(solvers), args...; kwargs...)
end

performance_profile(b::AbstractBackend, T :: Array{Tn,2}, labels :: Vector{S}; kwargs...) where {Tn <: Number, S <: AbstractString} =
  performance_profile(b, convert(Array{Float64,2}, T), convert(Vector{AbstractString}, labels); kwargs...)

"""
    performance_profile(b, stats, cost)
Produce a performance profile comparing solvers in `stats` using the `cost` function.
Inputs:
- `b::AbstractBackend`: the backend used to produce the plot.
- `stats::Dict{Symbol,DataFrame}`: pairs of `:solver => df`;
- `cost::Function`: cost function applyed to each `df`. Should return a vector with the cost of solving the problem at each row;
  - if the cost is zero for at least one problem, all costs will be shifted by 1;
  - if the solver did not solve the problem, return Inf or a negative number.
Examples of cost functions:
- `cost(df) = df.elapsed_time`: Simple `elapsed_time` cost. Assumes the solver solved the problem.
- `cost(df) = (df.status .!= :first_order) * Inf + df.elapsed_time`: Takes the status of the solver into consideration.
"""
function performance_profile(b::AbstractBackend, stats::Dict{Symbol,DataFrame}, cost, args...; kwargs...)
  solvers = keys(stats)
  dfs = (stats[s] for s in solvers)
  P = hcat([cost(df) for df in dfs]...)
  performance_profile(b, P, string.(solvers), args...; kwargs...)
end
