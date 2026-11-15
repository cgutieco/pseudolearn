use crate::error::CliError;
use serde_json::Value;
use std::io::Write;
use std::path::Path;

pub(crate) fn read(path: &str) -> Result<Value, CliError> {
    let bytes = std::fs::read(path).map_err(operational)?;
    serde_json::from_slice(&bytes).map_err(operational)
}

pub(crate) fn persist(path: &str, response: &Value) -> Result<(), CliError> {
    let tape = response
        .get("effect_tape")
        .ok_or_else(|| operational("missing effect tape"))?;
    let target = Path::new(path);
    let filename = target
        .file_name()
        .and_then(|name| name.to_str())
        .ok_or_else(|| operational("invalid tape path"))?;
    let temporary = target.with_file_name(format!(".{filename}.{}.partial", std::process::id()));
    let result = write_tape(&temporary, tape)
        .and_then(|()| std::fs::rename(&temporary, target).map_err(operational));
    if result.is_err() {
        let _cleanup = std::fs::remove_file(&temporary);
    }
    result
}

fn write_tape(path: &Path, tape: &Value) -> Result<(), CliError> {
    let mut file = std::fs::OpenOptions::new()
        .write(true)
        .create_new(true)
        .open(path)
        .map_err(operational)?;
    let bytes = serde_json::to_vec(tape).map_err(operational)?;
    file.write_all(&bytes).map_err(operational)?;
    file.sync_all().map_err(operational)
}

fn operational(error: impl std::fmt::Display) -> CliError {
    CliError::Operational(error.to_string())
}
