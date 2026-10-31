use crate::workspace_model::{WorkspaceOptions, WorkspaceSnapshot};
use crate::workspace_session::WorkspaceSession;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{FileInput, PackageInput, PackageKind, ProjectInput};
use serde_json::Value;
use std::collections::BTreeMap;

pub(crate) fn install_snapshot(
    server: &mut crate::lsp_session::LspServer,
    request_parameters: &Value,
) -> Result<(), String> {
    let snapshot = parse_snapshot(request_parameters, server.profile, server.strict)?;
    let uris = parse_uris(request_parameters)?;
    let session = WorkspaceSession::new(snapshot).map_err(|error| format!("{error:?}"))?;
    server.workspace_session = Some(session);
    server.workspace_paths = uris
        .iter()
        .map(|(path, uri)| (uri.clone(), path.clone()))
        .collect();
    server.workspace_uris = uris;
    Ok(())
}

fn parse_snapshot(
    request_parameters: &Value,
    requested_profile: Profile,
    strict: bool,
) -> Result<WorkspaceSnapshot, String> {
    let project = request_parameters.get("project").ok_or("missing project")?;
    let project_id = integer(project, "project_id")?;
    let revision_id = integer(project, "revision_id")?;
    let (packages, files) = parse_project_contents(project)?;
    let options = parse_options(request_parameters.get("options"), requested_profile, strict)?;
    Ok(WorkspaceSnapshot {
        project: ProjectInput {
            project_id,
            revision_id,
            packages,
            files,
        },
        options,
    })
}

fn parse_project_contents(project: &Value) -> Result<(Vec<PackageInput>, Vec<FileInput>), String> {
    let packages = project
        .get("packages")
        .and_then(Value::as_array)
        .ok_or("missing packages")?
        .iter()
        .map(parse_package)
        .collect::<Result<Vec<_>, _>>()?;
    let files = project
        .get("files")
        .and_then(Value::as_array)
        .ok_or("missing files")?
        .iter()
        .map(parse_file)
        .collect::<Result<Vec<_>, _>>()?;
    Ok((packages, files))
}

fn parse_package(value: &Value) -> Result<PackageInput, String> {
    let name = string(value, "name")?;
    let root = string(value, "root")?;
    let kind = match string(value, "kind")?.as_str() {
        "application" => PackageKind::Application,
        "library" => PackageKind::Library,
        _ => return Err("invalid package kind".to_owned()),
    };
    let entries = strings(value, "entries")?;
    let dependencies = package_dependencies(value)?;
    Ok(PackageInput {
        name,
        root,
        kind,
        entries,
        dependencies,
    })
}

fn package_dependencies(value: &Value) -> Result<BTreeMap<String, String>, String> {
    value
        .get("dependencies")
        .and_then(Value::as_object)
        .ok_or("invalid package dependencies")?
        .iter()
        .map(|(alias, target)| {
            target
                .as_str()
                .map(|target| (alias.clone(), target.to_owned()))
                .ok_or_else(|| "invalid dependency target".to_owned())
        })
        .collect()
}

fn parse_file(value: &Value) -> Result<FileInput, String> {
    Ok(FileInput {
        path: string(value, "path")?,
        source_id: u32::try_from(integer(value, "source_id")?)
            .map_err(|_| "invalid source id".to_owned())?,
        text: string(value, "text")?,
    })
}

fn parse_options(
    value: Option<&Value>,
    requested_profile: Profile,
    strict: bool,
) -> Result<WorkspaceOptions, String> {
    let empty = Value::Null;
    let options = value.unwrap_or(&empty);
    let requested_profile = match options.get("profile") {
        Some(value) => Profile::from_name(value.as_str().ok_or("invalid workspace profile")?)
            .ok_or("invalid workspace profile")?,
        None => requested_profile,
    };
    let strict = match options.get("strictness").and_then(Value::as_str) {
        Some("strict") => true,
        Some("flexible") => false,
        Some(_) => return Err("invalid workspace strictness".to_owned()),
        None => strict,
    };
    let (file_profiles, entry) = option_contents(options);
    Ok(WorkspaceOptions {
        requested_profile: Some(requested_profile),
        file_profiles,
        strict,
        entry,
        configurations: Vec::new(),
        dependency_inputs: BTreeMap::new(),
    })
}

fn option_contents(options: &Value) -> (BTreeMap<String, Profile>, Option<String>) {
    let file_profiles = options
        .get("file_profiles")
        .and_then(Value::as_object)
        .map(|profiles| {
            profiles
                .iter()
                .filter_map(|(path, profile)| {
                    Some((path.clone(), Profile::from_name(profile.as_str()?)?))
                })
                .collect()
        })
        .unwrap_or_default();
    let entry = options
        .get("entry")
        .and_then(Value::as_str)
        .map(str::to_owned);
    (file_profiles, entry)
}

fn parse_uris(request_parameters: &Value) -> Result<BTreeMap<String, String>, String> {
    request_parameters
        .get("uris")
        .and_then(Value::as_object)
        .ok_or("missing uris")?
        .iter()
        .map(|(path, uri)| {
            uri.as_str()
                .map(|uri| (path.clone(), uri.to_owned()))
                .ok_or_else(|| "invalid document uri".to_owned())
        })
        .collect()
}

fn string(value: &Value, field: &str) -> Result<String, String> {
    value
        .get(field)
        .and_then(Value::as_str)
        .map(str::to_owned)
        .ok_or_else(|| format!("invalid {field}"))
}

fn strings(value: &Value, field: &str) -> Result<Vec<String>, String> {
    value
        .get(field)
        .and_then(Value::as_array)
        .ok_or_else(|| format!("invalid {field}"))?
        .iter()
        .map(|candidate| {
            candidate
                .as_str()
                .map(str::to_owned)
                .ok_or_else(|| format!("invalid {field} entry"))
        })
        .collect()
}

fn integer(value: &Value, field: &str) -> Result<u64, String> {
    value
        .get(field)
        .and_then(|candidate| {
            candidate
                .as_u64()
                .or_else(|| candidate.as_str()?.parse().ok())
        })
        .ok_or_else(|| format!("invalid {field}"))
}
