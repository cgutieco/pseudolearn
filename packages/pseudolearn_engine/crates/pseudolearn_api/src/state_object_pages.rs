use crate::ApiError;
use crate::execution_resource::usage;
use pseudolearn_runtime::{self as runtime, Handle};
use pseudolearn_vm::Machine;
use serde_json::{Value, json};

pub(crate) fn page(
    machine: &Machine<'_>,
    ordinal: u64,
    range: (usize, usize),
) -> Result<(Vec<Value>, usize), ApiError> {
    let handle = runtime::allocation_handle(machine.heap(), ordinal)
        .ok_or_else(|| usage("invalid object reference"))?;
    if runtime::is_collection_allocation(machine.heap(), handle) {
        return collection(machine, handle, range);
    }
    if runtime::is_array_allocation(machine.heap(), handle) {
        return array(machine, ordinal, range);
    }
    let identifier = runtime::object_class_identifier(machine.heap(), handle)
        .map_err(|_| usage("invalid object reference"))?;
    let schema = pseudolearn_vm::machine_program(machine)
        .class_schema(identifier)
        .ok_or_else(|| usage("invalid class reference"))?;
    let mut elements = Vec::new();
    for (index, (name, _)) in schema.fields.iter().enumerate().skip(range.0).take(range.1) {
        let value = field(machine, handle, index)?;
        elements.push(json!({"name":name,"value":value}));
    }
    Ok((elements, schema.fields.len()))
}

fn field(machine: &Machine<'_>, handle: Handle, index: usize) -> Result<Value, ApiError> {
    let heap = machine.heap();
    if !runtime::is_defined_field(heap, handle, index)
        .map_err(|_| usage("invalid field reference"))?
    {
        return Ok(json!({"sin_valor":true}));
    }
    let kind = runtime::object_field_kind(heap, handle, index)
        .map_err(|_| usage("invalid field reference"))?;
    let word = runtime::read_field_raw(heap, handle, index)
        .map_err(|_| usage("invalid field reference"))?;
    crate::execution_state::raw_value(machine, word, kind)
        .ok_or_else(|| usage("invalid field value"))
}

fn array(
    machine: &Machine<'_>,
    ordinal: u64,
    range: (usize, usize),
) -> Result<(Vec<Value>, usize), ApiError> {
    let handle = runtime::allocation_handle(machine.heap(), ordinal)
        .ok_or_else(|| usage("invalid array reference"))?;
    let dimensions = runtime::array_dimensions(machine.heap(), handle)
        .map_err(|_| usage("invalid array reference"))?;
    let total = dimensions
        .iter()
        .try_fold(1_usize, |total, dimension| {
            total.checked_mul(usize::try_from(*dimension).ok()?)
        })
        .ok_or_else(|| usage("array size overflow"))?;
    if range.0 > total {
        return Err(usage("invalid page offset"));
    }
    let values = pseudolearn_timeline::capture_array_slice(
        machine,
        ordinal,
        pseudolearn_timeline::ArraySliceRange {
            start_index: range.0,
            slice_length: range.1.min(total.saturating_sub(range.0)),
        },
    )
    .map_err(|error| usage(&error.to_string()))?;
    Ok((values.iter().enumerate().map(|(offset,value)|json!({"name":range.0.saturating_add(offset).to_string(),"value":crate::execution_state::value(value)})).collect(),total))
}

fn collection(
    machine: &Machine<'_>,
    handle: Handle,
    range: (usize, usize),
) -> Result<(Vec<Value>, usize), ApiError> {
    let heap = machine.heap();
    let layout = runtime::collection_layout(heap, handle)
        .map_err(|_| usage("invalid collection reference"))?;
    let schema = pseudolearn_vm::machine_program(machine)
        .class_schema(layout.type_identity)
        .ok_or_else(|| usage("invalid collection schema"))?;
    let fields = schema
        .fields
        .iter()
        .filter(|(name, _)| name.starts_with("$leaf"))
        .collect::<Vec<_>>();
    let total = usize::try_from(
        runtime::collection_length(heap, handle)
            .map_err(|_| usage("invalid collection reference"))?,
    )
    .map_err(|_| usage("collection size overflow"))?;
    if range.0 > total {
        return Err(usage("invalid page offset"));
    }
    let dictionary = runtime::collection_is_dictionary(heap, handle)
        .map_err(|_| usage("invalid collection reference"))?;
    let elements = if dictionary {
        dictionary_elements(machine, (handle, range), &schema.fields, &fields)?
    } else {
        vector_elements(machine, (handle, range, total), &fields)?
    };
    Ok((elements, total))
}

fn dictionary_elements(
    machine: &Machine<'_>,
    window: (Handle, (usize, usize)),
    schema_fields: &[(String, pseudolearn_bytecode::ValueType)],
    fields: &[&(String, pseudolearn_bytecode::ValueType)],
) -> Result<Vec<Value>, ApiError> {
    let (handle, range) = window;
    let key = schema_fields
        .iter()
        .find(|(name, _)| matches!(name.as_str(), "$key" | "$keyEnum"))
        .ok_or_else(|| usage("missing dictionary key type"))?;
    let values = runtime::dictionary_window(machine.heap(), handle, range)
        .map_err(|_| usage("invalid dictionary page"))?;
    let mut elements = Vec::new();
    for (key_word, payload) in values {
        let key = crate::execution_state::raw_value(
            machine,
            key_word,
            crate::collection_state::kind(&key.1),
        )
        .ok_or_else(|| usage("invalid dictionary key"))?;
        let value = crate::collection_state::element(machine, fields, &payload)
            .ok_or_else(|| usage("invalid collection value"))?;
        elements.push(json!({"name":key.get("valor").and_then(Value::as_str).unwrap_or("<key>"),"value":value}));
    }
    Ok(elements)
}

fn vector_elements(
    machine: &Machine<'_>,
    window: (Handle, (usize, usize), usize),
    fields: &[&(String, pseudolearn_bytecode::ValueType)],
) -> Result<Vec<Value>, ApiError> {
    let (handle, range, total) = window;
    let mut elements = Vec::new();
    for index in range.0..range.0.saturating_add(range.1).min(total) {
        let index = i64::try_from(index).map_err(|_| usage("invalid vector index"))?;
        let payload = runtime::vector_get(machine.heap(), handle, index)
            .map_err(|_| usage("invalid vector index"))?;
        let value = crate::collection_state::element(machine, fields, &payload)
            .ok_or_else(|| usage("invalid collection value"))?;
        elements.push(json!({"name":index.to_string(),"value":value}));
    }
    Ok(elements)
}
