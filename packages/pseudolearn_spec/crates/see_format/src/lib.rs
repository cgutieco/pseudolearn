#![forbid(unsafe_code)]

pub mod parsing;

use see_model::{Corpus, Specification};
use std::path::Path;

pub fn read(root: &Path) -> Result<Corpus, String> {
    let mut paths = Vec::new();
    collect(root, &mut paths)?;
    paths.sort();
    paths
        .iter()
        .map(|path| {
            let text = std::fs::read_to_string(path).map_err(|error| error.to_string())?;
            parsing::parse(&path.to_string_lossy(), &text)
        })
        .collect()
}

fn collect(root: &Path, paths: &mut Vec<std::path::PathBuf>) -> Result<(), String> {
    for entry in std::fs::read_dir(root).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.is_dir() && path.file_name().is_some_and(|name| name != "fixtures") {
            collect(&path, paths)?;
        } else if path.extension().is_some_and(|extension| extension == "md") {
            paths.push(path);
        }
    }
    Ok(())
}

pub fn write(specification: &Specification) -> Result<String, String> {
    let header =
        serde_saphyr::to_string(&specification.metadata).map_err(|error| error.to_string())?;
    let mut text = format!("---\n{header}---\n\n# {}\n", specification.metadata.titulo);
    for block in &specification.blocks {
        let fields = serde_saphyr::to_string(&block.fields).map_err(|error| error.to_string())?;
        text.push_str(&format!("\n```{}\n{fields}```\n", block.kind));
    }
    Ok(text)
}
