"Current commit of module"
current_commit(mod::Module) = current_commit(joinpath(dirname(pathof(mod), "..")))

"Commit of current directory. Stolen from Dr.Watson"
function current_commit(gitpath = pwd())
  # Here we test if the gitpath is a git repository.
  try
      repo = LibGit2.GitRepo(gitpath)
  catch er
      @warn "The current project directory is not a Git repository, "*
      "returning `nothing` instead of the commit id."
      return nothing
  end
  # then we return the current commit
  repo = LibGit2.GitRepo(gitpath)
  c = string(LibGit2.head_oid(repo))
  if LibGit2.isdirty(repo)
      @warn "The Git repository is dirty! Adding appropriate comment to "*
      "commit id..."
      return c*"_dirty"
  end
  return c
end