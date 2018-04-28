"Dispatch many runs"
function dispatchmany(φs, sim, ignoreexceptions = false)
  @showprogress 1 "Computing..." for φ in φs
  try
    dispatchruns(φ...)
  catch y
    φ[:threw_exception] = true
    println("Exception caught: $y")
    println("continuing to next run")
  end
end


"""
Run (or schedule to run) `sim` with params `φ`

- run `sim(opt)` locally non blocking in another process (if `runlocal==true`)
- run `sim(opt)` locally in this process (if `runnow==true`)
- schedule a job on slurm with sbatch (if `runsbatch==true`)
"""
function dispatchruns(φs,
                      sim,
                      runlocal = false,
                      runsbatch = false,
                      runnow = false,
                      runpath = joinpath(Pkg.dir("RunTools", "src", "run.sh")))
  # Create logdir
  mkpath(logdir_)

  # Save the param file 
  optpath = joinpath(logdir_, "$runname_.rd")

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
    sim(opt)
  end
end