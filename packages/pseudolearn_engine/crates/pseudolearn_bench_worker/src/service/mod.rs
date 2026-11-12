mod completion_quality;
mod corpus;
mod edit_session_latency;
mod help_campaign;
mod incremental_latency;
mod measurement_file;
mod precision_tally;
mod project_campaign;
mod statistics;
mod thresholds;
mod toolchain;
mod workspace_campaign;

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let argument = |slot: usize| arguments.get(slot).map(String::as_str).unwrap_or_default();
    let measurements = if argument(3).is_empty() {
        "results/measurement-conformance.json"
    } else {
        argument(3)
    };
    match argument(0) {
        "e09" => completion_quality::run(argument(1), measurements),
        "incremental" => incremental_latency::run(argument(1), measurements),
        "e20" => toolchain::run(argument(1), argument(2)),
        "help" => help_campaign::collect(arguments.get(1..).unwrap_or_default()),
        "project" => project_campaign::collect(arguments.get(1..).unwrap_or_default()),
        "workspace" => workspace_campaign::collect(arguments.get(1..).unwrap_or_default()),
        _ => Err(
            "Usage: service e09|incremental <output> [measurements] | e20 <pseudo> <output>"
                .to_owned(),
        ),
    }
}

#[cfg(test)]
mod measurement_file_tests;
#[cfg(test)]
mod statistics_tests;
#[cfg(test)]
mod thresholds_tests;
