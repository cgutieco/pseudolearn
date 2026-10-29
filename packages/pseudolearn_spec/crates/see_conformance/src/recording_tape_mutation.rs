use serde_json::{Value, json};
use sha2::{Digest, Sha256};

type TapeEntryHashFields = (
    u64,
    u64,
    u32,
    String,
    String,
    String,
    Option<String>,
    String,
    Vec<u8>,
);

pub(crate) fn alter_request_digest(replay: &mut Value) -> Result<(), String> {
    let entries = replay
        .pointer_mut("/effect_tape/entries")
        .and_then(Value::as_array_mut)
        .ok_or("SEE-RECORDING: missing tape entries")?;
    let final_index = entries
        .len()
        .checked_sub(1)
        .ok_or("SEE-RECORDING: missing final tape entry")?;
    let previous_index = final_index
        .checked_sub(1)
        .ok_or("SEE-RECORDING: missing previous tape entry")?;
    let previous_hash = entries
        .get(previous_index)
        .and_then(|entry| entry.get("entry_hash"))
        .and_then(Value::as_str)
        .ok_or("SEE-RECORDING: missing previous tape hash")?
        .to_owned();
    let final_entry = entries
        .get_mut(final_index)
        .ok_or("SEE-RECORDING: missing final tape entry")?;
    alter_final_request(final_entry)?;
    let entry_hash = calculate_entry_hash(&previous_hash, final_entry)?;
    let hash_value = final_entry
        .get_mut("entry_hash")
        .ok_or("SEE-RECORDING: missing final entry hash")?;
    *hash_value = json!(entry_hash);
    Ok(())
}

fn alter_final_request(entry: &mut Value) -> Result<(), String> {
    if entry.get("operation").and_then(Value::as_str) != Some("network_send") {
        return Err("SEE-RECORDING: final effect is not network_send".to_owned());
    }
    let Some(Value::String(digest)) = entry.get_mut("request_digest") else {
        return Err("SEE-RECORDING: missing request digest".to_owned());
    };
    *digest = "altered-request-digest".to_owned();
    Ok(())
}

fn calculate_entry_hash(previous: &str, entry: &Value) -> Result<String, String> {
    let fields = entry_hash_fields(entry)?;
    let serialized = serde_json::to_vec(&fields)
        .map_err(|failure| format!("SEE-RECORDING: cannot serialize tape entry: {failure}"))?;
    let mut digest = Sha256::new();
    digest.update(previous.as_bytes());
    digest.update(serialized);
    if let Some(delivery) = entry.get("delivery_seq").and_then(Value::as_u64) {
        digest.update(delivery.to_be_bytes());
    }
    Ok(format!("{:x}", digest.finalize()))
}

fn entry_hash_fields(entry: &Value) -> Result<TapeEntryHashFields, String> {
    let effect_seq = required_unsigned(entry, "effect_seq")?;
    let task_id = required_unsigned(entry, "task_id")?;
    let source_node_id = u32::try_from(required_unsigned(entry, "source_node_id")?)
        .map_err(|failure| format!("SEE-RECORDING: invalid source node id: {failure}"))?;
    let capability_kind = required_string(entry, "capability_kind")?;
    let operation = required_string(entry, "operation")?;
    let request_digest = required_string(entry, "request_digest")?;
    let secret_reference = entry
        .get("secret_reference")
        .and_then(Value::as_str)
        .map(str::to_owned);
    let outcome = required_string(entry, "outcome")?;
    let payload_bytes = entry
        .get("payload_bytes")
        .and_then(Value::as_array)
        .ok_or("SEE-RECORDING: missing payload bytes")?
        .iter()
        .map(byte_value)
        .collect::<Result<Vec<_>, _>>()?;
    Ok((
        effect_seq,
        task_id,
        source_node_id,
        capability_kind,
        operation,
        request_digest,
        secret_reference,
        outcome,
        payload_bytes,
    ))
}

fn byte_value(value: &Value) -> Result<u8, String> {
    value
        .as_u64()
        .and_then(|number| u8::try_from(number).ok())
        .ok_or_else(|| "SEE-RECORDING: invalid payload byte".to_owned())
}

fn required_unsigned(entry: &Value, name: &str) -> Result<u64, String> {
    entry
        .get(name)
        .and_then(Value::as_u64)
        .ok_or_else(|| format!("SEE-RECORDING: missing unsigned field {name}"))
}

fn required_string(entry: &Value, name: &str) -> Result<String, String> {
    entry
        .get(name)
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| format!("SEE-RECORDING: missing text field {name}"))
}

#[cfg(test)]
#[path = "recording_tape_mutation_tests.rs"]
mod recording_tape_mutation_tests;
