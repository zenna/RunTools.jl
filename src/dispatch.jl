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

function dry(f, verbose=true)
  function dryf(args...; kwargs...)
    verbose && println("Dry run of $f called with args: $args and kwargs $kwargs")
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
                      runname = get(φ, :runname, "noname"),
                      runfile = φ[:runfile],
                      logdir = get(φ, :logdir, false),
                      runlocal = get(φ, :runlocal, false),
                      runsbatch = get(φ, :runsbatch, false),
                      runnow = get(φ, :runnow, false),
                      runpath = get(φ, :runpath, joinpath(Pkg.dir("RunTools", "src", "run.sh"))),
                      dryrun = get(φ, :dryrun, false))
  mkpath_ = dryrun ? dry(mkpath) : mkpath 
  run_ = dryrun ? dry(run) : run 
  sim_ = dryrun ? dry(sim) : sim
  @show dryrun

  mkpath_(logdir)    # Create logdir
  optpath = joinpath(logdir, "$runname.rd")    # Save the param file 

  # Schedule job using sbatch
  if runsbatch
    cmd =`sbatch -J $runname -o $runname.out $runpath $runfile $optpath`
    println("Scheduling sbatch: ", cmd)
    run_(cmd)
  end
  # Run job on local machine in new process
  if runlocal
    cmd = `julia $runfile $optpath`
    println("Running: ", cmd)
    run_(cmd)
  end
  # Run right now on this process
  if runnow
    sim_(φ)
  end
end


"""

```jldoctest
runcmds = [`echo hi \$i` & `sleep $(rand(1:3))` for i = 1:3]
```

"""
function queue(runcmds, maxpoolsize)
  pool = []
  cleanpool!(pool) = filter!(process_running, pool)
  @showprogress 1 "Spawning runcmds..." for runcmd in runcmds
    cleanpool!(pool)
    while length(pool) >= maxpoolsize
      cleanpool!(pool)
      yield()
    end
    println("Spawning Process")
    push!(pool, spawn(runcmd))
  end
end

function queue(runcmds, stdout_, maxpoolsize)
  queue((pipeline(runcmd, stdout=stdout_)) for (runcmd, stdout_) in zip(runcmds, outfiles))
end
