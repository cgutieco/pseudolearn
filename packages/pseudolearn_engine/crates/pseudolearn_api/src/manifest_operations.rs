use crate::ApiError;
use crate::manifest_wire::{MANIFEST_BYTE_BUDGET, configuration, error_value, parse_grants};
use crate::project_resource::usage;
use pseudolearn_project::{
    Configuration, ManifestRequest, is_logical_path, normalize_logical_path,
};
use serde_json::{Value, json};

pub(crate) fn resolve(arguments: &Value) -> Result<Value, ApiError> {
    let text = text_argument(arguments, "manifest")?;
    let location = text_argument(arguments, "location")?;
    if !is_logical_path(location) {
        return Err(usage("location must be a logical path"));
    }
    let canonical_location =
        normalize_logical_path(location).unwrap_or_else(|| location.to_owned());
    let grants = parse_grants(arguments)?;
    let request = ManifestRequest {
        text,
        location,
        grants: &grants,
        max_bytes: MANIFEST_BYTE_BUDGET,
    };
    Ok(match Configuration::resolve(&request) {
        Ok(resolved) => json!({"configuration": configuration(&resolved), "manifest_errors": []}),
        Err(errors) => {
            let listed: Vec<Value> = errors
                .iter()
                .map(|error| error_value(error, &canonical_location))
                .collect();
            json!({"configuration": Value::Null, "manifest_errors": listed})
        }
    })
}

fn text_argument<'arguments>(
    arguments: &'arguments Value,
    name: &str,
) -> Result<&'arguments str, ApiError> {
    arguments
        .get(name)
        .and_then(Value::as_str)
        .ok_or_else(|| usage(&format!("missing {name}")))
}
