# About

## About Julia
Most of these solutions will be written in Julia. Any visualisation will be done using `Makie.jl` and its WebGL backend.

``` {.toml file=brei.toml}
include = [".entangled/tasks.json"]

[runner.julia]
command = "julia"
args = [ "--project=.", "--startup-file=no", "--compile=min", "-O0",
         "-e", "using DaemonMode; runargs()",
         "${script}" ]

[[task]]
name = "julia-daemon"
script = "julia --project=. --startup-file=no -e 'using Revise; using DaemonMode; serve()'"

[template.run-day]
name = "day${day}"
runner = "julia"
requires = ["input/day${day}.txt", "src/Day${day}.jl"]
stdout = "output/day${day}.txt"
script = """
using AOC2023.Day${day}

open("input/day${day}.txt", "r") do f_in
    Day${day}.main(f_in)
end
println()
"""

[[call]]
template = "run-day"
collect = "run"
[call.args]
day = ["01"]
```

``` {.julia file=test/runtests.jl}
using AOC2023
using Test

@testset "tests" begin
    <<test>>
end
```

``` {.julia file=src/AOC2023.jl}
module AOC2023

include("Day01.jl")

end
```
