use pseudolearn_api::{
    AnalyzeRequest, ExecuteRequest, TargetLanguage, equivalent_code, execute_program,
};
use serde_json::Value;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::time::{Duration, Instant};

struct Sample {
    identity: String,
    profile: String,
    program: String,
    output: String,
}

fn samples(path: &Path) -> Vec<Sample> {
    let text = std::fs::read_to_string(path).unwrap_or_default();
    let mut found = Vec::new();
    for block in text.split("```caso\n").skip(1) {
        let Some(json) = block.split("\n```").next() else {
            continue;
        };
        let Ok(case) = serde_json::from_str::<Value>(json) else {
            continue;
        };
        if case.get("operacion").and_then(Value::as_str) != Some("execute")
            || case.get("entradas").is_some()
        {
            continue;
        }
        let identity = case.get("id").and_then(Value::as_str).unwrap_or_default();
        let Some(programs) = case.get("programas").and_then(Value::as_object) else {
            continue;
        };
        for (profile, program) in programs {
            let program = program.as_str().unwrap_or_default().to_owned();
            let request = ExecuteRequest {
                program: program.clone(),
                profile: profile.clone(),
                ..Default::default()
            };
            let response = execute_program(&request);
            if response.termination.get("kind").and_then(Value::as_str) != Some("completed") {
                continue;
            }
            found.push(Sample {
                identity: format!(
                    "{}:{identity}:{profile}",
                    path.file_stem()
                        .and_then(|stem| stem.to_str())
                        .unwrap_or_default()
                ),
                profile: profile.clone(),
                program,
                output: response.output,
            });
        }
    }
    found
}

fn run_with_timeout(command: &mut Command) -> Option<String> {
    let mut child = command
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .ok()?;
    let started = Instant::now();
    loop {
        if child.try_wait().ok()?.is_some() {
            let output = child.wait_with_output().ok()?;
            let mut text = String::from_utf8_lossy(&output.stdout).into_owned();
            if !output.status.success() {
                text.push_str(&format!(
                    "\n<<failed: {}>>",
                    String::from_utf8_lossy(&output.stderr)
                ));
            }
            return Some(text);
        }
        if started.elapsed() > Duration::from_secs(20) {
            let _ = child.kill();
            return Some("<<timeout>>".to_owned());
        }
        std::thread::sleep(Duration::from_millis(5));
    }
}

fn translated_output(
    sample: &Sample,
    target: TargetLanguage,
    directory: &Path,
    index: usize,
) -> Result<String, String> {
    let request = AnalyzeRequest {
        program: sample.program.clone(),
        profile: sample.profile.clone(),
        source: None,
    };
    let result = equivalent_code(&request, target, Some(0));
    match result.get("status").and_then(Value::as_str) {
        Some("ready") => {}
        Some("unavailable") => {
            let constructs = result
                .get("blockers")
                .and_then(Value::as_array)
                .map(|items| {
                    items
                        .iter()
                        .filter_map(|entry| entry.get("construct").and_then(Value::as_str))
                        .collect::<Vec<_>>()
                        .join(",")
                });
            return Err(format!("UNAVAILABLE {}", constructs.unwrap_or_default()));
        }
        other => return Err(format!("STATUS {other:?}")),
    }
    let code = result
        .get("code")
        .and_then(Value::as_str)
        .unwrap_or_default();
    match target {
        TargetLanguage::Rust => {
            let source = directory.join(format!("case{index}.rs"));
            let binary = directory.join(format!("case{index}"));
            std::fs::write(&source, code).map_err(|error| error.to_string())?;
            let compiled = Command::new("rustc")
                .args([
                    "--edition",
                    "2024",
                    "-A",
                    "warnings",
                    "-C",
                    "debuginfo=0",
                    "-o",
                ])
                .arg(&binary)
                .arg(&source)
                .output()
                .map_err(|error| error.to_string())?;
            if !compiled.status.success() {
                return Err(format!(
                    "COMPILE {}",
                    String::from_utf8_lossy(&compiled.stderr)
                        .lines()
                        .take(12)
                        .collect::<Vec<_>>()
                        .join("\n")
                ));
            }
            let output =
                run_with_timeout(&mut Command::new(&binary)).ok_or_else(|| "RUN".to_owned());
            let _ = std::fs::remove_file(&binary);
            output
        }
        TargetLanguage::Python => {
            let source = directory.join(format!("case{index}.py"));
            std::fs::write(&source, code).map_err(|error| error.to_string())?;
            run_with_timeout(Command::new("python3.11").arg("-I").arg(&source))
                .ok_or_else(|| "RUN".to_owned())
        }
    }
}

#[test]
#[ignore]
fn translations_reproduce_engine_output() {
    let files: Vec<PathBuf> = std::env::var("SWEEP_FILES")
        .unwrap_or_default()
        .split(':')
        .filter(|entry| !entry.is_empty())
        .map(PathBuf::from)
        .collect();
    let target = std::env::var("SWEEP_TARGET")
        .ok()
        .and_then(|identity| TargetLanguage::from_identity(&identity))
        .unwrap_or(TargetLanguage::Rust);
    let directory = PathBuf::from(
        std::env::var("SWEEP_DIRECTORY")
            .unwrap_or_else(|_| std::env::temp_dir().display().to_string()),
    );
    let _ = std::fs::create_dir_all(&directory);
    let all: Vec<Sample> = files.iter().flat_map(|file| samples(file)).collect();
    let workers = 8;
    let reports: Vec<String> = std::thread::scope(|scope| {
        let handles: Vec<_> = (0..workers)
            .map(|worker| {
                let all = &all;
                let directory = &directory;
                scope.spawn(move || {
                    let mut reports = Vec::new();
                    for (index, sample) in all
                        .iter()
                        .enumerate()
                        .filter(|(index, _)| index % workers == worker)
                    {
                        let report = match translated_output(sample, target, directory, index) {
                            Ok(output) if output == sample.output => {
                                format!("PASS {}", sample.identity)
                            }
                            Ok(output) => format!(
                                "DIFF {}\n--- program\n{}--- expected\n{:?}\n--- actual\n{:?}",
                                sample.identity, sample.program, sample.output, output
                            ),
                            Err(reason) => format!(
                                "FAIL {} {reason}\n--- program\n{}",
                                sample.identity, sample.program
                            ),
                        };
                        reports.push(report);
                    }
                    reports
                })
            })
            .collect();
        handles
            .into_iter()
            .flat_map(|handle| handle.join().unwrap_or_default())
            .collect()
    });
    let passed = reports
        .iter()
        .filter(|report| report.starts_with("PASS"))
        .count();
    let summary = format!("passed {passed} of {}", reports.len());
    let report_path = directory.join("report.txt");
    let _ = std::fs::write(
        &report_path,
        format!("{summary}\n\n{}", reports.join("\n\n")),
    );
    println!("{summary}");
}
