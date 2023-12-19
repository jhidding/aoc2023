# ~/~ begin <<docs/day19.md#src/Day19.jl>>[init]
module Day19

using AOC2023.Parsing: sequence, token, fmap, sep_by_p, pure_p, many_p, some_p, integer, skip

# ~/~ begin <<docs/day19.md#day19>>[init]
abstract type Instr end
struct Accept <: Instr end
struct Reject <: Instr end
struct Forward <: Instr
  label::Symbol
end

struct Condition
  attribute::Symbol
  operator::Symbol
  value::Integer
  action::Instr
end

struct Cond
  clauses::Vector{Condition}
  default::Instr
end

@kwdef struct Part
  x::Int
  m::Int
  a::Int
  s::Int
end

struct Input
  conds::IdDict{Symbol,Cond}
  parts::Vector{Part}
end
# ~/~ end
# ~/~ begin <<docs/day19.md#day19>>[1]
input_p = let
  enclosed(a, b) = p -> token(a) >>> p >> skip(token(b))
  sep_end_by(a, sep) = some_p(a >> skip(sep))
  symbol(re::Regex) = token(re) >> fmap(m -> Symbol(m.match))
  curly = enclosed("{", "}")

  action_p = token("R") >>> pure_p(Reject()) |
             token("A") >>> pure_p(Accept()) |
             symbol(r"[a-z]+") >> fmap(Forward)
  operator_p = symbol(r"[><]")
  condition_p = sequence(
    symbol(r"[xmas]"),
    operator_p, integer, token(":") >>> action_p) >>
                fmap(splat(Condition))
  cond_p = sequence(
    symbol(r"[a-z]+"),
    curly(sequence(sep_end_by(condition_p, token(",")), action_p)) >>
    fmap(splat(Cond)))

  attribute_p = sequence(symbol(r"[xmas]"), token("=") >>> integer) >>
                fmap(Tuple{Symbol,Int})
  item_p = curly(sep_by_p(attribute_p, token(","))) >> fmap(x -> Part(; x...))

  sequence(
    many_p(cond_p) >>
    fmap(IdDict{Symbol,Cond}),
    many_p(item_p)) >> fmap(splat(Input))
end
# ~/~ end
# ~/~ begin <<docs/day19.md#day19>>[2]
function compile(cond::Cond)
  compile_cond(p::Symbol) = function (c::Condition, else_clause)
    getattr(x::Symbol, attr::Symbol) = Expr(:., x, QuoteNode(attr))
    Expr(:if,
      Expr(:call, c.operator, getattr(p, c.attribute), c.value),
      c.action,
      else_clause)
  end

  Expr(:->, :p, foldr(compile_cond(:p), cond.clauses; init=cond.default))
end
# ~/~ end
# ~/~ begin <<docs/day19.md#day19>>[3]
function part1(inp)
  conds = IdDict(k => eval(compile(v)) for (k, v) in inp.conds)
  run(instr::Forward, part::Part) = run(Base.invokelatest(conds[instr.label], part), part)
  run(::Accept, part::Part) = part.x + part.m + part.a + part.s
  run(::Reject, ::Part) = 0

  inp.parts .|> (p -> run(Forward(:in), p)) |> sum
end
# ~/~ end
# ~/~ begin <<docs/day19.md#day19>>[4]
PartRange = IdDict{Symbol,UnitRange{Int}}
update(d, k, v) =
  let x = copy(d)
    x[k] = v
    x
  end
# ~/~ end
# ~/~ begin <<docs/day19.md#day19>>[5]
apply(condition::Condition, else_clause) = function (result::Vector{Tuple{Instr,PartRange}}, pr::PartRange)
  key = condition.attribute
  rng = pr[key]

  if condition.value in rng
    if condition.operator === :<
      push!(result, (condition.action, update(pr, key, rng.start:(condition.value-1))))
      else_clause(result, update(pr, key, condition.value:rng.stop))
    else
      push!(result, (condition.action, update(pr, key, condition.value+1:rng.stop)))
      else_clause(result, update(pr, key, rng.start:condition.value))
    end
  else
    if (condition.operator === :< && rng.stop < condition.value) ||
       (condition.operator === :> && rng.start > condition.value)
      push!(result, (condition.action, pr))
    else
      else_clause(result, pr)
    end
  end
end

apply(instr::Instr) = function (result::Vector{Tuple{Instr,PartRange}}, pr::PartRange)
  push!(result, (instr, pr))
end

apply(cond::Cond) = foldr(apply, cond.clauses; init=apply(cond.default))
# ~/~ end
# ~/~ begin <<docs/day19.md#day19>>[6]
function part2(inp)
  accepted = PartRange[]

  handle(i::Forward, pr::PartRange) = apply(inp.conds[i.label])(Tuple{Instr,PartRange}[], pr)
  handle(::Accept, pr::PartRange) = begin
    push!(accepted, pr)
    []
  end
  handle(::Reject, ::PartRange) = []

  x = [(Forward(:in), PartRange(i => 1:4000 for i in [:x, :m, :a, :s]))]
  while !isempty(x)
    x = reduce(vcat, x .|> splat(handle))
  end
  accepted .|> (pr -> pr |> values .|> length |> prod) |> sum
end
# ~/~ end

function main(io::IO)
  inp = read(io, String) |> input_p |> first
  println("Part 1: ", part1(inp))
  println("Part 2: ", part2(inp))
end

end
# ~/~ end
