use pseudolearn_runtime::{self as runtime, Handle, ValueKind};
use pseudolearn_vm::Machine;
use serde_json::{Map, Value, json};

pub(crate) fn capture(machine: &Machine<'_>, handle: Handle) -> Option<(String, Value)> {
    let layout = runtime::collection_layout(machine.heap(), handle).ok()?;
    let schema = pseudolearn_vm::machine_program(machine).class_schema(layout.type_identity)?;
    let ordinal = runtime::allocation_ordinal(machine.heap(), handle).ok()?;
    let length = runtime::collection_length(machine.heap(), handle).ok()?;
    let dictionary = runtime::collection_is_dictionary(machine.heap(), handle).ok()?;
    let fields: Vec<_> = schema
        .fields
        .iter()
        .filter(|(name, _)| name.starts_with("$leaf"))
        .collect();
    let mut values = Vec::new();
    if dictionary {
        let key_kind = schema
            .fields
            .iter()
            .find(|(name, _)| matches!(name.as_str(), "$key" | "$keyEnum"))
            .map(|(_, kind)| kind)?;
        let mut cursor = 0;
        while let Some((next, key, payload)) =
            runtime::dictionary_next(machine.heap(), handle, cursor).ok()?
        {
            values.push(json!({"clave":crate::execution_state::raw_value(machine, key, kind(key_kind))?,"valor":element(machine, &fields, &payload)?}));
            cursor = next;
        }
    } else {
        for index in 0..length {
            let payload = runtime::vector_get(machine.heap(), handle, i64::from(index)).ok()?;
            values.push(element(machine, &fields, &payload)?);
        }
    }
    let value = if dictionary {
        json!({"diccionario":{"longitud":length,"entradas":values}})
    } else {
        json!({"vector":{"longitud":length,"elementos":values}})
    };
    Some((ordinal.to_string(), value))
}

fn element(
    machine: &Machine<'_>,
    fields: &[&(String, pseudolearn_bytecode::ValueType)],
    payload: &runtime::CollectionWords,
) -> Option<Value> {
    if fields
        .first()
        .is_some_and(|(name, _)| name.starts_with("$leaf:function:"))
    {
        return Some(json!({"valor":"<subprograma>"}));
    }
    let words = payload
        .scalars
        .iter()
        .copied()
        .chain(payload.references.iter().map(|handle| u64::from(handle.0)));
    let mut components = Map::new();
    for ((name, value_type), word) in fields.iter().copied().zip(words) {
        let value = crate::execution_state::raw_value(machine, word, kind(value_type))?;
        if name == "$leaf:value" {
            return Some(value);
        }
        let name = name.strip_prefix("$leaf:record:").unwrap_or("valor");
        components.insert(name.to_owned(), value);
    }
    Some(json!({"campos":components}))
}

fn kind(kind: &pseudolearn_bytecode::ValueType) -> ValueKind {
    use pseudolearn_bytecode::ValueType;
    match kind {
        ValueType::I64 => ValueKind::Integer,
        ValueType::F64 => ValueKind::Real,
        ValueType::Bool => ValueKind::Boolean,
        ValueType::Char => ValueKind::Character,
        _ => ValueKind::Reference,
    }
}
