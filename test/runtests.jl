using Profiles
using Plots
using Base.Test

unicodeplots()
T = 10 * rand(25, 3)
performance_profile(T, labels=["a", "b", "c"], title="Test Profile")
