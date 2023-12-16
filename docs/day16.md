# Day 16: The Floor Will Be Lava

Write the direction of the laser as two coordinates.
At a slash or back-slash, the reflected direction is found by swapping the axes or swapping and negating.

``` {.julia #day16}
@inline swap(i::CartesianIndex) = CartesianIndex(i[2], i[1])
split(i::CartesianIndex) = (swap(i), -swap(i))
```

To keep track of where the laser has already visited, encode the direction into a single integer.

``` {.julia #day16}
@inline dirmap(i::CartesianIndex) = i[1] == 0 ?
                                    convert(UInt8, (i[2] + 3) >> 1) :
                                    convert(UInt8, (i[1] + 3) << 1)
```

Map all interactions on the map from characters to functions.

``` {.julia #day16}
where_to = Dict(
  '\\' => i -> (swap(i), nothing),
  '/' => i -> (-swap(i), nothing),
  '-' => i -> i[1] == 0 ? (i, nothing) : split(i),
  '|' => i -> i[1] == 0 ? split(i) : (i, nothing),
  '.' => i -> (i, nothing)
)
```

For part 1 we can track the laser using a stack to manage splits

``` {.julia #day16}
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
```

For part 2 we can brute force on all starting positions, and get the result in about half a second.

``` {.julia file=src/Day16.jl}
module Day16

<<day16>>

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
```

``` title="output day 16"
{% include "day16.txt" %}
```

## Rust implementation
Let's do this the right way: create a few structs and implement methods on top of them to get some 2d array support.

??? "2d array implementation"

    ``` {.rust #day16-vec2-rs}
    #[derive(Debug)]
    struct Vec2<T> {
        width: usize,
        height: usize,
        data: Vec<T>,
    }

    #[derive(Debug, Clone, Copy, PartialEq, Eq)]
    struct Ix2 {
        x: isize,
        y: isize,
    }

    impl Ix2 {
        fn swap(&self) -> Ix2 {
            Ix2 { x: self.y, y: self.x }
        }
    }

    impl Add for Ix2 {
        type Output = Self;
        fn add(self, other: Self) -> Self::Output {
            Ix2 { x: self.x + other.x, y: self.y + other.y }
        }
    }

    impl Sub for Ix2 {
        type Output = Self;
        fn sub(self, other: Self) -> Self::Output {
            Ix2 { x: self.x - other.x, y: self.y - other.y }
        }
    }

    impl Neg for Ix2 {
        type Output = Self;
        fn neg(self) -> Self::Output {
            Ix2 { x: -self.x, y: -self.y }
        }
    }

    impl<T: Clone> Vec2<T> {
        fn inbounds(&self, index: Ix2) -> bool {
            index.x < (self.width as isize)
                && index.x >= 0
                && index.y < (self.height as isize)
                && index.y >= 0
        }

        fn zeros(width: usize, height: usize) -> Vec2<T>
        where
            T: From<u8>,
        {
            Vec2 { width, height, data: vec![0.into(); width * height] }
        }
    }

    impl<T> Index<Ix2> for Vec2<T> {
        type Output = T;
        fn index(&self, index: Ix2) -> &Self::Output {
            &self.data[index.x as usize + index.y as usize * self.width]
        }
    }

    impl<T> IndexMut<Ix2> for Vec2<T> {
        fn index_mut(&mut self, index: Ix2) -> &mut Self::Output {
            &mut self.data[index.x as usize + index.y as usize * self.width]
        }
    }
    ```

The rest of the implementation is a straight-forward translation of the Julia code into Rust. What is not so trivial is the performance improvement: the Rust code is more than 10 times faster.

??? "Run rust code"

    ``` {.bash .task}
    #| description: run rust day 16
    #| stdout: output/day16-rust.txt
    #| stdin: input/day16.txt
    #| requires: src/bin/day16.rs
    #| collect: rust
    cargo run --release --bin day16 < input/day16.txt
    ```

``` title="output day 16 - rust"
{% include "day16-rust.txt" %}
```

``` {.rust file=src/bin/day16.rs}
use std::convert::From;
use std::io;
use std::ops::{Add, Index, IndexMut, Neg, Sub};
use std::time::Instant;

<<day16-vec2-rs>>

fn dirmap(d: Ix2) -> u8 {
    if d.x == 0 {
        ((d.y + 3) >> 1) as u8
    } else {
        ((d.x + 3) << 1) as u8
    }
}

const DOT: u8 = '.' as u8;
const HYPHEN: u8 = '-' as u8;
const VBAR: u8 = '|' as u8;
const SLASH: u8 = '/' as u8;
const BACKSLASH: u8 = '\\' as u8;

fn rec(f: &Vec2<u8>, v: &mut Vec2<u8>, x: Ix2, dx: Ix2) {
    if !f.inbounds(x) {
        return;
    };
    if v[x] & dirmap(dx) != 0 {
        return;
    };

    v[x] |= dirmap(dx);
    if f[x] == DOT || (f[x] == HYPHEN && dx.y == 0)
                   || (f[x] == VBAR && dx.x == 0) {
        rec(f, v, x + dx, dx)
    } else if f[x] == SLASH {
        rec(f, v, x - dx.swap(), -dx.swap())
    } else if f[x] == BACKSLASH {
        rec(f, v, x + dx.swap(), dx.swap())
    } else {
        rec(f, v, x + dx.swap(), dx.swap());
        rec(f, v, x - dx.swap(), -dx.swap())
    }
}

fn trace(f: &Vec2<u8>, x: Ix2, dx: Ix2) -> usize {
    let mut visited = Vec2::<u8>::zeros(f.width, f.height);
    rec(f, &mut visited, x, dx);
    visited
        .data
        .iter()
        .map(|&x| if x != 0 { 1 } else { 0 })
        .sum()
}

fn border(w_: usize, h_: usize) -> impl Iterator<Item = (Ix2, Ix2)> {
    let w = w_ as isize;
    let h = h_ as isize;

    (0..w).map(move |x| (Ix2 { x, y: 0 }, Ix2 { x: 0, y: 1 }))
    .chain((0..h).map(move |y| (Ix2 { x: 0, y }, Ix2 { x: 1, y: 0 })))
    .chain((0..w).map(move |x| (Ix2 { x, y: h - 1 }, Ix2 { x: 0, y: -1 })))
    .chain((0..h).map(move |y| (Ix2 { x: w - 1, y }, Ix2 { x: -1, y: 0 })))
}

#[derive(Debug)]
enum Error {
    IO(io::Error),
    NoMaximum
}

fn main() -> Result<(), Error> {
    let input: Vec<Vec<u8>> = io::stdin()
        .lines()
        .map(|s| Ok::<Vec<u8>, io::Error>(s?.as_bytes().to_vec()))
        .collect::<Result<Vec<_>, _>>().map_err(Error::IO)?;
    let width = input[0].len();
    let height = input.len();
    let f = Vec2::<u8> {
        width,
        height,
        data: input.into_iter().flatten().collect(),
    };

    let part1 = trace(&f, Ix2 { x: 0, y: 0 }, Ix2 { x: 1, y: 0 });
    println!("Part 1: {}", part1);
    let now = Instant::now();
    let part2 = border(width, height).map(|(x, dx)| trace(&f, x, dx)).max();
    println!("Part 2: {}", part2.ok_or(Error::NoMaximum)?);
    let elapsed = now.elapsed();
    println!("part 2 took {} seconds", elapsed.as_secs_f64());
    Ok(())
}
```
