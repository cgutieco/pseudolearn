pub mod bounce;
pub mod list;
pub mod mandelbrot;
pub mod nbody;
pub mod permute;
pub mod queens;
pub mod richards;
mod richards_tasks;
pub mod sieve;
pub mod storage;
pub mod towers;

use crate::machine::{Handle, Machine, Outcome, Shape};

pub const RANDOM_SHAPE: Shape = Shape { links: 0, words: 1 };

pub fn random<Implementation: Machine>(machine: &mut Implementation) -> Outcome<Handle> {
    let random = machine.object(RANDOM_SHAPE)?;
    machine.set_field(random, 0, 74755)?;
    Ok(random)
}

pub fn draw<Implementation: Machine>(machine: &mut Implementation, random: Handle) -> Outcome<i64> {
    let seed = machine.field(random, 0)?;
    let scaled = machine.multiply(seed, 1309)?;
    let shifted = machine.add(scaled, 13849)?;
    let next = machine.remainder(shifted, 65536)?;
    machine.set_field(random, 0, next)?;
    Ok(next)
}

pub fn exclusive_or<Implementation: Machine>(
    machine: &mut Implementation,
    first: i64,
    second: i64,
) -> Outcome<i64> {
    let (mut left, mut right, mut result, mut weight) = (first, second, 0, 1);
    while left > 0 || right > 0 {
        if machine.remainder(left, 2)? != machine.remainder(right, 2)? {
            result = machine.add(result, weight)?;
        }
        left = machine.quotient(left, 2)?;
        right = machine.quotient(right, 2)?;
        weight = machine.multiply(weight, 2)?;
        machine.tick();
    }
    Ok(result)
}
