use crate::{AliasDestination, VariableValue, VariableView};
use pseudolearn_bytecode::{RegisterClass, ValueType};
use pseudolearn_runtime::ValueKind;
use pseudolearn_vm::{
    Cell, Machine, machine_cell, machine_defined, machine_reference, machine_scalar,
};

pub(crate) fn inspect_cell(machine: &Machine<'_>, word: u32, name: &str) -> Option<VariableView> {
    let index = usize::try_from(word.checked_sub(1)?).ok()?;
    let Cell::Local {
        slot,
        absolute,
        kind,
    } = machine_cell(machine, index)?
    else {
        return None;
    };
    let owner = find_owner(machine, word)?;
    let alias = (owner.target_name != name).then_some(owner);
    let raw = match slot.class {
        RegisterClass::Scalar => machine_scalar(machine, absolute)?,
        RegisterClass::Reference => u64::from(machine_reference(machine, absolute)?),
    };
    let defined = kind != ValueKind::Integer || machine_defined(machine, absolute)?;
    Some(VariableView {
        name: name.to_owned(),
        variable_type: format!("{kind:?}"),
        alias,
        value: if defined {
            crate::inspect::decode_field_value(machine, kind, raw)
        } else {
            VariableValue::Undefined
        },
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
