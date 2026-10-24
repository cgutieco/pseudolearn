use crate::error::CliError;
use crate::messages;
use crate::options::CliOptions;
use crate::project_files::{self, ProjectSnapshot};
use pseudolearn_api::ApiSession;
use serde_json::{Value, json};

pub(crate) struct Prepared {
    pub snapshot: ProjectSnapshot,
    pub arguments: Value,
}

pub(crate) fn call(operation: &str, arguments: &Value) -> Result<Value, CliError> {
    let response = ApiSession::default().call(operation, arguments);
    response
        .get("value")
        .cloned()
        .ok_or_else(|| CliError::Operational(response.to_string()))
}

pub(crate) fn prepare(options: &CliOptions, entry_required: bool) -> Result<Prepared, CliError> {
    let locale = &options.interface_language;
    let directory = options
        .project
        .directory
        .as_deref()
        .ok_or_else(|| CliError::Usage(messages::missing_input(locale).to_owned()))?;
    if entry_required && options.project.entry.is_none() {
        return Err(CliError::Usage(messages::missing_entry(locale).to_owned()));
    }
    let snapshot = project_files::load(directory, locale)?;
    verify_lock(&snapshot, locale)?;
    let arguments = arguments(options, &snapshot);
    Ok(Prepared {
        snapshot,
        arguments,
    })
}

fn arguments(options: &CliOptions, snapshot: &ProjectSnapshot) -> Value {
    let mut arguments = json!({
        "strictness": options.strictness.as_deref().unwrap_or("strict"),
        "project": project_value(snapshot),
    });
    if let Some(fields) = arguments.as_object_mut() {
        if let Some(profile) = &options.vocabulary {
            fields.insert("profile".to_owned(), json!(profile));
        }
        if let Some(entry) = &options.project.entry {
            fields.insert("entry".to_owned(), json!(entry));
        }
    }
    arguments
}

pub(crate) fn project_value(snapshot: &ProjectSnapshot) -> Value {
    let manifests: Vec<Value> = snapshot
        .manifests
        .iter()
        .map(|manifest| json!({"location": manifest.location, "text": manifest.text}))
        .collect();
    let files: Vec<Value> = snapshot
        .sources
        .iter()
        .map(|source| json!({"path": source.path, "source_id": source.source_id, "text": source.text}))
        .collect();
    json!({
        "project_id": "1",
        "revision_id": "1",
        "manifests": manifests,
        "files": files,
    })
}

pub(crate) fn lock_packages(snapshot: &ProjectSnapshot) -> Result<Vec<Value>, Vec<Value>> {
    let mut packages = Vec::new();
    let mut failures = Vec::new();
    for manifest in &snapshot.manifests {
        let request = json!({"manifest": manifest.text, "location": manifest.location});
        let Ok(resolved) = call("resolve_manifest", &request) else {
            continue;
        };
        match resolved
            .get("configuration")
            .filter(|found| !found.is_null())
        {
            Some(configuration) => packages.push(package_of(configuration, &manifest.location)),
            None => failures.extend(manifest_failures(&resolved)),
        }
    }
    if failures.is_empty() {
        Ok(packages)
    } else {
        Err(failures)
    }
}

fn manifest_failures(resolved: &Value) -> Vec<Value> {
    resolved
        .get("manifest_errors")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default()
}

fn package_of(configuration: &Value, location: &str) -> Value {
    let name = configuration
        .pointer("/package/name/value")
        .and_then(Value::as_str)
        .unwrap_or("");
    let mut dependencies: Vec<&str> = configuration
        .get("dependencies")
        .and_then(Value::as_array)
        .map_or(&[][..], Vec::as_slice)
        .iter()
        .filter_map(|dependency| dependency.get("package").and_then(Value::as_str))
        .collect();
    dependencies.sort_unstable();
    dependencies.dedup();
    json!({"name": name, "origin": location, "kind": "local", "dependencies": dependencies})
}

fn verify_lock(snapshot: &ProjectSnapshot, locale: &str) -> Result<(), CliError> {
    let (Some(lock), Ok(packages)) = (&snapshot.lock, lock_packages(snapshot)) else {
        return Ok(());
    };
    let verdict = call("resolve_lock", &json!({"lock": lock, "packages": packages}))?;
    if verdict.get("verified").and_then(Value::as_bool) == Some(true) {
        return Ok(());
    }
    let code = verdict
        .pointer("/lock_errors/0/code")
        .and_then(Value::as_str)
        .unwrap_or("lockInvalid");
    Err(CliError::Operational(messages::render(
        "lockMismatch",
        locale,
        &[("code", code)],
    )))
}
