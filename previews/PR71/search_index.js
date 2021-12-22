var documenterSearchIndex = {"docs":
[{"location":"reference/#Reference","page":"Reference","title":"Reference","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Contents","page":"Reference","title":"Contents","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/#Index","page":"Reference","title":"Index","text":"","category":"section"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Pages = [\"reference.md\"]","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"​","category":"page"},{"location":"reference/","page":"Reference","title":"Reference","text":"Modules = [BenchmarkProfiles]","category":"page"},{"location":"reference/#BenchmarkProfiles.data_profile-Union{Tuple{S}, Tuple{BenchmarkProfiles.AbstractBackend, Array{Float64, 3}, Vector{Float64}}, Tuple{BenchmarkProfiles.AbstractBackend, Array{Float64, 3}, Vector{Float64}, Vector{S}}} where S<:AbstractString","page":"Reference","title":"BenchmarkProfiles.data_profile","text":"data_profile(b, H, N, labels; τ=1.0e-3, operations=\"function evaluations\", title=\"\"; kwargs...)\n\nProduce a data profile using the specified backend.\n\nArguments\n\nb :: AbstractBackend: the backend used to produce the plot.\nH :: Array{Float64,3}: the performance data for each solver and each problem (smaller is better). H[k,p,s] is the k-th costly operation (e.g., function evaluation) for problem p and solver s. Failures on a given problem are represented by a negative value, an infinite value, or NaN.\nN :: Vector{Float64}: scaling associated to each problem. If the number of simplex gradients is being measured, N[p] should be n(p) + 1 where n(p) is the number of variables of problem p.\nlabels :: Vector{AbstractString}: a vector of labels for each profile used to produce a legend. If empty, labels will be set to [\"column 1\", \"column 2\", ...].\n\nKeyword Arguments\n\nτ :: Float64=1.0e-3: threshold that determines the tolerance in the convergence criterion\nf(x) ≤ fL + τ (f0 - fL),\nwhere for each problem f(x) is a measure recorded (e.g., the objective value), f0 is the measure at the initial point, and fL is the best measure obtained by any solver.\noperations :: AbstractString=\"function evaluations\": used for labeling the horizontal axis.\ntitle :: AbstractString=\"\": set a title for the plot.\n\nOther keyword arguments are passed to the plot command for the corresponding backend.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BenchmarkProfiles.data_ratios-Tuple{Array{Float64, 3}, Vector{Float64}}","page":"Reference","title":"BenchmarkProfiles.data_ratios","text":"Compute data ratios used to produce a data profile.\n\nThere is normally no need to call this function directly. See the documentation of data_profile() for more information.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BenchmarkProfiles.performance_profile-Union{Tuple{S}, Tuple{BenchmarkProfiles.AbstractBackend, Matrix{Float64}}, Tuple{BenchmarkProfiles.AbstractBackend, Matrix{Float64}, Vector{S}}} where S<:AbstractString","page":"Reference","title":"BenchmarkProfiles.performance_profile","text":"performance_profile(b, T, labels; logscale=true, title=\"\", sampletol=0.0, drawtol=0.0; kwargs...)\n\nProduce a performance profile using the specified backend.\n\nArguments\n\nb :: AbstractBackend: the backend used to produce the plot.\nT :: Matrix{Float64}: each column of T defines the performance data for a solver (smaller is better). Failures on a given problem are represented by a negative value, an infinite value, or NaN.\nlabels :: Vector{AbstractString}: a vector of labels for each profile used to produce a legend. If empty, labels will be set to [\"column 1\", \"column 2\", ...].\n\nKeyword Arguments\n\nlogscale :: Bool=true: produce a logarithmic (base 2) performance plot.\ntitle :: AbstractString=\"\": set a title for the plot.\nsampletol :: Float64 = 0.0: a tolerance used to downsample profiles for performance when using a large number of problems.\ndrawtol :: Float64 = 0.0: a tolerance to declare a draw between two performance measures.\nlinestyles::Vector{Symbol}: a vector of line styles to use for the profiles, if supported by the backend.\n\nOther keyword arguments are passed to the plot command for the corresponding backend.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BenchmarkProfiles.performance_profile_data-Tuple{Matrix{Float64}}","page":"Reference","title":"BenchmarkProfiles.performance_profile_data","text":"Produce the coordinates for a performance profile.\n\nThere is normally no need to call this function directly. See the documentation of performance_profile() for more information.\n\n\n\n\n\n","category":"method"},{"location":"reference/#BenchmarkProfiles.performance_ratios-Tuple{Matrix{Float64}}","page":"Reference","title":"BenchmarkProfiles.performance_ratios","text":"Compute performance ratios used to produce a performance profile.\n\nThere is normally no need to call this function directly. See the documentation of performance_profile() for more information.\n\n\n\n\n\n","category":"method"},{"location":"#Home","page":"Home","title":"BenchmarkProfiles.jl documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"A simple package to plot performance and data profiles.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package containts Julia translations of original scripts by Elizabeth Dolan, Jorge Moré and Stefan Wild. See http://www.mcs.anl.gov/~wild/dfo/benchmarking.","category":"page"},{"location":"","page":"Home","title":"Home","text":"The original code was not accompanied by an open-source license. Jorge Moré and Stefan Wild have kindly provided their consent in writing to allow distribution of this Julia translation. See here for a full transcription.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Watch out for the pitfalls of profiles!","category":"page"},{"location":"#How-to-Install","page":"Home","title":"How to Install","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"pkg> add BenchmarkProfiles","category":"page"},{"location":"","page":"Home","title":"Home","text":"No plotting backend is loaded by default so the user can choose among several available plotting backends. Currently, Plots.jl and UnicodePlots.jl are supported. Backends become available when the corresponding package is imported.","category":"page"},{"location":"#Example","page":"Home","title":"Example","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"julia> using BenchmarkProfiles\njulia> T = 10 * rand(25,3);  # 25 problems, 3 solvers\njulia> performance_profile(PlotsBackend(), T, [\"Solver 1\", \"Solver 2\", \"Solver 3\"], title=\"Celebrity Deathmatch\")\nERROR: ArgumentError: The backend PlotsBackend() is not loaded. Please load the corresponding AD package.\njulia> using Plots\njulia> performance_profile(PlotsBackend(), T, [\"Solver 1\", \"Solver 2\", \"Solver 3\"], title=\"Celebrity Deathmatch\")  # Success!","category":"page"},{"location":"","page":"Home","title":"Home","text":"(Image: Performance Profile)","category":"page"},{"location":"#Adding-a-New-Backend","page":"Home","title":"Adding a New Backend","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"In order to add a new backend, there are two steps:","category":"page"},{"location":"","page":"Home","title":"Home","text":"Edit src/BenchmarkProfiles.jl to define the backend and make it available:","category":"page"},{"location":"","page":"Home","title":"Home","text":"struct SomeNewPlotBackend <: AbstractBackend end\nconst bp_backends = [:PlotsBackend, :UnicodePlotsBackend, :SomeNewPlotBackend]","category":"page"},{"location":"","page":"Home","title":"Home","text":"Edit src/requires.jl to define how to produce the plot from the data:","category":"page"},{"location":"","page":"Home","title":"Home","text":"@require SomeNewPlot = \"91a5bcdd-55d7-5caf-9e0b-520d859cae80\" begin\n  function performance_profile_plot(::SomeNewPlotBackend,\n                                    x_plot,\n                                    y_plot,\n                                    max_ratio,\n                                    xlabel,\n                                    ylabel,\n                                    labels,\n                                    title,\n                                    logscale;\n                                    kwargs...)\n    #\n    # now produce the plot and return the plot object\n    #\n  end\n\n  function data_profile_plot(::SomeNewPlotBackend,\n                             T,\n                             xs,\n                             max_data,\n                             xlabel,\n                             ylabel,\n                             labels,\n                             title;\n                             kwargs...)\n    #\n    # do the same here\n    #\n  end\nend","category":"page"},{"location":"#References","page":"Home","title":"References","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"E. Dolan and J. Moré, Benchmarking Optimization Software with Performance Profiles, Mathematical Programming 91, pages 201–213, 2002. DOI 10.1007/s101070100263.","category":"page"},{"location":"","page":"Home","title":"Home","text":"J. J. Moré and S. M. Wild, Benchmarking Derivative-Free Optimization Algorithms, SIAM Journal on Optimization, 20(1), pages 172–191, 2009. DOI 10.1137/080724083.","category":"page"},{"location":"tutorial/#Tutorial","page":"Tutorial","title":"Tutorial","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"This tutorial is essentially a collection of examples.","category":"page"},{"location":"tutorial/#Performance-Profile","page":"Tutorial","title":"Performance Profile","text":"","category":"section"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Performance profiles are straightforward to use. The input is a matrix T with entries T[i,j] indicating the cost to solve problem i using solver j. Cost can be, for instance, elapsed time, or number of evaluations. The cost should be positive. If any cost is zero, all measures will be shifted by 1.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Basic usage:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"using BenchmarkProfiles, Random, Plots\n\nRandom.seed!(0)\n\nT = 10 * rand(25, 3)\nperformance_profile(PlotsBackend(), T, [\"Solver 1\", \"Solver 2\", \"Solver 3\"])","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"A negative or infinite cost indicates a failure:","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"T[2:20,1] .= Inf\nperformance_profile(PlotsBackend(), T, [\"Solver 1\", \"Solver 2\", \"Solver 3\"])","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Here's an example with a strongly superior solver.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"T[:,2] = 100T[:,3]\nperformance_profile(PlotsBackend(), T, [\"Solver 1\", \"Solver 2\", \"Solver 3\"])","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"Plots arguments can be passed to performance_profile() or used as they normally would be with Plots. In the example below, we pass xlabel to performance_profile and set ylabel through ylabel!.","category":"page"},{"location":"tutorial/","page":"Tutorial","title":"Tutorial","text":"using Plots\n\nT = 10 * rand(25, 3)\nperformance_profile(PlotsBackend(), T, [\"Solver 1\", \"Solver 2\", \"Solver 3\"],\n      lw=2, c=:black, linestyles=[:solid, :dash, :dot], xlabel=\"\\\\tau\")\nylabel!(\"\\\\rho(\\\\tau)\")","category":"page"}]
}
