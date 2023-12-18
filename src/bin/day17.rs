// ~/~ begin <<docs/day17.md#src/bin/day17.rs>>[init]
use std::io;
use ndarray::Array2;

#[derive(Debug)]
enum Error {
    IO(io::Error),
}

fn main() -> Result<(), Error> {
    let input: Vec<Vec<u8>> = io::stdin()
        .lines()
        .map(|s| Ok::<Vec<u8>, io::Error>(
            s?.as_bytes().into_iter().map(|c| c - '0' as u8).collect()))
        .collect::<Result<Vec<_>, _>>()
        .map_err(Error::IO)?;
    let w = input[0].len();
    let h = input.len();

    let cost = Array2::from_shape_vec((w, h), input.into_iter().flatten().collect());
    println!("{:?}", cost);
    Ok(())
}
// ~/~ end