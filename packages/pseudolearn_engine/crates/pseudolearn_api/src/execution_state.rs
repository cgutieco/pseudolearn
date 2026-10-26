use pseudolearn_runtime::{self as runtime, Handle, ValueKind};
use pseudolearn_timeline::{VariableValue, capture_frame, format_real};
use pseudolearn_vm::Machine;
use serde_json::{Map, Value, json};

pub(crate) fn capture(machine: &Machine<'_>) -> Value {
    let frames: Vec<_> = (0..machine.active_frames_count())
        .filter_map(|position| capture_frame(machine, position).ok())
        .map(|view| frame(&view))
        .collect();
    let objects: Map<_, _> = runtime::live_allocation_handles(machine.heap())
        .into_iter()
        .filter_map(|handle| object(machine, handle))
        .collect();
    json!({"marcos":frames,"objetos":objects})
}

pub(crate) fn value(value: &VariableValue) -> Value {
    match value {
        VariableValue::Undefined => json!({"sin_valor":true}),
        VariableValue::ArrayReference {
            identity_ordinal, ..
        }
        | VariableValue::ObjectReference {
            identity_ordinal, ..
        } => json!({"ref":identity_ordinal}),
        VariableValue::NullReference => json!({"nulo":true}),
        other => json!({"valor":display_value(other)}),
    }
}

fn display_value(value: &VariableValue) -> String {
    match value {
        VariableValue::Undefined => "sin_valor".to_owned(),
        VariableValue::Integer(number) => number.to_string(),
        VariableValue::Real(number) => format_real(*number),
        VariableValue::Boolean(flag) => {
            if *flag {
                "Verdadero".to_owned()
            } else {
                "Falso".to_owned()
            }
        }
        VariableValue::Character(symbol) => symbol.to_string(),
        VariableValue::Text(content) => content.clone(),
        VariableValue::ObjectReference {
            identity_ordinal, ..
        } => format!("objeto({identity_ordinal})"),
        VariableValue::ArrayReference {
            identity_ordinal, ..
        } => format!("arreglo({identity_ordinal})"),
        VariableValue::NullReference => "nulo".to_owned(),
    }
}

fn object(machine: &Machine<'_>, handle: Handle) -> Option<(String, Value)> {
    let heap = machine.heap();
    if runtime::is_collection_allocation(heap, handle) {
        return crate::collection_state::capture(machine, handle);
    }
    if runtime::is_object_allocation(heap, handle) {
        return instance(machine, handle);
    }
    if !runtime::is_array_allocation(heap, handle) {
        return None;
    }
    let ordinal = runtime::allocation_ordinal(heap, handle).ok()?;
    let dimensions = runtime::array_dimensions(heap, handle).ok()?;
    let total = dimensions.iter().try_fold(1_usize, |total, dimension| {
        total.checked_mul(usize::try_from(*dimension).ok()?)
    })?;
    let kind = runtime::array_element_kind(heap, handle).ok()?;
    let mut cells = Vec::new();
    for index in 0..total {
        cells.push(array_value(machine, handle, index, kind)?);
    }
    Some((
        ordinal.to_string(),
        json!({"arreglo":{"dimensiones":dimensions,"celdas":cells}}),
    ))
}

fn array_value(
    machine: &Machine<'_>,
    handle: Handle,
    index: usize,
    kind: ValueKind,
) -> Option<Value> {
    let heap = machine.heap();
    if !runtime::is_defined_element(heap, handle, index).ok()? {
        return Some(json!({"sin_valor":true}));
    }
    let word = runtime::read_element_raw(heap, handle, index).ok()?;
    raw_value(machine, word, kind)
}

fn instance(machine: &Machine<'_>, handle: Handle) -> Option<(String, Value)> {
    let heap = machine.heap();
    let ordinal = runtime::allocation_ordinal(heap, handle).ok()?;
    let identifier = runtime::object_class_identifier(heap, handle).ok()?;
    let schema = pseudolearn_vm::machine_program(machine).class_schema(identifier)?;
    let kinds = runtime::object_field_kinds(heap, handle).ok()?;
    let mut fields = Map::new();
    for (index, ((name, _), kind)) in schema.fields.iter().zip(kinds).enumerate() {
        let field = if runtime::is_defined_field(heap, handle, index).ok()? {
            let word = runtime::read_field_raw(heap, handle, index).ok()?;
            raw_value(machine, word, kind)?
        } else {
            json!({"sin_valor":true})
        };
        fields.insert(name.clone(), field);
    }
    Some((
        ordinal.to_string(),
        json!({"clase":schema.name,"campos":fields}),
    ))
}

