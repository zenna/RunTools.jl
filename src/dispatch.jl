"""Run `sim` now, queue `sim`, or `dispatch` depending on `φs`

- sim(φ) Runs simulation taking parameters as input
- args: run parameters
- φs: Collection of parameters
"""
function control(sim, φs, args = RunTools.stdargs())
  sim_ = args.dryrun ? RunTools.dry(sim) : sim
  @show args
  if args[:dispatch]
    RunTools.dispatchmany(sim, φs;
                          sbatch = args[:sbatch],
                          here = args[:here],
                          dryrun = args[:dryrun])
  elseif args.now 
    φ = RunTools.loadparams(args[:param])
    sim_(φ)
  elseif args.queue
    queue(φs, args[:maxpoolsize])
  end
end

"Dispatch many runs"
function dispatchmanylocal(sim, φs; ignoreexceptions = false, kwargs...)
  queue()
  queue(runcmds, stdout_, maxpoolsize)
end

"Dispatch many runs"
function dispatchmany(sim, φs; ignoreexceptions = Exception[], kwargs...)
  @showprogress 1 "Computing..." for φ in φs
    try
      dispatchruns(sim, φ; kwargs...)
    catch y
      !any(((y isa ex for ex in ignoreexceptions)...)) && rethrow(y)
      φ[:threw_exception] = true
      println("Exception caught: $y")
      println("continuing to next run")
    end
  end 
end

"`dry(f; verbose)` returns `dryf`, s.t `dryf(args...)` does nothing put print `f` and `args`"
function dry(f, verbose=true)
  function dryf(args...; kwargs...)
    verbose && println("Dry run of $f called with args: $args and kwargs $kwargs\n")
  end
end

"""
Run (or schedule to run) `sim` with params `φ`

- run `sim(opt)` locally non blocking in another process (if `runlocal==true`)
- run `sim(opt)` locally in this process (if `runnow==true`)
- schedule a job on slurm with sbatch (if `runsbatch==true`)
"""
function dispatchruns(sim,
                      φ;
                      # runnow = false,
                      sbatch = false,
                      here = false,
                      runname = get(φ, :runname, "noname"),
                      runfile = φ[:runfile],
                      logdir = get(φ, :logdir, false),
                      runpath = get(φ, :runpath, joinpath(Pkg.dir("RunTools", "src", "run.sh"))),
                      dryrun = get(φ, :dryrun, false))
  mkpath_ = dryrun ? dry(mkpath) : mkpath 
  run_ = dryrun ? dry(run) : run 
  sim_ = dryrun ? dry(sim) : sim
  saveparams_  = dryrun ? dry(RunTools.saveparams) : RunTools.saveparams

  mkpath_(logdir)    # Create logdir
  φpath = joinpath(φ[:logdir], "$(φ[:runname]).jld2")    # Save the param file 
  outpath = joinpath(φ[:logdir], "$(φ[:runname]).out")
  errpath = joinpath(φ[:logdir], "$(φ[:runname]).err")
  saveparams_(φ, φpath)

  # Schedule job using sbatch
  if sbatch
    cmd =`sbatch -J $runname -o $outpath $runpath $runfile --now --param $φpath`
    println("Scheduling sbatch: ", cmd)
    run_(cmd)
  end
  # Run job on local machine in new process
  if here
    cmd_ = ` --depwarn=no --depwarn=no $runfile --now --param $φpath`
    cmd = pipeline(cmd_, stdout = outpath, stderr = errpath)
    println("Running: ", cmd)
    run_(cmd)
  end
end

# """

# ```jldoctest
# runcmds = [`echo hi \$i` & `sleep $(rand(1:3))` for i = 1:3]
# ```
# """
# function queue(runcmds, maxpoolsize)
#   pool = []
#   cleanpool!(pool) = filter!(process_running, pool)
#   @showprogress 1 "Spawning runcmds..." for runcmd in runcmds
#     cleanpool!(pool)
#     while length(pool) >= maxpoolsize
#       cleanpool!(pool)
#       yield()
#     end
#     println("Spawning Process")
#     push!(pool, spawn(runcmd))
#   end
# end

"""

```jldoctest
runcmds = [`echo hi \$i` & `sleep $(rand(1:3))` for i = 1:3]
```
"""
function queue(φs, maxpoolsize)
  pool = []
  cleanpool!(pool) = filter!(process_running, pool)
  @showprogress 1 "Spawning runcmds..." for φ in φs
    cleanpool!(pool)
    while length(pool) >= maxpoolsize
      cleanpool!(pool)
      yield()
    end

    mkpath(φ[:logdir])    # Create logdir
    φpath = joinpath(φ[:logdir], "$(φ[:runname]).jld2")    # Save the param file 
    outpath = joinpath(φ[:logdir], "$(φ[:runname]).out")
    errpath = joinpath(φ[:logdir], "$(φ[:runname]).err")
    saveparams(φ, φpath)
    runcmd_ = `julia --depwarn=no $(φ[:runfile]) --now --param $φpath`
    runcmd = pipeline(runcmd_, stdout = outpath, stderr = errpath)
    println("Spawning Process $runcmd")
    push!(pool, spawn(runcmd))
  end
end

# function queue(runcmds, stdout_, maxpoolsize)
#   queue((pipeline(runcmd, stdout=stdout_)) for (runcmd, stdout_) in zip(runcmds, outfiles))
# end

# function queue(φs)
#   saveparams_(φ, φpath)
# end