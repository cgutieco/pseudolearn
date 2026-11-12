use crate::ApiError;
use crate::lock_digest::{file_digest, package_digest};
use crate::project_resource::usage;
use pseudolearn_project::{Location, LockError, LockKind, LockPackage};
use serde_json::{Value, json};
use std::collections::BTreeMap;

pub(crate) const LOCK_BYTE_BUDGET: usize = 1_048_576;

pub(crate) fn packages(arguments: &Value) -> Result<Vec<LockPackage>, ApiError> {
    let listed = arguments
        .get("packages")
        .and_then(Value::as_array)
        .ok_or_else(|| usage("missing packages"))?;
    listed.iter().map(package).collect()
}

fn package(wire: &Value) -> Result<LockPackage, ApiError> {
    let name = text(wire, "name")?;
    let kind = match text(wire, "kind")? {
        "local" => LockKind::Local,
        "locked" => LockKind::Locked,
        _ => return Err(usage("kind must be local or locked")),
    };
    let files = match kind {
        LockKind::Local => BTreeMap::new(),
        LockKind::Locked => digests(wire)?,
    };
    Ok(LockPackage {
        name: name.to_owned(),
        origin: text(wire, "origin")?.to_owned(),
        kind,
        dependencies: strings(wire, "dependencies")?,
        digest: (kind == LockKind::Locked).then(|| package_digest(&files)),
        files,
        position: Location::START,
    })
}

fn digests(wire: &Value) -> Result<BTreeMap<String, String>, ApiError> {
    let listed = wire
        .get("files")
        .and_then(Value::as_array)
        .ok_or_else(|| usage("missing files"))?;
    let mut files = BTreeMap::new();
    for entry in listed {
        let path = text(entry, "path")?;
        let content = text(entry, "text")?;
        if files
            .insert(path.to_owned(), file_digest(content.as_bytes()))
            .is_some()
        {
            return Err(usage("duplicate file path"));
        }
    }
    Ok(files)
}

fn text<'wire>(wire: &'wire Value, name: &str) -> Result<&'wire str, ApiError> {
    wire.get(name)
        .and_then(Value::as_str)
        .ok_or_else(|| usage(&format!("missing {name}")))
}

fn strings(wire: &Value, name: &str) -> Result<Vec<String>, ApiError> {
    let Some(listed) = wire.get(name) else {
        return Ok(Vec::new());
    };
    listed
        .as_array()
        .ok_or_else(|| usage(&format!("{name} must be a list")))?
        .iter()
        .map(|entry| {
            entry
                .as_str()
                .map(str::to_owned)
                .ok_or_else(|| usage(&format!("{name} must hold strings")))
        })
        .collect()
}

pub(crate) fn error_values(errors: &[LockError]) -> Value {
    Value::Array(
        errors
            .iter()
            .map(|error| {
                json!({
                    "code": error.code.as_str(),
                    "field": error.field,
                    "line": error.position.line,
                    "column": error.position.column,
                })
            })
            .collect(),
    )
}
