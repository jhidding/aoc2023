# ~/~ begin <<docs/day14.md#src/Day14.jl>>[init]
module Day14

using .Iterators: flatmap

function find_ranges(v::AbstractVector{Bool})
  Channel() do ch
    idx = 1
    while true
      start = findnext(v, idx)
      isnothing(start) && return
      stop = findnext(!, v, start)
      if isnothing(stop)
        put!(ch, start:length(v))
        return
      end
      put!(ch, start:stop-1)
      idx = stop
    end
  end
end

function iterate(f)
  Channel() do ch
    while true
      put!(ch, f())
    end
  end
end

function gravitate!(ranges, v)
  for w in ranges
    n = sum(v[w])
    v[w[1:n]] .= true
    v[w[n+1:end]] .= false
  end
  v
end


function cycler(m::AbstractMatrix{Bool})
  nr = eachcol(m) .|> (collect ∘ find_ranges) |>
       rs -> flatmap(((i, r),) -> tuple.(i, r), enumerate(rs))
  north = nr .|> ((i, r),) -> CartesianIndices((r, i:i))
  south = nr .|> ((i, r),) -> CartesianIndices((reverse(r), i:i))
  wr = eachrow(m) .|> (collect ∘ find_ranges) |>
       rs -> flatmap(((i, r),) -> tuple.(i, r), enumerate(rs))
  west = wr .|> ((i, r),) -> CartesianIndices((i:i, r))
  east = wr .|> ((i, r),) -> CartesianIndices((i:i, reverse(r)))

  function cycle!(m::AbstractMatrix{Bool})
    for r in (north, west, south, east)
      gravitate!(r, m)
    end
    m
  end
end

support_load(m) = enumerate(sum(m[end:-1:1, :]; dims=2)) .|> splat(*) |> sum

function find_period(it)
  s = Dict()
  for (i, x) in enumerate(it)
    if x in keys(s)
      return (s[x], i - s[x])
    end
    s[x] = i
  end
end

function main(io::IO)
  input = readlines(io) .|> collect |> v -> reduce(hcat, v) |> permutedims
  nr = eachcol(input .!= '#') .|> (collect ∘ find_ranges) |> collect
  north = reduce(
    vcat,
    (map(r -> CartesianIndices((r, i:i)), rs)
     for (i, rs) in enumerate(nr)))
  println("Part 1: ", gravitate!(north, input .== 'O') |> support_load)
  m = input .== 'O'
  cycle! = cycler(input .!= '#')
  seq = Iterators.take(iterate(() -> cycle!(m)), 200) |> collect
  (offset, period) = find_period(seq)
  idx = (10^9 - offset) % period + offset
  println("Part 2: ", seq[idx] |> support_load)
end
end
# ~/~ end
