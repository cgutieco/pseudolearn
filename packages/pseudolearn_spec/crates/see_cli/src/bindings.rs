use see_model::{Corpus, evidence::Conformance};
use std::path::{Path, PathBuf};

pub fn check(root: &Path, corpus: &Corpus) -> Result<Vec<String>, String> {
    let subjects: std::collections::BTreeSet<_> = corpus
        .iter()
        .flat_map(|specification| &specification.metadata.sujetos)
        .collect();
    let mut errors = Vec::new();
    for subject in subjects {
        let Some(path) = manifest_path(root, subject) else {
            errors.push(format!("SEE-BINDING: unknown subject {subject}"));
            continue;
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

pub fn manifest_path(root: &Path, subject: &str) -> Option<PathBuf> {
    let relative = match subject {
        "see" => "conformance.yaml",
        "reference" => "../pseudolearn_core/conformance.yaml",
        "engine" => "../pseudolearn_engine/conformance.yaml",
        "aot" => "../pseudolearn_engine/conformance-aot.yaml",
        "service" => "../pseudolearn_service/conformance.yaml",
        "cli" => "../../apps/pseudolearn_cli/conformance.yaml",
        "app" => "../../apps/pseudolearn_app/conformance.yaml",
        _ => return None,
    };
    Some(root.join(relative))
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
