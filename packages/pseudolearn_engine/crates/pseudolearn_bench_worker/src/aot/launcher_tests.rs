use super::emission;
use super::launcher::prepare;
use super::measurement::run;
use super::runtime_archive;
use crate::corpus::CorpusCase;

const PROGRAM: &str = "Algoritmo P\nDefinir x Como Entero <- 6;\nEscribir x * 7;\nFinAlgoritmo\n";

fn case(expected: &str) -> CorpusCase {
    CorpusCase {
        name: "answer".to_owned(),
        source: PROGRAM.to_owned(),
        inputs: Vec::new(),
        expected_output: expected.to_owned(),
    }
}

fn workspace(label: &str) -> Result<std::path::PathBuf, String> {
    let directory = std::env::temp_dir().join(format!(
        "pseudolearn_launcher_test_{label}_{}",
        std::process::id()
    ));
    std::fs::create_dir_all(&directory).map_err(|error| error.to_string())?;
    Ok(directory)
}

#[test]
fn a_launcher_runs_the_generated_code_and_reports_every_iteration() -> Result<(), String> {
    let directory = workspace("valid")?;
    let archive = runtime_archive::build()?;
    let program = case("42\n");
    let emission = emission::measure(&program)?;
    let launcher = prepare(&program, &emission.object, (&directory, &archive))?;
    let samples = run(&launcher, 0)?;
    assert_eq!(samples.len(), 30);
    assert!(samples.iter().all(|sample| sample.nanoseconds > 0.0));
    let _removed = std::fs::remove_dir_all(directory);
    Ok(())
}

#[test]
fn a_wrong_expected_output_fails_the_verification() -> Result<(), String> {
    let directory = workspace("invalid")?;
    let archive = runtime_archive::build()?;
    let program = case("43\n");
    let emission = emission::measure(&program)?;
    let launcher = prepare(&program, &emission.object, (&directory, &archive))?;
    assert!(run(&launcher, 0).is_err());
    let _removed = std::fs::remove_dir_all(directory);
    Ok(())
}

#[test]
fn a_missing_runtime_archive_cannot_be_linked() -> Result<(), String> {
    let directory = workspace("missing")?;
    let program = case("42\n");
    let emission = emission::measure(&program)?;
    let outcome = prepare(
        &program,
        &emission.object,
        (&directory, std::path::Path::new("/nonexistent/runtime.a")),
    );
    assert!(outcome.is_err());
    let _removed = std::fs::remove_dir_all(directory);
    Ok(())
}
