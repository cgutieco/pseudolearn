use see_model::{Corpus, evidence::Conformance};
use std::path::Path;

pub fn check(root: &Path, corpus: &Corpus) -> Result<Vec<String>, String> {
    let subjects: std::collections::BTreeSet<_> = corpus
        .iter()
        .flat_map(|specification| &specification.metadata.sujetos)
        .collect();
    let mut errors = Vec::new();
    for subject in subjects {
        let path = match subject.as_str() {
            "see" => root.join("conformance.yaml"),
            "reference" => root.join("../pseudolearn_core/conformance.yaml"),
            "engine" | "aot" | "service" => root.join("../pseudolearn_engine/conformance.yaml"),
            "cli" => root.join("../../apps/pseudolearn_cli/conformance.yaml"),
            "app" => root.join("../../apps/pseudolearn_app/conformance.yaml"),
            _ => {
                errors.push(format!("SEE-BINDING: unknown subject {subject}"));
                continue;
            }
        };
        if path.exists() {
            errors.extend(subject_bindings(&path, subject, corpus)?);
        } else if corpus.iter().any(|specification| {
            specification.metadata.estado == "estable"
                && specification.metadata.sujetos.contains(subject)
        }) {
            errors.push(format!(
                "SEE-BINDING: missing stable subject manifest {subject}"
            ));
        }
    }
    Ok(errors)
}

fn subject_bindings(path: &Path, subject: &str, corpus: &Corpus) -> Result<Vec<String>, String> {
    let text = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
    let conformance: Conformance =
        serde_saphyr::from_str(&text).map_err(|error| error.to_string())?;
    if conformance.sujeto != subject {
        return Err("SEE-BINDING: subject manifest identity mismatch".to_owned());
    }
    Ok(see_validation::bindings::check(corpus, &conformance))
}
