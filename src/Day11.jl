# ~/~ begin <<docs/day11.md#src/Day11.jl>>[init]
module Day11

function combinations(x)
  Channel() do c
    for i in eachindex(x)
      for j in eachindex(x[i+1:end])
        put!(c, (x[i], x[i+j]))
      end
    end
  end
end

function main(io::IO)
  input = readlines(io) .|> collect |> lines -> reduce(hcat, lines)
  empty_cols = Set(i for (i, c) in enumerate(eachcol(input)) if all(c .== '.'))
  empty_rows = Set(i for (i, r) in enumerate(eachrow(input)) if all(r .== '.'))
  function distance(a, b, expansion_factor)
    row_r = min(a[1], b[1]):max(a[1], b[1])
    col_r = min(a[2], b[2]):max(a[2], b[2])
    row_d = max(0, length(row_r) + length(intersect(row_r, empty_rows)) * (expansion_factor - 1) - 1)
    col_d = max(0, length(col_r) + length(intersect(col_r, empty_cols)) * (expansion_factor - 1) - 1)
    row_d + col_d
  end
  galaxies = findall(input .== '#') |> collect
  println("Part 1: ", (distance(a, b, 2) for (a, b) in combinations(galaxies)) |> sum)
  println("Part 2: ", (distance(a, b, 10^6) for (a, b) in combinations(galaxies)) |> sum)
end

end
# ~/~ end