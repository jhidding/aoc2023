# Day 12: Hot Springs

These are Japanese puzzles! I know how to solve those, but programming that is trickier. Dynamic programming is in order. I distinguish some special cases:

If no numbers are left, we can't have any `#` in the string.

``` {.julia #day12-cases}
if isempty(num)
  return '#' ∉ s ? 1 : 0
end
```

The minimum string length, given a sequence of numbers is $\sum n + #n - 1$.

``` {.julia #day12-cases}
if length(s) < sum(num) + length(num) - 1
  return 0
end
```

We may strip any excess space on either side of the string.

``` {.julia #day12-cases}
if startswith(s, ".") || endswith(s, ".")
  return count(num, strip(s, '.'))
end
```

If the string starts with `#`, we need to fill it with the given number, and the character after that cannot be `#`.

``` {.julia #day12-cases}
if s[1] == '#'
  if ('.' in s[1:num[1]]) || (get(s, num[1] + 1, '.') == '#')
    return 0
  end
  return count(num[2:end], s[num[1]+2:end])
end
```

In other cases we need to split between trying to replace a `?` with either `.` or `#` and see from there.

I use `Memoize.jl` to give me a nice `@memoize` macro.

``` {.julia file=src/Day12.jl}
module Day12

using ..Parsing: token, sep_by_p, integer, fmap, starmap, sequence
using Memoize

struct Puzzle
  pattern::String
  numbers::Vector{Int}
end

puzzle_p = sequence(
  token(r"[.?#]+") >> fmap(m -> m.match),
  sep_by_p(integer, token(","))
) >> starmap(Puzzle)

@memoize Dict function count(num::Vector{Int}, s::AbstractString)
  <<day12-cases>>

  return count(num, s[2:end]) + count(num, "#" * s[2:end])
end

function main(io::IO)
  input = readlines(io) .|> (first ∘ puzzle_p)
  n_solutions(p::Puzzle) = count(p.numbers, p.pattern)
  println("Part 1: ", input .|> n_solutions |> sum)
  five_fold(p::Puzzle) = Puzzle(join(repeat([p.pattern], 5), "?"), repeat(p.numbers, 5))
  println("Part 2: ", input .|> five_fold .|> n_solutions |> sum)
end

end
```

``` title="output day 12"
{% include "day12.txt" %}
```

