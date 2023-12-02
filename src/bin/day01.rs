// ~/~ begin <<docs/day01.md#src/bin/day01.rs>>[init]
use std::io;

fn calibration(line: &String) -> Option<u32> {
    let mut x = line.chars().filter(|x| x.is_digit(10));
    let a = x.next()?;
    let b = x.last().unwrap_or(a);
    Some((a as u32 - '0' as u32) * 10 + (b as u32 - '0' as u32))
}

fn main() -> Result<(), io::Error> {
    let input: Vec<_> = io::stdin().lines().collect::<Result<Vec<_>, _>>()?;
    println!("{}", input.iter().filter_map(calibration).sum::<u32>());
    Ok(())
}
// ~/~ end

