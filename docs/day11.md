# Day 11: Cosmic Expansion
I figured out a recursion for finding the sum of all combinations of distances, when iterating those sorted:

$$t_{n+1} = 2t_{n} - t_{n-1} + nx_n,$$

where $x_n$ is the distance between each consecutive number. Since we're in Manhattan metric, we can compute the sum for columns and rows separately.
Now we don't need the sets to keep the empty space or anything. If $x_n > 1$ that automatically means there were empty columns or rows in between.

Note that by default, `findall` already returns cartesian indices sorted on second index.

``` {.julia file=src/Day11.jl}
module Day11

using Transducers

function main(io::IO)
  total(f) = last ∘ 
	  foldxl(((t1, t2), (n, dx)) -> (t2, 2t2 - t1 + n*dx); init=(0, 0)) ∘
    Enumerate() ∘ Map(((a, b),) ->  max(0, (b - a - 1) * f + 1)) ∘
    Consecutive(2, 1)

  universe = open(foldxl(hcat) ∘ Map(collect) ∘ readlines, "input/day11.txt", "r") .== '#'
  galaxies = findall(universe) |> Map(Tuple) |> collect
  solve(f) = (sort!(first.(galaxies)) |> total(f)) + (last.(galaxies) |> total(f))
  println("Part 1: ", solve(2))
  println("Part 2: ", solve(10^6))
end

end
```

``` title="output day 11"
{% include "day11.txt" %}
```

## Old solution

My old solution has a method to get all combinations of galaxies and then computes the distance between all of them, having a complexity of at least $O(n^2)$, while the solution above is more like $O(n\log n)$ (sorting being the most expensive operation).

??? "Old solution"

    ``` {.julia #day10-old-solution}
    function combinations(x)
      Channel() do c
        for i in eachindex(x)
          for j in eachindex(x[i+1:end])
            put!(c, (x[i], x[i+j]))
          end
        end
      end
    end

    function main(io::IO)
      input = readlines(io) .|> collect |> lines -> reduce(hcat, lines)
      empty_cols = Set(i for (i, c) in enumerate(eachcol(input)) if all(c .== '.'))
      empty_rows = Set(i for (i, r) in enumerate(eachrow(input)) if all(r .== '.'))
      function distance(a, b, expansion_factor)
        row_r = min(a[1], b[1]):max(a[1], b[1])
        col_r = min(a[2], b[2]):max(a[2], b[2])
        row_d = max(0, length(row_r) + length(intersect(row_r, empty_rows)) * (expansion_factor - 1) - 1)
        col_d = max(0, length(col_r) + length(intersect(col_r, empty_cols)) * (expansion_factor - 1) - 1)
        row_d + col_d
      end
      galaxies = findall(input .== '#') |> collect
      println("Part 1: ", (distance(a, b, 2) for (a, b) in combinations(galaxies)) |> sum)
      println("Part 2: ", (distance(a, b, 10^6) for (a, b) in combinations(galaxies)) |> sum)
    end
    ```

