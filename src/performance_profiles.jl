# The functions in this module are a direct translation of the original
# Matlab functions by E. Doland and J. J. Moré.
# See http://www.mcs.anl.gov/~more/cops.
#
# D. Orban, 2015, 2016.

"""Compute performance ratios used to produce a performance profile.

There is normally no need to call this function directly.
See the documentation of `performance_profile()` for more information.
"""
function performance_ratios(T :: Array{Float64,2}; logscale :: Bool=true)

  (np, ns) = size(T);       # Number of problems and number of solvers.

  T[isinf.(T)] = NaN;
  T[T .< 0] = NaN;
  minperf = mapslices(NaNMath.minimum, T, 2) # Minimal (i.e., best) performance per solver

  # Compute ratios and divide by smallest element in each row.
  r = zeros(np, ns);
  for p = 1 : np
    r[p, :] = T[p, :] / minperf[p];
  end

  logscale && (r = log2.(r));
  max_ratio = NaNMath.maximum(r)

  # Replace failures with twice the max_ratio and sort each column of r.
  failures = isnan.(r);
  r[failures] = 2 * max_ratio;
  r = sort(r, 1);
  return (r, max_ratio)
end

performance_ratios{Td <: Number}(T :: Array{Td,2}; logscale :: Bool=true) = performance_ratios(convert(Array{Float64,2}, T), logscale=logscale)


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
                             sampletol :: Float64 = 5e-2,
                             kwargs...)

  (ratios, max_ratio) = performance_ratios(T, logscale=logscale)
  (np, ns) = size(ratios)

  ratios = [ratios; 2.0 * max_ratio * ones(1, ns)]
  xs = [1:np+1;] / np
  length(labels) == 0 && (labels = [@sprintf("column %d", col) for col = 1 : ns])
  profile = Plots.plot(; kwargs...)  # initial empty plot
  for s = 1 : ns
    rs = view(ratios,:,s)
    urs = unique(rs)
    @show length(urs)
    xidx = zeros(Int,length(urs)+1)
    k = 0
    rv = log2(minimum(rs))
    while rv < log2(maximum(urs))
      k += 1
      xidx[k] = findlast(log2.(rs) .<= rv)
      rv = max(log2(rs[xidx[k]])+sampletol, log2(rs[xidx[k]+1]))
    end
    xidx[k+1] = length(rs)
    xidx = xidx[xidx .> 0]
    xidx = unique(xidx) # Needed?
    @show length(xidx)
    Plots.plot!(rs[xidx], xs[xidx], t=:steppost, label=labels[s])
  end
 #Plots.xlims!(logscale ? 0.0 : 1.0, 1.1 * max_ratio)
  #Plots.ylims!(0, 1.1)
  Plots.xlabel!("Within this factor of the best" * (logscale ? " (log scale)" : ""))
  Plots.ylabel!("Proportion of problems")
  Plots.title!(title)
  return profile
end

performance_profile{Tn <: Number, S <: AbstractString}(T :: Array{Tn,2}, labels :: Vector{S}; kwargs...) =
  performance_profile(convert(Array{Float64,2}, T), convert(Vector{AbstractString}, labels); kwargs...)
