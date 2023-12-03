# ~/~ begin <<docs/day03.md#src/Day03.jl>>[init]
module Day03

using .Iterators: flatmap

struct Number
  line::Int
  pos::UnitRange{Int}
  value::Int
end

function find_numbers(inp)
  int_re = r"[1-9][0-9]*"
  numbers_from_line((line, str)) =
    findall(int_re, str) .|> (pos -> Number(line, pos, parse(Int, str[pos])))
  flatmap(numbers_from_line, enumerate(inp))
end

function dilation(n::Number, size)
  CartesianIndices((
    max(n.pos.start - 1, 1):min(n.pos.stop + 1, size[1]),
    max(n.line - 1, 1):min(n.line + 1, size[2])
  ))
end

function main(io::IO)
  input = collect(readlines(io))
  inp_mat = input .|> (line -> [line...]) |> (vv -> reduce(hcat, vv))

  number_mat = zeros(Int, size(inp_mat)...)
  symbol_char(c) = ((c < '0') | (c > '9')) & (c != '.')
  part_sum = 0
  for n in find_numbers(input)
    number_mat[n.pos, n.line] .= n.value
    if any(symbol_char.(inp_mat[dilation(n, size(inp_mat))]))
      part_sum += n.value
    end
  end
  println("Part 1: ", part_sum)

  star(p) = CartesianIndices((p[1]-1:p[1]+1, p[2]-1:p[2]+1))
  gear_sum = 0
  for g in findall(c -> c == '*', inp_mat)
    nums = setdiff!(Set(number_mat[star(g)]), [0])
    if length(nums) == 2
      gear_sum += prod(nums)
    end
  end
  println("Part 2: ", gear_sum)
end

end
# ~/~ end
