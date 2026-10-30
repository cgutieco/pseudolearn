#![forbid(unsafe_code)]

use crate::error::CliError;
pub use crate::locale_resolution::{determine_interface_language, preference_file_path};
use crate::messages::{invalid_option_value, unknown_option};

#[derive(Clone, Copy, Debug, Default, Eq, PartialEq)]
pub enum FormatAction {
    #[default]
    Print,
    CheckOnly,
    WriteInPlace,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct CliOptions {
    pub interface_language: String,
    pub command: Option<String>,
    pub positional_arguments: Vec<String>,
    pub strictness: Option<String>,
    pub vocabulary: Option<String>,
    pub output: Option<String>,
    pub json_output: bool,
    pub help_requested: bool,
    pub execution: crate::execution_options::ExecutionArguments,
    pub format_action: FormatAction,
    pub target_profile: Option<String>,
    pub project: crate::project_options::ProjectArguments,
}

#[derive(Default)]
struct ParsedArguments {
    command: Option<String>,
    positional_arguments: Vec<String>,
    strictness: Option<String>,
    vocabulary: Option<String>,
    output: Option<String>,
    json_output: bool,
    help_requested: bool,
    execution: crate::execution_options::ExecutionArguments,
    format_action: FormatAction,
    target_profile: Option<String>,
    project: crate::project_options::ProjectArguments,
}

pub fn parse_cli_options(raw_arguments: &[String]) -> Result<CliOptions, CliError> {
    let interface_language = determine_interface_language(raw_arguments);
    let mut parsed = ParsedArguments::default();
    let mut current_index = 0;
    while current_index < raw_arguments.len() {
        handle_argument_step(
            raw_arguments,
            &mut current_index,
            &interface_language,
            &mut parsed,
        )?;
    }

    Ok(CliOptions {
        interface_language,
        command: parsed.command,
        positional_arguments: parsed.positional_arguments,
        strictness: parsed.strictness,
        vocabulary: parsed.vocabulary,
        output: parsed.output,
        json_output: parsed.json_output,
        help_requested: parsed.help_requested,
        execution: parsed.execution,
        format_action: parsed.format_action,
        target_profile: parsed.target_profile,
        project: parsed.project,
    })
}

fn handle_argument_step(
    raw_arguments: &[String],
    current_index: &mut usize,
    locale: &str,
    parsed: &mut ParsedArguments,
) -> Result<(), CliError> {
    let current = raw_arguments.get(*current_index).map_or("", String::as_str);
    if apply_switch(current, parsed) {
        *current_index = current_index.saturating_add(1);
        return Ok(());
    }
    handle_valued_option(raw_arguments, current_index, locale, parsed)
}

fn apply_switch(flag: &str, parsed: &mut ParsedArguments) -> bool {
    match flag {
        "--ayuda" | "--help" => parsed.help_requested = true,
        "--json" => parsed.json_output = true,
        "--traza" | "--trace" => parsed.execution.trace = true,
        "--nativo" | "--native" => parsed.execution.native = true,
        "--editor" => parsed.execution.editor = true,
        "--verificar" | "--check" => parsed.format_action = FormatAction::CheckOnly,
        "--escribir" | "--write" | "-w" => parsed.format_action = FormatAction::WriteInPlace,
        _ => return false,
    }
    true
}

fn handle_valued_option(
    raw_arguments: &[String],
    current_index: &mut usize,
    locale: &str,
    parsed: &mut ParsedArguments,
) -> Result<(), CliError> {
    let current = raw_arguments.get(*current_index).map_or("", String::as_str);
    match current {
        "--idioma" | "--language" => handle_language_option(raw_arguments, current_index, locale),
        "--rigor" | "--strictness" => {
            handle_strictness_option(raw_arguments, current_index, locale, &mut parsed.strictness)
        }
        "--vocabulario" | "--vocabulary" | "--perfil" | "--profile" => {
            handle_vocabulary_option(raw_arguments, current_index, locale, &mut parsed.vocabulary)
        }
        "--hacia" | "--to" => handle_target_profile_option(
            raw_arguments,
            current_index,
            locale,
            &mut parsed.target_profile,
        ),
        "-o" | "--salida" | "--output" => {
            handle_output_option(raw_arguments, current_index, locale, &mut parsed.output)
        }
        "--semilla" | "--seed" | "--profundidad" | "--depth" | "--sentencias" | "--statements"
        | "--celdas" | "--cells" | "--tareas" | "--tasks" | "--grabar-cinta" | "--record-tape"
        | "--reproducir-cinta" | "--replay-tape" | "--conceder" | "--grant" | "--archivos"
        | "--files" | "--origen" | "--origin" | "--origen-local" | "--local-origin"
        | "--raiz-prueba" | "--test-root" => {
            handle_execution_option(raw_arguments, current_index, locale, parsed)
        }
        "--proyecto" | "--project" | "--entrada" | "--entry" => {
            handle_project_option(raw_arguments, current_index, locale, parsed)
        }
        _ => handle_positional_or_unknown(current, current_index, locale, parsed),
    }
}

fn handle_execution_option(
    raw_arguments: &[String],
    current_index: &mut usize,
    locale: &str,
    parsed: &mut ParsedArguments,
) -> Result<(), CliError> {
    let current = raw_arguments.get(*current_index).map_or("", String::as_str);
    match current {
        "--grabar-cinta" | "--record-tape" | "--reproducir-cinta" | "--replay-tape" => {
            crate::execution_options::parse_tape_option(
                raw_arguments,
                current_index,
                locale,
                &mut parsed.execution,
            )
        }
        "--conceder" | "--grant" | "--archivos" | "--files" => {
            crate::execution_options::parse_grant_option(
                raw_arguments,
                current_index,
                locale,
                &mut parsed.execution,
            )
        }
        "--origen" | "--origin" | "--origen-local" | "--local-origin" | "--raiz-prueba"
        | "--test-root" => crate::execution_options::parse_network_option(
            raw_arguments,
            current_index,
            locale,
            &mut parsed.execution,
        ),
        _ => crate::execution_options::parse_numeric(
            raw_arguments,
            current_index,
            locale,
            &mut parsed.execution,
        ),
    }
}

fn handle_project_option(
    raw_arguments: &[String],
    current_index: &mut usize,
    locale: &str,
    parsed: &mut ParsedArguments,
) -> Result<(), CliError> {
    crate::project_options::parse_project_option(
        raw_arguments,
        current_index,
        locale,
        &mut parsed.project,
    )
}

fn handle_language_option(
    raw_arguments: &[String],
    current_index: &mut usize,
    locale: &str,
) -> Result<(), CliError> {
    let flag = raw_arguments.get(*current_index).map_or("", String::as_str);
    *current_index = current_index.saturating_add(1);
    let choice = raw_arguments.get(*current_index).map_or("", String::as_str);
    if choice != "es" && choice != "en" {
        return Err(CliError::Usage(invalid_option_value(locale, flag, choice)));
    }
    *current_index = current_index.saturating_add(1);
    Ok(())
}

fn handle_strictness_option(
    raw_arguments: &[String],
    current_index: &mut usize,
    locale: &str,
    target: &mut Option<String>,
) -> Result<(), CliError> {
    let flag = raw_arguments.get(*current_index).map_or("", String::as_str);
    *current_index = current_index.saturating_add(1);
    let choice = raw_arguments.get(*current_index).map_or("", String::as_str);
    let validated = match choice {
        "estricto" | "strict" => "strict",
        "flexible" => "flexible",
        _ => return Err(CliError::Usage(invalid_option_value(locale, flag, choice))),
    };
    *target = Some(validated.to_owned());
    *current_index = current_index.saturating_add(1);
    Ok(())
}

fn handle_vocabulary_option(
    raw_arguments: &[String],
    current_index: &mut usize,
    locale: &str,
    target: &mut Option<String>,
) -> Result<(), CliError> {
    let flag = raw_arguments.get(*current_index).map_or("", String::as_str);
    *current_index = current_index.saturating_add(1);
    let choice = raw_arguments.get(*current_index).map_or("", String::as_str);
    if choice != "es" && choice != "en" {
        return Err(CliError::Usage(invalid_option_value(locale, flag, choice)));
    }
    *target = Some(choice.to_owned());
    *current_index = current_index.saturating_add(1);
    Ok(())
}

fn handle_target_profile_option(
    raw_arguments: &[String],
    current_index: &mut usize,
    locale: &str,
    target: &mut Option<String>,
) -> Result<(), CliError> {
    let flag = raw_arguments.get(*current_index).map_or("", String::as_str);
    *current_index = current_index.saturating_add(1);
    let choice = raw_arguments.get(*current_index).map_or("", String::as_str);
    if choice != "es" && choice != "en" {
        return Err(CliError::Usage(invalid_option_value(locale, flag, choice)));
    }
    *target = Some(choice.to_owned());
    *current_index = current_index.saturating_add(1);
    Ok(())
}

fn handle_output_option(
    raw_arguments: &[String],
    current_index: &mut usize,
    locale: &str,
    target: &mut Option<String>,
) -> Result<(), CliError> {
    let flag = raw_arguments.get(*current_index).map_or("", String::as_str);
    *current_index = current_index.saturating_add(1);
    let choice = raw_arguments.get(*current_index).map_or("", String::as_str);
    if choice.is_empty() || choice.starts_with("--") {
        return Err(CliError::Usage(invalid_option_value(locale, flag, choice)));
    }
    *target = Some(choice.to_owned());
    *current_index = current_index.saturating_add(1);
    Ok(())
}

fn handle_positional_or_unknown(
    current: &str,
    current_index: &mut usize,
    locale: &str,
    parsed: &mut ParsedArguments,
) -> Result<(), CliError> {
    *current_index = current_index.saturating_add(1);
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
