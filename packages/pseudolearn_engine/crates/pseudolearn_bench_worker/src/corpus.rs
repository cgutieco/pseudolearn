use serde_json::Value;

pub struct CorpusCase {
    pub name: String,
    pub source: String,
    pub inputs: Vec<String>,
    pub expected_output: String,
}

pub fn awfy_cases() -> Result<Vec<CorpusCase>, String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../pseudolearn_spec/specifications/export.json");
    let corpus: Value =
        serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
            .map_err(|error| error.to_string())?;
    let suite = corpus
        .get("specifications")
        .and_then(Value::as_array)
        .and_then(|specifications| {
            specifications.iter().find(|specification| {
                specification
                    .pointer("/metadata/id")
                    .and_then(Value::as_str)
                    == Some("PERF.SUITE.CORE")
            })
        })
        .ok_or("Missing AWFY suite")?;
    let mut cases = Vec::new();
    for block in suite
        .get("blocks")
        .and_then(Value::as_array)
        .ok_or("Missing cases")?
    {
        let fields = block.get("fields").ok_or("Missing fields")?;
        let Some(tags) = fields.get("etiquetas").and_then(Value::as_array) else {
            continue;
        };
        if tags.iter().any(|tag| tag.as_str() == Some("medicion")) {
            cases.push(case_of(fields, tags)?);
        }
    }
    if cases.len() != 10 {
        return Err("Expected ten AWFY workloads".to_owned());
    }
    Ok(cases)
}

fn case_of(fields: &Value, tags: &[Value]) -> Result<CorpusCase, String> {
    Ok(CorpusCase {
        name: tags
            .last()
            .and_then(Value::as_str)
            .ok_or("Missing workload name")?
            .to_owned(),
        source: fields
            .get("programa")
            .and_then(Value::as_str)
            .ok_or("Missing source")?
            .to_owned(),
        inputs: serde_json::from_value(fields.get("entradas").cloned().ok_or("Missing inputs")?)
            .map_err(|error| error.to_string())?,
        expected_output: fields
            .pointer("/espera/salida")
            .and_then(Value::as_str)
            .ok_or("Missing expectation")?
            .to_owned(),
    })
}
