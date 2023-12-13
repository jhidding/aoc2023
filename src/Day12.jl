# ~/~ begin <<docs/day12.md#src/Day12.jl>>[init]
module Day12

using ..Parsing: token, sep_by_p, integer, fmap, starmap, sequence
using Memoize

struct Puzzle
  pattern::String
  numbers::Vector{Int}
end

puzzle_p = sequence(
  token(r"[.?#]+") >> fmap(m -> m.match),
  sep_by_p(integer, token(","))
) >> starmap(Puzzle)

@memoize Dict function count(num::Vector{Int}, s::AbstractString)
  # ~/~ begin <<docs/day12.md#day12-cases>>[init]
  if isempty(num)
    return '#' ∉ s ? 1 : 0
  end
  # ~/~ end
  # ~/~ begin <<docs/day12.md#day12-cases>>[1]
  if length(s) < sum(num) + length(num) - 1
    return 0
  end
  # ~/~ end
  # ~/~ begin <<docs/day12.md#day12-cases>>[2]
  if startswith(s, ".") || endswith(s, ".")
    return count(num, strip(s, '.'))
  end
  # ~/~ end
  # ~/~ begin <<docs/day12.md#day12-cases>>[3]
  if s[1] == '#'
    if ('.' in s[1:num[1]]) || (get(s, num[1] + 1, '.') == '#')
      return 0
    end
    return count(num[2:end], s[num[1]+2:end])
  end
  # ~/~ end

  return count(num, s[2:end]) + count(num, "#" * s[2:end])
end

function main(io::IO)
  input = readlines(io) .|> (first ∘ puzzle_p)
  n_solutions(p::Puzzle) = count(p.numbers, p.pattern)
  println("Part 1: ", input .|> n_solutions |> sum)
  five_fold(p::Puzzle) = Puzzle(join(repeat([p.pattern], 5), "?"), repeat(p.numbers, 5))
  println("Part 2: ", input .|> five_fold .|> n_solutions |> sum)
end

end
# ~/~ end