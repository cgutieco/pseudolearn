use crate::checked::{draw, random};
use crate::machine::{Handle, Machine, Outcome, Shape};

const NODE: Shape = Shape { links: 4, words: 1 };
const SIZE: u8 = 4;

fn build<Implementation: Machine>(
    machine: &mut Implementation,
    depth: i64,
    generator: Handle,
    count: &mut i64,
) -> Outcome<Handle> {
    machine.enter(&[depth], &[generator])?;
    *count = machine.add(*count, 1)?;
    let node = machine.object(NODE)?;
    if depth == 1 {
        let drawn = draw(machine, generator)?;
        let size = machine.remainder(drawn, 10)?;
        let size = machine.add(size, 1)?;
        machine.set_field(node, SIZE, size)?;
    } else {
        let lower = machine.subtract(depth, 1)?;
        for slot in 0..4 {
            let child = build(machine, lower, generator, count)?;
            machine.set_link(node, slot, child)?;
        }
    }
    machine.leave();
    Ok(node)
}

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let generator = random(machine)?;
    let mut count = 0;
    let root = build(machine, size, generator, &mut count)?;
    machine.settle()?;
    std::hint::black_box(root);
    Ok(count.to_string())
}
