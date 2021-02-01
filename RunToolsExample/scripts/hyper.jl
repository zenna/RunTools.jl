using RunToolsExample: train
using RunToolsExample: allparams
using SuParameters: Params
using RunTools

"Run with julia -L hyper.jl -E 'hyper(;)' -- --queue"
function hyper(; params = Params(), n = 10)
  params_ = merge(allparams(), params)
  paramsamples = rand(params_, n)
  display.(paramsamples)
  control(train, paramsamples)
end