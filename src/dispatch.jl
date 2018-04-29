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


# Options
# 1. Only pass in varphi. Problem is all arguments are hidden
# 2. Only pass in kwargs. Problem is want to pass φ to sim
# 3. Do both, what about inconsistencies
"""
Run (or schedule to run) `sim` with params `φ`

- run `sim(opt)` locally non blocking in another process (if `runlocal==true`)
- run `sim(opt)` locally in this process (if `runnow==true`)
- schedule a job on slurm with sbatch (if `runsbatch==true`)
"""
function dispatchruns(sim,
                      φ;
                      runfile = φ[:runfile],
                      logdir = get(φ, :logdir, false),
                      runlocal = get(φ, :runlocal, false),
                      runsbatch = get(φ, :runsbatch, false),
                      runnow = get(φ, :runnow, false),
                      runpath = get(φ, :runpath, joinpath(Pkg.dir("RunTools", "src", "run.sh"))))
  mkpath(logdir)    # Create logdir
  optpath = joinpath(logdir, "$runname_.rd")    # Save the param file 

  # Schedule job using sbatch
  if runsbatch
    cmd =`sbatch -J $runname_ -o $runname_.out $runpath $runfile $optpath`
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