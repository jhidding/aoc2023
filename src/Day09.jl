# ~/~ begin <<docs/day09.md#src/Day09.jl>>[init]
module Day09

using Transducers

read_input(io::IO) = readlines(io) .|> split .|> x -> parse.(Int, x)

diff(seq) = seq[2:end] .- seq[1:end-1]
diffs(seq) = Iterators.countfrom() |> Iterated(diff, seq) |> TakeWhile(x -> !all(x .== 0))
next_number(seq) = diffs(seq) |> Map(last) |> sum
prev_number(seq) = foldr(-, diffs(seq) |> Map(first) |> collect)

function main(io::IO)
  sequences = read_input(io)
  println("Part 1: ", sequences .|> next_number |> sum)
  println("Part 2: ", sequences .|> prev_number |> sum)
end

end
# ~/~ end
