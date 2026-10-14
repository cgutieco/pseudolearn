use see_model::Corpus;
use serde_json::{Value, json};
use std::collections::BTreeMap;
use std::path::Path;

pub fn execute(root: &Path, corpus: &Corpus) -> Result<String, String> {
    let resources = see_export::resources::generate(corpus)?;
    let vocabulary = resources
        .get("vocabulary")
        .ok_or("Missing normative vocabulary")?;
    let directory = root.join("../../apps/pseudolearn_app/assets/knowledge/examples");
    let sources = source_files(&directory)?;
    let mut files = Vec::new();
    for path in sources {
        let filename = path
            .file_name()
            .and_then(|name| name.to_str())
            .ok_or("Invalid example name")?;
        let profile = if filename.ends_with("_es.pseudo") {
            "es"
        } else {
            "en"
        };
        let source = std::fs::read_to_string(&path).map_err(|error| error.to_string())?;
        files.push(json!({"file":filename,"profile":profile,"measurement":measure(&source, profile, vocabulary)?}));
    }
    if files.is_empty() {
        return Err("Cannot establish experiment provenance".to_owned());
    }
    let revision = revision(root)?;
    crate::storage::artifact(
        &root.join("results/e10.json"),
        &json!({"experiment":"E-10","revision":revision.trim(),"method":"declaration-and-counted-control-candidates/1","limitations":"Editorial local examples; no student sample, no external repositories, no inference of negligible collision risk.","files":files}),
        false,
    )
}

fn source_files(directory: &Path) -> Result<Vec<std::path::PathBuf>, String> {
    let mut sources = Vec::new();
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path
            .extension()
            .is_some_and(|extension| extension == "pseudo")
        {
            sources.push(path);
        }
    }
    sources.sort();
    Ok(sources)
}

fn revision(root: &Path) -> Result<String, String> {
    let output = std::process::Command::new("git")
        .current_dir(root)
        .args(["rev-parse", "HEAD"])
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err("Cannot establish experiment revision".to_owned());
    }
    String::from_utf8(output.stdout).map_err(|error| error.to_string())
}

fn measure(source: &str, profile: &str, vocabulary: &Value) -> Result<Value, String> {
    let reserved = reserved(profile, vocabulary)?;
    let mut candidates = BTreeMap::<String, usize>::new();
    for line in source.lines() {
        for name in candidates_in(line) {
            let count = candidates.entry(name).or_default();
            *count = count.checked_add(1).ok_or("Candidate count overflow")?;
        }
    }
    let collisions: BTreeMap<_, _> = candidates
        .iter()
        .filter(|(name, _)| reserved.contains_key(&normalize(name, profile)))
        .collect();
    Ok(json!({"reserved_forms":reserved.len(),"candidates":candidates,"collisions":collisions}))
}

fn reserved(profile: &str, vocabulary: &Value) -> Result<BTreeMap<String, String>, String> {
    let mut reserved = BTreeMap::new();
    let entries = vocabulary.as_object().ok_or("Invalid vocabulary")?;
    for (identity, entry) in entries {
        let canonical = entry
            .get("lexemas")
            .and_then(|profiles| profiles.get(profile))
            .and_then(Value::as_str)
            .ok_or("Missing profile")?;
        let aliases = entry
            .get("alias")
            .and_then(|profiles| profiles.get(profile));
        for word in std::iter::once(canonical).chain(see_model::strings(aliases)) {
            reserved.insert(normalize(word, profile), identity.clone());
        }
    }
    Ok(reserved)
}

fn candidates_in(line: &str) -> Vec<String> {
    let line = line.split_once("//").map_or(line, |(source, _)| source);
    let words: Vec<_> = line.split_whitespace().collect();
    let declaration = words.iter().take(2).position(|word| {
        ["definir", "define", "declare", "dimension"].contains(&word.to_lowercase().as_str())
    });
    if let Some(beginning) = declaration {
        let content = words
            .iter()
            .skip(beginning.saturating_add(1))
            .take_while(|word| !["como", "as"].contains(&word.to_lowercase().as_str()))
            .copied()
            .collect::<Vec<_>>()
            .join(" ");
        return content
            .split(',')
            .filter_map(identifier)
            .map(str::to_owned)
            .collect();
    }
    if words
        .first()
        .is_some_and(|word| ["para", "for"].contains(&word.to_lowercase().as_str()))
    {
        return words
            .get(1)
            .and_then(|word| identifier(word))
            .into_iter()
            .map(str::to_owned)
            .collect();
    }
    Vec::new()
}

fn identifier(text: &str) -> Option<&str> {
    let text = text.trim();
    if !text.starts_with(|character: char| character.is_alphabetic() || character == '_') {
        return None;
    }
    let end = text
        .find(|character: char| !character.is_alphanumeric() && character != '_')
        .unwrap_or(text.len());
    text.get(..end)
}

fn normalize(text: &str, profile: &str) -> String {
    let folded = text.to_lowercase();
    if profile == "en" {
        return folded;
    }
    folded
        .replace('á', "a")
        .replace('é', "e")
        .replace('í', "i")
        .replace('ó', "o")
        .replace(['ú', 'ü'], "u")
}

#[cfg(test)]
#[path = "e10_tests.rs"]
mod e10_tests;
