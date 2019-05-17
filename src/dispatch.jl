
"`dry(f; verbose)` returns `dryf`, s.t `dryf(args...)` just prints `f(args)`"
function dry(f, verbose = true)
  function dryf(args...; kwargs...)
    verbose && println("Dryrun: $f($args; $kwargs)\n")
  end
end

"""Run `sim` now, queue `sim`, or `dispatch` depending on `φs`

- `sim(φ)` Runs simulation taking parameters as input
- `args`: run parameters (taken from cmdline with Agparse by default)
- `φs`: iterable collection of parameters
"""
function control(sim, φs, args = stdargs())
  sim_ = args.dryrun ? dry(sim) : sim
  display(args)
  if args.dispatch
    dispatch(sim, φs; sbatch = args.sbatch,
                      spawnlocal = args.spawnlocal,
                      dryrun = args.dryrun)
  elseif args.fromparams
    runnow(sim_, args)
  elseif args.queue
    queue(φs; maxpoolsize = args.maxpoolsize)
  end
end

"Run from params"
function runnow(sim, args = stdargs())
  φ = loadparams(args.param)
  sim(φ)
end

"Dispatch many runs"
function dispatch(sim, φs; ignoreexceptions = Exception[], kwargs...)
  @showprogress 1 "Dispatching runs..." for φ in φs
    try
      dispatch(sim, φ; kwargs...)
    catch y
      # !any(((y isa ex for ex in ignoreexceptions)...)) && rethrow(y)
      φ[:threw_exception] = true
      println("Exception caught: $y")
      println("continuing to next run")
    end
  end 
end

gencmd(runfile, simname, paramspath) = 
  `julia --color=yes -L $runfile -E 'import RunTools; '$simname'(RunTools.loadparams("'$paramspath'"))'`


"""
Run (or schedule to run) `sim` with params `φ`

- run `sim(opt)` locally non blocking in another process (if `runlocal==true`)
- run `sim(opt)` locally in this process (if `runnow==true`)
- schedule a job on slurm with sbatch (if `runsbatch==true`)
"""
function dispatch(sim,
                  φ::Params;
                  # runnow = false,
                  sbatch = false,
                  spawnlocal = false,
                  runname = get(φ, :runname, "noname"),
                  runfile = φ.runfile,
                  logdir = get(φ, :logdir, false),
                  runpath = get(φ, :runpath, joinpath(dirname(pathof(RunTools)), "run.sh")),
                  dryrun = get(φ, :dryrun, false))
  mkpath_ = dryrun ? dry(mkpath) : mkpath 
  run_ = dryrun ? dry(run) : run 
  sim_ = dryrun ? dry(sim) : sim
  saveparams_  = dryrun ? dry(saveparams) : saveparams

  mkpath_(logdir)    # Create logdir
  paramspath = joinpath(φ.logdir, "$(φ.runname).jld2")    # Save the param file 
  outpath = joinpath(φ.logdir, "$(φ.runname).out")
  errpath = joinpath(φ.logdir, "$(φ.runname).err")
  simname = φ.simname
  saveparams_(φ, paramspath)

  # Schedule job using sbatch
  if sbatch
    cmd =`sbatch -J $runname -o $outpath $runpath --color=yes -L $runfile -E 'import RunTools; '$simname'(RunTools.loadparams("'$paramspath'"))'`
    println("Scheduling sbatch: ", cmd)
    run_(cmd)
  end
  # Run job on local machine in new process
  if spawnlocal
    cmd_ = gencmd(runfile, φ.simname, paramspath)
    cmd = pipeline(cmd_, stdout = outpath, stderr = errpath)
    println("Running: ", cmd)
    run_(cmd)
  end
end

"""
`queue(φs; maxpoolsize)`

Executes up to `maxpoolsize` number of jobs in queue, locally

```jldoctest
runcmds = [`echo hi \$i` & `sleep $(rand(1:3))` for i = 1:3]
```
"""
function queue(φs; maxpoolsize)
  pool = []
  cleanpool!(pool) = filter!(process_running, pool)
  @showprogress 1 "Spawning runcmds..." for φ in φs
    cleanpool!(pool)

    # Wait until pool is not full 
    while length(pool) >= maxpoolsize
      cleanpool!(pool)
      yield()
    end

    mkpath(φ.logdir)    # Create logdir
    paramspath = joinpath(φ.logdir, "$(φ.runname).jld2")    # Save the param file 
    outpath = joinpath(φ.logdir, "$(φ.runname).out")
    errpath = joinpath(φ.logdir, "$(φ.runname).err")
    saveparams(φ, paramspath)

    cmd_ = gencmd(φ.runfile, φ.simname, paramspath)
    cmd = pipeline(cmd_, stdout = outpath, stderr = errpath)

    println("Run $cmd")
    push!(pool, run(cmd; wait = false))
  end
end

# function queue(runcmds, stdout_, maxpoolsize)
#   queue((pipeline(runcmd, stdout=stdout_)) for (runcmd, stdout_) in zip(runcmds, outfiles))
# end

# function queue(φs)
#   saveparams_(φ, paramspath)
# end