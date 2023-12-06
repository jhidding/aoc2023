# ~/~ begin <<docs/day05.md#src/Day05.jl>>[init]
module Day05

using ..Parsing: token_p, match_p, sep_by_p, fmap, some_p, sequence, starmap, skip
using .Iterators: flatmap

# ~/~ begin <<docs/day05.md#day05>>[init]
struct MapItem
  range::UnitRange{Int}
  offset::Int
end

struct SeedMap
  from::String
  to::String
  items::Vector{MapItem}
end

struct Almanak
  seeds::Vector{Int}
  maps::Vector{SeedMap}
end
# ~/~ end
# ~/~ begin <<docs/day05.md#day05>>[1]
function read_input(io::IO)
  token(expr) = token_p(match_p(expr), match_p(r" *"))
  newline = match_p(r"\n")
  integer = token(r"\d+") >> fmap(x -> parse(Int, x.match))

  map_item =
    sequence(integer, integer, integer) >>
    starmap((d, s, l) -> MapItem(s:s+l-1, d - s))
  seed_map =
    sequence(
      match_p(r"(?<from>[a-z]+)-to-(?<to>[a-z]+) map:") >> skip(newline),
      sep_by_p(map_item, newline)) >>
    starmap((m, x) -> SeedMap(m[:from], m[:to], x))
  almanak =
    sequence(
      token("seeds:") >>> some_p(integer) >> skip(some_p(newline)),
      some_p(seed_map >> skip(some_p(newline)))) >> starmap(Almanak)

  read(io, String) |> almanak |> first
end
# ~/~ end
# ~/~ begin <<docs/day05.md#day05>>[2]
function search_sorted_ranges(vec::AbstractVector{UnitRange{Int}}, x::Int)
  a = 1
  b = length(vec)

  if x < vec[a].start
    return 1
  end
  if x > vec[b].stop
    return :over
  end

  while (b - a) > 1
    mid = (a + b) ÷ 2
    if x < vec[mid].start
      b = mid
      continue
    end
    if x > vec[mid].stop
      a = mid
      continue
    end
    return mid
  end

  if x > vec[a].stop
    return b
  else
    return a
  end
end
# ~/~ end
# ~/~ begin <<docs/day05.md#day05>>[3]
function find_map_item(vec::AbstractVector{MapItem}, l::Int)
  x = search_sorted_ranges(map(m -> m.range, vec), l)
  x isa Symbol ? nothing : (l in vec[x].range ? vec[x] : nothing)
end

function (m::SeedMap)(l::Int)
  f = find_map_item(m.items, l)
  isnothing(f) ? l : (l + f.offset)
end
# ~/~ end
# ~/~ begin <<docs/day05.md#day05>>[4]
function (m::SeedMap)(r::UnitRange{Int})
  if (r.stop < m.items[1].range.start) |
     (r.start > m.items[end].range.stop)
    return [r]
  end

  result = []
  start = r.start
  a = search_sorted_ranges(map(m -> m.range, m.items), start)

  for f in m.items[a:end]
    if start < f.range.start
      if r.stop < f.range.start
        push!(result, start:r.stop)
        return result
      end
      push!(result, start:f.range.start-1)
      start = f.range.start
    end
    substop = min(f.range.stop, r.stop)
    push!(result, start+f.offset:substop+f.offset)
    start = substop + 1
    if start > r.stop
      break
    end
  end
  if start < r.stop
    push!(result, start:r.stop)
  end
  result
end
# ~/~ end

function (maps::Vector{SeedMap})(i::Int)
  foldl((x, f) -> f(x), maps; init=i)
end

function (maps::Vector{SeedMap})(r::UnitRange{Int})
  foldl((x, f) -> collect(flatmap(f, x)), maps; init=[r])
end

# only tokenize on horizontal space
function main(io::IO)
  input = read_input(io)
  foreach(x -> sort!(x.items; by=y -> y.range), input.maps)
  println("Part 1: ", input.seeds .|> (input.maps,) |> minimum)
  ranges = map(x -> x[1]:x[1]+x[2]-1, eachcol(reshape(input.seeds, 2, :)))
  println("Part 2: ", ranges .|> (minimum ∘ input.maps) |> minimum |> minimum)
  input
end

end
# ~/~ end