#![forbid(unsafe_code)]

mod arguments;
mod bindings;
mod commands;
mod conformance;
mod history;
mod resources;
mod storage;
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
