use pseudolearn_api::ApiSession;
use serde_json::Value;
use std::io::{self, BufRead, Write};
use std::process::ExitCode;

fn main() -> ExitCode {
    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("{error}");
            ExitCode::FAILURE
        }
    }
}

fn run() -> Result<(), String> {
    let standard_input = io::stdin();
    let standard_output = io::stdout();
    let mut output = standard_output.lock();
    let mut session = ApiSession::default();
    for input_line in standard_input.lock().lines() {
        let input_line = input_line.map_err(|error| error.to_string())?;
        let (operation, arguments_json) = input_line
            .split_once('\t')
            .ok_or_else(|| "Invalid request record".to_owned())?;
        let arguments: Value =
            serde_json::from_str(arguments_json).map_err(|error| error.to_string())?;
        let response = session.call(operation, &arguments);
        let response_json = serde_json::to_string(&response).map_err(|error| error.to_string())?;
        writeln!(output, "{response_json}").map_err(|error| error.to_string())?;
    }
    Ok(())
}
