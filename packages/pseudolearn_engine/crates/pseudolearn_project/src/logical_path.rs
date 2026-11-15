use pseudolearn_source::IdentifierNormalizer;

pub(crate) fn segments(path: &str) -> Option<Vec<String>> {
    if path.is_empty() {
        return None;
    }
    let parts: Vec<String> = path
        .split('/')
        .map(IdentifierNormalizer::normalize)
        .collect();
    parts
        .iter()
        .all(|part| valid_segment(part))
        .then_some(parts)
}

pub(crate) fn normalize(path: &str) -> Option<String> {
    segments(path).map(|parts| parts.join("/"))
}

pub(crate) fn key(path: &str) -> Option<Vec<String>> {
    segments(path).map(|parts| key_parts(&parts))
}

pub(crate) fn key_parts(parts: &[String]) -> Vec<String> {
    parts
        .iter()
        .map(|part| {
            let lowered: String = part.chars().flat_map(char::to_lowercase).collect();
            IdentifierNormalizer::normalize(&lowered)
        })
        .collect()
}

pub(crate) fn is_prefix(root: &[String], path: &[String]) -> bool {
    path.len() > root.len() && key_parts(path).starts_with(&key_parts(root))
}

pub fn normalize_logical_path(path: &str) -> Option<String> {
    normalize(path)
}

pub fn logical_path_key(path: &str) -> Option<String> {
    key(path).map(|parts| parts.join("/"))
}

fn valid_segment(part: &str) -> bool {
    if part.is_empty() || part == "." || part == ".." || part.ends_with('.') || part.ends_with(' ')
    {
        return false;
    }
    if part.chars().any(|character| {
        character.is_control()
            || matches!(character, '<' | '>' | ':' | '"' | '\\' | '|' | '?' | '*')
    }) {
        return false;
    }
    !is_reserved_device(part)
}

fn is_reserved_device(part: &str) -> bool {
    let stem = part.split('.').next().unwrap_or("");
    let upper = stem.to_ascii_uppercase();
    matches!(
        upper.as_str(),
        "CON" | "PRN" | "AUX" | "NUL" | "CONIN$" | "CONOUT$"
    ) || numbered_device(&upper, "COM")
        || numbered_device(&upper, "LPT")
        || superscript_device(&upper, "COM")
        || superscript_device(&upper, "LPT")
}

fn numbered_device(stem: &str, prefix: &str) -> bool {
    stem.strip_prefix(prefix)
        .is_some_and(|suffix| matches!(suffix, "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"))
}

fn superscript_device(stem: &str, prefix: &str) -> bool {
    stem.strip_prefix(prefix)
        .is_some_and(|suffix| matches!(suffix, "¹" | "²" | "³"))
}
