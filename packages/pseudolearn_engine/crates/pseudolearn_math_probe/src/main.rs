#![forbid(unsafe_code)]

use std::process::ExitCode;

fn main() -> ExitCode {
    let Some(directory) = std::env::args().nth(1) else {
        eprintln!("usage: math-probe <directory>");
        return ExitCode::FAILURE;
    };
    match pseudolearn_math_probe::probe_directory(std::path::Path::new(&directory)) {
        Ok(count) => {
            println!("Evaluated {count} arguments");
            ExitCode::SUCCESS
        }
        Err(error) => {
            eprintln!("{error}");
            ExitCode::FAILURE
        }
    }
}
