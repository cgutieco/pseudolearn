use ceiling_kernels::differential::{Differential, Unobserved};
use ceiling_kernels::machine::{Arithmetic, Calls, Heap, Trap};
use ceiling_kernels::remanso::RemansoMachine;

#[test]
fn immediate_arithmetic_checks_the_first_failure_and_array_boundaries() -> Result<(), Trap> {
    let mut machine = RemansoMachine::<Unobserved>::default();
    assert_eq!(machine.add(i64::MAX, 1), Err(Trap::IntegerOverflow));
    assert_eq!(machine.quotient(1, 0), Err(Trap::DivisionByZero));
    assert_eq!(machine.remainder(i64::MIN, -1), Ok(0));
    assert_eq!(machine.array(-1), Err(Trap::NegativeSize));
    let empty = machine.array(0)?;
    assert_eq!(machine.read(empty, 0), Err(Trap::IndexOutOfRange));
    let array = machine.array(2)?;
    machine.write(array, 1, 42)?;
    assert_eq!(machine.read(array, 1), Ok(42));
    assert_eq!(machine.read(array, -1), Err(Trap::IndexOutOfRange));
    assert_eq!(machine.write(array, 2, 9), Err(Trap::IndexOutOfRange));
    Ok(())
}

#[test]
fn deterministic_polling_takes_real_checkpoints_across_resets() {
    let mut machine = RemansoMachine::<Differential>::default();
    for _ in 0..((1 << 17) - 1) {
        machine.tick();
    }
    assert_eq!(machine.checkpoints(), 0);
    machine.reset();
    machine.tick();
    assert_eq!(machine.checkpoints(), 1);
}
