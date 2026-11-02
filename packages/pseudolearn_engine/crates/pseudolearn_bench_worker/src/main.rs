#![forbid(unsafe_code)]

mod aot;
mod bridge;
mod bridge_script;
mod campaign_collect;
mod campaign_summary;
mod campaign_verify;
mod campaign_workloads;
mod corpus;
mod e06;
mod execution;
mod frontend;
mod http_campaign;
mod http_growth;
mod http_summary;
mod http_workloads;
mod paired;
mod robustness;
mod service;
mod tape_collect;
mod tape_loads;
mod tasks_agendas;
mod tasks_campaign;
mod tasks_compare;
mod tasks_families;
mod tasks_summary;
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
        "pg-collect" => campaign_collect::collect(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-tape" => tape_collect::collect(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-tasks" => tasks_campaign::collect(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-summary" => campaign_summary::summarize(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-http" => http_campaign::collect(&std::env::args().skip(2).collect::<Vec<_>>()),
        "pg-http-summary" => {
            http_summary::summarize(&std::env::args().skip(2).collect::<Vec<_>>())
        }
        "pg-verify" => campaign_verify::verify(&std::env::args().nth(2).unwrap_or_default()),
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
mod campaign_summary_tests;
#[cfg(test)]
mod campaign_verify_tests;
#[cfg(test)]
mod campaign_workloads_tests;
#[cfg(test)]
mod frontend_tests;
#[cfg(test)]
mod http_campaign_tests;
#[cfg(test)]
mod http_growth_tests;
#[cfg(test)]
mod http_summary_tests;
#[cfg(test)]
mod http_workloads_tests;
#[cfg(test)]
mod tape_tests;
#[cfg(test)]
mod tasks_agendas_tests;
#[cfg(test)]
mod tasks_campaign_tests;
#[cfg(test)]
mod tasks_compare_tests;
#[cfg(test)]
mod tasks_summary_tests;
#[cfg(test)]
mod workloads_tests;

#[cfg(test)]
mod bridge_script_tests;
