`src/model.jl` constains model to run mnist includes a function `frain(φ)`

Here `φ` is a parameters object.  `src/params.jl` creates a distribution over parameters

`src/hyper.jl` contains a function which samples a bunch of parameters and runs them.  It uses RunTools to queue them, etc.