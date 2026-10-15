#![forbid(unsafe_code)]

mod adapter;
mod check_command;
mod error;
mod messages;
mod options;
mod preferences_command;

use check_command::execute_check;
use error::CliError;
use messages::{help_text, missing_command, missing_input, unknown_command};
use options::parse_cli_options;
use preferences_command::execute_preferences;
use std::process::ExitCode;

fn main() -> ExitCode {
    let raw_arguments: Vec<String> = std::env::args().skip(1).collect();
    if raw_arguments.first().map(String::as_str) == Some("--see-adapter") {
        return adapter::run_see_adapter();
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
        "ejecutar" | "run" => {
            if options.positional_arguments.is_empty() {
                return Err(CliError::Usage(
                    missing_input(&options.interface_language).to_owned(),
                ));
            }
            Ok(0)
        }
        other => Err(CliError::Usage(unknown_command(
            &options.interface_language,
            other,
        ))),
    }
}
