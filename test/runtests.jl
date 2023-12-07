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
  # ~/~ begin <<docs/day04.md#test>>[0]
  @testset "day 4" begin
    using AOC2023.Day04: card_p, score, play, play2
    input = [
      "Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53",
      "Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19",
      "Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1",
      "Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83",
      "Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36",
      "Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"
    ]
    cards = input .|> (first ∘ card_p)
    @test cards .|> score == [8, 2, 2, 1, 0, 0]
    @test 1:6 .|> play(cards) |> sum == 30
    @test cards |> play2 |> sum == 30
  end
  # ~/~ end
  # ~/~ begin <<docs/day05.md#test>>[0]
  @testset "day 5" begin
    using AOC2023.Day05: read_input
    data = "seeds: 79 14 55 13\n\
            \n\
            seed-to-soil map:\n\
            50 98 2\n\
            52 50 48\n\
            \n\
            soil-to-fertilizer map:\n\
            0 15 37\n\
            37 52 2\n\
            39 0 15\n\
            \n\
            fertilizer-to-water map:\n\
            49 53 8\n\
            0 11 42\n\
            42 0 7\n\
            57 7 4\n\
            \n\
            water-to-light map:\n\
            88 18 7\n\
            18 25 70\n\
            \n\
            light-to-temperature map:\n\
            45 77 23\n\
            81 45 19\n\
            68 64 13\n\
            \n\
            temperature-to-humidity map:\n\
            0 69 1\n\
            1 0 69\n\
            \n\
            humidity-to-location map:\n\
            60 56 37\n\
            56 93 4\n"
    input = read_input(IOBuffer(data))
    foreach(x -> sort!(x.items; by=y -> y.range), input.maps)
    @test input.seeds .|> (input.maps,) |> minimum == 35
    ranges = map(x -> x[1]:x[1]+x[2]-1, eachcol(reshape(input.seeds, 2, :)))
    @test ranges .|> (minimum ∘ input.maps) |> minimum |> minimum == 46
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
  # ~/~ begin <<docs/day07.md#test>>[0]
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
  # ~/~ end
end
# ~/~ end