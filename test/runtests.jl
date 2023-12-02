# ~/~ begin <<docs/index.md#test/runtests.jl>>[init]
using AOC2023
using Test

@testset "tests" begin
  # ~/~ begin <<docs/day01.md#test>>[init]
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
  # ~/~ end
  # ~/~ begin <<docs/day02.md#test>>[0]
  @testset "day 2" begin
    using AOC2023.Day02: game_p, Game
    input = ["Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green",
      "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue",
      "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red",
      "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red",
      "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"]
    games = input .|> (first ∘ game_p)
    bag = [12, 13, 14]
    possible(g::Game) = all(g.draws .<= bag')
    @test filter(possible, games) .|> (g -> g.n) |> sum == 8

    minbag(g::Game) = maximum(g.draws; dims=1)
    power(bag) = reduce(*, bag)
    @test games .|> minbag .|> power |> sum == 2286
  end
  # ~/~ end
  # ~/~ begin <<docs/day02.md#test>>[1]
  @testset "Parsing" begin
    using AOC2023.Parsing: match_p, integer_p, token_p, sequence, many_p

    @test match_p("hello")("hellogoodbye") == ("hello", "goodbye")

    p = match_p("a") >>> match_p("b")
    @test p("abc") == ("b", "c")

    p = sequence(match_p("a"), match_p("b"))
    @test p("abc") == (["a", "b"], "c")

    p = sequence(n=match_p("a"), m=match_p("b"))
    @test p("abc") == (Dict(:n => "a", :m => "b"), "c")

    p = many_p(token_p(integer_p))
    @test p("1  2 3  4 56    7 abc") == ([1, 2, 3, 4, 56, 7], "abc")
  end
  # ~/~ end
end
# ~/~ end
