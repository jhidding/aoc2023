# Day 06: Wait For It

Distance travelled with pressing the button only at the start for $t_a$ milliseconds.

$$x = (t - t_a) (a t_a),$$

where $a$ is the accelleration in ${\rm ms}^{-2}$. This can be expanded, setting $a = 1 {\rm ms}^{-2}$,

$$x = t t_a - t_a^2.$$

Solving for a minimal distance $d$ we get a quadratic equation

$$t_a^2 - t t_a + d = 0.$$

The optimal play is $t_a = t / 2$, rounded to nearest integer. Then, a margin of

$$\Delta = {\sqrt{t^2 - 4d} \over 2},$$

around that will still win the game. We need to take care if $t$ is odd or even how to treat rounding.

In the case of odd $t$ and a $2\Delta$ of just $1$, we have two points included. In the case of even $t$ and a $2\Delta$ of just $2$, we have three points included. Number of wins keep increasing by 2, so we do some integer math hackery to get the right answers.

``` {.julia #day06}
function amount_of_wins(t::Int, d::Int)
  Δ2 = isqrt(t^2 - 4d)
  t & 1 == 0 ? Δ2 | 1 : (Δ2 + 1) & ~1
end
```

The second part is now also trivial.

``` {.julia file=src/Day06.jl}
module Day06

using ..Parsing: token, integer, sequence, starmap, some_p

struct Data
  time::Vector{Int}
  distance::Vector{Int}
end

data_p = sequence(
  token("Time:") >>> some_p(integer),
  token("Distance:") >>> some_p(integer)
) >> starmap(Data)

<<day06>>

function main(io::IO)
  input = read(io, String) |> data_p |> first
  println("Part 1: ", prod(amount_of_wins.(input.time, input.distance .+ 1)))
  rt = parse(Int, "$(input.time...)")
  rd = parse(Int, "$(input.distance...)")
  println("Part 2: ", amount_of_wins(rt, rd + 1))
end
end
```

``` title="output day 6"
{% include 'day06.txt' %}
```

