function stdargs()
  s = ArgParseSettings()
  @add_arg_table s begin
    "--dispatch", "-d"
      help = "Dispatch runs"
      action = :store_true
    "--now", "-n"
      help = "Run job now (in this thread)"
      action = :store_true
    "--here", "-l"
      help = "Run here, locally (spawns new processes)"
      action = :store_true
    "--sbatch", "-b"
      help = "Call with sbatch"
      action = :store_true
    "--queue", "-q"
      help = "Queue many locally"
      action = :store_true
    "--maxpoolsize", "-m"
      help = "Max number or processes to run at once"
      default = 2
      arg_type = Int
    "--param", "-p"
      help = "JLD2 Param file path"
      arg_type = String
    "--dryrun", "-y"
      help = "Dry Run"
      action = :store_true
  end
  args = parse_args(ARGS, s)
  if !(args["now"] ⊻ args["dispatch"] ⊻ args["queue"])
      throw(ArgumentError("Choose one of now, dispatch, queue"))
  end
  args
  Params((Symbol(k) => v for (k, v) in args)...)
end

"Commit of current directory"
gitinfo() = strip(read(`git describe --always`, String))
gitinfo(path::String) = strip(read(`cd $path` & `git describe --always`, String))
gitinfo(mod::Module) = gitinfo(Pkg.dir(string(mod)))
