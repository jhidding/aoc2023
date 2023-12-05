# Day 05: If You Give A Seed A Fertilizer

``` {.julia file=src/Day05.jl}
module Day05

using ..Parsing: token_p, match_p, sep_by_p, fmap, some_p, sequence, starmap, skip
using .Iterators: flatmap

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

function find_map_item(vec::AbstractVector{MapItem}, l::Int)
  x = search_sorted_ranges(map(m -> m.range, vec), l)
  x isa Symbol ? nothing : (l in vec[x].range ? vec[x] : nothing)
end

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

function (m::SeedMap)(l::Int)
  f = find_map_item(m.items, l)
  isnothing(f) ? l : (l + f.offset)
end

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
```

``` {.julia #test}
@testset "day 5"
    data = "seeds: 79 14 55 13\n\
            \n\
            seed-to-soil map:\n\
            50 98 2\n\
            52 50 48\n\
            \n\
            soil-to-fertilizer map:\n\
            0 15 37\n\
            37 52 2\n\
            39 0 15\n\
            \n\
            fertilizer-to-water map:\n\
            49 53 8\n\
            0 11 42\n\
            42 0 7\n\
            57 7 4\n\
            \n\
            water-to-light map:\n\
            88 18 7\n\
            18 25 70\n\
            \n\
            light-to-temperature map:\n\
            45 77 23\n\
            81 45 19\n\
            68 64 13\n\
            \n\
            temperature-to-humidity map:\n\
            0 69 1\n\
            1 0 69\n\
            \n\
            humidity-to-location map:\n\
            60 56 37\n\
            56 93 4\n"
end
```
