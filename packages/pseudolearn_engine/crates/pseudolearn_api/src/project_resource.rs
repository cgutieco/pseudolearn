use crate::ApiError;
use pseudolearn_lexicon::Profile;
use pseudolearn_project::{
    Configuration, FileInput, HostGrants, LocatedError, LocatedManifest, PackageInput, PackageKind,
    ProjectError, ProjectInput,
};
use serde::Deserialize;
use serde_json::{Value, json};
use std::collections::BTreeMap;

#[derive(Clone, Deserialize)]
struct WirePackage {
    name: String,
    root: String,
    kind: String,
    #[serde(default)]
    entries: Vec<String>,
    #[serde(default)]
    dependencies: BTreeMap<String, String>,
}

#[derive(Clone, Deserialize)]
struct WireFile {
    path: String,
    source_id: u32,
    text: String,
}

#[derive(Clone, Deserialize)]
struct WireManifest {
    location: String,
    text: String,
}

#[derive(Deserialize)]
struct WireProject {
    project_id: String,
    revision_id: String,
    packages: Option<Vec<WirePackage>>,
    manifests: Option<Vec<WireManifest>>,
    files: Vec<WireFile>,
}

pub(crate) struct ProjectRequest {
    pub profile: Profile,
    pub strict: bool,
    pub input: ProjectInput,
    pub entry: Option<String>,
    pub configurations: Vec<Configuration>,
    pub manifest_errors: Vec<LocatedError>,
    pub manifests_used: bool,
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
        let grants = crate::manifest_wire::parse_grants(arguments)?;
        let source = package_source(&wire, &grants)?;
        Ok(Self {
            profile,
            strict,
            input: input(&wire, source.packages)?,
            entry,
            configurations: source.configurations,
            manifest_errors: source.manifest_errors,
            manifests_used: source.manifests_used,
        })
    }
}

fn package_source(
    wire: &WireProject,
    grants: &HostGrants,
) -> Result<crate::project_packages::PackageSource, ApiError> {
    let packages = wire
        .packages
        .clone()
        .map(|list| list.into_iter().map(package).collect::<Result<Vec<_>, _>>())
        .transpose()?;
    let manifests = wire.manifests.clone().map(|list| {
        list.into_iter()
            .map(|manifest| LocatedManifest {
                location: manifest.location,
                text: manifest.text,
            })
            .collect()
    });
    crate::project_packages::choose(packages, manifests, grants)
}

fn input(wire: &WireProject, packages: Vec<PackageInput>) -> Result<ProjectInput, ApiError> {
    Ok(ProjectInput {
        project_id: decimal(&wire.project_id)?,
        revision_id: decimal(&wire.revision_id)?,
        packages,
        files: wire.files.iter().cloned().map(file).collect(),
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
    Value::Array(errors.iter().map(error_value).collect())
}

fn error_value(error: &ProjectError) -> Value {
    let mut fields = serde_json::Map::new();
    fields.insert("code".to_owned(), json!(error.code.as_str()));
    if let Some(path) = &error.path {
        fields.insert("path".to_owned(), json!(path));
    }
    if !error.chain.is_empty() {
        fields.insert("chain".to_owned(), json!(error.chain));
    }
    Value::Object(fields)
}
