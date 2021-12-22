function __init__()
  @require Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
    """
    Keyword arguments specific to the `PlotsBackend` backend:

    * `linestyles::Vector{Symbol}`: a list of line styles.
    """
    performance_profile

    function performance_profile_plot(
      ::PlotsBackend,
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
      kwargs = Dict{Symbol, Any}(kwargs)
      linestyles = pop!(kwargs, :linestyles, Symbol[])
      profile = Plots.plot(
        xlabel = xlabel,
        ylabel = ylabel,
        title = title,
        xlims = (logscale ? 0.0 : 1.0, 1.1 * max_ratio),
        ylims = (0, 1.1),
      )  # initial plot
      for s = 1:length(labels)
        if length(linestyles) > 0
          kwargs[:linestyle] = linestyles[s]
        end
        Plots.plot!(x_plot[s], y_plot[s], t = :steppost, label = labels[s]; kwargs...)  # add to initial plot
      end
      if logscale
        for xt in Plots.xticks(profile)
          Plots.plot!(xticks = (xt[1], map(x -> powertick(x), xt[2])))
          Plots.plot!(xtickfontsize=10)
        end
      end
      return profile
    end

    function data_profile_plot(
      ::PlotsBackend,
      T,
      xs,
      max_data,
      xlabel,
      ylabel,
      labels,
      title;
      kwargs...,
    )
      profile = Plots.plot()  # initial empty plot
      for s = 1:size(T, 2)
        Plots.plot!(T[:, s], xs, t = :steppost, label = labels[s]; kwargs...)
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
    function performance_profile_plot(
      ::UnicodePlotsBackend,
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
      kwargs = Dict{Symbol, Any}(kwargs)
      kwargs[:xlabel] = xlabel
      kwargs[:ylabel] = ylabel
      kwargs[:title] = title
      kwargs[:xlim] = logscale ? 0.0 : 1.0, round(max_ratio, digits = 1)
      kwargs[:ylim] = (0, 1.1)
      kwargs[:style] = :post
      profile = UnicodePlots.stairs(x_plot[1], y_plot[1], name = labels[1]; kwargs...)  # initial plot
      for s = 2:length(labels)
        UnicodePlots.stairs!(profile, x_plot[s], y_plot[s], name = labels[s])
      end
      return profile
    end

    function data_profile_plot(
      ::UnicodePlotsBackend,
      T,
      xs,
      max_data,
      xlabel,
      ylabel,
      labels,
      title;
      kwargs...,
    )
      kwargs = Dict{Symbol, Any}(kwargs)
      kwargs[:xlabel] = xlabel
      kwargs[:ylabel] = ylabel
      kwargs[:title] = title
      kwargs[:xlim] = (1.0, round(max_data, digits = 1))
      kwargs[:ylim] = (0, 1.1)
      kwargs[:style] = :post
      profile = UnicodePlots.stairs(T[:, 1], xs, name = labels[1]; kwargs...)
      for s = 2:size(T, 2)
        UnicodePlots.stairs!(profile, T[:, s], xs, name = labels[s])
      end
      return profile
    end
  end
end
