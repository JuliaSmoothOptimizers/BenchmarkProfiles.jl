module BenchmarkProfiles

import NaNMath
using Requires
using Printf

export performance_ratios, performance_profile, performance_profile_data
export data_ratios, data_profile
export bp_backends, PlotsBackend, UnicodePlotsBackend

abstract type AbstractBackend end
struct PlotsBackend <: AbstractBackend end
struct UnicodePlotsBackend <: AbstractBackend end

const bp_backends = [:PlotsBackend, :UnicodePlotsBackend]

function throw_error(b)
  throw(ArgumentError("The backend $b is not loaded. Please load the corresponding package."))
end

for backend ∈ bp_backends
  @eval begin
    B = eval($backend)
    performance_profile_plot(b::B, args...; kwargs...) = throw_error(b)
    data_profile_plot(b::B, args...; kwargs...) = throw_error(b)
  end
end

include("performance_profiles.jl")
include("data_profiles.jl")

function powertick(s::AbstractString)
  codes = Dict(collect(".1234567890") .=> collect("⋅¹²³⁴⁵⁶⁷⁸⁹⁰"))
  return "2" * map(c -> codes[c], s) # powertick("15") = 2¹⁵ and powertick(2.1) = "2²⋅¹"
end

include("requires.jl")

end
