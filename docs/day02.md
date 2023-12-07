# Day 02: Cube Conundrum
So we need to parse some stuff. Good reason to implement a parser combinator. For those interested, I put the implementation at the end.

## Parsing a game
I store a `Game` as a $3 \times n$ `Matrix`, making the solution of the exercise easier.

``` {.julia #day02-parse}
struct Game
  n::Int
  draws::Matrix{Int}
end

token = token_p ∘ match_p

color_p = let
  red(x) = token("red") >>> pure_p([x, 0, 0])
  green(x) = token("green") >>> pure_p([0, x, 0])
  blue(x) = token("blue") >>> pure_p([0, 0, x])
  token_p(integer_p) >> (x -> red(x) | green(x) | blue(x))
end

draw_p = sep_by_p(color_p, token(",")) >> fmap(x -> reduce(.+, x))

game_p = sequence(
  token("Game") >>> integer_p >> skip(token(":")),
  sep_by_p(draw_p, token(";")) >> fmap(x -> reduce(hcat, x)')
) >> starmap(Game)
```

## The problem
For the first part, we need to check if a draw is possible from a `[12, 13, 14]` bag. Since we store a game as a matrix, we can use broadcasting to compare a game to the bag. All should be less or equal than the bag.

``` {.julia #day02-part1}
bag = [12, 13, 14]
possible(g::Game) = all(g.draws .<= bag')
println("Part 1: ", filter(possible, games) .|> (g -> g.n) |> sum)
```

In the second part we need to figure out the minimum contents of the bag.

``` {.julia #day02-part2}
minbag(g::Game) = maximum(g.draws; dims=1)
power(bag) = reduce(*, bag)
println("Part 2: ", games .|> minbag .|> power |> sum)
```

``` title="output day 2"
{% include 'day02.txt' %}
```

??? "main function and unit test"

    ``` {.julia file=src/Day02.jl}
    module Day02

    using ..Parsing: pure_p, integer_p, match_p, token_p, fmap, skip, sep_by_p, sequence, starmap

    <<day02-parse>>

    function main(io::IO)
      games = readlines(io) .|> (first ∘ game_p)
      <<day02-part1>>
      <<day02-part2>>
    end

    end
    ```

    ``` {.julia #test}
    @testset "day 2" begin
      using AOC2023.Day02: game_p, Game
      input = ["Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green",
        "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue",
        "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red",
        "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red",
        "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"]
      games = input .|> (first ∘ game_p)
      bag = [12, 13, 14]
      possible(g::Game) = all(g.draws .<= bag')
      @test filter(possible, games) .|> (g -> g.n) |> sum == 8

      minbag(g::Game) = maximum(g.draws; dims=1)
      power(bag) = reduce(*, bag)
      @test games .|> minbag .|> power |> sum == 2286
    end
    ```

## Parser combinators
A parser is a function from a `String` to `(T, String)`, where `T` is the return-type of the parser. If the parser fails, we throw an error using Julia's exceptions.
We put the parser inside a `struct` so that we can specialize methods for them. Then we need to overload function calls on that struct so that we retain its behaviour as a function.

| operator | meaning |
| --- | --- |
| `a >> f` | Monadic bind, `f` is called with the result of `a` |
| `a >>> b` | Ignore sequence, result of `a` is ignored |
| `a | b`  | Choice combinator |
| `~a` | Optional parser |

``` {.julia #parsing}
struct Parser
  fn::Function
end

function (p::Parser)(s::AbstractString)
  p.fn(s)
end
```

A Parser is a monad.

``` {.julia #parsing}
function bind_p(p::Parser, f::Function)
  function (inp::AbstractString)
    (x, next_inp) = p(inp)
    f(x)(next_inp)
  end |> Parser
end

function pure_p(v)
  function (inp::AbstractString)
    (v, inp)
  end |> Parser
end

Base.:>>(p::Parser, f::Function) = bind_p(p, f)

fmap(f) = pure_p ∘ f
fmap(f, p::Parser) = p >> fmap(f)

starmap(f) = (x -> pure_p(f(x...)))
thunk_p(f) = Parser(inp -> (f(), inp))
```

### Fails

