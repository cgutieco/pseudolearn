#![forbid(unsafe_code)]

mod capture;
mod collection;
mod corpus;
mod report;
mod worker;

fn main() -> std::process::ExitCode {
    match dispatch() {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("{error}");
            std::process::ExitCode::FAILURE
        }
    }
}

fn dispatch() -> Result<(), String> {
    match std::env::args().nth(1).as_deref() {
        Some("run") => worker::run(),
        Some("collect") => collection::collect(),
        Some("summarize") => report::write(std::path::Path::new("../results/e02")),
        _ => Err("Usage: ceiling_runner run|collect|summarize".to_owned()),
    }
}
