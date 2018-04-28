"Turn a key value into command line argument"
function stringify(k, v)
  if v == true
    "--$k"
  elseif v == false
    ""
  else
    "--$k=$v"
  end
end

function linearstring(d::Dict, ks::Symbol...)
  join([string(k, "_", d[k]) for k in ks], "_")
end

"Data Directory. Defaults to `homedir()` if `DATADIR`` not environment variable"
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
function log_dir(;root=datadir(), runname=randrunname(), group="nogroup", comment="")
  logdir = join([runname,
                 now(),
                 gethostname(),
                 comment],
                 "_")
  joinpath(root, "runs", group, logdir)
end