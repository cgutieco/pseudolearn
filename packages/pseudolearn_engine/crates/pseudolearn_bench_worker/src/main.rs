#![forbid(unsafe_code)]

mod corpus;
mod e06;
mod execution;
mod frontend;
mod workloads;

fn main() -> std::process::ExitCode {
    let operation = std::env::args().nth(1).unwrap_or_default();
    let result = match operation.as_str() {
        "execute" => execution::collect(),
        "e06" => e06::collect(),
        "e06-rss" => e06::rss_child(&std::env::args().nth(2).unwrap_or_default()),
        "frontend" => frontend::collect(),
        "frontend-profile" => frontend::profile(),
        _ => Err("Usage: pseudolearn_bench_worker frontend|frontend-profile".to_owned()),
    };
    match result {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("{error}");
            std::process::ExitCode::FAILURE
        }
    }
}

#[cfg(test)]
mod frontend_tests;
#[cfg(test)]
mod workloads_tests;
