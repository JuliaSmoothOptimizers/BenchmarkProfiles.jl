export export_performance_profile_tikz

"""
    function export_performance_profile_tikz(T, filename; kwargs...)

Export tikz figure of the performance profiles given by `T` in `filename`.

## Arguments

* `T :: Matrix{Float64}`: each column of `T` defines the performance data for a solver (smaller is better).
  Failures on a given problem are represented by a negative value, an infinite value, or `NaN`.
* `filename :: String` : path to the tikz exported file.

## Keyword Arguments

* `solvernames :: Vector{String} = []` : names of the solvers, should have as many elements as the number of columns of `T`. If empty, use the labels returned by `performance_profile_axis_labels`.
* `xlim::AbstractFloat=10.` : size of the figure along the x axis. /!\\ the legend is added on the right hand side of the figure.
* `ylim::AbstractFloat=10.` : size of the figure along the y axis.
* `nxgrad::Int=5` : number of graduations on the x axis.
* `nygrad::Int=5` : number of graduations on the y axis.
* `grid::Bool=true` : display grid if true.
* `colours::Vector{String} = []` : colours of the plots, should have as many elements as the number of columns of `T`.
* `linestyles::Vector{String} = []` : line style (dashed, dotted, ...) of the plots, should have as many elements as the number of columns of `T`.
* `linewidth::AbstractFloat = 1.0` : line width of the plots.
* `xlabel::String = ""` : x-axis label. If empty, uses the one returned by `performance_profile_axis_labels`.
* `ylabel::String = ""` : y-axis label. If empty, uses the one returned by `performance_profile_axis_labels`.

Other keyword arguments are passed to `performance_profile_data`.

"""
function export_performance_profile_tikz(
  T::Matrix{Float64},
  filename::String;
  solvernames::Vector{String}=String[],
  xlim::AbstractFloat=10.,
  ylim::AbstractFloat=10.,
  nxgrad::Int=5,
  nygrad::Int=5,
  grid::Bool=true,
  # markers::Vector{S} = String[],
  colours::Vector{String} = String[],
  linestyles::Vector{String} = String[],
  linewidth::AbstractFloat = 1.0,
  xlabel::String = "",
  ylabel::String = "",
  kwargs...)



  logscale = true
  if haskey(kwargs,:logscale)
    logscale = kwargs[:logscale]
  end
  xlabel_def, ylabel_def, solvernames = performance_profile_axis_labels(solvernames, size(T, 2), logscale; kwargs...)
  isempty(xlabel) && (xlabel=xlabel_def)
  isempty(ylabel) && (ylabel=ylabel_def)

  # some offsets
  axis_tik_l = 0.2 # tick length
  lgd_offset = 0.5 # space between figure and legend box
  lgd_box_length = 3. # legend box length
  lgd_plot_length = 0.7 # legend plot length
  lgd_v_offset = 0.7 # vertical space between legend items 

  label_val = [0.2,0.25,0.5,1] # possible graduation labels along axes are multiples of label_val elements times 10^n
  ymax = 1.0
  y_grad = collect(0.:ymax/(nygrad-1):ymax)

  isempty(colours) && (colours = ["black" for _ =1:size(T,2)])
  isempty(linestyles) && (linestyles = ["solid" for _ =1:size(T,2)])
  
  x_mat, y_mat = BenchmarkProfiles.performance_profile_data_mat(T;kwargs...)

  # get nice looking graduation on x axis
  xmax , _ = findmax(x_mat[.!isnan.(x_mat)])
  dist = xmax/(nxgrad-1)
  n=log.(10,dist./label_val)
  _, ind = findmin(abs.(n .- round.(n)))
  xgrad_dist = label_val[ind]*10^round(n[ind])
  x_grad = [0. , [xgrad_dist*i for i =1 : nxgrad-1]...]
  #x_grad[end] <= xmax || (pop!(x_grad))
  xmax=max(x_grad[end],xmax)
  to_int(x) = isinteger(x) ? Int(x) : x

  xratio = xlim/xmax
  yratio = ylim/ymax
  open(filename, "w") do io
    println(io, "\\begin{tikzpicture}")
    # axes
    println(io, "\\draw[line width=$linewidth] (0,0) -- ($xlim,0);")
    println(io, "\\node at ($(xlim/2), -1) {$xlabel};")
    println(io, "\\draw[line width=$linewidth] (0,0) -- (0,$ylim);")
    println(io, "\\node at (-1,$(ylim/2)) [rotate = 90]  {$ylabel};")
    # axes graduations and labels,
    if logscale
      for i in eachindex(x_grad)
        println(io, "\\draw[line width=$linewidth] ($(x_grad[i]*xratio),0) -- ($(x_grad[i]*xratio),$axis_tik_l) node [pos=0, below] {\$2^{$(to_int(x_grad[i]))}\$};")
      end
    else
      for i in eachindex(x_grad)
        println(io, "\\draw[line width=$linewidth] ($(x_grad[i]*xratio),0) -- ($(x_grad[i]*xratio),$axis_tik_l) node [pos=0, below] {$(to_int(x_grad[i]))};")
      end
    end
    for i in eachindex(y_grad)
      println(io, "\\draw[line width=$linewidth] (0,$(y_grad[i]*yratio)) -- ($axis_tik_l,$(y_grad[i]*yratio)) node [pos=0, left] {$(to_int(y_grad[i]))};")
    end
    # grid
    if grid
      for i in eachindex(x_grad)
        println(io, "\\draw[gray] ($(x_grad[i]*xratio),0) -- ($(x_grad[i]*xratio),$ylim);")
      end
      for i in eachindex(y_grad)
        println(io, "\\draw[gray] (0,$(y_grad[i]*yratio)) -- ($xlim,$(y_grad[i]*yratio)) node [pos=0, left] {$(to_int(y_grad[i]))};")
      end
    end

    # profiles
    for j in eachindex(solvernames) 
      drawcmd = "\\draw[line width=$linewidth, $(colours[j]), $(linestyles[j]), line width = $linewidth] "
      drawcmd *= "($(x_mat[1,j]*xratio),$(y_mat[1,j]*yratio))"
      for k in 2:size(x_mat,1)
        if isnan(x_mat[k,j])
          break
        end
        if y_mat[k,j] > 1 # for some reasons last point of profile is set with y=1.1 by data function...
          drawcmd *= " -- ($(xmax*xratio),$(y_mat[k-1,j]*yratio)) -- ($(xmax*xratio),$(y_mat[k-1,j]*yratio))"
        else
          # if !isempty(markers)
          #   drawcmd *= " -- ($(x_mat[k,j]*xratio),$(y_mat[k-1,j]*yratio)) node[$(colours[j]),draw,$(markers[j]),solid] {} -- ($(x_mat[k,j]*xratio),$(y_mat[k,j]*yratio))"
          # else
          drawcmd *= " -- ($(x_mat[k,j]*xratio),$(y_mat[k-1,j]*yratio)) -- ($(x_mat[k,j]*xratio),$(y_mat[k,j]*yratio))"
          # end
        end
      end
      drawcmd *= ";"
      println(io,drawcmd)
    end
    # legend
    for j in eachindex(solvernames) 
      legcmd = "\\draw[$(colours[j]), $(linestyles[j]), line width = $linewidth] "
      legcmd *= "($(xlim+lgd_offset),$(ylim-j*lgd_v_offset)) -- ($(xlim+lgd_offset+lgd_plot_length),$(ylim-j*lgd_v_offset)) node [black,pos=1,right] {$(String(solvernames[j]))}"
      # if !isempty(markers)
      #   legcmd *= " node [midway,draw,$(markers[j]),solid] {}"
      # end
      legcmd *= ";"

      println(io,legcmd)
    end
    # legend box
    println(io,"\\draw[line width=$linewidth] ($(xlim+lgd_offset-0.1),$ylim) -- ($(xlim+lgd_offset+lgd_box_length),$ylim) -- ($(xlim+lgd_offset+lgd_box_length),$(ylim-lgd_v_offset*(length(solvernames)+1))) -- ($(xlim+lgd_offset-0.1),$(ylim-lgd_v_offset*(length(solvernames)+1))) -- cycle;")
    println(io,"\\end{tikzpicture}")
  end
end