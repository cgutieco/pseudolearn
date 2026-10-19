use serde_json::Value;

pub fn threshold(specification: &str, measurement: &str) -> Result<f64, String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../pseudolearn_spec/specifications/export.json");
    let corpus: Value =
        serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
            .map_err(|error| error.to_string())?;
    corpus
        .get("specifications")
        .and_then(Value::as_array)
        .into_iter()
        .flatten()
        .filter(|entry| {
            entry.pointer("/metadata/id").and_then(Value::as_str) == Some(specification)
        })
        .flat_map(|entry| {
            entry
                .get("blocks")
                .and_then(Value::as_array)
                .into_iter()
                .flatten()
        })
        .filter(|block| block.get("kind").and_then(Value::as_str) == Some("medicion"))
        .filter_map(|block| block.get("fields"))
        .find(|fields| fields.get("id").and_then(Value::as_str) == Some(measurement))
        .and_then(|fields| fields.get("umbral"))
        .and_then(Value::as_f64)
        .ok_or_else(|| format!("Missing threshold {specification}#{measurement}"))
}
