# RunTools.jl

Tools for running simulations at scale

- Hyper Parameter Sweeping
- Interaction with Slurm

## Usage

- Define a `Param`s

```julia
module MyModule
using Random

mutable struct Params
  niterations::Int
  verbose::Bool
end

function f(rng)
  rand(rng)
end
```

- Define a simulation function which takes a paramter value as its single argument

Example:

```julia
function simulate(p)
  total = 0
  for i = 1:p.niterations
    total += rand()
  end
end

end # end module

```

- Then write a file, by convention `hyper.jl`.  I often put this in MyPackage.jl/scripts

```julia
using RunTools
using MyModule

# Run from cmdline with: julia -L hyper.jl -E 'hyper(; params = Params(tags = [:leak]))' -- --queue
function hyper(; params = Params(), n = 10)
  params_ = merge(p(), params)
  paramsamples = rand(params_, n)
  display.(paramsamples)
  control(infer, paramsamples)
end
```
