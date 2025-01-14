using MomentClosure
using MomentClosure: define_μ, define_M, polynomial_propensities
using Symbolics: value, expand
using Test

μ = define_μ(3, 3)
@test μ[(0,0,0)] == 1
@test string(μ[(2,1,0)]) == "μ₂₁₀(t)"
@test string(μ[(0,0,3)]) == "μ₀₀₃(t)"
M = define_M(3, 3)
@test M[(1,0,0)] == 0
@test string(M[1,0,2]) == "M₁₀₂(t)"

@variables t x(t) y(t)
@parameters c
t = value(t); x = value(x); y = value(y); c = value(c)
smap = Dict([x => 1, y => 2])

expr = x*y + y^2
fcs, pwrs, mpwr = polynomial_propensities([expr], t, smap)
@test fcs[1] == [1., 1.] && pwrs[1] == [[1, 1], [0, 2]] && mpwr == 2

expr = x*(x^2+y) / (c+2)
fcs, pwrs, mpwr = polynomial_propensities([expand(expr)], t, smap)
@test all(isequal.(fcs[1], [1 / (2 + c), 1 / (2 + c)])) && pwrs[1] == [[3, 0], [1, 1]] && mpwr == 3

expr = c^2*x + y / c
fcs, pwrs, mpwr = polynomial_propensities([expr], t, smap)
@test all(isequal.(fcs[1], [c^2, 1 / c])) && pwrs[1] == [[1, 0], [0, 1]] && mpwr == 1

expr = x / (y+1) 
@test_throws ErrorException polynomial_propensities([expr], t, smap)