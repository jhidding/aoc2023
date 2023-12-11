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
  (c1, _, c2, _, _, c3) = Makie.wong_colors()
  fig = Figure(size=(600, 800))
  ax1 = Axis(fig[2:3, 1]; aspect=AxisAspect(1))
  lines!(ax1, path; color=c2)
  poly!(ax1, inner .- [0.5, 0.5]; color=c3)

  ax2 = Axis(fig[1, 1]; aspect=DataAspect(), limits=(70, 80, 80, 85))
  lines!(ax2, path; color=c2)
  scatter!(ax2, path; color=c2)
  poly!(ax2, inner .- [0.5, 0.5]; color=c3)
  lines!(ax2, inner .- [0.5, 0.5]; color=:black)
  scatter!(ax2, inner .- [0.5, 0.5]; color=:black)
  save("docs/fig/day10.svg", fig)
end

end

open(PlotDay10.main, "input/day10.txt", "r")
# ~/~ end
