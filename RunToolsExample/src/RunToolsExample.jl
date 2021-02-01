module RunToolsExample

using Flux, MNIST
using Flux: accuracy

data = [(trainfeatures(i), onehot(trainlabel(i), 0:9)) for i = 1:60_000]
train = data[1:50_000]
test = data[50_001:60_000]

function train_network(model, φ)
  Flux.train!(model, train, η = φ.η,
              cb = [()->@show accuracy(m, test)])
end

function build_network(φ)
  Flux.Chain(
  Input(784),
  Affine(φ.nhidden), φ.activation,
  Affine( 64),  φ.activation,
  Affine( 10), softmax)
end

function trainy(φ)
  model = build_network(φ)
  train_network!(model, φ)
end

using SuParameters
using Omega

function runparams()
  φ = Params()
  φ.train = true
  φ.simname = "infer"
  φ.name = "neuralscene"
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
          opt = uniform([Descent, ADAM])))
end

function netparams()
  Params(midlen = uniform(40:60),
         nhidden = uniform(0:8),
         activation = uniform([relu, elu, selu]))
end

function all_params()
  # Setup tensorboard
  Parameters(η = uniform([1e-3]),
             nlayers = uniform(1:5),
             )
end

end # module
