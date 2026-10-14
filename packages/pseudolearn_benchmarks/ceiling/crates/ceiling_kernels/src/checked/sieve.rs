use crate::machine::{Machine, Outcome};

pub fn run<Implementation: Machine>(machine: &mut Implementation, size: i64) -> Outcome<String> {
    let flags = machine.array(5001)?;
    let mut index = 0;
    while index <= size {
        machine.write(flags, index, 1)?;
        index = machine.add(index, 1)?;
        machine.tick();
    }
    let mut count = 0;
    index = 2;
    while index <= size {
        if machine.read(flags, index)? != 0 {
            count = machine.add(count, 1)?;
            let mut multiple = machine.add(index, index)?;
            while multiple <= size {
                machine.write(flags, multiple, 0)?;
                multiple = machine.add(multiple, index)?;
                machine.tick();
            }
        }
        index = machine.add(index, 1)?;
        machine.tick();
    }
    machine.settle()?;
    Ok(count.to_string())
}
