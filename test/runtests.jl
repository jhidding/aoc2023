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
end
# ~/~ end