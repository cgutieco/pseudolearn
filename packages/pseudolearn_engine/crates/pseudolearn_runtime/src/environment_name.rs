const SENSITIVE_SUFFIXES: [&str; 4] = ["token", "key", "secret", "password"];

pub fn environment_name_is_valid(name: &str) -> bool {
    !name.is_empty() && !name.contains('=') && !name.contains('\0')
}

pub fn environment_name_is_sensitive(name: &str) -> bool {
    let lowered = name.to_ascii_lowercase();
    SENSITIVE_SUFFIXES
        .iter()
        .any(|suffix| lowered.ends_with(suffix))
}
