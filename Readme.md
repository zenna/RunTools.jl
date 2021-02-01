# Run.jl

Tools for running simulations at scale

- Hyper Parameter Sweeping
- Interaction with Slurm

# Usage

- Define a `Param`s
```julia
module MyModule

using SuParameters
p = Params(niterations = 10)
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

Run from cmdline with: julia -L hyper.jl -E 'hyper(; params = Params(tags = [:leak]))' -- --queue



The main function called here is `control`

```julia
"""Run `sim` now, queue `sim`, or `dispatch` depending on `φs`

- `sim(φ)` Runs simulation taking parameters as input
- `args`: run parameters (taken from cmdline with Agparse by default)
- `φs`: iterable collection of parameters
- 'runfile' : file which will actually be run
Optional:
- `tags` : some tags, for your own reference
- 'name' : not sure
- 'gitinfo' : just gets get info
"""
function control(sim, φs, args = stdargs())
  ...
end
```