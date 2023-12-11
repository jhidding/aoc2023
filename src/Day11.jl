# ~/~ begin <<docs/day11.md#src/Day11.jl>>[init]
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
# ~/~ end