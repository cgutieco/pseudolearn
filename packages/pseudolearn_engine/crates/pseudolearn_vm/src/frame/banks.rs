#![forbid(unsafe_code)]

use crate::VmTrap;

pub(super) fn bank_size(register_count: usize) -> Result<usize, VmTrap> {
    register_count
        .max(1)
        .checked_next_power_of_two()
        .ok_or_else(|| VmTrap::new("resourceLimit", None))
}

pub(super) fn grow_bank(bank: &mut Vec<u64>, position: usize) -> Result<(), VmTrap> {
    if position < bank.len() {
        return Ok(());
    }
    let required = position
        .checked_add(1)
        .ok_or_else(|| VmTrap::new("resourceLimit", None))?;
    let capacity = required
        .checked_next_power_of_two()
        .ok_or_else(|| VmTrap::new("resourceLimit", None))?;
    bank.resize(capacity, 0);
    Ok(())
}

pub(super) fn grow_reference_bank(bank: &mut Vec<u32>, position: usize) -> Result<(), VmTrap> {
    if position < bank.len() {
        return Ok(());
    }
    let required = position
        .checked_add(1)
        .ok_or_else(|| VmTrap::new("resourceLimit", None))?;
    let capacity = required
        .checked_next_power_of_two()
        .ok_or_else(|| VmTrap::new("resourceLimit", None))?;
    bank.resize(capacity, 0);
    Ok(())
}
