use crate::corpus::CorpusCase;
use pseudolearn_api::BenchmarkObject;
use serde_json::{Value, json};
use std::path::{Path, PathBuf};
use std::process::Command;

pub struct Launcher {
    pub executable: PathBuf,
    pub configuration: Value,
    pub folder: PathBuf,
}

pub fn build(
    case: &CorpusCase,
    object: &BenchmarkObject,
    paths: (&Path, &Path),
) -> Result<Launcher, String> {
    let folder = paths.0.join(&case.name);
    std::fs::create_dir_all(&folder).map_err(|error| error.to_string())?;
    let source =
        include_str!("launcher.c.template").replace("@@ENTRY_SYMBOL@@", &object.entry_symbol);
    let source_path = folder.join("launcher.c");
    let object_path = folder.join("program.o");
    std::fs::write(&source_path, source).map_err(|error| error.to_string())?;
    std::fs::write(&object_path, &object.bytes).map_err(|error| error.to_string())?;
    let executable = folder.join("launcher");
    let output = Command::new("cc")
        .arg("-O2")
        .arg("-o")
        .arg(&executable)
        .args([&source_path, &object_path, &paths.1.to_path_buf()])
        .arg("-lm")
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    let size = size_of(case)?;
    Ok(Launcher {
        executable,
        folder,
        configuration: configuration(case, object, size),
    })
}

fn size_of(case: &CorpusCase) -> Result<i64, String> {
    case.inputs
        .first()
        .ok_or("Missing size")?
        .parse()
        .map_err(|error| format!("{error}"))
}

fn configuration(case: &CorpusCase, object: &BenchmarkObject, size: i64) -> Value {
    json!({"workload":case.name,"source":case.source,"size":size,
        "input":case.inputs.iter().map(|line| format!("{line}\n")).collect::<String>(),
        "expected":case.expected_output,"metadata":object.metadata,"process":0,"iterations":30})
}

pub fn run(launcher: &Launcher, process: u32) -> Result<Vec<Value>, String> {
    let mut configuration = launcher.configuration.clone();
    configuration
        .as_object_mut()
        .ok_or("Invalid configuration")?
        .insert("process".to_owned(), json!(process));
    let pairs = run_configuration(launcher, &configuration)?;
    super::validation::pairs(&pairs, process)?;
    Ok(pairs)
}

fn run_configuration(launcher: &Launcher, configuration: &Value) -> Result<Vec<Value>, String> {
    let path = launcher.folder.join("configuration.json");
    super::storage::write(&path, configuration)?;
    let output = Command::new(&launcher.executable)
        .arg(&path)
        .env_clear()
        .output()
        .map_err(|error| error.to_string())?;
    if !output.status.success() {
        return Err(String::from_utf8_lossy(&output.stderr).into_owned());
    }
    let pairs: Vec<Value> =
        serde_json::from_slice(&output.stdout).map_err(|error| error.to_string())?;
    Ok(pairs)
}

pub fn verify(launcher: &Launcher) -> Result<(), String> {
    let mut configuration = launcher.configuration.clone();
    configuration
        .as_object_mut()
        .ok_or("Invalid configuration")?
        .insert("iterations".to_owned(), json!(1));
    if run_configuration(launcher, &configuration)?.len() != 1 {
        return Err("Invalid verification response".to_owned());
    }
    Ok(())
}
