# Day 01: Trebuchet?!
For the first part, we need to create integers from the first and last digit in a string.

``` {.julia #day01-part1}
function calibration_value(line::String)
    first_and_last(x) = x[[1, length(x)]]
    number = first_and_last(filter(isdigit, line))
    parse(Int, number)
end
```

For the second part, we also need to read number words. I managed to generalize over `minimum`/`maximum` and `findfirst`/`findlast`.

``` {.julia #day01-part2}
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
```

Testing.

``` {.julia #test}
test_input_1 = [
  "1abc2",
  "pqr3stu8vwx",
  "a1b2c3d4e5f",
  "treb7uchet"
]

test_input_2 = [
  "two1nine",
  "eightwothree",
  "abcone2threexyz",
  "xtwone3four",
  "4nineeightseven2",
  "zoneight234",
  "7pqrstsixteen"
]

@testset "day 01" begin
  answer = test_input_1 .|> AOC2023.Day01.calibration_value |> sum
  @test answer == 142

  answer = test_input_2 .|> AOC2023.Day01.improved_calibration |> sum
  @test answer == 281
end
```

Putting things together.

``` {.julia file=src/Day01.jl}
module Day01

<<day01-part1>>
<<day01-part2>>

function main(io::IO=stdin)
    input = collect(readlines(io))
    println("Part 1: ", input .|> calibration_value |> sum)
    println("Part 2: ", input .|> improved_calibration |> sum)
end
end
```

``` title="output day 1"
{% include 'day01.txt' %}
```

## Rust

``` {.rust file=src/bin/day01.rs}
use std::io;

fn calibration(line: &String) -> Option<u32> {
    let mut x = line.chars().filter(|x| x.is_digit(10));
    let a = x.next()?;
    let b = x.last().unwrap_or(a);
    Some((a as u32 - '0' as u32) * 10 + (b as u32 - '0' as u32))
}

fn main() -> Result<(), io::Error> {
    let input: Vec<_> = io::stdin().lines().collect::<Result<Vec<_>, _>>()?;
    println!("{}", input.iter().filter_map(calibration).sum::<u32>());
    Ok(())
}
```
