use see_model::{Corpus, field, properties::PropertyRegistry};
use std::collections::BTreeSet;

pub fn check(corpus: &Corpus, registry: &PropertyRegistry) -> Vec<String> {
    let mut errors = header(corpus, registry);
    let references = references(corpus, &registry.subjects);
    let mut seen = BTreeSet::new();
    for entry in &registry.entries {
        if !seen.insert(entry.reference.clone()) {
            errors.push(format!("SEE-PROPERTY: duplicate {}", entry.reference));
        }
        if !references.contains(&entry.reference) {
            errors.push(format!("SEE-PROPERTY: unresolved {}", entry.reference));
        }
        if entry.samples == 0 {
            errors.push(format!("SEE-PROPERTY: zero samples {}", entry.reference));
        }
    }
    for reference in references.difference(&seen) {
        errors.push(format!("SEE-PROPERTY: unbound {reference}"));
    }
    errors
}

fn references(corpus: &Corpus, subjects: &[String]) -> BTreeSet<String> {
    corpus
        .iter()
        .filter(|specification| {
            specification
                .metadata
                .sujetos
                .iter()
                .any(|subject| subjects.contains(subject))
        })
        .flat_map(|specification| {
            specification
                .blocks
                .iter()
                .filter(|block| block.kind == "propiedad")
                .map(|block| {
                    format!(
                        "{}@{}#{}",
                        specification.metadata.id,
                        specification.metadata.version,
                        field(block, "id")
                    )
                })
        })
        .collect()
}

fn header(corpus: &Corpus, registry: &PropertyRegistry) -> Vec<String> {
    let mut errors = Vec::new();
    if registry.format != "see-properties/1" {
        errors.push("SEE-PROPERTY: incompatible registry format".to_owned());
    }
    let subjects: BTreeSet<_> = registry.subjects.iter().collect();
    if subjects.is_empty()
        || subjects.len() != registry.subjects.len()
        || subjects.iter().any(|subject| {
            !corpus
                .iter()
                .any(|specification| specification.metadata.sujetos.contains(subject))
        })
    {
        errors.push("SEE-PROPERTY: unknown, duplicate or empty subjects".to_owned());
    }
    errors
}
