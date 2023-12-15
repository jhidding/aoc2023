# ~/~ begin <<docs/day15.md#src/Day15.jl>>[init]
module Day15

using ..Parsing: sep_by_p, token, fmap, sequence, integer, skip

abstract type Instr end
struct InsertInstr <: Instr
  lens::String
  value::Int
end
struct DeleteInstr <: Instr
  lens::String
end

input_p = sep_by_p(token(r"[a-z0-9=\-]+") >> fmap(m -> m.match), token(","))
lens_p = token(r"[a-z]+") >> fmap(m -> m.match)
insert_p = sequence(lens_p, token("=") >>> integer) >> fmap(splat(InsertInstr))
delete_p = lens_p >> skip(token("-")) >> fmap(DeleteInstr)
instr_p = insert_p | delete_p

lens_hash(s::AbstractString) = foldl((curr, next) -> (curr + convert(Int64, next)) * 17 % 256, codeunits(s); init=0)

struct HashMap{Key,Value}
  boxes::Vector{Vector{Pair{Key,Value}}}
end

HashMap{K,V}() where {K,V} = HashMap{K,V}(Vector{Pair{K,V}}[Pair{K,V}[] for _ in 1:256])

function Base.setindex!(hm::HashMap{K,V}, value::V, key::K) where {K,V}
  h = lens_hash(key)
  box = hm.boxes[h+1]
  loc = findfirst(kv -> kv.first == key, box)
  if isnothing(loc)
    push!(box, key => value)
  else
    box[loc] = (key => value)
  end
  hm
end

function Base.delete!(hm::HashMap{K,V}, key::K) where {K,V}
  h = lens_hash(key)
  box = hm.boxes[h+1]
  loc = findfirst(kv -> kv.first == key, box)
  isnothing(loc) && return
  deleteat!(box, loc)
  hm
end

function execute(hm::HashMap{String,Int}, a::InsertInstr)
  hm[a.lens] = a.value
  hm
end

function execute(hm::HashMap{String,Int}, a::DeleteInstr)
  delete!(hm, a.lens)
  hm
end

function focussing_power(hm::HashMap{String,Int})
  box_power(b) = b .|> (l -> l.second) |> enumerate .|> splat(*) |> sum
  hm.boxes .|> box_power |> enumerate .|> splat(*) |> sum
end

function main(io::IO)
  input = read(io, String) |> (first ∘ input_p)
  println("Part 1: ", input .|> lens_hash |> sum)
  instr::Vector{Instr} = input .|> (first ∘ instr_p)
  hm = foldl(execute, instr; init=HashMap{String,Int}())
  println("Part 2: ", hm |> focussing_power)
end

end
# ~/~ end
