use see_generators::{GenerationSeed, generate};
use see_model::contract::Vocabulary;
use serde_json::{Value, json};

fn main() -> std::process::ExitCode {
    match emit() {
        Ok(()) => std::process::ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("{error}");
            std::process::ExitCode::FAILURE
        }
    }
}

fn emit() -> Result<(), String> {
    let arguments: Vec<_> = std::env::args().skip(1).collect();
    let vocabulary = vocabulary()?;
    let result = if arguments.first().is_some_and(|word| word == "suite") {
        suite(&arguments, &vocabulary)?
    } else {
        let seed = number(&arguments, 0)?;
        let sample = u32::try_from(number(&arguments, 1)?).map_err(|error| error.to_string())?;
        let profile = arguments.get(2).ok_or("Missing profile")?;
        payload(seed, sample, profile, &vocabulary)?
    };
    println!(
        "{}",
        serde_json::to_string_pretty(&result).map_err(|error| error.to_string())?
    );
    Ok(())
}

fn suite(arguments: &[String], vocabulary: &Vocabulary) -> Result<Value, String> {
    let seed = number(arguments, 1)?;
    let samples = u32::try_from(number(arguments, 2)?).map_err(|error| error.to_string())?;
    let mut cases = Vec::new();
    for sample in 0..samples {
        for profile in ["es", "en"] {
            cases.push(payload(seed, sample, profile, vocabulary)?);
        }
    }
    Ok(Value::Array(cases))
}

fn payload(
    seed: u64,
    sample: u32,
    profile: &str,
    vocabulary: &Vocabulary,
) -> Result<Value, String> {
    let generated = generate(GenerationSeed { seed, sample }, profile, vocabulary)?;
    Ok(
        json!({"seed": seed, "sample": sample, "profile": profile, "program": generated.source, "initial": generated.initial, "elements": generated.elements, "input": generated.input}),
    )
}

fn number(arguments: &[String], index: usize) -> Result<u64, String> {
    arguments
        .get(index)
        .ok_or("Missing generation argument")?
        .parse::<u64>()
        .map_err(|error| error.to_string())
}

fn vocabulary() -> Result<Vocabulary, String> {
    let path = std::path::Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../specifications/cases/vocabulary.json");
    serde_json::from_str(&std::fs::read_to_string(path).map_err(|error| error.to_string())?)
        .map_err(|error| error.to_string())
}