``` {.julia #parsing}
abstract type Fail <: Exception end

struct Expected <: Fail
  what::AbstractString
  got::AbstractString
end

struct ChoiceFail <: Fail
  fails::Vector{Fail}
  ChoiceFail(f1::ChoiceFail, f2::ChoiceFail) = new([f1.fails; f2.fails])
  ChoiceFail(f1::Fail, f2::ChoiceFail) = new([f1, f2.fails...])
  ChoiceFail(f1::ChoiceFail, f2::Fail) = new([f1.fails..., f2])
  ChoiceFail(f1::Fail, f2::Fail) = new([f1, f2])
end
```

### Combinators
The `choice` combinator (and its `|` alias) runs first one parser. If that fails, then run the second one.

``` {.julia #parsing}
function choice_p(p1::Parser, p2::Parser)
  function (inp::AbstractString)
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
```

``` {.julia #parsing}
optional_p(p::Parser) = p | pure_p(nothing)
Base.:~(p::Parser) = optional_p(p)
```

The `>>>` operator binds two parsers, ignoring the result of the first one, while `skip` is a function ignoring the result of a second parser, so `p1 >> skip(p2)` returns the result of `p1` only if followed by something for which `p2` succeeds.

``` {.julia #parsing}
Base.:>>>(p1::Parser, p2::Parser) = p1 >> (_ -> p2)
skip(p::Parser) = v -> (p >> (_ -> pure_p(v)))
```

We have two kinds of `sequence` combinators. These are used to put multiple parsers in sequence, either by positional arguments resulting in a `Vector` or keyword arguments resulting in a `Dict`.

``` {.julia #parsing}
function sequence(; xargs...)
  function (inp::AbstractString)
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
  function (inp::AbstractString)
    result = []
    next = inp
    for p in vargs
      (v, next) = p(next)
      push!(result, v)
    end
    (result, next)
  end |> Parser
end
```

The `many_p` combinator parses `p` as often as it can, resulting in a `Vector` of results.

``` {.julia #parsing}
function many_p(p::Parser)
  function (inp::AbstractString)
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
```

A nice derived combinator is `sep_by` that can be used to parse comma-separated lists and what not.

``` {.julia #parsing}
sep_by_p(p::Parser, sep::Parser) =
  sequence(p, many_p(sep >>> p)) >> starmap((h, t) -> pushfirst!(t, h))
```

### Basic parsers
The `match_p(s)` parser succeeds if `startswith(inp, s)` is true. This is implemented for both `String` literals and `Regex` patterns.

``` {.julia #parsing}
function match_p(s::AbstractString)
  function (inp::AbstractString)
    if !startswith(inp, s)
      throw(Expected(s, inp))
    end
    (s, inp[length(s)+1:end])
  end |> Parser
end

function match_p(r::Regex)
  function (inp::AbstractString)
    if !startswith(inp, r)
      throw(Expected("$r", inp))
    end
    m = match(r, inp)
    (m, inp[length(m.match)+1:end])
  end |> Parser
end
```

The `token_p` parser is used to skip any whitespace after a token.

``` {.julia #parsing}
token_p(p::Parser, space::Parser=match_p(r"\s*")) = p >> skip(space)
```

A handy derived parser gets us integers.

``` {.julia #parsers}
integer_p = match_p(r"-?[1-9][0-9]*") >> fmap(x -> parse(Int, x.match))

integer = token_p(integer_p)
```

``` {.julia file=src/Parsing.jl}
module Parsing

<<parsing>>

<<parsers>>

end
```

### Tests
Some non-exhaustive testing

``` {.julia #test}
@testset "Parsing" begin
  using AOC2023.Parsing: match_p, integer_p, token_p, sequence, many_p

  @test match_p("hello")("hellogoodbye") == ("hello", "goodbye")

  p = match_p("a") >>> match_p("b")
  @test p("abc") == ("b", "c")

  p = sequence(match_p("a"), match_p("b"))
  @test p("abc") == (["a", "b"], "c")

  p = sequence(n=match_p("a"), m=match_p("b"))
  @test p("abc") == (Dict(:n => "a", :m => "b"), "c")

  p = many_p(token_p(integer_p))
  @test p("1  2 3  4 56    7 abc") == ([1, 2, 3, 4, 56, 7], "abc")
end
```

