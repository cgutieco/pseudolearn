use ceiling_kernels::machine::{Calls, Handle, Heap, Shape, Trap};
use ceiling_kernels::semantic_memory::SemanticMachine;

#[test]
fn undefined_values_bounds_and_empty_allocations_are_distinct() -> Result<(), Trap> {
    let mut machine = SemanticMachine::default();
    let empty = machine.array(0)?;
    assert_eq!(machine.read(empty, 0), Err(Trap::IndexOutOfRange));
    assert_eq!(machine.array(-1), Err(Trap::NegativeSize));
    let array = machine.array(2)?;
    assert_eq!(machine.read(array, 1), Err(Trap::Uninitialized));
    machine.write(array, 1, 0)?;
    assert_eq!(machine.read(array, 1), Ok(0));
    let object = machine.object(Shape { words: 1, links: 1 })?;
    assert_eq!(machine.field(object, 1), Err(Trap::Uninitialized));
    assert_eq!(machine.link(object, 0), Err(Trap::Uninitialized));
    machine.set_field(object, 1, i64::MAX)?;
    assert_eq!(machine.field(object, 1), Ok(i64::MAX));
    assert_eq!(machine.read(Handle(u32::MAX), 0), Err(Trap::InvalidHandle));
    Ok(())
}

#[test]
fn rooted_cycles_survive_and_unreachable_cycles_release_live_cells() -> Result<(), Trap> {
    let mut machine = SemanticMachine::with_limit(4);
    machine.force_collection();
    machine.enter(&[], &[])?;
    let first = machine.object(Shape { words: 0, links: 1 })?;
    let second = machine.object(Shape { words: 0, links: 1 })?;
    machine.set_link(first, 0, second)?;
    machine.set_link(second, 0, first)?;
    machine.collect()?;
    assert_eq!(machine.link(second, 0), Ok(first));
    assert_eq!(machine.array(0), Err(Trap::CellLimit));
    machine.leave();
    let replacement = machine.array(3)?;
    assert_eq!(machine.link(first, 0), Err(Trap::InvalidHandle));
    machine.write(replacement, 2, 42)?;
    assert_eq!(machine.read(replacement, 2), Ok(42));
    Ok(())
}

#[test]
fn returned_handles_retained_by_callers_survive_collection() -> Result<(), Trap> {
    let mut machine = SemanticMachine::default();
    machine.enter(&[], &[])?;
    let array = machine.array(1)?;
    machine.write(array, 0, 42)?;
    machine.leave();
    machine.retain(array);
    machine.force_collection();
    machine.array(1)?;
    assert_eq!(machine.read(array, 0), Ok(42));
    Ok(())
}
