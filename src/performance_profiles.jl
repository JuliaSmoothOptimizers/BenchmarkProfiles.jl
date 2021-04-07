# The functions in this module are a direct translation of the original
# Matlab functions by E. Doland and J. J. Moré.
# See http://www.mcs.anl.gov/~more/cops.
#
# D. Orban, 2015, 2016.

"""Compute performance ratios used to produce a performance profile.

There is normally no need to call this function directly.
See the documentation of `performance_profile()` for more information.
"""
function performance_ratios(T :: Array{Float64,2}; logscale :: Bool=true, drawtol :: Float64 = 0.0)

  if any(T .== 0)
    @warn "some measures are zero; shifting all by one"
    T .+= 1
  end
  (np, ns) = size(T);       # Number of problems and number of solvers.

  T[isinf.(T)] .= NaN;
  T[T .< 0] .= NaN;
  minperf = mapslices(NaNMath.minimum, T, dims=2) # Minimal (i.e., best) performance per solver

  # Compute ratios and divide by smallest element in each row.
  r = zeros(np, ns);
  for p = 1 : np
    r[p, :] = T[p, :] / minperf[p];
  end
  # Use a draw tolerance of `drawtol` (in percentage).
  if (drawtol > 0 && drawtol < 1)
    drawtol += 1. 
    for p in 1 : np
      for s in 1 : ns
        if r[p,s] <= drawtol
          r[p,s] = 1.
        end
      end
    end
  end

  logscale && (r = log2.(r));
  max_ratio = NaNMath.maximum(r)

  # Replace failures with twice the max_ratio and sort each column of r.
  failures = isnan.(r);
  r[failures] .= 2 * max_ratio;
  r .= sort(r, dims=1);
  return (r, max_ratio)
end

performance_ratios(T :: Array{Td,2}; logscale :: Bool=true, drawtol :: Float64= 0.0) where Td <: Number = performance_ratios(convert(Array{Float64,2}, T), logscale=logscale, drawtol = drawtol)

"""Produce the coordinates for a performance profile.

There is normally no need to call this function directly. See the documentation
of `performance_profile()` for more information.
"""
function performance_profile_data(T :: Array{Float64,2}; logscale :: Bool=true,
                                  sampletol :: Float64 = 0.0, drawtol :: Float64 = 0.0)
    (ratios, max_ratio) = performance_ratios(T, logscale=logscale, drawtol=drawtol)
    (np, ns) = size(ratios)

    ratios = [ratios; 2.0 * max_ratio * ones(1, ns)]
    xs = [1:np+1;] / np

    x_plot = Vector{Vector{Float64}}(undef, ns)
    y_plot = Vector{Vector{Float64}}(undef, ns)

    for s = 1 : ns
      rs = view(ratios,:,s)
      xidx = zeros(Int,length(rs)+1)
      k = 0
      rv = minimum(rs)
      maxval = maximum(rs)
      while rv < maxval
        k += 1
        xidx[k] = findlast(rs .<= rv)
        rv = max(rs[xidx[k]] + sampletol, rs[xidx[k]+1])
      end
      xidx[k+1] = length(rs)
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

"""Produce a performance profile.

Each column of the matrix `T` defines the performance data for a solver
(smaller is better). Failures on a given problem are represented by a
negative value, an infinite value, or `NaN`.
The optional argument `logscale` is used to produce a logarithmic (base 2)
performance plot.
"""
function performance_profile(T :: Array{Float64,2}, labels :: Vector{AbstractString};
                             logscale :: Bool=true,
                             title :: AbstractString="",
                             sampletol :: Float64 = 0.0,
                             drawtol :: Float64 = 0.0,
                             kwargs...)
  kwargs = Dict{Symbol,Any}(kwargs)

  (x_plot, y_plot, max_ratio) = performance_profile_data(T, logscale=logscale, sampletol=sampletol, drawtol=drawtol)

  ns = size(T, 2)
  length(labels) == 0 && (labels = [@sprintf("column %d", col) for col = 1 : ns])
  xlabel = pop!(kwargs, :xlabel, "Within this factor of the best" * (logscale ? " (log scale)" : ""))
  ylabel = pop!(kwargs, :ylabel, "Proportion of problems")
  linestyles = pop!(kwargs, :linestyles, Symbol[])
  profile = Plots.plot(xlabel = xlabel, ylabel = ylabel, title = title, xlims = (logscale ? 0.0 : 1.0, 1.1 * max_ratio), ylims = (0, 1.1))  # initial plot
  for s = 1 : ns
    if length(linestyles) > 0
      kwargs[:linestyle] = linestyles[s]
    end
    Plots.plot!(x_plot[s], y_plot[s], t=:steppost, label=labels[s]; kwargs...)
  end
  return profile
end

performance_profile(T :: Array{Tn,2}, labels :: Vector{S}; kwargs...) where {Tn <: Number, S <: AbstractString} =
  performance_profile(convert(Array{Float64,2}, T), convert(Vector{AbstractString}, labels); kwargs...)
