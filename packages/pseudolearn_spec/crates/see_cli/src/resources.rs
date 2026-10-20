use see_model::{Block, Corpus, contract::Vocabulary, field, strings};
use std::path::Path;

pub fn export(root: &Path, corpus: &Corpus, check: bool) -> Result<String, String> {
    let exported = see_export::generate(corpus)?;
    let resources = exported
        .get("resources")
        .ok_or("SEE-RESOURCE: missing export resources")?;
    if resources.get("vocabulary").is_some() {
        crate::storage::artifact(
            &root.join("specifications/cases/vocabulary.json"),
            &see_export::resources::vocabulary(resources)?,
            check,
        )?;
        crate::storage::artifact(
            &root.join("specifications/cases/catalogs.json"),
            resources,
            check,
        )?;
    }
    crate::storage::artifact(&root.join("specifications/export.json"), &exported, check)
}

pub fn check(root: &Path, corpus: &Corpus) -> Result<Vec<String>, String> {
    let mut errors = features(root, corpus)?;
    let manifest = root.join("specifications/cases/migration.json");
    if manifest.exists() {
        let manifest = crate::storage::read_json(&manifest)?;
        let index = std::fs::read_to_string(root.join("subjects/reference/language-spec.md"))
            .map_err(|error| error.to_string())?;
        if let Err(error) = see_validation::migration::check(&manifest, &index, corpus) {
            errors.push(error);
        }
    }
    let path = root.join("specifications/cases/vocabulary.json");
    let vocabulary: Vocabulary = if path.exists() {
        crate::storage::read_json(&path)?
    } else {
        Default::default()
    };
    for specification in corpus {
        for case in specification
            .blocks
            .iter()
            .filter(|block| block.kind == "caso")
        {
            if !["ir", "cli", "service", "app"].contains(&field(case, "operacion")) {
                errors.extend(programs(case, &vocabulary));
            }
            errors.extend(see_translation::lexemes::validate(case, &vocabulary));
        }
    }
    Ok(errors)
}

fn programs(case: &Block, vocabulary: &Vocabulary) -> Vec<String> {
    let mut errors = Vec::new();
    let source = field(case, "perfil_base");
    let source = if source.is_empty() { "es" } else { source };
    for target in strings(case.fields.get("perfiles")) {
        let explicit = case
            .fields
            .get("programas")
            .and_then(|programs| programs.get(target))
            .and_then(|program| program.as_str());
        if explicit.is_some() {
            continue;
        }
        let Some(program) = case
            .fields
            .get("programa")
            .and_then(|program| program.as_str())
        else {
            errors.push(format!("SEE-PROFILE: missing {target} program"));
            continue;
        };
        if target == source {
            continue;
        }
        if vocabulary.is_empty() {
            errors.push("SEE-TRANSLATION: missing vocabulary".to_owned());
            continue;
        }
        if !see_translation::collisions(program, source, target, vocabulary).is_empty() {
            errors.push(format!(
                "SEE-PROFILE: reserved identifier collision in {target}"
            ));
        }
        if let Err(error) = see_translation::translate(program, source, target, vocabulary) {
            errors.push(error);
        }
    }
    errors
}

fn features(root: &Path, corpus: &Corpus) -> Result<Vec<String>, String> {
    let directory = root.join("specifications/features");
    if !directory.exists() {
        return Ok(Vec::new());
    }
    let mut errors = Vec::new();
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.extension().is_none_or(|extension| extension != "yaml") {
            continue;
        }
        let text = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
        let manifest = serde_saphyr::from_str(&text).map_err(|error| error.to_string())?;
        if let Err(error) = see_report::feature(corpus, &manifest) {
            errors.push(error);
        }
    }
    Ok(errors)
}
