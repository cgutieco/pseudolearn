use std::path::Path;

pub fn check(root: &Path) -> Result<(), String> {
    let root = root.canonicalize().map_err(|error| error.to_string())?;
    let mut documents = Vec::new();
    collect(&root.join("docs"), &mut documents)?;
    let listing = std::process::Command::new("git")
        .current_dir(&root)
        .args([
            "ls-files",
            "--cached",
            "--others",
            "--exclude-standard",
            "-z",
        ])
        .output()
        .map_err(|error| error.to_string())?;
    if !listing.status.success() {
        return Err("DOC-NO-TRANSIENT-REFS: cannot list repository files".to_owned());
    }
    for filename in listing.stdout.split(|byte| *byte == 0) {
        let Ok(filename) = std::str::from_utf8(filename) else {
            continue;
        };
        inspect(&root, filename, &documents)?;
    }
    Ok(())
}

fn collect(directory: &Path, documents: &mut Vec<String>) -> Result<(), String> {
    for entry in std::fs::read_dir(directory).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.is_dir() {
            collect(&path, documents)?;
            continue;
        }
        if path.extension().is_none_or(|extension| extension != "md") {
            continue;
        }
        let name = path
            .file_name()
            .and_then(|name| name.to_str())
            .ok_or("Invalid document name")?;
        if name != "README.md" {
            documents.push(name.to_owned());
        }
    }
    Ok(())
}

fn inspect(root: &Path, filename: &str, documents: &[String]) -> Result<(), String> {
    if filename.is_empty() || filename.starts_with("docs/") {
        return Ok(());
    }
    let path = root.join(filename);
    if !path.is_file() {
        return Ok(());
    }
    let bytes = std::fs::read(path).map_err(|error| error.to_string())?;
    if let Ok(text) = std::str::from_utf8(&bytes) {
        root_references(root, filename, text)?;
        reject(text, documents)
            .map_err(|reason| format!("DOC-NO-TRANSIENT-REFS: {filename}: {reason}"))?;
    }
    Ok(())
}

fn root_references(root: &Path, filename: &str, text: &str) -> Result<(), String> {
    let owner = root.join(filename);
    let parent = owner.parent().ok_or("Invalid owner path")?;
    let directory = root.join("docs");
    for token in text.split([
        ' ', '\t', '\n', '\r', '"', '\'', '(', ')', '[', ']', '<', '>', '`', '#', ',',
    ]) {
        if !token.contains("docs/") {
            continue;
        }
        let mut target = std::path::PathBuf::new();
        for component in parent.join(token).components() {
            match component {
                std::path::Component::ParentDir => {
                    target.pop();
                }
                std::path::Component::CurDir => (),
                other => target.push(other.as_os_str()),
            }
        }
        if target.starts_with(&directory) && target != directory {
            return Err(format!(
                "DOC-NO-TRANSIENT-REFS: {filename}: root document path {token}"
            ));
        }
    }
    Ok(())
}

fn reject(text: &str, documents: &[String]) -> Result<(), String> {
    for document in documents {
        if text.contains(document) {
            return Err(format!("Transient document citation {document}"));
        }
        let prefix = document.split('-').next().unwrap_or("");
        if prefix.chars().all(|character| character.is_ascii_digit())
            && !prefix.is_empty()
            && text.contains(&format!("docs/{prefix}"))
        {
            return Err(format!("Transient section citation {prefix}"));
        }
    }
    Ok(())
}

#[cfg(test)]
#[path = "documentation_tests.rs"]
mod documentation_tests;
