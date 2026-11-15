use ceiling_kernels::direct::DirectMachine;
use ceiling_kernels::machine::{Arithmetic, Heap, Trap};

#[test]
fn checked_arithmetic_and_bounds_return_failures() -> Result<(), Trap> {
    let mut machine = DirectMachine::default();
    assert_eq!(machine.add(i64::MAX, 1), Err(Trap::IntegerOverflow));
    assert_eq!(machine.quotient(1, 0), Err(Trap::DivisionByZero));
    assert_eq!(machine.remainder(i64::MIN, -1), Ok(0));
    assert_eq!(machine.array(-1), Err(Trap::NegativeSize));
    let empty = machine.array(0)?;
    assert_eq!(machine.read(empty, 0), Err(Trap::IndexOutOfRange));
    let array = machine.array(1)?;
    machine.write(array, 0, 42)?;
    assert_eq!(machine.read(array, 0), Ok(42));
    assert_eq!(machine.write(array, 1, 7), Err(Trap::IndexOutOfRange));
    Ok(())
}
