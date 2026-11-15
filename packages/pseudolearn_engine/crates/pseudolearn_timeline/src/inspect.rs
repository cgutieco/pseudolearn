use pseudolearn_bytecode::{RegisterClass, ValueType};
use pseudolearn_runtime::{Handle, ValueKind};
use pseudolearn_vm::{
    ActiveFrameInspection, Machine, machine_defined, machine_output, machine_reference,
    machine_scalar, machine_statements_executed,
};

use crate::model::{FrameView, StateSnapshot, VariableValue, VariableView};

pub fn capture_snapshot(machine: &Machine, event_index: usize) -> StateSnapshot {
    let statement_index = machine_statements_executed(machine);
    let output_text = machine_output(machine).to_string();
    let total_frames = machine.active_frames_count();
    let mut frames = Vec::new();
    for position in 0..total_frames {
        if let Some(inspection) = machine.active_frame(position) {
            frames.push(build_frame_view(machine, position, &inspection));
        }
    }
    StateSnapshot {
        event_index,
        statement_index,
        output_text,
        frames,
    }
}

pub(crate) fn build_frame_view(
    machine: &Machine,
    position: usize,
    inspection: &ActiveFrameInspection<'_>,
) -> FrameView {
    let mut variables = Vec::new();
    for (register, variable_name) in &inspection.names {
        let variable_view = read_variable(machine, inspection, *register, variable_name);
        variables.push(variable_view);
    }
    let receiver_handle = inspection.receiver_handle.map(|handle| handle.0);
    FrameView {
        position,
        function_name: inspection.function_name.to_string(),
        variables,
        receiver_handle,
    }
}

fn read_variable(
    machine: &Machine,
    inspection: &ActiveFrameInspection<'_>,
    register: pseudolearn_bytecode::Register,
    variable_name: &str,
) -> VariableView {
    match register.class {
        RegisterClass::Scalar => read_scalar_variable(machine, inspection, register, variable_name),
        RegisterClass::Reference => {
            read_reference_variable(machine, inspection, register, variable_name)
        }
    }
}

fn read_scalar_variable(
    machine: &Machine,
    inspection: &ActiveFrameInspection<'_>,
    register: pseudolearn_bytecode::Register,
    variable_name: &str,
) -> VariableView {
    let register_index = usize::from(register.index);
    let slot = inspection.scalar_base.saturating_add(register_index);
    let is_defined = machine_defined(machine, slot).unwrap_or(false);
    let expected_type = inspection
        .scalar_types
        .get(register_index)
        .cloned()
        .unwrap_or(ValueType::I64);
    let variable_type = format_value_type(&expected_type);
    if !is_defined {
        return VariableView {
            name: variable_name.to_string(),
            variable_type,
            value: VariableValue::Undefined,
            alias: None,
        };
    }
    let raw_word = machine_scalar(machine, slot).unwrap_or(0);
    let value = decode_scalar_value(&expected_type, raw_word);
    VariableView {
        name: variable_name.to_string(),
        variable_type,
        value,
        alias: None,
    }
}

fn decode_scalar_value(expected_type: &ValueType, raw_word: u64) -> VariableValue {
    match expected_type {
        ValueType::I64 => {
            let number = i64::from_ne_bytes(raw_word.to_ne_bytes());
            VariableValue::Integer(number)
        }
        ValueType::F64 => {
            let number = f64::from_bits(raw_word);
            VariableValue::Real(number)
        }
        ValueType::Bool => VariableValue::Boolean(raw_word != 0),
        ValueType::Char => {
            let character_code = u32::try_from(raw_word).unwrap_or(0);
            let character = char::from_u32(character_code).unwrap_or('?');
            VariableValue::Character(character)
        }
        _ => VariableValue::Undefined,
    }
}

fn read_reference_variable(
    machine: &Machine,
    inspection: &ActiveFrameInspection<'_>,
    register: pseudolearn_bytecode::Register,
    variable_name: &str,
) -> VariableView {
    let register_index = usize::from(register.index);
    let slot = inspection.reference_base.saturating_add(register_index);
    let handle_word = machine_reference(machine, slot).unwrap_or(0);
    let expected_type = inspection
        .reference_types
        .get(register_index)
        .cloned()
        .unwrap_or(ValueType::Str);
    if matches!(expected_type, ValueType::Cell(_))
        && let Some(view) = crate::cell_view::inspect_cell(machine, handle_word, variable_name)
    {
        return view;
    }
    let variable_type = format_value_type(&expected_type);
    if handle_word == 0 {
        return VariableView {
            name: variable_name.to_string(),
            variable_type,
            value: VariableValue::NullReference,
            alias: None,
        };
    }
    let value = decode_reference_value(machine, handle_word);
    VariableView {
        name: variable_name.to_string(),
        variable_type,
        value,
        alias: None,
    }
}

