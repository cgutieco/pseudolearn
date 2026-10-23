#[path = "help_catalog/coverage.rs"]
mod catalog_coverage;
#[path = "help_catalog/examples.rs"]
mod catalog_examples;
#[path = "help_catalog/references.rs"]
mod catalog_references;
#[path = "help_catalog/safety.rs"]
mod catalog_safety;
#[path = "help_catalog/shape.rs"]
mod catalog_shape;

use see_model::Corpus;
use serde_json::Value;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct CoverageRow {
    pub category: String,
    pub identity: String,
    pub role: String,
    pub destination: Option<String>,
}

pub fn check(value: &Value) -> Result<(), String> {
    catalog_shape::check(value)?;
    catalog_safety::check(value)
}

pub fn references(value: &Value, corpus: &Corpus) -> Vec<String> {
    let mut errors = catalog_references::check(value, corpus);
    match catalog_coverage::matrix(value, corpus) {
        Ok(rows) => errors.extend(
            rows.into_iter()
                .filter(|row| row.destination.is_none())
                .map(|row| {
                    format!(
                        "SEE-HELP-CATALOG: uncovered {} identity {} for role {}",
                        row.category, row.identity, row.role
                    )
                }),
        ),
        Err(error) => errors.push(format!("SEE-HELP-CATALOG: {error}")),
    }
    errors
}

pub fn coverage_matrix(value: &Value, corpus: &Corpus) -> Result<Vec<CoverageRow>, String> {
    catalog_coverage::matrix(value, corpus)
}
