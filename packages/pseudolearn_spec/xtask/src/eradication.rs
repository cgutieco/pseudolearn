use std::path::Path;

pub struct EradicationList {
    pub terms: Vec<String>,
    pub allowed: Vec<String>,
}

pub fn check(root: &Path, list_path: &Path) -> Result<(), String> {
    let root = root.canonicalize().map_err(|error| error.to_string())?;
    let list = parse_list(&std::fs::read_to_string(list_path).map_err(|error| error.to_string())?)?;
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
        return Err("ERADICATION: cannot list repository files".to_owned());
    }
    let mut found = Vec::new();
    for filename in listing.stdout.split(|byte| *byte == 0) {
        let Ok(filename) = std::str::from_utf8(filename) else {
            continue;
        };
        found.extend(inspect(&root, filename, &list));
    }
    if found.is_empty() {
        return Ok(());
    }
    Err(found.join("\n"))
}

pub fn parse_list(text: &str) -> Result<EradicationList, String> {
    let mut list = EradicationList {
        terms: Vec::new(),
        allowed: Vec::new(),
    };
    for line in text.lines().filter(|line| !line.trim().is_empty()) {
        match line.split_once(' ') {
            Some(("term", term)) if !term.is_empty() => list.terms.push(term.to_owned()),
            Some(("allowed", path)) if !path.is_empty() => list.allowed.push(path.to_owned()),
            _ => return Err(format!("ERADICATION: invalid list line {line}")),
        }
    }
    if list.terms.is_empty() {
        return Err("ERADICATION: the list declares no terms".to_owned());
    }
    Ok(list)
}

fn inspect(root: &Path, filename: &str, list: &EradicationList) -> Vec<String> {
    if filename.is_empty() || list.allowed.iter().any(|path| filename.starts_with(path)) {
        return Vec::new();
    }
    let Ok(text) = std::fs::read_to_string(root.join(filename)) else {
        return Vec::new();
    };
    violations(&text, &list.terms)
        .into_iter()
        .map(|term| format!("ERADICATION: {filename}: retired term {term}"))
        .collect()
}

pub fn violations(text: &str, terms: &[String]) -> Vec<String> {
    terms
        .iter()
        .filter(|term| text.contains(term.as_str()))
        .cloned()
        .collect()
}

#[cfg(test)]
#[path = "eradication_tests.rs"]
mod eradication_tests;
