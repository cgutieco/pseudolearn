use crate::{arguments::Arguments, commands::first};
use see_model::Corpus;
use std::process::Command;

pub fn diff(arguments: &Arguments, corpus: &Corpus) -> Result<String, String> {
    let revision = first(arguments)?;
    if revision.starts_with('-') {
        return Err("Invalid revision".to_owned());
    }
    let previous = read_revision(arguments, revision)?;
    let mut differences = Vec::new();
    for current in corpus {
        let original = previous
            .iter()
            .find(|original| original.metadata.id == current.metadata.id);
        let classes = match original {
            Some(original) => see_change::classification::classify(original, current)?,
            None => vec!["ampliacion_candidata".to_owned()],
        };
        differences.push(serde_json::json!({"id":current.metadata.id, "classes":classes, "review_required":classes.iter().any(|class| class != "editorial")}));
    }
    for original in previous.iter().filter(|original| {
        !corpus
            .iter()
            .any(|current| current.metadata.id == original.metadata.id)
    }) {
        differences.push(serde_json::json!({"id":original.metadata.id,"classes":["retirada"],"review_required":true}));
    }
    serde_json::to_string_pretty(&differences).map_err(|error| error.to_string())
}

fn git(root: &std::path::Path, arguments: &[&str]) -> Result<String, String> {
    let output = Command::new("git")
        .current_dir(root)
        .args(arguments)
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    String::from_utf8(output.stdout).map_err(|error| error.to_string())
}

fn read_revision(arguments: &Arguments, revision: &str) -> Result<Corpus, String> {
    let root = arguments
        .root
        .canonicalize()
        .map_err(|error| error.to_string())?;
    let repository = git(&root, &["rev-parse", "--show-toplevel"])?;
    let prefix = root
        .strip_prefix(repository.trim())
        .map_err(|error| error.to_string())?;
    let corpus_path = prefix.join("specifications");
    let listing = git(
        &root,
        &[
            "ls-tree",
            "--full-tree",
            "-r",
            "--name-only",
            revision,
            "--",
            &corpus_path.to_string_lossy(),
        ],
    )?;
    let mut previous = Vec::new();
    for path in listing.lines().filter(|path| path.ends_with(".md")) {
        let text = git(&root, &["show", &format!("{revision}:{path}")])?;
        previous.push(see_format::parsing::parse(path, &text)?);
    }
    Ok(previous)
}
