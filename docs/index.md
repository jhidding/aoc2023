# About

## About Julia
Most of these solutions will be written in Julia. The advantage of Julia is that we have a modern expressive language with native performance. However, since Julia compiles code just-in-time, there usually is a lag involved. It is relatively hard to evaluate Julia snippets from the shell in a usable manner. I'm using `DaemonMode.jl` to get a reasonable middle ground between responsivity and code efficiency.

To automate running scripts I use [Brei](https://entangled.github.io/brei). To run solutions for all days:

```
brei run
```

??? "Brei workflow"

    ``` {.toml file=brei.toml}
    include = [".entangled/tasks.json"]

    [runner.julia]
    command = "julia"
    args = [
             "--project=.",
             "--startup-file=no",
             "-O0",
             "-e",
             "using DaemonMode; runargs()",
             "${script}",
    ]

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
    day = ["01", "02", "03", "04"]
    ```

### Visualisations
Any visualisation will be done using `Makie.jl` and its WebGL backend.

### Testing
Examples in the exercises will be converted to unit tests.

``` {.julia file=test/runtests.jl}
using AOC2023
using Test

@testset "tests" begin
  <<test>>
end
```

### Main module

``` {.julia file=src/AOC2023.jl}
module AOC2023

include("Parsing.jl")

include("Day01.jl")
include("Day02.jl")
include("Day03.jl")
include("Day04.jl")

end
```
