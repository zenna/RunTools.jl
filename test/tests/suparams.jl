using RunTools
using Test
using Omega

x = SuParams()
x.a = 4
@test rand(x.a) == 4

x = SuParams()
x.a = 4;
x.b = x.a;
@test rand(x.b) == 4

x = SuParams()
x.b = x.a + 34
@test ismissing(rand(x.a))
x.a = 4
@test rand(x.b) == 38

x = SuParams()
x.b = x.a + 34
x.a = 4
x.a = 400
@test rand(x.b) == 400 + 34

x = SuParams()
x.b = normal(0, 1)
x.a = x.b + 5
@test rand(x.a) isa AbstractFloat
x.b = poisson(2)
@test rand(x.a) isa Integer

