"Tools for optimization / inference"
module RunTools
using ArgParse
using ProgressMeter
using JLD2
using FileIO
using IterTools
using Omega
using Random
using Dates: now
# using BSON  

bye() = Omega.hello()

include("dispatch.jl")    # Dispatch Jobs
include("misc.jl")        # Miscellaneous
include("generator.jl")   # Generators
include("param.jl")       # Parameters
include("optim/Optim.jl") # Generators
include("cmd.jl")         # Command Line Argument Parsing

export dispatchmany,
       dispatchruns,
       randrunname,
       logdir,
       datadir,
       Params
end
