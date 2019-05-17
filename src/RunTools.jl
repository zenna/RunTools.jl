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
using Lens


include("misc.jl")        # Miscellaneous
include("generator.jl")   # Generators
include("param.jl")       # Parameters
include("suparam.jl")     # Super Parameters
using .SuParameters

include("optim/Optim.jl") # Generators
include("git.jl")
include("cmd.jl")         # Command Line Argument Parsing

include("dispatch.jl")    # Dispatch Jobs

export control,
       dispatch,
       randrunname,
       logdir,
       datadir,
       Params,
       SuParams,
       current_commit
end
