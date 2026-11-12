use serde_json::Value;

pub struct Source {
    pub program: String,
    pub profile: String,
}

pub fn corpus_sources() -> Result<Vec<Source>, String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../../pseudolearn_spec/specifications/export.json");
    let text = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
    let corpus: Value = serde_json::from_str(&text).map_err(|error| error.to_string())?;
    let mut sources = Vec::new();
    collect(&corpus, &mut sources);
    if sources.is_empty() {
        return Err("Corpus without programs".to_owned());
    }
    Ok(sources)
}

fn collect(node: &Value, sources: &mut Vec<Source>) {
    match node {
        Value::Object(fields) => {
            push_programs(fields, sources);
            fields.values().for_each(|child| collect(child, sources));
        }
        Value::Array(items) => items.iter().for_each(|child| collect(child, sources)),
        _ => {}
    }
}

fn push_programs(fields: &serde_json::Map<String, Value>, sources: &mut Vec<Source>) {
    if let Some(program) = fields.get("programa").and_then(Value::as_str) {
        let profile = fields
            .get("perfil_base")
            .and_then(Value::as_str)
            .unwrap_or("es");
        sources.push(Source {
            program: program.to_owned(),
            profile: profile.to_owned(),
        });
    }
    if let Some(programs) = fields.get("programas").and_then(Value::as_object) {
        for (profile, program) in programs {
            if let Some(text) = program.as_str() {
                sources.push(Source {
                    program: text.to_owned(),
                    profile: profile.clone(),
                });
            }
        }
    }
}
