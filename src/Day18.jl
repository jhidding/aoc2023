# ~/~ begin <<docs/day18.md#src/Day18.jl>>[init]
module Day18

using ..Parsing: sequence, token, integer, fmap, skip
using Transducers

# ~/~ begin <<docs/day18.md#day18>>[init]
const dirs = eachrow([0 1; 1 0; 0 -1; -1 0]) .|> Tuple
const char2dir = Dict(zip("RDLU", dirs))

struct Instruction
  dx::NTuple{2, Int}
  color::UInt32
end

instruction_p = sequence(
  sequence(token(r"[RDLU]") >> fmap(m -> char2dir[m.match[1]]), integer) >>
    fmap(splat(.*)),
  token("(#") >>> token(r"[0-9a-f]{6}") >> skip(token(")")) >>
    fmap(m -> parse(UInt32, m.match, base=16))) >> fmap(splat(Instruction))
# ~/~ end
# ~/~ begin <<docs/day18.md#day18>>[1]
cross(a, b) = a[1] * b[2] - a[2] * b[1]

outside(dx1, dx2) = let s = cross(dx1, dx2)
	s < 0 ? (dx1 .+ sign.(dx1), dx2) :
	  (s > 0 ? (dx1, dx2 .- sign.(dx2)) :
      (dx1, dx2))
end
# ~/~ end
# ~/~ begin <<docs/day18.md#day18>>[2]
area(path) = path |>
  ScanEmit(outside, (0, 0), x -> x .+ sign.(x)) |>
  Scan(.+) |>
  Consecutive(2) |>
  Map(splat(cross)) |> sum |> abs
# ~/~ end

function main(io::IO)
  input = readlines(io) .|> (first ∘ instruction_p)
  path1 = input .|> (x -> x.dx)
  println("Part 1: ", area(path1))
  path2 = input .|> (x -> dirs[x.color & 0xf + 1] .* (x.color >> 4))
  println("Part 2: ", area(path2))
end

end
# ~/~ end