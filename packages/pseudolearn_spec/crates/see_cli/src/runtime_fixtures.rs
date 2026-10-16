use crate::{arguments::Arguments, storage};
use see_model::{Corpus, contract::Vocabulary};
use serde_json::{Value, json};

pub fn generate(arguments: &Arguments, corpus: &Corpus) -> Result<String, String> {
    let vocabulary: Vocabulary =
        storage::read_json(&arguments.root.join("specifications/cases/vocabulary.json"))?;
    let registry: Value = storage::read_json(&arguments.root.join("property-conformance.json"))?;
    let binding = registry
        .get("entries")
        .and_then(Value::as_array)
        .ok_or("Missing properties")?
        .iter()
        .find(|entry| entry.get("executor").and_then(Value::as_str) == Some("gc_transparency"))
        .ok_or("Missing collection property")?;
    let seed = binding
        .get("seed")
        .and_then(Value::as_u64)
        .ok_or("Missing memory seed")?;
    let samples = binding
        .get("samples")
        .and_then(Value::as_u64)
        .and_then(|value| u32::try_from(value).ok())
        .ok_or("Missing memory samples")?;
    let cases = see_conformance::runtime_fixtures::cases(corpus, &vocabulary)?;
    let memory = see_conformance::memory_fixtures::generate(seed, samples, &vocabulary)?;
    let hashes = corpus
        .iter()
        .map(|specification| {
            Ok((
                specification.metadata.id.clone(),
                see_change::hash(specification)?,
            ))
        })
        .collect::<Result<std::collections::BTreeMap<_, _>, String>>()?;
    serde_json::to_string(
        &json!({"format":"runtime-fixtures/1","hashes":hashes,"cases":cases,
        "memory":memory,"seed":seed,"samples":samples}),
    )
    .map_err(|error| error.to_string())
}
