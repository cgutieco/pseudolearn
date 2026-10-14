#![forbid(unsafe_code)]

use see_model::Corpus;
use serde_json::{Value, json};

pub mod resources;

pub fn generate(corpus: &Corpus) -> Result<Value, String> {
    let mut specifications = Vec::new();
    let mut areas = std::collections::BTreeMap::<String, Vec<String>>::new();
    for specification in corpus {
        let metadata = &specification.metadata;
        let area = metadata.id.split('.').take(2).collect::<Vec<_>>().join(".");
        areas.entry(area).or_default().push(metadata.id.clone());
        specifications.push(json!({"metadata":metadata, "blocks":specification.blocks, "hash":see_change::hash(specification)?}));
    }
    Ok(
        json!({"format":"see-export/1", "specifications":specifications, "areas":areas, "resources":resources::generate(corpus)?}),
    )
}
