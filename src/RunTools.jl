__precompile__()
"Module for optimization dispatching jobs / params stuff that kinda stuff"
module RunTools
using ArgParse
using ProgressMeter
using JLD2
using FileIO

include("dispatch.jl")    # Dispatch Jobs
include("misc.jl")        # Miscellaneous
include("cmd.jl")         # Command Line Argument Parsing
include("generator.jl")   # Generators
include("param.jl")       # Parameters
include("optim/Optim.jl") # Generators

export dispatchmany,
       dispatchruns,
       randrunname,
       logdir,
       datadir,
       Params
end