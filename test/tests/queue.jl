using Omega
using RunTools  
p = Params(sleetime = poisson(3), simname = "sim", logdir = ".", runname = "testqueuerun", runfile = @__FILE__)

function sim(p)
  sleep(p.sleeptime)
end

hyper() = control(sim, rand(p, 10))
cmd = `julia -L queue.jl -E 'hyper()' -- --queue`
# run(cmd)