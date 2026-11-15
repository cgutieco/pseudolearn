use crate::checked::{draw, random};
use crate::machine::{Handle, Machine, Outcome, Shape};

const BALL: Shape = Shape { links: 0, words: 4 };

fn absolute<Implementation: Machine>(machine: &mut Implementation, value: i64) -> Outcome<i64> {
    machine.enter(&[value], &[])?;
    let result = if value < 0 {
        machine.subtract(0, value)?
    } else {
        value
    };
    machine.leave();
    Ok(result)
}

fn ball<Implementation: Machine>(
    machine: &mut Implementation,
    generator: Handle,
) -> Outcome<Handle> {
    machine.enter(&[], &[generator])?;
    let ball = machine.object(BALL)?;
    for (slot, modulus, offset) in [(0, 500, 0), (1, 500, 0), (2, 300, 150), (3, 300, 150)] {
        let drawn = draw(machine, generator)?;
        let reduced = machine.remainder(drawn, modulus)?;
        let value = machine.subtract(reduced, offset)?;
        machine.set_field(ball, slot, value)?;
    }
    machine.leave();
    Ok(ball)
}

fn clamp<Implementation: Machine>(
    machine: &mut Implementation,
    ball: Handle,
    axis: u8,
) -> Outcome<bool> {
    let speed_slot = axis.wrapping_add(2);
    let position = machine.field(ball, axis)?;
    if position > 500 {
        machine.set_field(ball, axis, 500)?;
        let speed = machine.field(ball, speed_slot)?;
        let magnitude = absolute(machine, speed)?;
        let reversed = machine.subtract(0, magnitude)?;
        machine.set_field(ball, speed_slot, reversed)?;
        return Ok(true);
    }
    if position < 0 {
        machine.set_field(ball, axis, 0)?;
        let speed = machine.field(ball, speed_slot)?;
        let magnitude = absolute(machine, speed)?;
        machine.set_field(ball, speed_slot, magnitude)?;
        return Ok(true);
    }
    Ok(false)
}

fn bounce<Implementation: Machine>(machine: &mut Implementation, ball: Handle) -> Outcome<bool> {
    machine.enter(&[], &[ball])?;
    for axis in 0..2 {
        let position = machine.field(ball, axis)?;
        let speed = machine.field(ball, axis.wrapping_add(2))?;
        let moved = machine.add(position, speed)?;
        machine.set_field(ball, axis, moved)?;
    }
    let horizontal = clamp(machine, ball, 0)?;
    let vertical = clamp(machine, ball, 1)?;
    machine.leave();
    Ok(horizontal || vertical)
}

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let generator = random(machine)?;
    let balls = machine.array(100)?;
    let mut index = 0;
    while index <= 99 {
        let created = ball(machine, generator)?;
        machine.write_link(balls, index, created)?;
        index = machine.add(index, 1)?;
    }
    let (mut bounces, mut round) = (0, 1);
    while round <= size {
        index = 0;
        while index <= 99 {
            let current = machine.read_link(balls, index)?;
            if bounce(machine, current)? {
                bounces = machine.add(bounces, 1)?;
            }
            index = machine.add(index, 1)?;
            machine.tick();
        }
        round = machine.add(round, 1)?;
    }
    machine.settle()?;
    Ok(bounces.to_string())
}
