# ~/~ begin <<docs/day04.md#src/Day04.jl>>[init]
module Day04

# ~/~ begin <<docs/day04.md#day04>>[init]
using ..Parsing: token, sequence, skip, fmap, starmap, some_p

struct Card
    number::Int
    winning::Set{Int}
    trial::Vector{Int}
end

unsigned = token(r"\d+") >> fmap(x -> parse(Int, x.match))

card_p = sequence(
    token("Card") >>> unsigned >> skip(token(":")),
    some_p(unsigned) >> skip(token("|")) >> fmap(Set),
    some_p(unsigned)) >> starmap(Card)
# ~/~ end
# ~/~ begin <<docs/day04.md#day04>>[1]
wins(c::Card) = sum(c.trial .∈ (c.winning,))
score(c::Card) = let x = wins(c) 
    x > 0 ? 2^(x - 1) : 0
end
# ~/~ end
# ~/~ begin <<docs/day04.md#day04>>[2]
function play(cards::Vector{Card})
    copies = Vector{Union{Int,Nothing}}(nothing, length(cards))
    function f(n::Int)
        if n > length(copies)
            return 0
        end
        if isnothing(copies[n])
            s = wins(cards[n])
            copies[n] = sum(f.(n+1:n+s); init=1)
        end
        return copies[n]
    end
end
# ~/~ end
# ~/~ begin <<docs/day04.md#day04>>[3]
function play2(cards::Vector{Card})
    copies = ones(Int, length(cards))
    for (i, c) in enumerate(cards)
        copies[i+1:i+wins(c)] .+= copies[i]
    end
    copies
end
# ~/~ end

function main(io::IO)
    input = readlines(io) .|> (first ∘ card_p)
    println("Part 1: ", input .|> score |> sum)
    println("Part 2: ", input |> play2 |> sum)
end

end
# ~/~ end