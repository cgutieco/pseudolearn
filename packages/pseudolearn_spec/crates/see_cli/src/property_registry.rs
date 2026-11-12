use see_model::{Corpus, properties::PropertyRegistry};
use std::path::Path;

pub fn check(root: &Path, corpus: &Corpus) -> Result<Vec<String>, String> {
    if !corpus.iter().any(|specification| {
        specification
            .blocks
            .iter()
            .any(|block| block.kind == "propiedad")
    }) {
        return Ok(Vec::new());
    }
    let value: serde_json::Value =
        crate::storage::read_json(&root.join("property-conformance.json"))?;
    let schema: serde_json::Value =
        serde_json::from_str(include_str!("../../../schemas/properties-1.schema.json"))
            .map_err(|error| error.to_string())?;
    see_validation::schema_engine::check(&value, &schema, &schema, 0)
        .map_err(|error| format!("SEE-PROPERTY: {error}"))?;
    let registry: PropertyRegistry =
        serde_json::from_value(value).map_err(|error| format!("SEE-PROPERTY: {error}"))?;
    Ok(see_validation::property_registry::check(corpus, &registry))
}
