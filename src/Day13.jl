# ~/~ begin <<docs/day13.md#src/Day13.jl>>[init]
module Day13

using InitialValues

function reduce_partition_by(f, r, it)
  Channel() do ch
    x = iterate(it)
    isnothing(x) && return
    prev = f(x[1])
    chunk = InitialValue(r)

    while !isnothing(x)
      curr = f(x[1])
      if curr != prev
        put!(ch, chunk)
        chunk = r(InitialValue(r), x[1])
        prev = curr
      else
        chunk = r(chunk, x[1])
      end
      x = iterate(it, x[2])
    end

    put!(ch, chunk)
  end
end

function find_smudged_reflection(m, n)
  s = size(m)[1]
  for i in 1:(s-1)
    w = min(i, s - i)
    if sum(m[i-w+1:i, :] .!= m[i+w:-1:i+1, :]) == n
      return i
    end
  end
  nothing
end

function main(io::IO)
  # readlines(io) |> Map(collect) |> ReducePartitionBy(isempty, asmonoid(hcat)) |> collect
  input = Iterators.filter(!isempty,
    reduce_partition_by(isempty, asmonoid(hcat),
      Iterators.map(collect, readlines(io)))) |> collect
  score(n) = function (m)
    x = find_smudged_reflection(m, n)
    isnothing(x) ? 100 * find_smudged_reflection(permutedims(m), n) : x
  end
  println("Part 1: ", input .|> score(0) |> sum)
  println("Part 2: ", input .|> score(1) |> sum)
end

end
# ~/~ end
