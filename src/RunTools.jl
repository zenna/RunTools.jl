"Module for optimization dispatching jobs / params stuff that kinda stuff"
module RunTools
using ArgParse
using ProgressMeter

include("dispatch.jl")  # Dispatch Jobs
include("misc.jl")      # Miscellaneous
include("cmd.jl")       # Command Line Argument Parsing
include("generator.jl") # Generators
include("optim/Optim.jl") # Generators

export dispatchmany,
       dispatchruns,
       randrunname,
       logdir,
       datadir
end