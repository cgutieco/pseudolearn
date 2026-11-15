use pseudolearn_check_source::loading::read_text;
use std::path::Path;

pub fn verify_versions(root: &Path) -> Result<(), String> {
    let mut versions = std::collections::BTreeSet::new();
    collect_versions(root, &mut versions)?;
    if versions.len() != 1 {
        return Err("Rust members must pin one identical exact toolchain".to_owned());
    }
    Ok(())
}

fn collect_versions(
    root: &Path,
    versions: &mut std::collections::BTreeSet<String>,
) -> Result<(), String> {
    for entry in std::fs::read_dir(root).map_err(|error| error.to_string())? {
        let path = entry.map_err(|error| error.to_string())?.path();
        if path.is_symlink() {
            continue;
        }
        if path.file_name().is_some_and(|name| {
            matches!(
                name.to_str(),
                Some("target" | ".git" | "node_modules" | "fixtures" | ".dart_tool" | "build")
            )
        }) {
            continue;
        }
        if path.is_dir() {
            collect_versions(&path, versions)?;
        } else if path
            .file_name()
            .is_some_and(|name| name == "rust-toolchain.toml")
        {
            versions.insert(read_version(&path)?);
        }
    }
    Ok(())
}

fn read_version(path: &Path) -> Result<String, String> {
    let text = read_text(path)?;
    let channel = text
        .lines()
        .find_map(|line| line.trim().strip_prefix("channel = "))
        .ok_or("Toolchain channel is missing")?
        .trim_matches('"')
        .to_owned();
    if channel.split('.').count() != 3
        || !channel
            .chars()
            .all(|symbol| symbol.is_ascii_digit() || symbol == '.')
    {
        return Err("Toolchain must pin an exact stable version".to_owned());
    }
    Ok(channel)
}
