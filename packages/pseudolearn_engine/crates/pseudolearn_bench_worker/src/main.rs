#![forbid(unsafe_code)]

mod aot;
mod bridge;
mod bridge_script;
mod corpus;
mod e06;
mod execution;
mod frontend;
mod paired;
mod pg_campaign;
mod pg_collect;
mod pg_http_campaign;
mod pg_http_growth;
mod pg_http_summary;
mod pg_http_workloads;
mod pg_summary;
mod pg_tape_collect;
mod pg_tape_loads;
mod pg_tasks_agendas;
mod pg_tasks_campaign;
mod pg_tasks_compare;
mod pg_tasks_families;
mod pg_tasks_summary;
mod pg_workloads;
mod robustness;
mod service;
mod workloads;

fn main() -> std::process::ExitCode {
    let operation = std::env::args().nth(1).unwrap_or_default();
    let result = match operation.as_str() {
        "execute" => execution::collect(),
        "bridge" => bridge::collect(),
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
        "aot" => collect_aot(&std::env::args().skip(2).collect::<Vec<_>>()),
        "service" => service::collect(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-collect" => pg_collect::collect(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-tape" => pg_tape_collect::collect(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-tasks" => pg_tasks_campaign::collect(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-summary" => pg_summary::summarize(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-http" => pg_http_campaign::collect(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-http-summary" => {
            pg_http_summary::summarize(&std::env::args().skip(2).collect::<Vec<_>>())
        }
        "pg-verify" => pg_campaign::verify(&std::env::args().nth(2).unwrap_or_default()),
        "frontend" => frontend::collect(),
        "frontend-profile" => frontend::profile(),
        _ => Err("Usage: pseudolearn_bench_worker frontend|frontend-profile|aot <output> <ceiling-raw.json> <vm-summary.json>".to_owned()),
    };
    match result {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("{error}");
            std::process::ExitCode::FAILURE
        }
    }
}

fn collect_aot(arguments: &[String]) -> Result<(), String> {
    let output = arguments
        .first()
        .cloned()
        .unwrap_or_else(|| "results/r6-aot".to_owned());
    let ceiling = arguments.get(1).cloned().unwrap_or_default();
    let machine = arguments.get(2).cloned().unwrap_or_default();
    if ceiling.is_empty() || machine.is_empty() {
        return Err(
            "Usage: pseudolearn_bench_worker aot <output> <ceiling-raw.json> <vm-summary.json>"
                .to_owned(),
        );
    }
    aot::collect(&output, &ceiling, &machine)
}

#[cfg(test)]
mod frontend_tests;
#[cfg(test)]
mod pg_campaign_tests;
#[cfg(test)]
mod pg_http_campaign_tests;
#[cfg(test)]
mod pg_http_growth_tests;
#[cfg(test)]
mod pg_http_summary_tests;
#[cfg(test)]
mod pg_http_workloads_tests;
#[cfg(test)]
mod pg_summary_tests;
#[cfg(test)]
mod pg_tape_tests;
#[cfg(test)]
mod pg_tasks_agendas_tests;
#[cfg(test)]
mod pg_tasks_campaign_tests;
#[cfg(test)]
mod pg_tasks_compare_tests;
#[cfg(test)]
mod pg_tasks_summary_tests;
#[cfg(test)]
mod pg_workloads_tests;
#[cfg(test)]
mod workloads_tests;

#[cfg(test)]
mod bridge_script_tests;
