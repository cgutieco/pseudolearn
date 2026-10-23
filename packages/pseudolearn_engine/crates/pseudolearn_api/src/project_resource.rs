use crate::ApiError;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{FileInput, PackageInput, PackageKind, ProjectError, ProjectInput};
use serde::Deserialize;
use serde_json::{Value, json};
use std::collections::BTreeMap;

#[derive(Deserialize)]
struct WirePackage {
    name: String,
    root: String,
    kind: String,
    #[serde(default)]
    entries: Vec<String>,
    #[serde(default)]
    dependencies: BTreeMap<String, String>,
}

#[derive(Deserialize)]
struct WireFile {
    path: String,
    source_id: u32,
    text: String,
}

#[derive(Deserialize)]
struct WireProject {
    project_id: String,
    revision_id: String,
    packages: Vec<WirePackage>,
    files: Vec<WireFile>,
}

pub(crate) struct ProjectRequest {
    pub profile: Profile,
    pub strict: bool,
    pub input: ProjectInput,
    pub entry: Option<String>,
}

impl ProjectRequest {
    pub(crate) fn parse(arguments: &Value) -> Result<Self, ApiError> {
        let wire: WireProject = arguments
            .get("project")
            .cloned()
            .ok_or_else(|| usage("missing project"))
            .and_then(|value| {
                serde_json::from_value(value).map_err(|error| usage(&error.to_string()))
            })?;
        let profile = arguments
            .get("profile")
            .and_then(Value::as_str)
            .map_or(Some(Profile::Spanish), Profile::from_name)
            .ok_or_else(|| usage("unknown profile"))?;
        let strict = arguments.get("strictness").and_then(Value::as_str) != Some("flexible");
        let entry = arguments
            .get("entry")
            .and_then(Value::as_str)
            .map(str::to_owned);
        Ok(Self {
            profile,
            strict,
            input: input(wire)?,
            entry,
        })
    }
}

fn input(wire: WireProject) -> Result<ProjectInput, ApiError> {
    Ok(ProjectInput {
        project_id: decimal(&wire.project_id)?,
        revision_id: decimal(&wire.revision_id)?,
        packages: wire
            .packages
            .into_iter()
            .map(package)
            .collect::<Result<_, _>>()?,
        files: wire.files.into_iter().map(file).collect(),
    })
}

fn package(wire: WirePackage) -> Result<PackageInput, ApiError> {
    let kind = match wire.kind.as_str() {
        "application" => PackageKind::Application,
        "library" => PackageKind::Library,
        _ => return Err(usage("unknown package kind")),
    };
    Ok(PackageInput {
        name: wire.name,
        root: wire.root,
        kind,
        entries: wire.entries,
        dependencies: wire.dependencies,
    })
}

fn file(wire: WireFile) -> FileInput {
    FileInput {
        path: wire.path,
        source_id: wire.source_id,
        text: wire.text,
    }
}

fn decimal(text: &str) -> Result<u64, ApiError> {
    text.parse::<u64>()
        .ok()
        .filter(|value| value.to_string() == text)
        .ok_or_else(|| usage("identifier must be a canonical decimal u64"))
}

pub(crate) fn usage(detail: &str) -> ApiError {
    ApiError::InvalidProtocol(detail.to_owned())
}

pub(crate) fn error_values(errors: &[ProjectError]) -> Value {
    Value::Array(
        errors
            .iter()
            .map(|error| match &error.path {
                Some(path) => json!({"code": error.code.as_str(), "path": path}),
                None => json!({"code": error.code.as_str()}),
            })
            .collect(),
    )
}
