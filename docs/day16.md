# Day 16: The Floor Will Be Lava

Write the direction of the laser as two coordinates.
At a slash or back-slash, the reflected direction is found by swapping the axes or swapping and negating.

``` {.julia #day16}
swap(i::CartesianIndex) = CartesianIndex(i[2], i[1])
split(i::CartesianIndex) = (swap(i), -swap(i))
```

To keep track of where the laser has already visited, encode the direction into a single integer.

``` {.julia #day16}
dirmap(i::CartesianIndex) = i[1] == 0 ?
                            convert(UInt8, (i[2] + 3) >> 1) :
                            convert(UInt8, (i[1] + 3) << 1)
```

Map all interactions on the map from characters to functions.

``` {.julia #day16}
where_to = Dict(
  '\\' => i -> (swap(i), nothing),
  '/' => i -> (-swap(i), nothing),
  '-' => i -> i[1] == 0 ? (i, nothing) : split(i),
  '|' => i -> i[1] == 0 ? split(i) : (i, nothing),
  '.' => i -> (i, nothing)
)
```

For part 1 we can track the laser using a stack to manage splits

``` {.julia #day16}
function part1(inp, x=CartesianIndex(1, 1), dx=CartesianIndex(0, 1))
  stack = [(x, dx)]
  dirs = zeros(Int, size(inp)...)

  check(x, dx) = checkbounds(Bool, inp, x) && (dirs[x] & dirmap(dx) == 0)

  while !isempty(stack)
    (x, dx) = stack[end]
    dirs[x] |= dirmap(dx)
    (one, other) = where_to[inp[x]](dx)

    if check(x + one, one)
      stack[end] = (x + one, one)
    else
      pop!(stack)
    end

    if !isnothing(other) && check(x + other, other)
      push!(stack, (x + other, other))
    end
  end

  sum(dirs .!= 0)
end
```

For part 2 we can brute force on all starting positions, and get the result in about half a second.

``` {.julia file=src/Day16.jl}
module Day16

<<day16>>

function borders(s)
  Iterators.flatten((
    ((CartesianIndex(1, i), CartesianIndex(1, 0)) for i in 1:s[2]),
    ((CartesianIndex(i, 1), CartesianIndex(0, 1)) for i in 1:s[1]),
    ((CartesianIndex(s[1], i), CartesianIndex(-1, 0)) for i in 1:s[2]),
    ((CartesianIndex(i, s[2]), CartesianIndex(0, -1)) for i in 1:s[2])))
end

function main(io::IO)
  inp = readlines(io) .|> collect |> stack |> permutedims
  println("Part 1: ", part1(inp))
  println("Part 2: ", maximum(((x, dx),) -> part1(inp, x, dx), borders(size(inp))))
end

end
```

``` title="output day 16"
{% include "day16.txt" %}
```

