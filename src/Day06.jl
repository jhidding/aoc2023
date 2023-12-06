# ~/~ begin <<docs/day06.md#src/Day06.jl>>[init]
module Day06

using ..Parsing: token, integer, sequence, starmap, some_p

struct Data
  time::Vector{Int}
  distance::Vector{Int}
end

data_p = sequence(
  token("Time:") >>> some_p(integer),
  token("Distance:") >>> some_p(integer)
) >> starmap(Data)

# ~/~ begin <<docs/day06.md#day06>>[init]
function amount_of_wins(t::Int, d::Int)
  Δ2 = isqrt(t^2 - 4d)
  t & 1 == 0 ? Δ2 | 1 : (Δ2 + 1) & ~1
end
# ~/~ end

function main(io::IO)
  input = read(io, String) |> data_p |> first
  println("Part 1: ", prod(amount_of_wins.(input.time, input.distance .+ 1)))
  rt = parse(Int, "$(input.time...)")
  rd = parse(Int, "$(input.distance...)")
  println("Part 2: ", amount_of_wins(rt, rd + 1))
end
end
# ~/~ end
