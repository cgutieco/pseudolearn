use serde_json::Value;

fn main() {
    println!("cargo:rerun-if-changed=../../../pseudolearn_spec/specifications/export.json");
    if let Err(error) = generate() {
        eprintln!("Failed to generate effect operations: {error}");
        std::process::exit(1);
    }
}

fn generate() -> Result<(), String> {
    let directory = std::env::var("CARGO_MANIFEST_DIR").map_err(|error| error.to_string())?;
    let path = std::path::Path::new(&directory)
        .join("../../../pseudolearn_spec/specifications/export.json");
    let bytes = std::fs::read(path).map_err(|error| error.to_string())?;
    let corpus: Value = serde_json::from_slice(&bytes).map_err(|error| error.to_string())?;
    let operations = corpus
        .pointer("/resources/capabilityLibrary/operations")
        .and_then(Value::as_array)
        .ok_or("missing capabilityLibrary")?;
    let mut source = String::from("pub static EFFECT_OPERATIONS: &[EffectOperation] = &[\n");
    for (index, operation) in operations.iter().enumerate() {
        source.push_str(&entry(index, operation)?);
    }
    source.push_str("];\n");
    let output = std::env::var("OUT_DIR").map_err(|error| error.to_string())?;
    std::fs::write(
        std::path::Path::new(&output).join("effect_operations.rs"),
        source,
    )
    .map_err(|error| error.to_string())
}

fn text_field<'operation>(
    operation: &'operation Value,
    name: &str,
) -> Result<&'operation str, String> {
    operation
        .get(name)
        .and_then(Value::as_str)
        .ok_or_else(|| format!("missing {name}"))
}

fn flag_field(operation: &Value, name: &str) -> Result<bool, String> {
    operation
        .get(name)
        .and_then(Value::as_bool)
        .ok_or_else(|| format!("missing {name}"))
}

fn receiver_source(operation: &Value) -> Result<String, String> {
    Ok(operation
        .get("receiver")
        .and_then(Value::as_str)
        .map(value_kind)
        .transpose()?
        .map_or("None".to_owned(), |kind| {
            format!("Some(EffectValueKind::{kind})")
        }))
}

fn parameters_source(operation: &Value) -> Result<String, String> {
    Ok(operation
        .get("parameters")
        .and_then(Value::as_array)
        .ok_or("missing parameters")?
        .iter()
        .map(|kind| {
            value_kind(kind.as_str().ok_or("invalid parameter")?)
                .map(|kind| format!("EffectValueKind::{kind}"))
        })
        .collect::<Result<Vec<_>, _>>()?
        .join(","))
}

fn entry(index: usize, operation: &Value) -> Result<String, String> {
    let receiver = receiver_source(operation)?;
    let parameters = parameters_source(operation)?;
    Ok(format!(
        "EffectOperation {{ id: {index}, identity: {:?}, receiver: {receiver}, spanish: {:?}, english: {:?}, parameters: &[{parameters}], result: EffectValueKind::{}, effect: {}, fallible: {} }},\n",
        text_field(operation, "identity")?,
        text_field(operation, "es")?,
        text_field(operation, "en")?,
        value_kind(text_field(operation, "result")?)?,
        flag_field(operation, "effect")?,
        flag_field(operation, "fallible")?
    ))
}

fn value_kind(name: &str) -> Result<&'static str, String> {
    match name {
        "integer" => Ok("Integer"),
        "boolean" => Ok("Boolean"),
        "text" => Ok("Text"),
        "bytes" => Ok("Bytes"),
        "text_list" => Ok("TextList"),
        "console" => Ok("Console"),
        "arguments" => Ok("Arguments"),
        "directory" => Ok("Directory"),
        "file" => Ok("File"),
        "clock" => Ok("Clock"),
        "timer" => Ok("Timer"),
        _ => Err(format!("invalid effect data kind {name}")),
    }
}
