# Day 18: Lavaduct Lagoon
This is very similar to the problem on [Day 10](day10.md).

## Parsing
I parse the instructions directly to tuples of $(\Delta x, \Delta y)$.

``` {.julia #day18}
const dirs = eachrow([0 1; 1 0; 0 -1; -1 0]) .|> Tuple
const char2dir = Dict(zip("RDLU", dirs))

struct Instruction
  dx::NTuple{2, Int}
  color::UInt32
end

instruction_p = sequence(
  sequence(token(r"[RDLU]") >> fmap(m -> char2dir[m.match[1]]), integer) >>
    fmap(splat(.*)),
  token("(#") >>> token(r"[0-9a-f]{6}") >> skip(token(")")) >>
    fmap(m -> parse(UInt32, m.match, base=16))) >> fmap(splat(Instruction))
```

## Tracing the outside
We can see if we turn left or right by looking at the sign of the cross-product between consecutive steps.

$$a \times b = a_y b_x - a_x b_y$$

While tracing the path, we need to make sure to stick to the outside of the curve. When taking a right turn, we need to extend the previous step by one; at left turns, the next step is shortened by one. When going straight, we don't modify the path.

``` {.julia #day18}
cross(a, b) = a[1] * b[2] - a[2] * b[1]

outside(dx1, dx2) = let s = cross(dx1, dx2)
	s < 0 ? (dx1 .+ sign.(dx1), dx2) :
	  (s > 0 ? (dx1, dx2 .- sign.(dx2)) :
      (dx1, dx2))
end
```

## Area
Using `Transducers.jl` the function for computing the area becomes a one-liner, the sum of consecutive cross-products on the absolute coordinates of the polygon.

``` {.julia #day18}
area(path) = path |>
  ScanEmit(outside, (0, 0), x -> x .+ sign.(x)) |>
  Scan(.+) |>
  Consecutive(2) |>
  Map(splat(cross)) |> sum |> abs
```

One thing I don't understand is, where did the factor $1/2$ go? I tried this out on small examples and it seems to work as long as edges are in grid directions. The `Consecutive(2)` transducer generates `[(1,2), (3, 4), (5, 6)...]` not `[(1,2), (2,3), (3,4)...]` as I expected. Somehow, the math works out and for grid walks, the odd terms exactly match the even terms... Lucky me.

## Main

``` {.julia file=src/Day18.jl}
module Day18

using ..Parsing: sequence, token, integer, fmap, skip
using Transducers

<<day18>>

function main(io::IO)
  input = readlines(io) .|> (first ∘ instruction_p)
  path1 = input .|> (x -> x.dx)
  println("Part 1: ", area(path1))
  path2 = input .|> (x -> dirs[x.color & 0xf + 1] .* (x.color >> 4))
  println("Part 2: ", area(path2))
end

end
```

``` title="output day 18"
{% include "day18.txt" %}
```
