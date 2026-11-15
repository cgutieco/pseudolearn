use crate::{ArraySliceRange, TimelineError, VariableValue};
use pseudolearn_runtime::{
    Handle, allocation_ordinal, array_dimensions, array_element_kind, is_defined_element,
    live_allocation_handles, read_element_raw,
};
use pseudolearn_vm::Machine;

pub(crate) fn find_identity(machine: &Machine<'_>, ordinal: u64) -> Option<Handle> {
    live_allocation_handles(machine.heap())
        .into_iter()
        .find(|handle| allocation_ordinal(machine.heap(), *handle) == Ok(ordinal))
}

pub(crate) fn read_slice(
    machine: &Machine<'_>,
    identity_ordinal: u64,
    range: ArraySliceRange,
) -> Result<Vec<VariableValue>, TimelineError> {
    let handle = find_identity(machine, identity_ordinal)
        .ok_or(TimelineError::InvalidArray { identity_ordinal })?;
    let dimensions = array_dimensions(machine.heap(), handle)
        .map_err(|_| TimelineError::InvalidArray { identity_ordinal })?;
    let total = dimensions
        .iter()
        .try_fold(1_usize, |total, dimension| {
            usize::try_from(*dimension)
                .ok()
                .and_then(|dimension| total.checked_mul(dimension))
        })
        .ok_or(TimelineError::ReplayFailure)?;
    validate_range(range, total)?;
    let kind =
        array_element_kind(machine.heap(), handle).map_err(|_| TimelineError::ReplayFailure)?;
    let mut values = Vec::new();
    for offset in 0..range.slice_length {
        let index = range
            .start_index
            .checked_add(offset)
            .ok_or(TimelineError::ReplayFailure)?;
        let defined = is_defined_element(machine.heap(), handle, index)
            .map_err(|_| TimelineError::ReplayFailure)?;
        let word = read_element_raw(machine.heap(), handle, index)
            .map_err(|_| TimelineError::ReplayFailure)?;
        values.push(if defined {
            crate::inspect::decode_field_value(machine, kind, word)
        } else {
            VariableValue::Undefined
        });
    }
    Ok(values)
}

fn validate_range(range: ArraySliceRange, total_elements: usize) -> Result<(), TimelineError> {
    if range
        .start_index
        .checked_add(range.slice_length)
        .is_none_or(|end| end > total_elements)
    {
        return Err(TimelineError::SliceOutOfRange {
            start_index: range.start_index,
            slice_length: range.slice_length,
            total_elements,
        });
    }
    Ok(())
}
