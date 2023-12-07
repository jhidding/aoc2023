# Day 07: Camel Cards
We need to sort the given hands of cards on signature first, then card value. The signature is `[5]` for a five-of-a-kind, `[3, 2]` for full-house, `[2, 2, 1]` for two pairs ... etc.

The `count_elements` function counts how many copies of each unique element is in a collection.

``` {.julia #day07}
function count_elements(coll)
  groups = Dict()
  for el in coll
    groups[el] = get(groups, el, 0) + 1
  end
  groups
end
```

Then the `signature` function gets those counts and sorts them. We return `[0]` for empty collections, a useful choice for part 2.

``` {.julia #day07}
function signature(hand)
  if isempty(hand)
    return [0]
  end
  sort!(collect(values(count_elements(hand))); rev=true)
end
```

The trick with part two is to find the signature of the hand without jokers and then increase the leading value to a total of five.

??? "Main"

    ``` {.julia file=src/Day07.jl}
    module Day07

    using ..Parsing: token, match_p, integer, fmap, starmap, sequence, some_p

    struct Bid
      hand::String
      amount::Int
    end

    bid_p = sequence(
      token(r"[2-9TJQKA]+") >> fmap(m -> m.match),
      integer) >> starmap(Bid)

    <<day07>>

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
    ```

??? "Test"

    ``` {.julia #test}
    @testset "day 7" begin
      using AOC2023.Day07: bid_p, hand_score, joker_hand_score
      input = """
      32T3K 765
      T55J5 684
      KK677 28
      KTJJT 220
      QQQJA 483"""
      bids = split(strip(input), "\n") .|> (first ∘ bid_p)
      sort!(bids; by=b -> hand_score(b.hand))
      @test sum(i * h.amount for (i, h) in enumerate(bids)) == 6440
      sort!(bids; by=b -> joker_hand_score(b.hand))
      @test sum(i * h.amount for (i, h) in enumerate(bids)) == 5905
    end
    ```

```
{% include "day07.txt" %}
```
