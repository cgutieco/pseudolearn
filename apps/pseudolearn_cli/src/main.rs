#![forbid(unsafe_code)]

mod adapter;
mod aot_adapter;
mod build_command;
mod check_command;
mod error;
mod execution_options;
mod ir_command;
mod messages;
mod native_cache;
mod native_linker;
mod native_run;
mod options;
mod preferences_command;
mod run_command;
mod runtime_archive;
mod trace_output;

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
        "comprobar" | "check" => execute_check(&options, &options.positional_arguments),
        "preferencias" | "preferences" => {
            execute_preferences(&options, &options.positional_arguments)
        }
        "ri" | "ir" => execute_ir(&options, &options.positional_arguments),
        "ejecutar" | "run" => run_command::execute_run(&options),
        "compilar" | "build" => build_command::execute_build(&options),
        other => Err(CliError::Usage(unknown_command(
            &options.interface_language,
            other,
        ))),
    }
}
