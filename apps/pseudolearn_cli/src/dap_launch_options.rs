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
    if let Some(seed) = arguments.get("seed") {
        options.execution.seed = Some(parse_seed(seed)?);
    }
    configure_context(options, arguments)?;
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

fn configure_context(options: &mut CliOptions, arguments: &Value) -> Result<(), String> {
    if let Some(values) = arguments.get("args") {
        options.execution.program_arguments = values
            .as_array()
            .ok_or("args must be an array")?
            .iter()
            .map(|value| {
                value
                    .as_str()
                    .map(str::to_owned)
                    .ok_or("args must contain strings")
            })
            .collect::<Result<Vec<_>, _>>()?;
    }
    if let Some(directory) = arguments.get("cwd") {
        let directory = directory.as_str().ok_or("cwd must be a string")?;
        let path = std::fs::canonicalize(directory).map_err(|error| error.to_string())?;
        if !path.is_dir() {
            return Err("cwd must be a directory".to_owned());
        }
        options.execution.working_directory = Some(path.to_string_lossy().into_owned());
    }
    Ok(())
}
