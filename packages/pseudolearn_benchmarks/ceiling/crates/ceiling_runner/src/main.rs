#![forbid(unsafe_code)]

mod capture;
mod collection;
mod corpus;
mod memory_report;
mod memory_worker;
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
    let mut arguments = std::env::args().skip(1);
    let command = arguments.next();
    let path = arguments
        .next()
        .unwrap_or_else(|| match command.as_deref() {
            Some("summarize-memory") => "../results/e12".to_owned(),
            Some("summarize-remanso") => "../results/e02r".to_owned(),
            Some("summarize") => "../results/e02".to_owned(),
            Some("collect-remanso") => "../results/e02r".to_owned(),
            Some("collect-memory") => "../results/e12".to_owned(),
            _ => "../results/e02".to_owned(),
        });
    match command.as_deref() {
        Some("run") => worker::run(),
        Some("run-remanso") => worker::run_remanso(),
        Some("collect-remanso") => collection::collect_remanso(std::path::Path::new(&path)),
        Some("run-memory") => memory_worker::run(),
        Some("collect-memory") => collection::collect_memory(std::path::Path::new(&path)),
        Some("summarize-memory") => memory_report::write(std::path::Path::new(&path)),
        Some("summarize-remanso") => report::write_remanso(std::path::Path::new(&path)),
        Some("collect") => collection::collect(std::path::Path::new(&path)),
        Some("summarize") => report::write(std::path::Path::new(&path)),
        _ => Err("Usage: ceiling_runner run|collect [directory]|summarize [directory]".to_owned()),
    }
}
