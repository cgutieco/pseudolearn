use super::{CollectionMachine, Collector, Statistics};
use crate::machine::{Calls, Handle, Heap, Outcome, Shape};

pub fn run(
    kernel: &str,
    size: i64,
    collector: Collector,
    forced: bool,
) -> Outcome<(String, Statistics)> {
    let mut machine = CollectionMachine::new(collector, forced);
    let output = match kernel {
        "storage-deep" => deep_storage(&mut machine, size)?,
        "list-churn" => list_churn(&mut machine, size)?,
        _ => crate::variant::checked(kernel, &mut machine, size)?,
    };
    machine.collect()?;
    machine.checkpoint();
    Ok((output, machine.statistics))
}

fn deep_storage(machine: &mut CollectionMachine, depth: i64) -> Outcome<String> {
    let mut stack = vec![(depth, Handle(0), 0_u8)];
    let mut count = 0_i64;
    while let Some((level, parent, slot)) = stack.pop() {
        let node = machine.object(Shape { links: 4, words: 1 })?;
        count = count.saturating_add(1);
        if parent.0 != 0 {
            machine.set_link(parent, slot, node)?;
        }
        if level > 1 {
            for next in (0..4).rev() {
                stack.push((level.saturating_sub(1), node, next));
            }
        }
        machine.tick();
    }
    Ok(count.to_string())
}

fn list_churn(machine: &mut CollectionMachine, rounds: i64) -> Outcome<String> {
    let mut head = Handle(0);
    let mut count = 0_i64;
    for round in 0..rounds {
        if round.checked_rem(64) == Some(0) {
            head = Handle(0);
        }
        machine.frames.clear();
        machine.frames.push(vec![head]);
        let node = machine.object(Shape { links: 1, words: 1 })?;
        machine.set_link(node, 0, head)?;
        machine.set_field(node, 1, round)?;
        head = node;
        count = count.saturating_add(1);
        machine.tick();
    }
    Ok(count.to_string())
}
