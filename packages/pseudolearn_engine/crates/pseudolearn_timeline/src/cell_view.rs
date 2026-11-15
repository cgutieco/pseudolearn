use crate::{AliasDestination, VariableValue, VariableView};
use pseudolearn_bytecode::{RegisterClass, ValueType};
use pseudolearn_runtime::ValueKind;
use pseudolearn_vm::{
    Cell, Machine, machine_cell, machine_defined, machine_reference, machine_scalar,
};

pub(crate) fn inspect_cell(machine: &Machine<'_>, word: u32, name: &str) -> Option<VariableView> {
    let index = usize::try_from(word.checked_sub(1)?).ok()?;
    let cell = machine_cell(machine, index)?;
    let alias = find_owner(machine, word).filter(|owner| owner.target_name != name);
    match cell {
        Cell::Local {
            slot,
            absolute,
            kind,
        } => inspect_local_cell(machine, (slot, absolute, kind), (name, alias)),
        Cell::Managed(cell) => inspect_managed_cell(machine, cell, (name, alias)),
    }
}

fn inspect_local_cell(
    machine: &Machine<'_>,
    (slot, absolute, kind): (pseudolearn_bytecode::Register, usize, ValueKind),
    (name, alias): (&str, Option<AliasDestination>),
) -> Option<VariableView> {
    let raw = match slot.class {
        RegisterClass::Scalar => machine_scalar(machine, absolute)?,
        RegisterClass::Reference => u64::from(machine_reference(machine, absolute)?),
    };
    let defined = kind != ValueKind::Integer || machine_defined(machine, absolute)?;
    Some(VariableView {
        name: name.to_owned(),
        variable_type: crate::inspect::format_kind_type(kind),
        alias,
        value: if defined {
            crate::inspect::decode_field_value(machine, kind, raw)
        } else {
            VariableValue::Undefined
        },
    })
}

fn inspect_managed_cell(
    machine: &Machine<'_>,
    cell: pseudolearn_runtime::MemoryCell,
    (name, alias): (&str, Option<AliasDestination>),
) -> Option<VariableView> {
    let heap = machine.heap();
    let (kind, defined) = if pseudolearn_runtime::is_array_allocation(heap, cell.owner) {
        (
            pseudolearn_runtime::array_element_kind(heap, cell.owner).ok()?,
            pseudolearn_runtime::is_defined_element(heap, cell.owner, cell.index).ok()?,
        )
    } else {
        let kind = pseudolearn_runtime::object_field_kinds(heap, cell.owner)
            .ok()?
            .get(cell.index)
            .copied()?;
        (
            kind,
            pseudolearn_runtime::is_defined_field(heap, cell.owner, cell.index).ok()?,
        )
    };
    let value = if defined {
        let raw = pseudolearn_runtime::read_memory_cell(heap, cell).ok()?;
        crate::inspect::decode_field_value(machine, kind, raw)
    } else {
        VariableValue::Undefined
    };
    Some(VariableView {
        name: name.to_owned(),
        variable_type: crate::inspect::format_kind_type(kind),
        value,
        alias,
    })
}

fn find_owner(machine: &Machine<'_>, word: u32) -> Option<AliasDestination> {
    for position in 0..machine.active_frames_count() {
        let frame = machine.active_frame(position)?;
        for (register, name) in frame.names {
            if register.class != RegisterClass::Reference {
                continue;
            }
            if !matches!(
                frame.reference_types.get(usize::from(register.index)),
                Some(ValueType::Cell(_))
            ) {
                continue;
            }
            let absolute = frame
                .reference_base
                .checked_add(usize::from(register.index))?;
            if machine_reference(machine, absolute) == Some(word) {
                return Some(AliasDestination {
                    frame_position: position,
                    target_name: name.clone(),
                });
            }
        }
    }
    None
}

#[cfg(test)]
#[path = "cell_view_tests.rs"]
mod cell_view_tests;
