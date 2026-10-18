#![forbid(unsafe_code)]

mod aot;
mod corpus;
mod e06;
mod execution;
mod frontend;
mod paired;
mod robustness;
mod workloads;

fn main() -> std::process::ExitCode {
    let operation = std::env::args().nth(1).unwrap_or_default();
    let result = match operation.as_str() {
        "execute" => execution::collect(),
        "e06" => e06::collect(),
        "e06-rss" => e06::rss_child(&std::env::args().nth(2).unwrap_or_default()),
        "robust" => robustness::collect(),
        "robust-child" => robustness::child(),
        "paired-probe" => {
            paired::diagnostics::collect(&std::env::args().nth(2).unwrap_or_default())
        }
        "paired-summary" => {
            paired::summarize_existing(&std::env::args().nth(2).unwrap_or_default())
        }
        "paired" => paired::collect(&std::env::args().nth(2).unwrap_or_default()),
        "aot" => aot::collect(
            &std::env::args()
                .nth(2)
                .unwrap_or_else(|| "results/r6-aot".to_owned()),
        ),
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
