use crate::machine::{Handle, Machine, Outcome};

fn swap<Implementation: Machine>(
    machine: &mut Implementation,
    values: Handle,
    left: i64,
    right: i64,
) -> Outcome<()> {
    let first = machine.read(values, left)?;
    let second = machine.read(values, right)?;
    machine.write(values, left, second)?;
    machine.write(values, right, first)
}

fn permute<Implementation: Machine>(
    machine: &mut Implementation,
    values: Handle,
    number: i64,
) -> Outcome<i64> {
    machine.enter(&[number], &[values])?;
    let (number, values) = (machine.word(0), machine.handle(0));
    let mut count = 1;
    if number != 0 {
        let below = machine.subtract(number, 1)?;
        let nested = permute(machine, values, below)?;
        count = machine.add(count, nested)?;
        let mut index = below;
        while index >= 0 {
            swap(machine, values, below, index)?;
            let nested = permute(machine, values, below)?;
            count = machine.add(count, nested)?;
            swap(machine, values, below, index)?;
            index = machine.subtract(index, 1)?;
            machine.tick();
        }
    }
    machine.leave();
    Ok(count)
}

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let values = machine.array(10)?;
    let mut index = 0;
    while index <= 9 {
        machine.write(values, index, 0)?;
        index = machine.add(index, 1)?;
    }
    let count = permute(machine, values, size)?;
    machine.settle()?;
    Ok(count.to_string())
}
