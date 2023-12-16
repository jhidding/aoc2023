// ~/~ begin <<docs/day16.md#src/bin/day16.rs>>[init]
use std::convert::From;
use std::io;
use std::ops::{Add, Index, IndexMut, Neg, Sub};
use std::time::Instant;

// ~/~ begin <<docs/day16.md#day16-vec2-rs>>[init]
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
// ~/~ end

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
// ~/~ end
