mod case;
mod clock;
mod comparison;
mod driver;
mod edge;
mod framing;
mod loads;
mod observation;
mod record;
mod run;
mod scenario;
mod selection;
mod summary;
mod transport;
mod wire;

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let argument = |slot: usize| arguments.get(slot).map(String::as_str).unwrap_or_default();
    match argument(0) {
        "plan" => driver::plan(argument(1)),
        "run" => {
            let selection = selection::Selection::parse(arguments.get(4..).unwrap_or_default())?;
            driver::run(argument(1), argument(2), argument(3), &selection)
        }
        "summary" => {
            let selection = selection::Selection::parse(arguments.get(2..).unwrap_or_default())?;
            driver::summarize_directory(argument(1), &selection)
        }
        _ => Err(
            "Usage: service workspace plan <dir> | run <dir> <pseudo> <process> [--load <name>] [--scenario <name>] | summary <dir> [--load <name>] [--scenario <name>]"
                .to_owned(),
        ),
    }
}

#[cfg(test)]
mod case_tests;
#[cfg(test)]
mod comparison_tests;
#[cfg(test)]
mod observation_tests;
#[cfg(test)]
mod record_tests;
#[cfg(test)]
mod run_tests;
#[cfg(test)]
mod selection_tests;
#[cfg(test)]
mod summary_tests;
#[cfg(test)]
mod test_support;
