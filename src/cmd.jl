using ArgParse

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
          help = "BSON Param file path"
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

# "Commit of current directory"
gitinfo() = strip(readstring(`git describe --always`))
gitinfo(path::String) = strip(readstring(`cd $path` & `git describe --always`))
gitinfo(mod::Module) = gitinfo(Pkg.dir(string(mod)))

# function stdargs()
#   s = ArgParseSettings()
#   @add_arg_table s begin
#     "--train"
#         help = "Train the model"
#     "--name", "-o"
#         help = "Name of job"
#         arg_type = Int
#         default = 0
#     "--logdir"
#         help = "Path to store data"
#         action = :store_true
#     "--resumepath"
#         help = "Path to resume parameters from"
#         required = true
#     "--nocuda"
#         help = "disables CUDA training"
#         required = true
#     "--dispatch"
#         help = "Dispatch many jobs"
#         required = true
#     "--optfile"
#         help = "Specify load file to get options from"
#         required = true
#     "--slurm"
#         help = "Use the SLURM batching system"
#         default = false
#     "--dryrun"
#         help = "Do a dry run, does not call subprocess"
#         default = false
#   end
# end


# def handle_log_dir(opt):
#   # if log_dir was specified, just keep that
#   # if log_dir not specified and name or group is specifeid
#   if opt["log_dir"] is None:
#     opt["log_dir"] = asl.util.io.log_dir(group=opt["group"], comment=opt["name"])


# def handle_cuda(opt):
#   if not opt["nocuda"] and not torch.cuda.is_available():
#     print("Chose CUDA but CUDA not available, continuing without CUDA!")
#     opt["cuda"] = False


# def handle_arch(opt):
#   opt["arch"] = asl.archs.convnet.ConvNet
#   opt["arch_opt"] = {}

# "Handle command line arguments"
# function handle_args(*add_cust_parses):
#   # add_cust_parses modifies the parses to add custom arguments
#   parser = argparse.ArgumentParser(description='')
#   add_std_args(parser)
#   add_dispatch_args(parser)
#   for add_cust_parse in add_cust_parses:
#     add_cust_parse(parser)
#   run_opt = parser.parse_args().__dict__

#   # handle_log_dir
#   handle_log_dir(run_opt)
#   handle_cuda(run_opt)
#   handle_arch(run_opt)
#   add_git_info(run_opt)
#   # dispatch_opt = run_opt[]
#   dargs = ["dispatch", "dryrun", "sample", "optfile", "jobsinchunk", "nsamples", "blocking", "slurm"]
#   dispatch_opt = {k : run_opt[k] for k in dargs}
#   return run_opt, dispatch_opt
# end

# def chunks(l, n):
#     """Yield successive n-sized chunks from l."""
#     for i in range(0, len(l), n):
#         yield l[i:i + n]

# function dispatch_runs(runpath, dispatch_opt, runopts):
#   # Split up the jobs into sets and dispatch
#   jobchunks = chunks(runopts, dispatch_opt["jobsinchunk"])
#   i = 0
#   for chunk in jobchunks:
#     i = i + 1
#     if dispatch_opt["slurm"]:
#       run_sbatch_chunk(runpath, chunk, dryrun=dispatch_opt["dryrun"])
#     else:
#       run_local_chunk(runpath, chunk, blocking=dispatch_opt["blocking"],
#                       dryrun=dispatch_opt["dryrun"])
#     print("Dispatched {} chunks".format(i))
#   end
# end
