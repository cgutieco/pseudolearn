use crate::idiomatic::nbody::PLANETS;
use crate::machine::{
    Handle, Machine, Outcome, RealOperation, Shape, real_from_word, word_from_real,
};
use std::f64::consts::PI;

const SOLAR_MASS: f64 = 4.0 * PI * PI;
const BODY: Shape = Shape { links: 0, words: 7 };

fn read<Implementation: Machine>(
    machine: &mut Implementation,
    body: Handle,
    slot: u8,
) -> Outcome<f64> {
    Ok(real_from_word(machine.field(body, slot)?))
}

fn write<Implementation: Machine>(
    machine: &mut Implementation,
    body: Handle,
    slot: u8,
    value: f64,
) -> Outcome<()> {
    machine.set_field(body, slot, word_from_real(value))
}

fn create<Implementation: Machine>(
    machine: &mut Implementation,
    values: [f64; 7],
) -> Outcome<Handle> {
    let body = machine.object(BODY)?;
    for (slot, value) in (0_u8..7).zip(values) {
        write(machine, body, slot, value)?;
    }
    Ok(body)
}

fn system<Implementation: Machine>(machine: &mut Implementation) -> Outcome<Vec<Handle>> {
    let sun = create(machine, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, SOLAR_MASS])?;
    let mut bodies = vec![sun];
    for [horizontal, vertical, depth, speed_x, speed_y, speed_z, mass] in PLANETS {
        let speed_x = machine.real(RealOperation::Multiply, speed_x, 365.24)?;
        let speed_y = machine.real(RealOperation::Multiply, speed_y, 365.24)?;
        let speed_z = machine.real(RealOperation::Multiply, speed_z, 365.24)?;
        let mass = machine.real(RealOperation::Multiply, mass, SOLAR_MASS)?;
        bodies.push(create(
            machine,
            [horizontal, vertical, depth, speed_x, speed_y, speed_z, mass],
        )?);
    }
    for axis in 0_u8..3 {
        let mut momentum = 0.0;
        for body in &bodies {
            let speed = read(machine, *body, axis.wrapping_add(3))?;
            let mass = read(machine, *body, 6)?;
            let product = machine.real(RealOperation::Multiply, speed, mass)?;
            momentum = machine.real(RealOperation::Add, momentum, product)?;
        }
        let scaled = machine.real(RealOperation::Divide, momentum, SOLAR_MASS)?;
        let speed = machine.real(RealOperation::Subtract, 0.0, scaled)?;
        write(machine, sun, axis.wrapping_add(3), speed)?;
    }
    Ok(bodies)
}

fn delta<Implementation: Machine>(
    machine: &mut Implementation,
    first: Handle,
    second: Handle,
) -> Outcome<([f64; 3], f64)> {
    let mut difference = [0.0; 3];
    for (axis, target) in (0_u8..3).zip(difference.iter_mut()) {
        let left = read(machine, first, axis)?;
        let right = read(machine, second, axis)?;
        *target = machine.real(RealOperation::Subtract, left, right)?;
    }
    let mut squared = 0.0;
    for value in difference {
        let product = machine.real(RealOperation::Multiply, value, value)?;
        squared = machine.real(RealOperation::Add, squared, product)?;
    }
    Ok((difference, squared))
}

fn interact<Implementation: Machine>(
    machine: &mut Implementation,
    first: Handle,
    second: Handle,
) -> Outcome<()> {
    machine.enter(&[], &[first, second])?;
    let (difference, squared) = delta(machine, first, second)?;
    let distance = machine.root(squared)?;
    let cubed = machine.real(RealOperation::Multiply, squared, distance)?;
    let magnitude = machine.real(RealOperation::Divide, 0.01, cubed)?;
    for (axis, difference) in (3_u8..6).zip(difference) {
        let mass = read(machine, second, 6)?;
        let product = machine.real(RealOperation::Multiply, difference, mass)?;
        let shift = machine.real(RealOperation::Multiply, product, magnitude)?;
        let speed = read(machine, first, axis)?;
        let speed = machine.real(RealOperation::Subtract, speed, shift)?;
        write(machine, first, axis, speed)?;
        let mass = read(machine, first, 6)?;
        let product = machine.real(RealOperation::Multiply, difference, mass)?;
        let shift = machine.real(RealOperation::Multiply, product, magnitude)?;
        let speed = read(machine, second, axis)?;
        let speed = machine.real(RealOperation::Add, speed, shift)?;
        write(machine, second, axis, speed)?;
    }
    machine.leave();
    Ok(())
}

fn advance<Implementation: Machine>(
    machine: &mut Implementation,
    bodies: &[Handle],
) -> Outcome<()> {
    for (index, first) in bodies.iter().enumerate() {
        for second in bodies.iter().skip(index.wrapping_add(1)) {
            interact(machine, *first, *second)?;
        }
    }
    for body in bodies {
        for axis in 0_u8..3 {
            let speed = read(machine, *body, axis.wrapping_add(3))?;
            let shift = machine.real(RealOperation::Multiply, 0.01, speed)?;
            let position = read(machine, *body, axis)?;
            let position = machine.real(RealOperation::Add, position, shift)?;
            write(machine, *body, axis, position)?;
        }
        machine.tick();
    }
    Ok(())
}

fn kinetic<Implementation: Machine>(machine: &mut Implementation, body: Handle) -> Outcome<f64> {
    let mut squared = 0.0;
    for axis in 3..6 {
        let speed = read(machine, body, axis)?;
        let product = machine.real(RealOperation::Multiply, speed, speed)?;
        squared = machine.real(RealOperation::Add, squared, product)?;
    }
    let mass = read(machine, body, 6)?;
    let half_mass = machine.real(RealOperation::Multiply, 0.5, mass)?;
    machine.real(RealOperation::Multiply, half_mass, squared)
}

fn energy<Implementation: Machine>(
    machine: &mut Implementation,
    bodies: &[Handle],
) -> Outcome<f64> {
    let mut total = 0.0;
    for (index, first) in bodies.iter().enumerate() {
        let motion = kinetic(machine, *first)?;
        total = machine.real(RealOperation::Add, total, motion)?;
        for second in bodies.iter().skip(index.wrapping_add(1)) {
            let (_, squared) = delta(machine, *first, *second)?;
            let distance = machine.root(squared)?;
            let left = read(machine, *first, 6)?;
            let right = read(machine, *second, 6)?;
            let product = machine.real(RealOperation::Multiply, left, right)?;
            let attraction = machine.real(RealOperation::Divide, product, distance)?;
            total = machine.real(RealOperation::Subtract, total, attraction)?;
        }
    }
    Ok(total)
}

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let bodies = system(machine)?;
    for _ in 0..size {
        advance(machine, &bodies)?;
    }
    let energy = energy(machine, &bodies)?;
    let scaled = machine.real(RealOperation::Multiply, energy, 1_000_000_000_000_000.0)?;
    machine.settle()?;
    Ok(format!("{:.0}", scaled.trunc()))
}
