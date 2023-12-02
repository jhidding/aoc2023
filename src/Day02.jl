# ~/~ begin <<docs/day02.md#src/Day02.jl>>[init]
module Day02

using ..Parsing: pure_p, integer_p, match_p, token_p, fmap, skip, sep_by_p, sequence, starmap

# ~/~ begin <<docs/day02.md#day02-parse>>[init]
struct Game
  n::Int
  draws::Matrix{Int}
end

token = token_p ∘ match_p

color_p = let
  red(x) = token("red") >>> pure_p([x, 0, 0])
  green(x) = token("green") >>> pure_p([0, x, 0])
  blue(x) = token("blue") >>> pure_p([0, 0, x])
  token_p(integer_p) >> (x -> red(x) | green(x) | blue(x))
end

draw_p = sep_by_p(color_p, token(",")) >> fmap(x -> reduce(.+, x))

game_p = sequence(
  token("Game") >>> integer_p >> skip(token(":")),
  sep_by_p(draw_p, token(";")) >> fmap(x -> reduce(hcat, x)')
) >> starmap(Game)
# ~/~ end

function main(io::IO)
  games = readlines(io) .|> (first ∘ game_p)
  # ~/~ begin <<docs/day02.md#day02-part1>>[init]
  bag = [12, 13, 14]
  possible(g::Game) = all(g.draws .<= bag')
  println("Part 1: ", filter(possible, games) .|> (g -> g.n) |> sum)
  # ~/~ end
  # ~/~ begin <<docs/day02.md#day02-part2>>[init]
  minbag(g::Game) = maximum(g.draws; dims=1)
  power(bag) = reduce(*, bag)
  println("Part 2: ", games .|> minbag .|> power |> sum)
  # ~/~ end
end

end
# ~/~ end