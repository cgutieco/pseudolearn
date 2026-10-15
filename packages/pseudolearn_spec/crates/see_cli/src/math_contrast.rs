use crate::arguments::Arguments;
use see_conformance::math_arguments::{MATH_FUNCTIONS, MathFunction, arguments};
use see_conformance::math_contrast::{format_arguments, parse_arguments, parse_outcome};
use serde_json::{Value, json};
use std::path::{Path, PathBuf};

const DEFAULT_COUNT: usize = 1_000_000;
const DEFAULT_SEED: u64 = 20_261_015;
const MANIFEST: &str = "manifest.json";

pub fn dispatch(options: &Arguments) -> Option<Result<String, String>> {
    match options.command.as_str() {
        "math-arguments" => Some(generate(options)),
        "math-check" => Some(check(options)),
        _ => None,
    }
}

fn generate(options: &Arguments) -> Result<String, String> {
    let output = directory(options, "output")?;
    let count = number(options, "count", DEFAULT_COUNT)?;
    let seed = u64::try_from(number(
        options,
        "seed",
        usize::try_from(DEFAULT_SEED).map_err(|error| error.to_string())?,
    )?)
    .map_err(|error| error.to_string())?;
    std::fs::create_dir_all(&output).map_err(|error| error.to_string())?;
    for function in MATH_FUNCTIONS {
        let lines = arguments(function, count, seed)
            .iter()
            .map(|entry| format_arguments(entry))
            .collect::<Vec<_>>()
            .join("\n");
        write(
            &output.join(format!("{}.arguments", function.name())),
            &lines,
        )?;
    }
    let manifest = json!({"seed": seed, "countPerFunction": count, "functions": MATH_FUNCTIONS.map(MathFunction::name)});
    write(&output.join(MANIFEST), &manifest.to_string())?;
    Ok(format!(
        "Generated {count} arguments per function in {}",
        output.display()
    ))
}

fn check(options: &Arguments) -> Result<String, String> {
    let input = directory(options, "input")?;
    let manifest: Value = crate::storage::read_json(&input.join(MANIFEST))?;
    let mut functions = serde_json::Map::new();
    let mut mismatched = 0_usize;
    for function in MATH_FUNCTIONS {
        let rows = rows(&input, function)?;
        let summary = crate::math_verdicts::compare(function, &rows)?;
        mismatched = mismatched.saturating_add(summary.mismatches.len());
        functions.insert(function.name().to_owned(), summary.to_json());
    }
    let report = json!({
        "contract": "LIB.CORE.MATH#R1, LANG.OPS.POWER, LANG.TYPES.REAL",
        "oracle": "see_oracles rational enclosure with exact dyadic powers",
        "subject": "pseudolearn_library through pseudolearn_math_probe",
        "revision": crate::e10::revision(&options.root)?.trim(),
        "seed": manifest.get("seed"),
        "countPerFunction": manifest.get("countPerFunction"),
        "functions": functions,
        "allMatch": mismatched == 0,
    });
    crate::storage::artifact(
        &options.root.join("results/r5-math-contrast.json"),
        &report,
        false,
    )?;
    if mismatched == 0 {
        Ok("Math contrast matched every argument".to_owned())
    } else {
        Err(format!("Math contrast found {mismatched} mismatches"))
    }
}

fn rows(input: &Path, function: MathFunction) -> Result<Vec<crate::math_verdicts::Row>, String> {
    let arguments = read(&input.join(format!("{}.arguments", function.name())))?;
    let results = read(&input.join(format!("{}.results", function.name())))?;
    if arguments.lines().count() != results.lines().count() {
        return Err(format!(
            "{}: argument and result counts differ",
            function.name()
        ));
    }
    arguments
        .lines()
        .zip(results.lines())
        .map(|(argument, result)| {
            let values = parse_arguments(argument)?;
            if values.len() != function.arity() {
                return Err(format!("{}: wrong argument count", function.name()));
            }
            Ok(crate::math_verdicts::Row {
                arguments: values,
                engine: parse_outcome(result.trim())?,
            })
        })
        .collect()
}

fn directory(options: &Arguments, name: &str) -> Result<PathBuf, String> {
    options
        .options
        .get(name)
        .map(PathBuf::from)
        .ok_or(format!("Missing --{name} directory"))
}

fn number(options: &Arguments, name: &str, default: usize) -> Result<usize, String> {
    options.options.get(name).map_or(Ok(default), |text| {
        text.parse::<usize>()
            .map_err(|error| format!("--{name}: {error}"))
    })
}

fn read(path: &Path) -> Result<String, String> {
    std::fs::read_to_string(path).map_err(|error| format!("{}: {error}", path.display()))
}

fn write(path: &Path, text: &str) -> Result<(), String> {
    std::fs::write(path, format!("{text}\n"))
        .map_err(|error| format!("{}: {error}", path.display()))
}
