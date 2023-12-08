# ~/~ begin <<docs/day08.md#src/viz-day08-gen.jl>>[init]
#| creates: docs/fig/viz-day08.svg
#| requires: src/Day08.jl input/day08.txt
#| description: Create GraphViz plot
#| collect: figures

using AOC2023.Day08: input_p, map_node
using GraphvizDotLang: digraph, edge, save, node, attr

input = open("input/day08.txt", "r") do io
  read(io, String) |> input_p |> first
end
nodes = collect(keys(input.network))
m = length(input.instructions)

starts = nodes[occursin.(r"..A", nodes)]
step_map = Dict(
  id => map_node(input.network, id, input.instructions)
  for id in nodes)

# gt = digraph()
# for n in nodes
#   gt |> edge(n, input.network[n].left) |>
#        edge(n, input.network[n].right)
# end
# save(gt, "docs/fig/day08-tree.svg")

g = digraph(;bgcolor="transparent", nodesep="0.1", ranksep="0.05",
            rankdir="TD") |>
    attr(:node; style="filled", fillcolor="black", fontcolor="white", color="gray", fontname="monospace", fontsize="1", margin="0.05", width="0.05", height="0.05") |>
    attr(:edge; color="gray", arrowsize="0.3")
for s in starts
  g |> node(s; fillcolor="green", fontsize="14")
end
for e in nodes[occursin.(r"..Z", nodes)]
  g |> node(e; fillcolor="blue", fontsize="10")
end
for id in nodes
  g |> edge(id, map_node(input.network, id, input.instructions))
end
save(g, "docs/fig/viz-day08.svg")
# ~/~ end