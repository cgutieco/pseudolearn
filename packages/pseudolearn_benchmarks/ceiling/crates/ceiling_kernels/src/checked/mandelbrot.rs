use crate::checked::exclusive_or;
use crate::machine::{Machine, Outcome, RealOperation};

fn coordinate<Implementation: Machine>(
    machine: &mut Implementation,
    position: i64,
    size: i64,
    offset: f64,
) -> Outcome<f64> {
    let position = machine.real(RealOperation::Multiply, 2.0, real_of(position))?;
    let scaled = machine.real(RealOperation::Divide, position, real_of(size))?;
    machine.real(RealOperation::Subtract, scaled, offset)
}

fn real_of(value: i64) -> f64 {
    i32::try_from(value).map_or(f64::NAN, f64::from)
}

fn escapes<Implementation: Machine>(
    machine: &mut Implementation,
    real: f64,
    imaginary: f64,
) -> Outcome<i64> {
    let (mut squared_real, mut current_imaginary, mut squared_imaginary) = (0.0, 0.0, 0.0);
    let mut iteration = 0;
    while iteration < 50 {
        let difference = machine.real(RealOperation::Subtract, squared_real, squared_imaginary)?;
        let current_real = machine.real(RealOperation::Add, difference, real)?;
        let doubled = machine.real(RealOperation::Multiply, 2.0, current_real)?;
        let product = machine.real(RealOperation::Multiply, doubled, current_imaginary)?;
        current_imaginary = machine.real(RealOperation::Add, product, imaginary)?;
        squared_real = machine.real(RealOperation::Multiply, current_real, current_real)?;
        squared_imaginary = machine.real(
            RealOperation::Multiply,
            current_imaginary,
            current_imaginary,
        )?;
        let magnitude = machine.real(RealOperation::Add, squared_real, squared_imaginary)?;
        iteration = machine.add(iteration, 1)?;
        machine.tick();
        if magnitude > 4.0 {
            return Ok(1);
        }
    }
    Ok(0)
}

struct Accumulator {
    sum: i64,
    bits: i64,
    value: i64,
}

fn flush<Implementation: Machine>(
    machine: &mut Implementation,
    accumulator: &mut Accumulator,
    shift: i64,
) -> Outcome<()> {
    let mut factor = 1;
    let mut remaining = shift;
    while remaining > 0 {
        factor = machine.multiply(factor, 2)?;
        remaining = machine.subtract(remaining, 1)?;
    }
    let shifted = machine.multiply(accumulator.value, factor)?;
    accumulator.sum = exclusive_or(machine, accumulator.sum, shifted)?;
    accumulator.value = 0;
    accumulator.bits = 0;
    Ok(())
}

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let mut accumulator = Accumulator {
        sum: 0,
        bits: 0,
        value: 0,
    };
    let mut row = 0;
    while row < size {
        let imaginary = coordinate(machine, row, size, 1.0)?;
        let mut column = 0;
        while column < size {
            let real = coordinate(machine, column, size, 1.5)?;
            let escape = escapes(machine, real, imaginary)?;
            let doubled = machine.multiply(accumulator.value, 2)?;
            accumulator.value = machine.add(doubled, escape)?;
            accumulator.bits = machine.add(accumulator.bits, 1)?;
            let last = machine.subtract(size, 1)?;
            if accumulator.bits == 8 || column == last {
                let shift = machine.subtract(8, accumulator.bits)?;
                flush(machine, &mut accumulator, shift)?;
            }
            column = machine.add(column, 1)?;
        }
        row = machine.add(row, 1)?;
    }
    machine.settle()?;
    Ok(accumulator.sum.to_string())
}
