# ~/~ begin <<docs/day10.md#src/viz-day10.jl>>[init]
#| description: plot day 10
#| creates: docs/fig/day10.svg
#| requires: src/Day10.jl input/day10.txt
#| collect: figures

module PlotDay10

using AOC2023.Day10: read_input, plot_loop
using CairoMakie

function main(io)
  pm, sp = open(read_input, "input/day10.txt", "r")
  tr, path, inner = plot_loop(pm, sp)
  fig = Figure()
  ax = Axis(fig[1, 1])
  lines!(ax, path)
  poly!(ax, inner .- [0.5, 0.5]; color=:green)
  save("docs/fig/day10.svg", fig)
end

end

open(PlotDay10.main, "input/day10.txt", "r")
# ~/~ end