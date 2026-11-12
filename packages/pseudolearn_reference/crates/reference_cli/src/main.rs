#![forbid(unsafe_code)]

mod book;
mod bundle_files;
mod checks;
mod commands;
mod links;
mod route_book;
mod route_checks;
mod route_coverage;
mod route_workspace;
mod web_bundles;
mod workspace;
mod workspace_files;

fn main() -> std::process::ExitCode {
    let arguments: Vec<String> = std::env::args().skip(1).collect();
    match commands::run(&arguments) {
        Ok(true) => std::process::ExitCode::SUCCESS,
        Ok(false) => std::process::ExitCode::from(1),
        Err(error) => {
            eprintln!("reference: {error}");
            std::process::ExitCode::from(2)
        }
    }
}

#[cfg(test)]
mod bundle_files_tests;
#[cfg(test)]
mod commands_tests;
#[cfg(test)]
mod web_bundles_tests;
#[cfg(test)]
mod workspace_tests;
