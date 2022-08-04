module BenchmarkProfiles

using LaTeXStrings
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

"""
Replace each number by 2^{number} in a string.
Useful to transform axis ticks when plotting in log-base 2.

Examples:

    powertick("15") == "2¹⁵"
    powertick("2.1") == "2²⋅¹"
"""
function powertick(s::AbstractString)
  codes = Dict(collect(".1234567890") .=> collect("⋅¹²³⁴⁵⁶⁷⁸⁹⁰"))
  return "2" * map(c -> codes[c], s)
end

"""
Replace each number by 2^{number} in LaTeXStrings.
Useful to transform axis ticks when plotting in log-base 2.

Examples:

    powertick(L"\$15\$") == L"\$2^{15}\$"
    powertick(L"\$2.1\$") == L"\$2^{2.1}\$"
"""
function powertick(s::LaTeXString)
  ex = r"[0-9.]+"
  for m ∈ eachmatch(ex, s)
    s = LaTeXString(replace(s, m.match => "2^{$(m.match)}"))
  end
  return s
end

include("requires.jl")

end
