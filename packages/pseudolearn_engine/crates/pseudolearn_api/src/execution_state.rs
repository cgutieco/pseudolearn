use pseudolearn_runtime::{self as runtime, Handle, ValueKind};
use pseudolearn_timeline::{VariableValue, capture_frame};
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

fn value(value: &VariableValue) -> Value {
    match value {
        VariableValue::Undefined => json!({"sin_valor":true}),
        VariableValue::ArrayReference {
            identity_ordinal, ..
        }
        | VariableValue::ObjectReference {
            identity_ordinal, ..
        } => json!({"ref":identity_ordinal}),
        VariableValue::NullReference => json!({"nulo":true}),
        other => json!({"valor":other.display_representation()}),
    }
}

fn object(machine: &Machine<'_>, handle: Handle) -> Option<(String, Value)> {
    let heap = machine.heap();
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

fn raw_value(machine: &Machine<'_>, word: u64, kind: ValueKind) -> Option<Value> {
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

fn frame(frame: &pseudolearn_timeline::FrameView) -> Value {
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
            let view = frame(&view);
            Ok(if operation == "query_variables" {
                view["variables"].clone()
            } else {
                view
            })
        }
        "query_array_slice" => {
            let values = pseudolearn_timeline::capture_array_slice(
                machine,
                number("reference")?,
                pseudolearn_timeline::ArraySliceRange {
                    start_index: index("start")?,
                    slice_length: index("length")?,
                },
            )
            .map_err(|error| usage(&error.to_string()))?;
            Ok(json!(values.iter().map(value).collect::<Vec<_>>()))
        }
        "query_object" => {
            let ordinal = number("reference")?;
            let handle = runtime::live_allocation_handles(machine.heap())
                .into_iter()
                .find(|handle| runtime::allocation_ordinal(machine.heap(), *handle) == Ok(ordinal))
                .ok_or_else(|| usage("invalid object reference"))?;
            object(machine, handle)
                .map(|(_, object)| object)
                .ok_or_else(|| usage("invalid object reference"))
        }
        _ => Err(usage("invalid query operation")),
    }
}
