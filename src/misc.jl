"Data Directory. Defaults to `homedir()` if `ENV["DATADIR"]` undefined"
function datadir()
  if "DATADIR" in keys(ENV)
    ENV["DATADIR"]
  else
    homedir()
  end
end

pathfromgroup(group; root=datadir()) = joinpath(root, "runs", group)

"Random Run Name e.g. `run_abcbedl``"
randrunname(len=5)::Symbol = Symbol(:run_, randstring(len))

"Log directory, e.g. ~/datadir/mnist/Oct14_02-43-22_my_comp/"
function logdir(;root=datadir(), runname=randrunname(), tags="nogroup", comment="")
  logdir = join([runname,
                 now(),
                 gethostname(),
                 comment],
                 "_")
  joinpath(root, "runs", group, logdir)
end