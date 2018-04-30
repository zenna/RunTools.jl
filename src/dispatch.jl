"Dispatch many runs"
function dispatchmany(sim, φs; ignoreexceptions = false, kwargs...)
  @showprogress 1 "Computing..." for φ in φs
    try
      dispatchruns(sim, φ; kwargs...)
    catch y
      !ignoreexceptions && rethrow(y)
      φ[:threw_exception] = true
      println("Exception caught: $y")
      println("continuing to next run")
    end
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
                      runpath = get(φ, :runpath, joinpath(Pkg.dir("RunTools", "src", "run.sh"))))
  mkpath(logdir)    # Create logdir
  optpath = joinpath(logdir, "$runname.rd")    # Save the param file 

  # Schedule job using sbatch
  if runsbatch
    cmd =`sbatch -J $runname -o $runname.out $runpath $runfile $optpath`
    println("Scheduling sbatch: ", cmd)
    run(cmd)
  end
  # Run job on local machine in new process
  if runlocal
    cmd = `julia $runfile $optpath`
    println("Running: ", cmd)
    run(cmd)
  end
  # Run right now on this process
  if runnow
    sim(φ)
  end
end


"""

```jldoctest
tasks = [`echo hi \$i` & `sleep $(rand(1:3))` for i = 1:3]
```

"""
function queue(tasks, maxpoolsize)
  pool = []
  @showprogress 1 "Spawning Tasks..." for task in tasks
    cleanpool!(pool)
    while length(pool) >= maxpoolsize
      cleanpool!(pool)
      @show task
      # @show length(pool)
      # @show process_running.(pool)
    end
    println("Spawning Process")
    push!(pool, spawn(task))
  end
end

function queue(tasks, stdout_, maxpoolsize)
  queue((pipeline(task), stdout=stdout_) for (task, stdout_) in zip(tasks, outfiles))
end

function pool(sim, φ)
  # if the pool is empty then add to it, otherwise
end
