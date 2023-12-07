# ~/~ begin <<docs/day07.md#src/Day07.jl>>[init]
module Day07

using ..Parsing: token, match_p, integer, fmap, starmap, sequence, some_p

struct Bid
  hand::String
  amount::Int
end

bid_p = sequence(
  token(r"[2-9TJQKA]+") >> fmap(m -> m.match),
  integer) >> starmap(Bid)

# ~/~ begin <<docs/day07.md#day07>>[init]
function count_elements(coll)
  groups = Dict()
  for el in coll
    groups[el] = get(groups, el, 0) + 1
  end
  groups
end
# ~/~ end
# ~/~ begin <<docs/day07.md#day07>>[1]
function signature(hand)
  if isempty(hand)
    return [0]
  end
  sort!(collect(values(count_elements(hand))); rev=true)
end
# ~/~ end

function hand_score(hand::AbstractString)
  card_values = Dict(zip("23456789TJQKA", 1:13))
  int_hand = [card_values[c] for c in hand]
  return (signature(hand), int_hand)
end

function joker_hand_score(hand::AbstractString)
  card_values = Dict(zip("J23456789TQKA", 1:13))
  int_hand = [card_values[c] for c in hand]
  short_hand = replace(hand, "J" => "")
  sign = signature(short_hand)
  sign[1] += 5 - length(short_hand)
  return (sign, int_hand)
end

function main(io::IO)
  input = readlines(io) .|> (first ∘ bid_p)
  sort!(input; by=b -> hand_score(b.hand))
  println("Part 1: ", sum(i * h.amount for (i, h) in enumerate(input)))
  sort!(input; by=b -> joker_hand_score(b.hand))
  println("Part 2: ", sum(i * h.amount for (i, h) in enumerate(input)))
end

end
# ~/~ end