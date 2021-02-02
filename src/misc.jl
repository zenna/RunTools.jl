"Data Directory. Defaults to `homedir()` if `ENV[DATADIR]` undefined"
function datadir()
  if "DATADIR" in keys(ENV)
    ENV["DATADIR"]
  else
    path = homedir()
    println("Environment variable DATADIR not set, using $path")
    return path
  end
end

pathfromgroup(group; root=datadir()) = joinpath(root, "runs", group)

"Random Run Name e.g. `run_abcbedl``"
randrunname(; len = 5) = randrunname(Random.GLOBAL_RNG; len = len)

"Random Run Name e.g. `run_abcbedl``"
randrunname(rng::AbstractRNG; len = 5) = Symbol("rn" * Random.randstring(rng, len))


"Log directory, e.g. ~/datadir/mnist/Oct14_02-43-22_my_comp/"
function logdir(;root=datadir(),
                 runname=randrunname(),
                 tags::Vector=["notags"],
                 comment="")
  logdir = join([runname,
                 now(),
                 gethostname()],
                 "_")
  joinpath(root, "runs", join(tags, "_"), logdir)
end