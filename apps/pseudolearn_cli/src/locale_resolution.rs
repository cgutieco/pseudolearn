use std::path::{Path, PathBuf};

pub fn determine_interface_language(raw_arguments: &[String]) -> String {
    if let Some(explicit) = find_language_flag(raw_arguments) {
        return explicit;
    }
    if let Some(variable_language) = check_environment_language() {
        return variable_language;
    }
    if let Some(preference_language) = read_preference_language() {
        return preference_language;
    }
    if let Some(system_language) = check_system_language() {
        return system_language;
    }
    String::from("es")
}

fn find_language_flag(raw_arguments: &[String]) -> Option<String> {
    for (position, argument) in raw_arguments.iter().enumerate() {
        if argument == "--idioma" || argument == "--language" {
            let next_index = position.saturating_add(1);
            let next_value = raw_arguments.get(next_index)?;
            if next_value == "es" || next_value == "en" {
                return Some(next_value.clone());
            }
        }
    }
    None
}

fn check_environment_language() -> Option<String> {
    for variable_name in ["PSEUDO_IDIOMA", "PSEUDO_LANGUAGE"] {
        if let Ok(variable_value) = std::env::var(variable_name) {
            let trimmed = variable_value.trim();
            if trimmed == "es" || trimmed == "en" {
                return Some(trimmed.to_owned());
            }
        }
    }
    None
}

fn check_system_language() -> Option<String> {
    for variable_name in ["LC_ALL", "LC_MESSAGES", "LANG"] {
        if let Ok(variable_value) = std::env::var(variable_name) {
            let trimmed = variable_value.trim();
            if trimmed.is_empty() {
                continue;
            }
            if trimmed.starts_with("en") {
                return Some(String::from("en"));
            }
            if trimmed.starts_with("es") {
                return Some(String::from("es"));
            }
            return None;
        }
    }
    None
}

pub fn preference_file_path() -> Option<PathBuf> {
    if let Ok(config_home) = std::env::var("XDG_CONFIG_HOME")
        && !config_home.trim().is_empty()
    {
        return Some(
            Path::new(&config_home)
                .join("pseudolearn")
                .join("preferencias.toml"),
        );
    }
    if let Ok(user_home) = std::env::var("HOME") {
        return Some(
            Path::new(&user_home)
                .join(".config")
                .join("pseudolearn")
                .join("preferencias.toml"),
        );
    }
    None
}

fn read_preference_language() -> Option<String> {
    let preference_path = preference_file_path()?;
    let content = std::fs::read_to_string(preference_path).ok()?;
    for line in content.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("idioma") {
            if trimmed.contains("\"en\"") {
                return Some(String::from("en"));
            }
            if trimmed.contains("\"es\"") {
                return Some(String::from("es"));
            }
        }
    }
    None
}
