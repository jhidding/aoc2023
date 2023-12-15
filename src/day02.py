# ~/~ begin <<docs/day02.md#src/day02.py>>[init]
from pyparsing import Word, Literal, Group, nums, delimitedList, Suppress
import numpy as np

rgb = Literal("red") | Literal("green") | Literal("blue")
color = Word(nums) + rgb

@color.set_parse_action
def color_to_vector(result):
    match result:
        case [n, "red"]: return np.array([int(n), 0, 0])
        case [n, "green"]: return np.array([0, int(n), 0])
        case [n, "blue"]: return np.array([0, 0, int(n)])

test1 = "42 red"
print(f"'{test1}' parses to:", color.parse_string(test1))

draw = delimitedList(color, ",")

@draw.set_parse_action
def draw_to_vector(result):
    return sum(result)

test2 = "42 red, 13 blue, 3 green"
print(f"'{test2}' parses to:", draw.parse_string(test2))

game = Group(Suppress(Literal("Game")) + Word(nums) + Suppress(":")) \
    + delimitedList(draw, ";")

@game.set_parse_action
def to_game(result):
    return (int(result[0][0]), result[1:])

test3 = "Game 1: 12 blue, 15 red, 2 green; 17 red, 8 green, 5 blue; 8 red, 17 blue; 9 green, 1 blue, 4 red"
print(f"'{test3}' parses to:\n", game.parse_string(test3))
# ~/~ end
