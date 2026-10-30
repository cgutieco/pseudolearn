#![forbid(unsafe_code)]

mod adapter;
mod adapter_ir;
mod aot_adapter;
mod build_command;
mod check_command;
mod confined_sources;
mod editor_command;
mod editor_protocol;
mod editor_session;
mod error;
mod execution_options;
mod format_command;
mod ir_command;
mod locale_resolution;
mod lock_command;
mod lsp_command;
mod lsp_framing;
mod lsp_transport_state;
mod messages;
mod native_cache;
mod native_linker;
mod native_run;
mod native_run_command;
mod options;
mod physical_error;
mod physical_files;
mod physical_host;
mod physical_network;
pub mod physical_network_address;
mod physical_network_batch;
mod physical_network_body;
pub mod physical_network_resolver;
mod physical_network_send;
pub mod physical_network_tls;
mod physical_network_transport;
mod physical_network_transport_support;
mod physical_request;
mod physical_session;
mod preferences_command;
mod project_build;
mod project_command;
mod project_files;
mod project_options;
mod project_report;
mod project_session;
mod run_command;
mod runtime_archive;
mod tape_files;
mod trace_output;
mod translate_command;

#[cfg(test)]
mod confined_sources_tests;
#[cfg(test)]
mod editor_command_tests;
#[cfg(test)]
mod editor_protocol_tests;
#[cfg(test)]
mod editor_session_tests;
#[cfg(test)]
mod lsp_command_tests;
#[cfg(test)]
mod lsp_framing_tests;
#[cfg(test)]
mod network_address_policy_tests;
#[cfg(test)]
mod network_resolver_tests;
#[cfg(test)]
mod network_tls_tests;
#[cfg(test)]
mod physical_host_tests;
#[cfg(test)]
mod physical_network_body_tests;
#[cfg(test)]
mod physical_network_send_tests;
#[cfg(test)]
mod physical_network_stream_tests;
#[cfg(test)]
mod physical_network_tests;
#[cfg(test)]
mod physical_network_tls_send_tests;

use check_command::execute_check;
use error::CliError;
use ir_command::execute_ir;
use messages::{help_text, missing_command, unknown_command};
use options::parse_cli_options;
use preferences_command::execute_preferences;
use std::process::ExitCode;

fn main() -> ExitCode {
    let raw_arguments: Vec<String> = std::env::args().skip(1).collect();
    if raw_arguments.first().map(String::as_str) == Some("--see-adapter") {
        return match raw_arguments.get(1).map(String::as_str) {
            Some("aot") => aot_adapter::run_aot_adapter(),
            _ => adapter::run_see_adapter(),
        };
    }
    match dispatch(&raw_arguments) {
        Ok(code) => {
            let exit_u8 = u8::try_from(code).unwrap_or(1);
            ExitCode::from(exit_u8)
        }
        Err(error) => {
            let exit_number = error.exit_code();
            match error {
                CliError::Usage(message) | CliError::Operational(message) => {
                    eprint!("{message}");
                }
            }
            ExitCode::from(exit_number)
        }
    }
}

fn dispatch(raw_arguments: &[String]) -> Result<i32, CliError> {
    let options = parse_cli_options(raw_arguments)?;
    if options.help_requested {
        print!("{}", help_text(&options.interface_language));
        return Ok(0);
    }
    let command_name = match &options.command {
        Some(cmd) => cmd.as_str(),
        None => {
            return Err(CliError::Usage(
                missing_command(&options.interface_language).to_owned(),
            ));
        }
    };
    match command_name {
        "comprobar" | "check" if is_project(&options) => project_command::execute_check(&options),
        "comprobar" | "check" => execute_check(&options, &options.positional_arguments),
        "preferencias" | "preferences" => {
            execute_preferences(&options, &options.positional_arguments)
        }
        "ri" | "ir" => execute_ir(&options, &options.positional_arguments),
        "bloquear" | "lock" => lock_command::execute_lock(&options),
        "ejecutar" | "run" if options.execution.editor => editor_command::execute_editor(&options),
        "ejecutar" | "run" if is_project(&options) => project_command::execute_run(&options),
        "ejecutar" | "run" => run_command::execute_run(&options),
        "compilar" | "build" if is_project(&options) => project_build::execute_build(&options),
        "compilar" | "build" => build_command::execute_build(&options),
        "formatear" | "format" => format_command::execute_format(&options),
        "traducir" | "translate" => translate_command::execute_translate(&options),
        "lsp" => Ok(lsp_command::execute_lsp(&options)),
        other => Err(CliError::Usage(unknown_command(
            &options.interface_language,
            other,
        ))),
    }
}

fn is_project(options: &options::CliOptions) -> bool {
    options.project.directory.is_some()
}
