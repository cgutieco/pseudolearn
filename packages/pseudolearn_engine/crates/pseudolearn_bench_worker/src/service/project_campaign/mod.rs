mod catalogue;
pub(super) mod datasets;
mod functional;
mod lock_inputs;
mod measure;
mod modules;
mod profiles;
pub(super) mod shapes;
mod summary;
mod verification;

pub fn collect(arguments: &[String]) -> Result<(), String> {
    let argument = |slot: usize| arguments.get(slot).map(String::as_str).unwrap_or_default();
    match argument(0) {
        "functional" => functional::write(argument(1)),
        "run" => measure::run(argument(1), argument(2), argument(3)),
        "summary" => summary::write(argument(1)),
        "verify" => verification::verify(argument(1)),
        _ => Err(
            "Usage: service project functional <dir> | run profiles|project|resolution <dir> <process> | summary <dir> | verify <dir>"
                .to_owned(),
        ),
    }
}

#[cfg(test)]
mod datasets_tests;
#[cfg(test)]
mod verification_tests;
