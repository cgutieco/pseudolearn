#![forbid(unsafe_code)]

mod arguments;
mod bindings;
mod commands;
mod conformance;
mod differential;
mod e10;
mod history;
mod math_contrast;
mod math_verdicts;
mod property_execution;
mod property_registry;
mod property_selection;
mod resources;
mod runtime_fixtures;
mod storage;
mod target_evidence;
mod target_parity;
mod templates;

fn main() -> std::process::ExitCode {
    match arguments::parse(std::env::args().skip(1).collect()).and_then(commands::run) {
        Ok(output) => {
            println!("{output}");
            std::process::ExitCode::SUCCESS
        }
        Err(error) => {
            eprintln!("{error}");
            std::process::ExitCode::FAILURE
        }
    }
}