fn decode_reference_value(machine: &Machine, handle_word: u32) -> VariableValue {
    let handle = Handle(handle_word);
    decode_collection(machine, handle)
        .or_else(|| decode_object(machine, handle))
        .or_else(|| decode_array(machine, handle))
        .or_else(|| decode_channel(machine, handle))
        .or_else(|| decode_text(machine, handle))
        .unwrap_or(VariableValue::NullReference)
}

fn decode_collection(machine: &Machine, handle: Handle) -> Option<VariableValue> {
    let heap = machine.heap();
    pseudolearn_runtime::is_collection_allocation(heap, handle).then(|| {
        VariableValue::ObjectReference {
            handle_word: handle.0,
            identity_ordinal: pseudolearn_runtime::allocation_ordinal(heap, handle).unwrap_or(0),
            class_identifier: pseudolearn_runtime::collection_layout(heap, handle)
                .map(|layout| layout.type_identity)
                .unwrap_or(0),
        }
    })
}

fn decode_object(machine: &Machine, handle: Handle) -> Option<VariableValue> {
    let heap = machine.heap();
    pseudolearn_runtime::is_object_allocation(heap, handle).then(|| {
        VariableValue::ObjectReference {
            handle_word: handle.0,
            identity_ordinal: pseudolearn_runtime::allocation_ordinal(heap, handle).unwrap_or(0),
            class_identifier: pseudolearn_runtime::object_class_identifier(heap, handle)
                .unwrap_or(0),
        }
    })
}

fn decode_array(machine: &Machine, handle: Handle) -> Option<VariableValue> {
    let heap = machine.heap();
    pseudolearn_runtime::is_array_allocation(heap, handle).then(|| VariableValue::ArrayReference {
        handle_word: handle.0,
        identity_ordinal: pseudolearn_runtime::allocation_ordinal(heap, handle).unwrap_or(0),
        dimensions: pseudolearn_runtime::array_dimensions(heap, handle)
            .map(|slice| slice.to_vec())
            .unwrap_or_default(),
    })
}

fn decode_text(machine: &Machine, handle: Handle) -> Option<VariableValue> {
    pseudolearn_runtime::text_content(machine.heap(), handle)
        .ok()
        .map(|content| VariableValue::Text(content.to_string()))
}

fn decode_channel(machine: &Machine, handle: Handle) -> Option<VariableValue> {
    let identity =
        pseudolearn_runtime::channel_references::channel_identity(machine.heap(), handle).ok()?;
    let snapshot = machine.channel_snapshot(identity)?;
    Some(VariableValue::ChannelReference {
        handle_word: handle.0,
        identity,
        capacity: u64::try_from(snapshot.capacity).unwrap_or(u64::MAX),
        open: !snapshot.closed,
        queued: u64::try_from(snapshot.queued).unwrap_or(u64::MAX),
    })
}

pub(crate) fn decode_field_value(
    machine: &Machine,
    kind: ValueKind,
    raw_word: u64,
) -> VariableValue {
    match kind {
        ValueKind::Integer => {
            let number = i64::from_ne_bytes(raw_word.to_ne_bytes());
            VariableValue::Integer(number)
        }
        ValueKind::Real => {
            let number = f64::from_bits(raw_word);
            VariableValue::Real(number)
        }
        ValueKind::Boolean => VariableValue::Boolean(raw_word != 0),
        ValueKind::Character => {
            let code = u32::try_from(raw_word).unwrap_or(0);
            let character = char::from_u32(code).unwrap_or('?');
            VariableValue::Character(character)
        }
        ValueKind::Reference => {
            let handle_word = u32::try_from(raw_word).unwrap_or(0);
            if handle_word == 0 {
                VariableValue::NullReference
            } else {
                decode_reference_value(machine, handle_word)
            }
        }
    }
}

fn format_value_type(value_type: &ValueType) -> String {
    match value_type {
        ValueType::I64 => "Entero".to_string(),
        ValueType::F64 => "Real".to_string(),
        ValueType::Bool => "Logico".to_string(),
        ValueType::Char => "Caracter".to_string(),
        ValueType::Str => "Texto".to_string(),
        ValueType::Object(name) => name.replace('$', ""),
        ValueType::Array { .. } => "Arreglo".to_string(),
        ValueType::Cell(_) => "Celda".to_string(),
        ValueType::Unit => "Nulo".to_string(),
    }
}

pub(crate) fn format_kind_type(kind: ValueKind) -> String {
    match kind {
        ValueKind::Integer => "Entero".to_owned(),
        ValueKind::Real => "Real".to_owned(),
        ValueKind::Boolean => "Logico".to_owned(),
        ValueKind::Character => "Caracter".to_owned(),
        ValueKind::Reference => "Referencia".to_owned(),
    }
}

#[cfg(test)]
#[path = "inspect_tests.rs"]
mod inspect_tests;
