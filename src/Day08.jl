# ~/~ begin <<docs/day08.md#src/Day08.jl>>[init]
module Day08

# ~/~ begin <<docs/day08.md#day08>>[init]
using ..Parsing: token, sequence, fmap, starmap, some_p, skip

struct Node
  left::String
  right::String
end

struct Input
  instructions::String
  network::Dict{String,Node}
end

tokenm(re) = token(re) >> fmap(m -> m.match)
identifier = tokenm(r"[A-Z]{3}")

input_p = sequence(
  tokenm(r"[LR]+"),
  some_p(sequence(
    identifier,
    token("=") >>> sequence(
      token("(") >>> identifier,
      token(",") >>> identifier >> skip(token(")"))) >> starmap(Node)
  ) >> starmap(Pair)) >> fmap(Dict)
) >> starmap(Input)
# ~/~ end
# ~/~ begin <<docs/day08.md#day08>>[1]
map_node(network::Dict{String,Node}, id::String, instructions::String) =
  foldl((id, lr) -> lr == 'L' ? network[id].left : network[id].right,
    instructions; init=id)

function dist(step_map, from::String, to::Union{String,Regex})
  x = 1
  a = step_map[from]
  while !occursin(to, a)
    a = step_map[a]
    x += 1
  end
  x
end
# ~/~ end

function main(io::IO)
  input = read(io, String) |> input_p |> first
  nodes = collect(keys(input.network))
  m = length(input.instructions)

  step_map = Dict(
    id => map_node(input.network, id, input.instructions)
    for id in nodes)
  println("Part 1: ", dist(step_map, "AAA", "ZZZ") * m)

  starts = nodes[occursin.(r"..A", nodes)]
  step_map = Dict(
    id => map_node(input.network, id, input.instructions)
    for id in nodes)
  println("Part 2: ", prod(dist(step_map, k, r"..Z") for k in starts; init=m))
end

end
# ~/~ end