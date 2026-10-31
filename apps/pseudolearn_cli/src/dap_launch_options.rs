use crate::options::CliOptions;
use serde_json::Value;

pub(crate) fn configure(options: &mut CliOptions, arguments: &Value) -> Result<(), String> {
    if arguments
        .get("backend")
        .is_some_and(|value| value.as_str() != Some("vm"))
        || options.execution.native
    {
        return Err("debugging requires the VM backend".to_owned());
    }
    validate_authority(arguments)?;
    if let Some(profile) = arguments.get("profile") {
        let profile = profile.as_str().ok_or("invalid profile")?;
        if !["es", "en"].contains(&profile) {
            return Err("invalid profile".to_owned());
        }
        options.vocabulary = Some(profile.to_owned());
    }
    if let Some(strictness) = arguments.get("strictness") {
        let strictness = strictness.as_str().ok_or("invalid strictness")?;
        if !["strict", "flexible"].contains(&strictness) {
            return Err("invalid strictness".to_owned());
        }
        options.strictness = Some(strictness.to_owned());
    }
    if let Some(seed) = arguments.get("seed") {
        options.execution.seed = Some(parse_seed(seed)?);
    }
    options.execution.trace = true;
    Ok(())
}

fn validate_authority(arguments: &Value) -> Result<(), String> {
    if arguments
        .get("stopOnEntry")
        .is_some_and(|value| !value.is_boolean())
        || arguments
            .get("workspaceRoot")
            .is_some_and(|value| !value.is_string())
    {
        return Err("invalid launch options".to_owned());
    }
    if [
        "grants",
        "permissions",
        "origins",
        "filesRoot",
        "env",
        "args",
        "serverPath",
    ]
    .iter()
    .any(|name| arguments.get(name).is_some())
    {
        return Err("launch configuration cannot grant authority".to_owned());
    }
    Ok(())
}

fn parse_seed(value: &Value) -> Result<i64, String> {
    let text = value
        .as_str()
        .ok_or("seed must be a canonical i64 string")?;
    let number: i64 = text.parse().map_err(|_| "seed is outside i64")?;
    if number.to_string() != text {
        return Err("seed must be a canonical i64 string".to_owned());
    }
    Ok(number)
}
