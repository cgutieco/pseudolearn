use serde_json::Value;
use std::path::Path;
use std::process::Command;

const REPRODUCIBLE_FAULT: (&str, &str) = ("file_open", "permiso_denegado");
const ENGINE_ONLY_KEYS: &[&str] = &[
    "grabar_y_reproducir",
    "orden_entrega",
    "alterar_cinta",
    "secrets",
    "secret_keys",
    "max_tape_bytes",
    "detached",
    "cancel_on_awaiting_effect",
];

pub struct HostSetup {
    pub arguments: Vec<String>,
    pub environment: Vec<(String, String)>,
    pub masks_clock: bool,
}

const CLOCK_REQUESTS: &[&str] = &[
    "SolicitarReloj",
    "requestClock",
    "SolicitarTemporizador",
    "requestTimer",
];

pub fn unreproducible_reason(host: &Value) -> Option<String> {
    let object = host.as_object()?;
    if object
        .get("clock")
        .and_then(Value::as_array)
        .is_some_and(Vec::is_empty)
    {
        return Some("exhausted host clock".to_owned());
    }
    let paths: Vec<String> = object
        .get("files")
        .and_then(Value::as_object)
        .map(|files| files.keys().cloned().collect())
        .unwrap_or_default();
    if paths.iter().any(|path| path.starts_with('/')) {
        return Some("host file outside the working directory".to_owned());
    }
    let mut folded: Vec<String> = paths.iter().map(|path| path.to_lowercase()).collect();
    folded.sort();
    folded.dedup();
    if folded.len() < paths.len() {
        return Some("host files that differ only in case".to_owned());
    }
    for key in object.keys() {
        let replicated = matches!(
            key.as_str(),
            "files" | "directories" | "environment" | "args" | "clock" | "faults" | "http"
        );
        if !replicated && !ENGINE_ONLY_KEYS.contains(&key.as_str()) {
            return Some(format!("host key {key}"));
        }
    }
    let faults = object.get("faults").and_then(Value::as_array);
    for fault in faults.into_iter().flatten() {
        let operation = fault.get("operation").and_then(Value::as_str);
        let code = fault.get("code").and_then(Value::as_str);
        let reproducible = (operation, code)
            == (Some(REPRODUCIBLE_FAULT.0), Some(REPRODUCIBLE_FAULT.1))
            && fault.get("path").and_then(Value::as_str).is_some();
        if !reproducible {
            return Some(format!("fault {operation:?} {code:?}"));
        }
    }
    None
}

fn requests_directory(program: &str, path: &str) -> bool {
    ["SolicitarDirectorio", "requestDirectory"]
        .iter()
        .any(|request| program.contains(&format!("{request}(\"{path}\")")))
}

pub fn working_directory(program: &str, work: &Path) -> std::path::PathBuf {
    if requests_directory(program, ".") {
        work.join("root")
    } else {
        work.to_path_buf()
    }
}

pub fn prepare(host: Option<&Value>, program: &str, work: &Path) -> Result<HostSetup, String> {
    let _ = std::fs::remove_dir_all(work);
    let root = work.join("root");
    std::fs::create_dir_all(&root).map_err(|error| error.to_string())?;
    if requests_directory(program, ".") && requests_directory(program, "root") {
        link_root(&root)?;
    }
    let empty = serde_json::Map::new();
    let object = host.and_then(Value::as_object).unwrap_or(&empty);
    write_files(object.get("files"), &root)?;
    for directory in strings(object.get("directories")) {
        std::fs::create_dir_all(root.join(directory)).map_err(|error| error.to_string())?;
    }
    deny_access(object.get("faults"), &root)?;
    let environment = object
        .get("environment")
        .and_then(Value::as_object)
        .map(|variables| {
            variables
                .iter()
                .map(|(name, value)| (name.clone(), value.as_str().unwrap_or_default().to_owned()))
                .collect()
        })
        .unwrap_or_default();
    Ok(HostSetup {
        arguments: strings(object.get("args")),
        environment,
        masks_clock: masks_clock(host, program),
    })
}

pub fn configure(command: &mut Command, setup: &HostSetup, directory: &Path) {
    command
        .current_dir(directory)
        .env_clear()
        .args(&setup.arguments);
    if let Some(path) = std::env::var_os("PATH") {
        command.env("PATH", path);
    }
    for (name, value) in &setup.environment {
        command.env(name, value);
    }
}

pub fn masks_clock(host: Option<&Value>, program: &str) -> bool {
    host.is_some_and(|host| host.get("clock").is_some())
        || CLOCK_REQUESTS
            .iter()
            .any(|request| program.contains(request))
}

pub fn mask_clock(text: &str) -> String {
    let mut masked = String::new();
    let mut in_number = false;
    for character in text.chars() {
        if character.is_ascii_digit() {
            if !in_number {
                masked.push('#');
            }
            in_number = true;
        } else {
            in_number = false;
            masked.push(character);
        }
    }
    masked
}

fn link_root(work: &Path) -> Result<(), String> {
    #[cfg(unix)]
    {
        std::os::unix::fs::symlink(".", work.join("root")).map_err(|error| error.to_string())
    }
    #[cfg(not(unix))]
    {
        let _ = work;
        Err("root link needs unix".to_owned())
    }
}

fn write_files(files: Option<&Value>, work: &Path) -> Result<(), String> {
    for (path, content) in files.and_then(Value::as_object).into_iter().flatten() {
        let target = work.join(path);
        if let Some(parent) = target.parent() {
            std::fs::create_dir_all(parent).map_err(|error| error.to_string())?;
        }
        let bytes = match content {
            Value::String(text) => text.as_bytes().to_vec(),
            Value::Array(items) => items
                .iter()
                .filter_map(Value::as_u64)
                .filter_map(|byte| u8::try_from(byte).ok())
                .collect(),
            _ => Vec::new(),
        };
        std::fs::write(target, bytes).map_err(|error| error.to_string())?;
    }
    Ok(())
}

fn deny_access(faults: Option<&Value>, work: &Path) -> Result<(), String> {
    for fault in faults.and_then(Value::as_array).into_iter().flatten() {
        let Some(path) = fault.get("path").and_then(Value::as_str) else {
            continue;
        };
        let target = work.join(path);
        if !target.exists() {
            std::fs::write(&target, b"").map_err(|error| error.to_string())?;
        }
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            std::fs::set_permissions(&target, std::fs::Permissions::from_mode(0o000))
                .map_err(|error| error.to_string())?;
        }
    }
    Ok(())
}

fn strings(value: Option<&Value>) -> Vec<String> {
    value
        .and_then(Value::as_array)
        .map(|items| {
            items
                .iter()
                .filter_map(Value::as_str)
                .map(str::to_owned)
                .collect()
        })
        .unwrap_or_default()
}
