module BenchmarkProfiles

import Plots, NaNMath
using Compat.findfirst

export performance_ratios, performance_profile
export data_ratios, data_profile

include("performance_profiles.jl")
include("data_profiles.jl")

end
