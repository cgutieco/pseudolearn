use see_model::Block;
use serde_json::Value;

pub(crate) fn check(block: &Block, errors: &mut Vec<String>) {
    check_expectations(block, errors);
    let Some(host) = block.fields.get("anfitrion") else {
        return;
    };
    if let Some(files) = host.get("files").and_then(Value::as_object) {
        for (path, content) in files {
            if !valid_path(path)
                || content.as_array().is_some_and(|bytes| {
                    bytes
                        .iter()
                        .any(|byte| byte.as_u64().is_none_or(|byte| byte > 255))
                })
            {
                errors.push("SEE-HOST: invalid memory file".to_owned());
            }
        }
    }
    if let Some(faults) = host.get("faults").and_then(Value::as_array) {
        for fault in faults {
            check_fault(fault, errors);
        }
    }
    check_replay_options(block, host, errors);
}

fn check_expectations(block: &Block, errors: &mut Vec<String>) {
    for expected in expected_blocks(block) {
        if expected.get("efecto_pendiente").is_some()
            && expected.get("terminacion").and_then(Value::as_str) != Some("awaiting_effect")
        {
            errors
                .push("SEE-HOST: efecto_pendiente requires awaiting_effect termination".to_owned());
        }
        if let Some(effects) = expected
            .pointer("/anfitrion_observado/efectos")
            .and_then(Value::as_array)
        {
            check_effect_sequence(effects, errors);
        }
    }
}

pub(crate) fn check_effect_sequence(effects: &[Value], errors: &mut Vec<String>) {
    let delivered_out_of_order = effects
        .iter()
        .any(|entry| entry.get("delivery_seq").is_some());
    let valid = if delivered_out_of_order {
        has_distinct_requests(effects) && has_increasing_deliveries(effects)
    } else {
        is_strictly_increasing(effects, "effect_seq")
    };
    if !valid {
        errors.push("SEE-HOST: expected effect_seq must be strictly increasing".to_owned());
    }
}

fn is_strictly_increasing(effects: &[Value], field: &str) -> bool {
    let mut previous = 0_u64;
    for entry in effects {
        let sequence = entry.get(field).and_then(Value::as_u64).unwrap_or(0);
        if sequence <= previous {
            return false;
        }
        previous = sequence;
    }
    true
}

fn has_distinct_requests(effects: &[Value]) -> bool {
    let mut seen = std::collections::BTreeSet::new();
    effects
        .iter()
        .all(|entry| seen.insert(entry.get("effect_seq").and_then(Value::as_u64).unwrap_or(0)))
}

fn has_increasing_deliveries(effects: &[Value]) -> bool {
    let mut previous = 0_u64;
    for entry in effects {
        if let Some(delivery) = entry.get("delivery_seq").and_then(Value::as_u64) {
            if delivery <= previous {
                return false;
            }
            previous = delivery;
        }
    }
    true
}

fn check_replay_options(block: &Block, host: &Value, errors: &mut Vec<String>) {
    let expects_replay_failure = expected_blocks(block).into_iter().any(|expected| {
        expected
            .pointer("/anfitrion_observado/reproduccion_fallo")
            .is_some()
    });
    let mutates_tape = host.get("alterar_cinta").is_some();
    if host.get("grabar_y_reproducir") == Some(&Value::Bool(true))
        && (mutates_tape || expects_replay_failure)
    {
        errors.push(
            "SEE-HOST: grabar_y_reproducir cannot combine with tape alteration or expected replay failure"
                .to_owned(),
        );
    }
    if mutates_tape && !expects_replay_failure {
        errors.push("SEE-HOST: alterar_cinta requires reproduccion_fallo".to_owned());
    }
}

fn expected_blocks(block: &Block) -> Vec<&Value> {
    let mut result = Vec::new();
    if let Some(expected) = block.fields.get("espera") {
        result.push(expected);
    }
    if let Some(profiles) = block.fields.get("esperas").and_then(Value::as_object) {
        result.extend(profiles.values());
    }
    result
}

const MUTATING_OPERATIONS: [&str; 6] = [
    "file_open",
    "file_write_bytes",
    "file_write_text",
    "file_close",
    "directory_close",
    "console_write",
];

fn check_fault(fault: &Value, errors: &mut Vec<String>) {
    if fault
        .get("path")
        .and_then(Value::as_str)
        .is_some_and(|path| !valid_path(path))
    {
        errors.push("SEE-HOST: invalid fault path".to_owned());
    }
    let operation = fault.get("operation").and_then(Value::as_str).unwrap_or("");
    if fault.get("uncertain") == Some(&Value::Bool(true))
        && !MUTATING_OPERATIONS.contains(&operation)
    {
        errors.push("SEE-HOST: uncertainty requires a mutating operation".to_owned());
    }
}

fn valid_path(path: &str) -> bool {
    !path.is_empty()
        && !path.starts_with('/')
        && !path.contains(['\\', ':', '\0'])
        && path.split('/').all(|part| !["", ".", ".."].contains(&part))
}
