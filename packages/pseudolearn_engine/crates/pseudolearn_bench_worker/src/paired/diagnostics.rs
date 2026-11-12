use crate::corpus::CorpusCase;
use pseudolearn_api::{ExecuteRequest, build_benchmark_object, conformance_build_request};
use serde_json::{Value, json};
use std::path::Path;
use std::process::{Command, Stdio};

pub fn collect(output: &str) -> Result<(), String> {
    let directory = Path::new(output);
    if output.is_empty() || directory.exists() {
        return Err("Output must be new".to_owned());
    }
    std::fs::create_dir_all(directory).map_err(|error| error.to_string())?;
    super::storage::write(
        &directory.join("capture.json"),
        &super::provenance::describe()?,
    )?;
    let archive = super::storage::telemetry_archive()?;
    let mut records = Vec::new();
    for case in crate::corpus::awfy_cases()?.into_iter().filter(|case| {
        [
            "storage",
            "sieve",
            "queens",
            "nbody",
            "permute",
            "mandelbrot",
        ]
        .contains(&case.name.as_str())
    }) {
        records.extend(measure_scales(&case, directory, &archive)?);
    }
    super::storage::write(
        &directory.join("diagnostics.json"),
        &json!({"normative":false,"records":records}),
    )
}

fn measure(case: &CorpusCase, directory: &Path, archive: &Path) -> Result<Value, String> {
    let request = conformance_build_request(&ExecuteRequest {
        program: case.source.clone(),
        ..Default::default()
    });
    let object = build_benchmark_object(&request).map_err(|error| format!("{error:?}"))?;
    let workspace = super::Scratch(
        std::env::temp_dir().join(format!("pseudolearn_diagnostic_{}", std::process::id())),
    );
    let launcher = super::launcher::build(case, &object, (&workspace.0, archive))?;
    let pairs = super::launcher::run(&launcher, 0)?;
    let inspection = super::inspection::save(case, directory, &launcher.folder.join("program.o"))?;
    if case.name == "storage" && case.inputs.first().map(String::as_str) == Some("6") {
        profile(&launcher, &directory.join("storage-profile.txt"))?;
    }
    Ok(json!({"workload":case.name,"inputs":case.inputs,"pairs":pairs,"inspection":inspection}))
}

fn profile(launcher: &super::launcher::Launcher, path: &Path) -> Result<(), String> {
    let mut configuration = launcher.configuration.clone();
    configuration
        .as_object_mut()
        .ok_or("Invalid configuration")?
        .insert("iterations".to_owned(), json!(10000));
    let config_path = launcher.folder.join("profile.json");
    super::storage::write(&config_path, &configuration)?;
    let output_path = path.with_extension("json");
    let output = std::fs::File::create(&output_path).map_err(|error| error.to_string())?;
    let mut child = Command::new(&launcher.executable)
        .arg(&config_path)
        .stdout(Stdio::from(output))
        .stderr(Stdio::piped())
        .spawn()
        .map_err(|error| error.to_string())?;
    let sampled = Command::new("sample")
        .args([
            child.id().to_string(),
            "2".to_owned(),
            "1".to_owned(),
            "-file".to_owned(),
            path.display().to_string(),
        ])
        .output()
        .map_err(|error| error.to_string())?;
    let status = child.wait().map_err(|error| error.to_string())?;
    if !sampled.status.success() || !status.success() {
        return Err(format!(
            "Profiling failed: {}",
            String::from_utf8_lossy(&sampled.stderr)
        ));
    }
    Ok(())
}

fn measure_scales(
    case: &CorpusCase,
    directory: &Path,
    archive: &Path,
) -> Result<Vec<Value>, String> {
    let mut records = Vec::new();
    let scales: &[i64] = if case.name == "storage" {
        &[3, 4, 5, 6]
    } else {
        &[]
    };
    if scales.is_empty() {
        records.push(measure(case, directory, archive)?);
    }
    for scale in scales {
        let scaled = CorpusCase {
            name: case.name.clone(),
            source: case.source.clone(),
            inputs: vec![scale.to_string()],
            expected_output: format!(
                "{}\n",
                4_i64
                    .checked_pow(u32::try_from(*scale).map_err(|error| error.to_string())?)
                    .and_then(|count| count.checked_sub(1))
                    .and_then(|count| count.checked_div(3))
                    .ok_or("Invalid storage scale")?
            ),
        };
        records.push(measure(
            &scaled,
            &directory.join(format!("scale-{scale}")),
            archive,
        )?);
    }
    Ok(records)
}
