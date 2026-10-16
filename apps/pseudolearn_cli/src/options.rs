#![forbid(unsafe_code)]

use crate::error::CliError;
use crate::messages::{invalid_option_value, unknown_option};
use std::path::{Path, PathBuf};

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct CliOptions {
    pub interface_language: String,
    pub command: Option<String>,
    pub positional_arguments: Vec<String>,
    pub strictness: Option<String>,
    pub vocabulary: Option<String>,
    pub json_output: bool,
    pub help_requested: bool,
    pub execution: crate::execution_options::ExecutionArguments,
}

#[derive(Default)]
struct ParsedArguments {
    command: Option<String>,
    positional_arguments: Vec<String>,
    strictness: Option<String>,
    vocabulary: Option<String>,
    json_output: bool,
    help_requested: bool,
    execution: crate::execution_options::ExecutionArguments,
}

pub fn parse_cli_options(raw_arguments: &[String]) -> Result<CliOptions, CliError> {
    let interface_language = determine_interface_language(raw_arguments);
    let mut parsed = ParsedArguments::default();
    let mut index = 0;
    while index < raw_arguments.len() {
        handle_argument_step(raw_arguments, &mut index, &interface_language, &mut parsed)?;
    }

    Ok(CliOptions {
        interface_language,
        command: parsed.command,
        positional_arguments: parsed.positional_arguments,
        strictness: parsed.strictness,
        vocabulary: parsed.vocabulary,
        json_output: parsed.json_output,
        help_requested: parsed.help_requested,
        execution: parsed.execution,
    })
}

fn handle_argument_step(
    raw_arguments: &[String],
    index: &mut usize,
    locale: &str,
    parsed: &mut ParsedArguments,
) -> Result<(), CliError> {
    let current = raw_arguments.get(*index).map_or("", String::as_str);
    match current {
        "--ayuda" | "--help" => {
            parsed.help_requested = true;
            *index = index.saturating_add(1);
            Ok(())
        }
        "--json" => {
            parsed.json_output = true;
            *index = index.saturating_add(1);
            Ok(())
        }
        "--traza" | "--trace" => {
            parsed.execution.trace = true;
            *index = index.saturating_add(1);
            Ok(())
        }
        "--idioma" | "--language" => handle_language_option(raw_arguments, index, locale),
        "--rigor" | "--strictness" => {
            handle_strictness_option(raw_arguments, index, locale, &mut parsed.strictness)
        }
        "--vocabulario" | "--vocabulary" => {
            handle_vocabulary_option(raw_arguments, index, locale, &mut parsed.vocabulary)
        }
        "--semilla" | "--seed" | "--profundidad" | "--depth" | "--sentencias" | "--statements"
        | "--celdas" | "--cells" => crate::execution_options::parse_numeric(
            raw_arguments,
            index,
            locale,
            &mut parsed.execution,
        ),
        _ => handle_positional_or_unknown(current, index, locale, parsed),
    }
}

fn handle_language_option(
    raw_arguments: &[String],
    index: &mut usize,
    locale: &str,
) -> Result<(), CliError> {
    let flag = raw_arguments.get(*index).map_or("", String::as_str);
    *index = index.saturating_add(1);
    let choice = raw_arguments.get(*index).map_or("", String::as_str);
    if choice != "es" && choice != "en" {
        return Err(CliError::Usage(invalid_option_value(locale, flag, choice)));
    }
    *index = index.saturating_add(1);
    Ok(())
}

fn handle_strictness_option(
    raw_arguments: &[String],
    index: &mut usize,
    locale: &str,
    target: &mut Option<String>,
) -> Result<(), CliError> {
    let flag = raw_arguments.get(*index).map_or("", String::as_str);
    *index = index.saturating_add(1);
    let choice = raw_arguments.get(*index).map_or("", String::as_str);
    let validated = match choice {
        "estricto" | "strict" => "strict",
        "flexible" => "flexible",
        _ => return Err(CliError::Usage(invalid_option_value(locale, flag, choice))),
    };
    *target = Some(validated.to_owned());
    *index = index.saturating_add(1);
    Ok(())
}

fn handle_vocabulary_option(
    raw_arguments: &[String],
    index: &mut usize,
    locale: &str,
    target: &mut Option<String>,
) -> Result<(), CliError> {
    let flag = raw_arguments.get(*index).map_or("", String::as_str);
    *index = index.saturating_add(1);
    let choice = raw_arguments.get(*index).map_or("", String::as_str);
    if choice != "es" && choice != "en" {
        return Err(CliError::Usage(invalid_option_value(locale, flag, choice)));
    }
    *target = Some(choice.to_owned());
    *index = index.saturating_add(1);
    Ok(())
}

fn handle_positional_or_unknown(
    current: &str,
    index: &mut usize,
    locale: &str,
    parsed: &mut ParsedArguments,
) -> Result<(), CliError> {
    *index = index.saturating_add(1);
    if current.starts_with("--") {
        return Err(CliError::Usage(unknown_option(locale, current)));
    }
    if parsed.command.is_none() {
        parsed.command = Some(current.to_owned());
        return Ok(());
    }
    parsed.positional_arguments.push(current.to_owned());
    Ok(())
}

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
    "es".to_owned()
}

fn find_language_flag(raw_arguments: &[String]) -> Option<String> {
    for (index, argument) in raw_arguments.iter().enumerate() {
        if argument == "--idioma" || argument == "--language" {
            let next_value = raw_arguments.get(index.saturating_add(1))?;
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
                return Some("en".to_owned());
            }
            if trimmed.starts_with("es") {
                return Some("es".to_owned());
            }
            return None;
        }
    }
    None
}

pub fn preference_file_path() -> Option<PathBuf> {
    if let Ok(xdg_home) = std::env::var("XDG_CONFIG_HOME")
        && !xdg_home.trim().is_empty()
    {
        return Some(
            Path::new(&xdg_home)
                .join("pseudolearn")
                .join("preferencias.toml"),
        );
    }
    if let Ok(home) = std::env::var("HOME") {
        return Some(
            Path::new(&home)
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
                return Some("en".to_owned());
            }
            if trimmed.contains("\"es\"") {
                return Some("es".to_owned());
            }
        }
    }
    None
}
