# The functions in this module are a direct translation of the original
# Matlab functions by E. Doland and J. J. Moré.
# See http://www.mcs.anl.gov/~more/cops.
#
# D. Orban, 2015, 2016.

using CSV, Tables

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
    function performance_profile_data_mat(T;kwargs...)

Retruns `performance_profile_data` output (vectors) as matrices. Matrices are padded with NaN if necessary.
"""
function performance_profile_data_mat(T::Matrix{Float64};kwargs...)
  x_data, y_data, max_ratio = performance_profile_data(T;kwargs...)
  max_elem = maximum(length.(x_data))
  for i in eachindex(x_data)
    append!(x_data[i],[NaN for i=1:max_elem-length(x_data[i])])
    append!(y_data[i],[NaN for i=1:max_elem-length(y_data[i])])
  end
  x_mat = hcat(x_data...)
  y_mat = hcat(y_data...)
  return x_mat, y_mat
end

"""
export_performance_profile(T, filename; solver_names = [], header, kwargs...)

Export a performance profile plot data as .csv file. Profiles data are padded with `NaN` to ensure .csv consistency.

## Arguments

* `T :: Matrix{Float64}`: each column of `T` defines the performance data for a solver (smaller is better).
  Failures on a given problem are represented by a negative value, an infinite value, or `NaN`.
* `filename :: String` : path to the export file.

## Keyword Arguments

* `solver_names :: Vector{S}` : names of the solvers
- `header::Vector{String}`: Contains .csv file column names. Note that `header` value does not change columns order in .csv exported files (see Output).

Other keyword arguments are passed `performance_profile_data`.

Output:
File containing profile data in .csv format. Columns are solver1_x, solver1_y, solver2_x, ...
"""
function export_performance_profile(
  T::Matrix{Float64},
  filename::String;
  solver_names::Vector{S} = String[],
  header::Vector{S} = String[],
  kwargs...
) where {S <: AbstractString}
  nsolvers = size(T)[2]

  x_mat, y_mat = performance_profile_data_mat(T;kwargs...)
  isempty(solver_names) && (solver_names = ["solver_$i" for i = 1:nsolvers])

  if !isempty(header)
    header_l = size(T)[2]*2
    length(header) == header_l || error("Header should contain $(header_l) elements")
    header = vcat([[sname*"_x",sname*"_y"] for sname in solver_names]...)
  end
  data = Matrix{Float64}(undef,size(x_mat,1),nsolvers*2)
  for i =0:nsolvers-1
    data[:,2*i+1] .= x_mat[:,i+1]
    data[:,2*i+2] .= y_mat[:,i+1]
  end
  CSV.write(filename,Tables.table(data),header=header)
end
