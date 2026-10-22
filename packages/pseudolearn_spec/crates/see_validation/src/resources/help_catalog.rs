#[path = "help_catalog/references.rs"]
mod catalog_references;
#[path = "help_catalog/shape.rs"]
mod catalog_shape;

use see_model::Corpus;
use serde_json::Value;

pub fn check(value: &Value) -> Result<(), String> {
    catalog_shape::check(value)
}

pub fn references(value: &Value, corpus: &Corpus) -> Vec<String> {
    catalog_references::check(value, corpus)
}
