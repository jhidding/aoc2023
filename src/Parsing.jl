# ~/~ begin <<docs/day02.md#src/Parsing.jl>>[init]
module Parsing

# ~/~ begin <<docs/day02.md#parsing>>[init]
struct Parser
  fn::Function
end

function (p::Parser)(s::String)
  p.fn(s)
end
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[1]
function bind_p(p::Parser, f::Function)
  function (inp::String)
    (x, next_inp) = p(inp)
    f(x)(next_inp)
  end |> Parser
end

function pure_p(v)
  function (inp::String)
    (v, inp)
  end |> Parser
end

Base.:>>(p::Parser, f::Function) = bind_p(p, f)

fmap(f) = pure_p ∘ f
fmap(f, p::Parser) = p >> fmap(f)

starmap(f) = (x -> pure_p(f(x...)))
thunk_p(f) = Parser(inp -> (f(), inp))
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[2]
abstract type Fail <: Exception end

struct Expected <: Fail
  what::String
  got::String
end

struct ChoiceFail <: Fail
  fails::Vector{Fail}
  ChoiceFail(f1::ChoiceFail, f2::ChoiceFail) = new([f1.fails; f2.fails])
  ChoiceFail(f1::Fail, f2::ChoiceFail) = new([f1, f2.fails...])
  ChoiceFail(f1::ChoiceFail, f2::Fail) = new([f1.fails..., f2])
  ChoiceFail(f1::Fail, f2::Fail) = new([f1, f2])
end
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[3]
function choice_p(p1::Parser, p2::Parser)
  function (inp::String)
    try
      p1(inp)
    catch e1
      try
        p2(inp)
      catch e2
        throw(ChoiceFail(e1, e2))
      end
    end
  end |> Parser
end

Base.:|(p1::Parser, p2::Parser) = choice_p(p1, p2)
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[4]
optional_p(p::Parser) = p | pure_p(nothing)
Base.:~(p::Parser) = optional_p(p)
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[5]
Base.:>>>(p1::Parser, p2::Parser) = p1 >> (_ -> p2)
skip(p::Parser) = v -> (p >> (_ -> pure_p(v)))
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[6]
function sequence(; xargs...)
  function (inp::String)
    result = Dict()
    next = inp
    for (k, p) in xargs
      (v, next) = p(next)
      if string(k)[1] != '_'
        result[k] = v
      end
    end
    return (result, next)
  end |> Parser
end

function sequence(vargs...)
  function (inp::String)
    result = []
    next = inp
    for p in vargs
      (v, next) = p(next)
      push!(result, v)
    end
    (result, next)
  end |> Parser
end
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[7]
function many_p(p::Parser)
  function (inp::String)
    result = []
    while true
      try
        (x, inp) = p(inp)
        push!(result, x)
      catch
        return (result, inp)
      end
    end
  end |> Parser
end
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[8]
sep_by_p(p::Parser, sep::Parser) =
  sequence(p, many_p(sep >>> p)) >> starmap((h, t) -> pushfirst!(t, h))
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[9]
function match_p(s::String)
  function (inp::String)
    if !startswith(inp, s)
      throw(Expected(s, inp))
    end
    (s, inp[length(s)+1:end])
  end |> Parser
end

function match_p(r::Regex)
  function (inp::String)
    if !startswith(inp, r)
      throw(Expected("$r", inp))
    end
    m = match(r, inp)
    (m, inp[length(m.match)+1:end])
  end |> Parser
end
# ~/~ end
# ~/~ begin <<docs/day02.md#parsing>>[10]
token_p(p::Parser, space::Parser=match_p(r"\s*")) = p >> skip(space)
# ~/~ end

# ~/~ begin <<docs/day04.md#parsers>>[init]
some_p(p::Parser) = sequence(p, many_p(p)) >>
                    starmap((first, rest) -> pushfirst!(rest, first))

token = token_p ∘ match_p
# ~/~ end
# ~/~ begin <<docs/day02.md#parsers>>[0]
integer_p = match_p(r"-?[1-9][0-9]*") >> fmap(x -> parse(Int, x.match))

integer = token_p(integer_p)
# ~/~ end

end
# ~/~ end