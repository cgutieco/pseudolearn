use crate::service_request::ServiceRequest;
use pseudolearn_project::{FileInput, PackageInput, PackageKind, ProjectInput};
use pseudolearn_service::{
    Profile, SnapshotUpdateMode, WorkspaceOptions, WorkspaceSession, WorkspaceSnapshot,
};
use serde_json::{Map, Value, json};
use std::collections::BTreeMap;

pub fn handle(request: &ServiceRequest<'_>) -> Value {
    let Some(snapshot) = snapshot(request.raw().get("workspace")) else {
        return json!({"error": "invalid workspace snapshot"});
    };
    let Ok(mut session) = WorkspaceSession::new(snapshot) else {
        return json!({"error": "workspace creation failed"});
    };
    let actions = request
        .raw()
        .get("actions")
        .and_then(Value::as_array)
        .cloned()
        .unwrap_or_default();
    let mut errors = Vec::new();
    for action in actions {
        if let Err(error) = apply_action(&mut session, &action) {
            errors.push(error);
        }
    }
    outcome(&session, errors)
}

fn snapshot(value: Option<&Value>) -> Option<WorkspaceSnapshot> {
    let value = value?;
    let project = project(value.get("project")?)?;
    let options = WorkspaceOptions {
        requested_profile: profile(value.pointer("/options/profile")),
        strict: value.pointer("/options/strictness")?.as_str()? != "flexible",
        entry: value
            .pointer("/options/entry")
            .and_then(Value::as_str)
            .map(str::to_owned),
        file_profiles: profile_map(value.pointer("/options/file_profiles")),
        dependency_inputs: string_map(value.pointer("/options/dependency_inputs")),
        ..WorkspaceOptions::default()
    };
    Some(WorkspaceSnapshot { project, options })
}

fn project(value: &Value) -> Option<ProjectInput> {
    Some(ProjectInput {
        project_id: decimal(value.get("project_id")?)?,
        revision_id: decimal(value.get("revision_id")?)?,
        packages: packages(value.get("packages")?)?,
        files: files(value.get("files")?)?,
    })
}

fn packages(value: &Value) -> Option<Vec<PackageInput>> {
    value.as_array()?.iter().map(package).collect()
}

fn package(value: &Value) -> Option<PackageInput> {
    let kind = match value.get("kind")?.as_str()? {
        "application" => PackageKind::Application,
        "library" => PackageKind::Library,
        _ => return None,
    };
    Some(PackageInput {
        name: value.get("name")?.as_str()?.to_owned(),
        root: value.get("root")?.as_str()?.to_owned(),
        kind,
        entries: string_array(value.get("entries")),
        dependencies: string_map(value.get("dependencies")),
    })
}

fn files(value: &Value) -> Option<Vec<FileInput>> {
    value.as_array()?.iter().map(file).collect()
}

fn file(value: &Value) -> Option<FileInput> {
    Some(FileInput {
        path: value.get("path")?.as_str()?.to_owned(),
        source_id: u32::try_from(decimal(value.get("source_id")?)?).ok()?,
        text: value.get("text")?.as_str()?.to_owned(),
    })
}

fn apply_action(session: &mut WorkspaceSession, value: &Value) -> Result<(), String> {
    let path = value.get("path").and_then(Value::as_str).unwrap_or("");
    let version = value.get("version").and_then(decimal).unwrap_or(0);
    let text = value
        .get("text")
        .and_then(Value::as_str)
        .unwrap_or("")
        .to_owned();
    let outcome = match value.get("operation").and_then(Value::as_str).unwrap_or("") {
        "open" => session.open_document(path, version, text),
        "change" => session.change_document(path, version, text),
        "close" => session.close_document(path),
        "update" => update_snapshot(session, value, false),
        "resynchronize" => update_snapshot(session, value, true),
        _ => return Err("unsupportedAction".to_owned()),
    };
    outcome.map_err(workspace_error)
}

fn update_snapshot(
    session: &mut WorkspaceSession,
    action: &Value,
    resynchronize: bool,
) -> Result<(), pseudolearn_service::WorkspaceError> {
    let Some(snapshot) = snapshot(action.get("snapshot")) else {
        return Err(pseudolearn_service::WorkspaceError::InvalidDocumentPath);
    };
    if resynchronize {
        session.update_snapshot(snapshot, SnapshotUpdateMode::Resynchronize)
    } else {
        session.update_snapshot(snapshot, SnapshotUpdateMode::Advance)
    }
}

fn outcome(session: &WorkspaceSession, errors: Vec<String>) -> Value {
    let result = session.result();
    json!({
        "revision_id": result.revision_id,
        "diagnostics": result.diagnostics.iter().map(|diagnostic| diagnostic.code.as_str()).collect::<Vec<_>>(),
        "project_errors": result.project_errors.iter().map(|error| error.code.as_str()).collect::<Vec<_>>(),
        "changed": result.invalidation.changed_modules,
        "signature_changed": result.invalidation.signature_changed_modules,
        "invalidated": result.invalidation.invalidated_modules,
        "coincide_con_frio": session.matches_cold_analysis(),
        "errores": errors
    })
}

fn workspace_error(error: pseudolearn_service::WorkspaceError) -> String {
    format!("{error:?}")
}

fn profile(value: Option<&Value>) -> Option<Profile> {
    match value.and_then(Value::as_str) {
        Some("en") => Some(Profile::English),
        Some("es") => Some(Profile::Spanish),
        _ => None,
    }
}

fn profile_map(value: Option<&Value>) -> BTreeMap<String, Profile> {
    value
        .and_then(Value::as_object)
        .into_iter()
        .flat_map(Map::iter)
        .filter_map(|(path, value)| profile(Some(value)).map(|value| (path.clone(), value)))
        .collect()
}

fn string_array(value: Option<&Value>) -> Vec<String> {
    value
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter_map(Value::as_str)
        .map(str::to_owned)
        .collect()
}

fn string_map(value: Option<&Value>) -> BTreeMap<String, String> {
    value
        .and_then(Value::as_object)
        .into_iter()
        .flat_map(Map::iter)
        .filter_map(|(key, value)| value.as_str().map(|value| (key.clone(), value.to_owned())))
        .collect()
}

fn decimal(value: &Value) -> Option<u64> {
    value
        .as_u64()
        .or_else(|| value.as_str()?.parse::<u64>().ok())
}
