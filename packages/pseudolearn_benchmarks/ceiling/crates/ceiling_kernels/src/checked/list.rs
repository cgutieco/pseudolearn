use crate::machine::{Handle, Machine, Outcome, Shape};

const ELEMENT: Shape = Shape { links: 1, words: 2 };
const NEXT: u8 = 0;
const VALUE: u8 = 1;
const EMPTY: u8 = 2;

fn make<Implementation: Machine>(machine: &mut Implementation, length: i64) -> Outcome<Handle> {
    machine.enter(&[length], &[])?;
    let element = machine.object(ELEMENT)?;
    if length == 0 {
        machine.set_field(element, EMPTY, 1)?;
    } else {
        machine.set_field(element, EMPTY, 0)?;
        machine.set_field(element, VALUE, length)?;
        let shorter = machine.subtract(length, 1)?;
        let next = make(machine, shorter)?;
        machine.set_link(element, NEXT, next)?;
    }
    machine.leave();
    Ok(element)
}

fn is_shorter<Implementation: Machine>(
    machine: &mut Implementation,
    first: Handle,
    second: Handle,
) -> Outcome<bool> {
    machine.enter(&[], &[first, second])?;
    let (mut left, mut right) = (first, second);
    let mut result = false;
    while machine.field(right, EMPTY)? == 0 {
        if machine.field(left, EMPTY)? != 0 {
            result = true;
            break;
        }
        left = machine.link(left, NEXT)?;
        right = machine.link(right, NEXT)?;
        machine.tick();
    }
    machine.leave();
    Ok(result)
}

fn tail<Implementation: Machine>(
    machine: &mut Implementation,
    lists: [Handle; 3],
) -> Outcome<Handle> {
    machine.enter(&[], &lists)?;
    let [first, second, third] = lists;
    let result = if is_shorter(machine, second, first)? {
        let left_next = machine.link(first, NEXT)?;
        let left = tail(machine, [left_next, second, third])?;
        let middle_next = machine.link(second, NEXT)?;
        let middle = tail(machine, [middle_next, third, first])?;
        let right_next = machine.link(third, NEXT)?;
        let right = tail(machine, [right_next, first, second])?;
        tail(machine, [left, middle, right])?
    } else {
        third
    };
    machine.leave();
    Ok(result)
}

fn measure<Implementation: Machine>(machine: &mut Implementation, element: Handle) -> Outcome<i64> {
    machine.enter(&[], &[element])?;
    let length = if machine.field(element, EMPTY)? != 0 {
        0
    } else {
        let next = machine.link(element, NEXT)?;
        let rest = measure(machine, next)?;
        machine.add(1, rest)?
    };
    machine.leave();
    Ok(length)
}

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let first = make(machine, size)?;
    machine.retain(first);
    let middle = machine.subtract(size, 5)?;
    let second = make(machine, middle)?;
    machine.retain(second);
    let last = machine.subtract(size, 9)?;
    let third = make(machine, last)?;
    machine.retain(third);
    let result = tail(machine, [first, second, third])?;
    let length = measure(machine, result)?;
    machine.settle()?;
    Ok(length.to_string())
}
