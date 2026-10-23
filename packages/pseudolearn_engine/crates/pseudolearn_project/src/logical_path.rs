pub(crate) fn segments(path: &str) -> Option<Vec<String>> {
    if path.is_empty() {
        return None;
    }
    let parts: Vec<String> = path.split('/').map(str::to_owned).collect();
    parts
        .iter()
        .all(|part| !part.is_empty() && part != "." && part != "..")
        .then_some(parts)
}

pub(crate) fn is_prefix(root: &[String], path: &[String]) -> bool {
    path.len() > root.len() && path.starts_with(root)
}
