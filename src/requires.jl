function __init__()
  @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
    function performance_profile(::PlotsBackend,
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
      linestyles = pop!(kwargs, :linestyles, Symbol[])
      profile = Plots.plot(xlabel = xlabel, ylabel = ylabel, title = title, xlims = (logscale ? 0.0 : 1.0, 1.1 * max_ratio), ylims = (0, 1.1))  # initial plot
      for s = 1 : ns
        if length(linestyles) > 0
          kwargs[:linestyle] = linestyles[s]
        end
        Plots.plot!(x_plot[s], y_plot[s], t=:steppost, label=labels[s]; kwargs...)  # add to initial plot
      end
      return profile
    end

    function data_profile(::PlotsBackend,
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
      profile = Plots.plot()  # initial empty plot
      for s = 1 : ns
        Plots.plot!(T[:, s], xs, t=:steppost, label=labels[s]; kwargs...)
      end
      Plots.xlims!(0.0, 1.1 * max_data)
      Plots.ylims!(0, 1.1)
      Plots.xlabel!(xlabel)
      Plots.ylabel!(ylabel)
      Plots.title!(title)
      return profile
    end
  end

  @require UnicodePlots = "b8865327-cd53-5732-bb35-84acbb429228" begin
    function performance_profile(::UnicodePlotsBackend,
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
      kwargs[:xlabel] = xlabel
      kwargs[:ylabel] = ylabel
      kwargs[:title] = title
      kwargs[:xlim] = logscale ? 0.0 : 1.0, round(max_ratio, digits=1)
      kwargs[:ylim] = (0, 1.1)
      kwargs[:style] = :post
      profile = UnicodePlots.stairs(x_plot[1], y_plot[1], name=labels[1]; kwargs...)  # initial plot
      for s = 2 : ns
        UnicodePlots.stairs!(profile, x_plot[s], y_plot[s], name=labels[s])
      end
      return profile
    end

    function data_profile(::UnicodePlotsBackend,
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
      kwargs = Dict{Symbol,Any}(kwargs)
      kwargs[:xlabel] = xlabel
      kwargs[:ylabel] = ylabel
      kwargs[:title] = title
      kwargs[:xlim] = (1.0, round(max_data, digits=1))
      kwargs[:ylim] = (0, 1.1)
      kwargs[:style] = :post
      profile = UnicodePlots.stairs(T[:, 1], xs, name=labels[1]; kwargs...)
      for s = 2 : ns
        UnicodePlots.stairs!(profile, T[:, s], xs, name=labels[s])
      end
      return profile
    end
  end
end