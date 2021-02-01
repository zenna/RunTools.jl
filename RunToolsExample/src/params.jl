using Omega: normal, uniform, ciid
using SuParameters
using RunTools

function runparams()
  φ = Params()
  φ.train = true
  φ.simname = "infer"
  φ.name = "mnisttrain"
  φ.runname = ciid(randrunname)
  φ.tags = ["neuralscene", "first"]
  φ.logdir = ciid(ω -> logdir(runname = φ.runname(ω), tags = φ.tags))
  φ.runfile = joinpath(dirname(@__FILE__), "..", "scripts", "runscript.jl")
  φ.gitinfo = current_commit(@__FILE__)
  φ
end

"Optimization Parameters"
function optparams()
  Params((η = uniform([0.01, 0.001, 0.0001]),
          opt = uniform([Descent, ADAM]),
          batchsize = uniform([512, 1024])))
end

function netparams()
  Params(nhidden = uniform(32:64),
         activation = uniform([relu, elu, selu]))
end

function allparams()
  # Setup tensorboard
  φ = Params()
  merge(φ, runparams(), optparams(), netparams())
end