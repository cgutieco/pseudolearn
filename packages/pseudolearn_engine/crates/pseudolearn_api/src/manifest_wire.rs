use crate::ApiError;
use crate::project_resource::usage;
use pseudolearn_project::{
    Configuration, HostGrants, LimitName, LocatedError, ManifestError, PackageKind, Provenance,
};
use serde_json::{Map, Value, json};

pub(crate) const MANIFEST_BYTE_BUDGET: usize = 262_144;

pub(crate) fn parse_grants(arguments: &Value) -> Result<HostGrants, ApiError> {
    let Some(grants) = arguments.get("grants") else {
        return Ok(HostGrants::default());
    };
    let object = grants
        .as_object()
        .ok_or_else(|| usage("grants must be an object"))?;
    if object.keys().any(|name| name != "limits") {
        return Err(usage("unknown grant category"));
    }
    let mut result = HostGrants::default();
    let Some(limits) = object.get("limits") else {
        return Ok(result);
    };
    let limits = limits
        .as_object()
        .ok_or_else(|| usage("limit grants must be an object"))?;
    for (name, value) in limits {
        let limit = LimitName::ALL
            .into_iter()
            .find(|candidate| candidate.as_str() == name)
            .ok_or_else(|| usage("unknown limit name"))?;
        let ceiling = value
            .as_u64()
            .ok_or_else(|| usage("limit grant must be an unsigned integer"))?;
        result.limits.insert(limit, ceiling);
    }
    Ok(result)
}

pub(crate) fn error_value(error: &ManifestError, location: &str) -> Value {
    json!({
        "code": error.code.as_str(),
        "field": error.field,
        "line": error.position.line,
        "column": error.position.column,
        "location": location,
    })
}

pub(crate) fn located_errors(errors: &[LocatedError]) -> Value {
    Value::Array(
        errors
            .iter()
            .map(|failure| error_value(&failure.error, &failure.location))
            .collect(),
    )
}

fn provenance(source: Provenance) -> Value {
    match source {
        Provenance::Manifest(position) => {
            json!({"source": "manifest", "line": position.line, "column": position.column})
        }
        Provenance::Default => json!({"source": "default"}),
        Provenance::Location => json!({"source": "location"}),
        Provenance::Host => json!({"source": "host"}),
    }
}

fn field(value: Value, source: Provenance) -> Value {
    json!({"value": value, "provenance": provenance(source)})
}

fn kind_name(kind: PackageKind) -> &'static str {
    match kind {
        PackageKind::Application => "application",
        PackageKind::Library => "library",
    }
}

pub(crate) fn configuration(configuration: &Configuration) -> Value {
    let manifest = &configuration.manifest;
    let package = json!({
        "name": field(json!(manifest.name.value), manifest.name.provenance),
        "root": field(json!(configuration.root), Provenance::Location),
        "kind": field(json!(kind_name(manifest.kind.value)), manifest.kind.provenance),
        "profile": field(json!(manifest.profile.value.as_str()), manifest.profile.provenance),
        "entries": field(json!(manifest.entries.value), manifest.entries.provenance),
    });
    let profiles: Vec<Value> = manifest
        .profiles
        .iter()
        .map(|element| json!({"path": element.path, "profile": element.profile.as_str(), "provenance": provenance(Provenance::Manifest(element.position))}))
        .collect();
    let dependencies: Vec<Value> = manifest
        .dependencies
        .iter()
        .map(|element| json!({"alias": element.alias, "package": element.package, "provenance": provenance(Provenance::Manifest(element.position))}))
        .collect();
    json!({
        "schema": 1,
        "package": package,
        "profiles": profiles,
        "dependencies": dependencies,
        "limits": limits(configuration),
        "permissions": [],
    })
}

fn limits(configuration: &Configuration) -> Value {
    let mut entries = Map::new();
    for (name, authority) in &configuration.limits {
        entries.insert(
            name.as_str().to_owned(),
            json!({
                "requested": authority.requested,
                "granted": authority.granted,
                "effective": authority.effective,
                "provenance": provenance(authority.provenance),
            }),
        );
    }
    Value::Object(entries)
}
