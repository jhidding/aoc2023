# ~/~ begin <<docs/day01.md#src/Day01.jl>>[init]
module Day01

# ~/~ begin <<docs/day01.md#day01-part1>>[init]
function calibration_value(line::String)
    first_and_last(x) = x[[1, length(x)]]
    number = first_and_last(filter(isdigit, line))
    parse(Int, number)
end
# ~/~ end
# ~/~ begin <<docs/day01.md#day01-part2>>[init]
NUMBER_STRINGS = Dict(zip(
    ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"],
    1:9))

function find_digit(line::String, find, min_or_max)
    a = find(isdigit, line)
    words = filter(!isnothing, find.(keys(NUMBER_STRINGS), line))
    b = isnothing(a) ? min_or_max(words) : min_or_max(words, init=a:a)
    get(NUMBER_STRINGS, line[b]) do
        parse(Int, line[b])
    end
end

function improved_calibration(line::String)
    first = find_digit(line, findfirst, minimum)
    last = find_digit(line, findlast, maximum)
    first * 10 + last
end
# ~/~ end

function main(io::IO=stdin)
    input = collect(readlines(io))
    println("Part 1: ", input .|> calibration_value |> sum)
    println("Part 2: ", input .|> improved_calibration |> sum)
end
end
# ~/~ end