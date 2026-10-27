use see_model::Block;
use serde_json::Value;

pub(crate) fn check(block: &Block, errors: &mut Vec<String>) {
    let Some(host) = block.fields.get("anfitrion") else {
        return;
    };
    if let Some(files) = host.get("files").and_then(Value::as_object) {
        for (path, content) in files {
            if !valid_path(path) || content.as_array().is_some_and(|bytes| bytes.iter().any(|byte| byte.as_u64().is_none_or(|byte| byte > 255))) {
                errors.push("SEE-HOST: invalid memory file".to_owned());
            }
        }
    }
    if let Some(faults) = host.get("faults").and_then(Value::as_array) {
        for fault in faults {
            check_fault(fault, errors);
        }
    }
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
    if fault.get("path").and_then(Value::as_str).is_some_and(|path| !valid_path(path)) {
        errors.push("SEE-HOST: invalid fault path".to_owned());
    }
    let operation = fault.get("operation").and_then(Value::as_str).unwrap_or("");
    if fault.get("uncertain") == Some(&Value::Bool(true)) && !MUTATING_OPERATIONS.contains(&operation) {
        errors.push("SEE-HOST: uncertainty requires a mutating operation".to_owned());
    }
}

fn valid_path(path: &str) -> bool {
    !path.is_empty() && !path.starts_with('/') && !path.contains(['\\', ':', '\0'])
        && path.split('/').all(|part| !["", ".", ".."].contains(&part))
}
