mod completion_quality;
mod corpus;
mod incremental_latency;
mod measurement_file;
mod precision_tally;
mod statistics;
mod thresholds;
mod toolchain;

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let argument = |slot: usize| arguments.get(slot).map(String::as_str).unwrap_or_default();
    let measurements = if argument(3).is_empty() {
        "../pseudolearn_spec/results/measurement-conformance.json"
    } else {
        argument(3)
    };
    match argument(0) {
        "e09" => completion_quality::run(argument(1), measurements),
        "incremental" => incremental_latency::run(argument(1), measurements),
        "e20" => toolchain::run(argument(1), argument(2)),
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
