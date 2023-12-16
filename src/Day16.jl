# ~/~ begin <<docs/day16.md#src/Day16.jl>>[init]
module Day16

# ~/~ begin <<docs/day16.md#day16>>[init]
@inline swap(i::CartesianIndex) = CartesianIndex(i[2], i[1])
split(i::CartesianIndex) = (swap(i), -swap(i))
# ~/~ end
# ~/~ begin <<docs/day16.md#day16>>[1]
@inline dirmap(i::CartesianIndex) = i[1] == 0 ?
                                    convert(UInt8, (i[2] + 3) >> 1) :
                                    convert(UInt8, (i[1] + 3) << 1)
# ~/~ end
# ~/~ begin <<docs/day16.md#day16>>[2]
where_to = Dict(
  '\\' => i -> (swap(i), nothing),
  '/' => i -> (-swap(i), nothing),
  '-' => i -> i[1] == 0 ? (i, nothing) : split(i),
  '|' => i -> i[1] == 0 ? split(i) : (i, nothing),
  '.' => i -> (i, nothing)
)
# ~/~ end
# ~/~ begin <<docs/day16.md#day16>>[3]
function part1(inp, x=CartesianIndex(1, 1), dx=CartesianIndex(0, 1))
  stack = [(x, dx)]
  dirs = zeros(UInt8, size(inp)...)

  check(x, dx) = checkbounds(Bool, inp, x) && (dirs[x] & dirmap(dx) == 0)

  while !isempty(stack)
    (x, dx) = stack[end]
    dirs[x] |= dirmap(dx)
    (one, other) = where_to[inp[x]](dx)

    if check(x + one, one)
      stack[end] = (x + one, one)
    else
      pop!(stack)
    end

    if !isnothing(other) && check(x + other, other)
      push!(stack, (x + other, other))
    end
  end

  sum(dirs .!= 0)
end

function part1a(inp, x, dx)
  dirs = zeros(UInt8, size(inp)...)

  function loop(x, dx)
    !checkbounds(Bool, inp, x) && return
    dirs[x] & dirmap(dx) != 0 && return
    dirs[x] |= dirmap(dx)
    if inp[x] == '.' || (inp[x] == '-' && dx[1] == 0) || (inp[x] == '|' && dx[2] == 0)
      loop(x + dx, dx)
    elseif inp[x] == '/'
      loop(x - swap(dx), -swap(dx))
    elseif inp[x] == '\\'
      loop(x + swap(dx), swap(dx))
    else
      loop(x + swap(dx), swap(dx))
      loop(x - swap(dx), -swap(dx))
    end
  end

  loop(x, dx)
  sum(dirs .!= 0)
end
# ~/~ end

function borders(s)
  Iterators.flatten((
    ((CartesianIndex(1, i), CartesianIndex(1, 0)) for i in 1:s[2]),
    ((CartesianIndex(i, 1), CartesianIndex(0, 1)) for i in 1:s[1]),
    ((CartesianIndex(s[1], i), CartesianIndex(-1, 0)) for i in 1:s[2]),
    ((CartesianIndex(i, s[2]), CartesianIndex(0, -1)) for i in 1:s[2])))
end

function main(io::IO)
  inp = readlines(io) .|> collect |> stack |> permutedims
  println("Part 1: ", part1a(inp, CartesianIndex(1, 1), CartesianIndex(0, 1)))
  println("Part 2: ", maximum(((x, dx),) -> part1a(inp, x, dx), borders(size(inp))))
end

end
# ~/~ end