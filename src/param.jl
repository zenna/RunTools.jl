"Parameter Set"
struct Params{I, T} <: AbstractDict{I, T}
  d::Dict{I, T}
end

function Base.getproperty(φ::Params, k::Symbol)
  d_ = getfield(φ, :d)
  if k == :d
    d_
  else
    d_[k]
  end
end

function Base.setproperty!(φ::Params, name::Symbol, x)
  if name  == :d
    error("Cannot assign d as a property of params.  Use another name!")
  else
    φ.d[name] = x
  end
end

Params(; kwargs...) = isempty(kwargs) ? Params(Dict{Symbol, Any}()) : Params(kwargs...)
Params(x::NamedTuple) = Params(Dict(k => v for (k, v) in pairs(x)))
Params(ps::Pair...) = Params(Dict(ps))

# Base.as_kwargs(φ::Params) = Base.as_kwargs(φ.d)
Base.values(φ::Params) = values(φ.d)
Base.keys(φ::Params) = keys(φ.d)
Base.get(φ::Params, k, v) = get(φ.d, k, v)
Base.get!(φ::Params, k, v) = get!(φ.d, k, v)
Base.getindex(θ::Params{I}, i::I) where I = θ.d[i]
"Set default value"
Base.setindex!(θ::Params{I}, v, i::I) where I = θ.d[i] = v 
Base.merge(a::Params, b::Params...) = Params(merge(a.d, (φ.d for φ in b)...))

Base.iterate(φ::Params) = iterate(φ.d)
Base.iterate(φ::Params, state) = iterate(φ.d, state)

"""Product space of `Param` from  product of values(φ)

```jldoctest
julia> φ = Params(Dict(:a => [1,2,3], :b => ["x", "y"]))
Params
Dict{Symbol,Any} with 2 entries:
  :a => [1, 2, 3]
  :b => String["x", "y"]

julia> length(prod(φ))
6
```
"""
function Base.prod(toenum::Params)
  q = Base.Iterators.product(values(toenum)...)
  (Params(Dict(zip(keys(toenum), v))) for v in q)
end

# Rand
# dag(v, ω) = v
# dag(v::Params, ω) = v(ω)
# gag(v, ω) = v
# gag(v::Omega.RandVar, ω) = dag(v(ω), ω)
# gag(v::Params, ω) = v(ω)

# function (φ::Params)(ω::Omega.Ω)
#   Params(Dict(k => gag(v, ω) for (k, v) in φ.d))
# end
# Base.rand(ω::Ω, φ::Params) = φ(ω)
# Base.rand(φ::Params) = φ(Omega.defΩ()())

"Convert φ into namedtuple, useful for type stability / performance"
namedtuple(φ::Params) = NamedTuple{(keys(φ)...,)}((values(φ)...,))

# IO
function saveparams(param::Params, fn::String; verbose = true)
  verbose && println("Saving params to $fn")
  JLD2.@save fn param
end

"Load Paramas from path `fn`"
loadparams(fn)::Params = (JLD2.@load fn param; param)

## Show
## ====
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

Base.show(io::IO, φ::Params) = show(io, φ.d)
Base.display(φ::Params) = (println("Params"); display(φ.d))

