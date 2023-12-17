# ~/~ begin <<docs/day17.md#src/Day17.jl>>[init]
module Day17

# ~/~ begin <<docs/day17.md#grid-dijkstra>>[init]
using DataStructures

function grid_dijkstra(
  ::Type{T}, size::NTuple{Dim,Int},
  start::Vector{CartesianIndex{Dim}}, istarget::Function,
  neighbours::Function, dist_func::Function) where {T,Dim}

  visited = fill(false, size)
  distance = fill(typemax(T), size)
  for s in start
    distance[s] = zero(T)
  end
  queue = PriorityQueue{CartesianIndex{Dim},T}()
  prev = Array{CartesianIndex{Dim},Dim}(undef, size)
  for s in start
    enqueue!(queue, s, zero(T))
  end
  current = nothing
  while !isempty(queue)
    current = dequeue!(queue)
    istarget(current) && break
    visited[current] && continue
    for loc in neighbours(current)
      visited[loc] && continue
      d = distance[current] + dist_func(current, loc)
      if d < distance[loc]
        distance[loc] = d
        prev[loc] = current
        enqueue!(queue, loc, d)
      end
    end
    visited[current] = true
  end
  (distance=distance, route=prev, target=current)
end

function trace_back(prev, start, target)
  route = [target]
  current = target
  while current != start
    current = prev[current]
    pushfirst!(route, current)
  end
  route
end
# ~/~ end

function find_path(cost, jump, max_straight)
  # ~/~ begin <<docs/day17.md#day17>>[init]
  s = size(cost)

  function cost_fn(a, b)
    if a[1] == b[1]
      p, q = minmax(a[2], b[2])
      sum(cost[a[1], p:q]) - cost[a[1], a[2]]
    else
      p, q = minmax(a[1], b[1])
      sum(cost[p:q, a[2]]) - cost[a[1], a[2]]
    end
  end
  # ~/~ end
  # ~/~ begin <<docs/day17.md#day17>>[1]
  function neighbours(a)
    dx = [(0, 1), (1, 0), (0, -1), (-1, 0)]
    at = Tuple(a)

    function step(di)
      if di == 0
        CartesianIndex((at[1:2] .+ dx[a[3]])..., a[3], a[4] + 1)
      else
        i = mod1(a[3] + di, 4)
        CartesianIndex((at[1:2] .+ (dx[i] .* jump))..., i, jump)
      end
    end

    inbounds(c::CartesianIndex{4}) = c[1] > 0 && c[1] <= s[1] && c[2] > 0 && c[2] <= s[2] && c[4] <= max_straight
    filter(inbounds, [step(di) for di in -1:1])
  end
  # ~/~ end
  # ~/~ begin <<docs/day17.md#day17>>[2]
  target(a) = (a[1], a[2]) == s

  grid_dijkstra(
    Int, (s..., 4, max_straight),
    [CartesianIndex(1, 1, 1, 1),
      CartesianIndex(1, 1, 2, 1)],
    target, neighbours, cost_fn)
  # ~/~ end
end

function main(io::IO)
  cost = readlines(io) .|> collect .|> (x -> x .- '0') |> stack
  dist1, _, tgt1 = find_path(cost, 1, 3)
  println("Part 1: ", dist1[tgt1])
  dist2, _, tgt2 = find_path(cost, 4, 10)
  println("Part 2: ", dist2[tgt2])
end

end
# ~/~ end