pub(crate) fn raw_value(machine: &Machine<'_>, word: u64, kind: ValueKind) -> Option<Value> {
    let value = match kind {
        ValueKind::Integer => i64::from_ne_bytes(word.to_ne_bytes()).to_string(),
        ValueKind::Real => pseudolearn_timeline::format_real(f64::from_bits(word)),
        ValueKind::Boolean => if word == 0 { "Falso" } else { "Verdadero" }.to_owned(),
        ValueKind::Character => char::from_u32(u32::try_from(word).ok()?)?.to_string(),
        ValueKind::Reference => {
            let handle = Handle(u32::try_from(word).ok()?);
            if handle.0 == 0 {
                return Some(json!({"nulo":true}));
            }
            if let Ok(text) = runtime::text_content(machine.heap(), handle) {
                return Some(json!({"valor":text}));
            }
            return Some(json!({"ref":runtime::allocation_ordinal(machine.heap(),handle).ok()?}));
        }
    };
    Some(json!({"valor":value}))
}

pub(crate) fn frame(frame: &pseudolearn_timeline::FrameView) -> Value {
    let variables: Map<_, _> = frame
        .variables
        .iter()
        .filter(|variable| variable.name != "receiver")
        .map(|variable| {
            let value = if let Some(alias) = &variable.alias {
                json!({"alias":{"marco":alias.frame_position,"variable":alias.target_name}})
            } else {
                value(&variable.value)
            };
            (variable.name.clone(), value)
        })
        .collect();
    let mut result =
        json!({"unidad":frame.function_name.trim_start_matches('@'),"variables":variables});
    if frame.function_name.contains('.')
        && let Some(receiver) = frame
            .variables
            .iter()
            .find(|variable| variable.name == "receiver")
        && let Some(fields) = result.as_object_mut()
    {
        fields.insert("receptor".to_owned(), value(&receiver.value));
    }
    result
}

pub(crate) fn query(
    machine: &Machine<'_>,
    operation: &str,
    arguments: &Value,
) -> Result<Value, crate::ApiError> {
    use crate::execution_resource::usage;
    let number = |name| {
        arguments
            .get(name)
            .and_then(Value::as_u64)
            .ok_or_else(|| usage("missing query index"))
    };
    let index = |name| usize::try_from(number(name)?).map_err(|_| usage("query index overflow"));
    match operation {
        "query_frame" | "query_variables" => {
            let view = capture_frame(machine, index("frame")?)
                .map_err(|error| usage(&error.to_string()))?;
            let view = crate::typed_values::typed_frame(&view);
            Ok(if operation == "query_variables" {
                view.get("variables").cloned().unwrap_or(Value::Null)
            } else {
                view
            })
        }
        "query_array_slice" => query_array_slice(
            machine,
            number("reference")?,
            (index("start")?, index("length")?),
        ),
        "query_object" => query_object(machine, number("reference")?),
        _ => Err(usage("invalid query operation")),
    }
}

fn query_array_slice(
    machine: &Machine<'_>,
    reference: u64,
    (start_index, slice_length): (usize, usize),
) -> Result<Value, crate::ApiError> {
    let values = pseudolearn_timeline::capture_array_slice(
        machine,
        reference,
        pseudolearn_timeline::ArraySliceRange {
            start_index,
            slice_length,
        },
    )
    .map_err(|error| crate::execution_resource::usage(&error.to_string()))?;
    Ok(json!(values.iter().map(value).collect::<Vec<_>>()))
}

pub(crate) fn query_object(machine: &Machine<'_>, ordinal: u64) -> Result<Value, crate::ApiError> {
    use crate::execution_resource::usage;
    let handle = runtime::live_allocation_handles(machine.heap())
        .into_iter()
        .find(|handle| runtime::allocation_ordinal(machine.heap(), *handle) == Ok(ordinal))
        .ok_or_else(|| usage("invalid object reference"))?;
    object(machine, handle)
        .map(|(_, object)| object)
        .ok_or_else(|| usage("invalid object reference"))
}
