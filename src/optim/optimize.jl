import IterTools

# take!(x::Real) = x
# take!(x::Array{<:Real}) = x
# take!(f::Function) = f()

maxiters(n) = data -> data.i < n

"""
Optimization.
# Arguments
- `step!(cb_data, callbacks)`: takes a gradient step and returns the loss
   must also call populate cb_data with any additiona data and call callbacks
   e.g..,
   ```cb_data_ = merge(cb_data, @NT(loss = cur_loss))
      foreach(cb->cb(cb_data_), callbacks)```
"""
function optimize(step!::Function;
                  cont = maxiters(1000))
  i = 0
  while true
    loss = step!()
    lens(:loppend, (i = i, loss = loss))
    !cont((i = i, loss = loss)) && break
    i += 1
  end
end