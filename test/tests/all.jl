module MyModule
using SuParameters
p() = Params(niterations = 10)

function simulate(p)
  total = 0
  for i = 1:p.niterations
    total += rand()
  end
end

function hyper(; params = Params(), n = 10)
  params_ = merge(p(), params)
  paramsamples = rand(params_, n)
  display.(paramsamples)
  control(simulate, paramsamples)
end