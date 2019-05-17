function stdargs()
  s = ArgParseSettings()
  @add_arg_table s begin
    "--dispatch", "-d"
      help = "Dispatch runs (accompany this with --spawnlocal or --sbatch)"
      action = :store_true
    "--fromparams", "-n"
      help = "Run job fromparams (in this thread) from param file"
      action = :store_true
    "--queue", "-q"
      help = "Queue many locally"
      action = :store_true
    "--spawnlocal", "-l"
      help = "Run spawnlocal, locally (spawns new processes)"
      action = :store_true
    "--sbatch", "-b"
      help = "Call with sbatch"
      action = :store_true
    "--maxpoolsize", "-m"
      help = "Max number or processes to run at once"
      default = 2
      arg_type = Int
    "--params", "-p"
      help = "JLD2 Params file path"
      arg_type = String
    "--dryrun", "-y"
      help = "Dry Run"
      action = :store_true
  end
  args = parse_args(ARGS, s)
  if !(args["fromparams"] ⊻ args["dispatch"] ⊻ args["queue"])
      throw(ArgumentError("Choose one of fromparams, dispatch, queue"))
  end

  if args["fromparams"] && !isnothing(args["params"])
    throw(ArgumentError("Must define Params file with --fromparams"))
  end

  args
  Params((Symbol(k) => v for (k, v) in args)...)
end

"Commit of current directory"
gitinfo() = strip(read(`git describe --always`, String))
gitinfo(path::String) = strip(read(`cd $path` & `git describe --always`, String))
gitinfo(mod::Module) = gitinfo(Pkg.dir(string(mod)))
