use std::path::{Path, PathBuf};

pub fn read(path: &Path) -> Result<String, String> {
    std::fs::read_to_string(path)
        .map_err(|error| format!("cannot read {}: {error}", path.display()))
}

pub fn files_with_extension(directory: &Path, extension: &str) -> Result<Vec<PathBuf>, String> {
    let mut found = Vec::new();
    if !directory.exists() {
        return Ok(found);
    }
    let mut pending = vec![directory.to_path_buf()];
    while let Some(current) = pending.pop() {
        let (directories, files): (Vec<PathBuf>, Vec<PathBuf>) = children(&current)?
            .into_iter()
            .partition(|path| path.is_dir());
        pending.extend(directories);
        found.extend(
            files
                .into_iter()
                .filter(|path| path.extension().is_some_and(|found| found == extension)),
        );
    }
    found.sort();
    Ok(found)
}

fn children(directory: &Path) -> Result<Vec<PathBuf>, String> {
    std::fs::read_dir(directory)
        .map_err(|error| format!("cannot list {}: {error}", directory.display()))?
        .map(|entry| {
            entry
                .map(|entry| entry.path())
                .map_err(|error| error.to_string())
        })
        .collect()
}

pub fn relative(root: &Path, path: &Path) -> String {
    path.strip_prefix(root)
        .unwrap_or(path)
        .to_string_lossy()
        .replace('\\', "/")
}
