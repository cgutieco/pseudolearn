use ceiling_kernels::clepsydra::ClepsydraMachine;
use ceiling_kernels::machine::{Arithmetic, Heap, Trap};

#[test]
fn deferred_trap_prevents_following_effect() -> Result<(), Trap> {
    let mut machine = ClepsydraMachine::new(None)?;
    let array = machine.array(1)?;
    machine.write(array, 0, 42)?;
    machine.add(i64::MAX, 1)?;
    assert_eq!(machine.write(array, 0, 7), Err(Trap::IntegerOverflow));
    assert_eq!(machine.read(array, 0), Err(Trap::IntegerOverflow));
    machine.reset();
    assert_eq!(machine.settle(), Ok(()));
    Ok(())
}

#[test]
fn deferred_traps_preserve_first_failure() -> Result<(), Trap> {
    let mut machine = ClepsydraMachine::new(None)?;
    machine.add(i64::MAX, 1)?;
    machine.quotient(1, 0)?;
    assert_eq!(machine.settle(), Err(Trap::IntegerOverflow));
    machine.reset();
    machine.quotient(1, 0)?;
    machine.add(i64::MAX, 1)?;
    assert_eq!(machine.settle(), Err(Trap::DivisionByZero));
    Ok(())
}
