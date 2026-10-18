use super::launcher::Launcher;
use super::summary::Sample;
use std::process::{Command, Stdio};

pub const ITERATIONS: u32 = 30;

pub fn run(launcher: &Launcher, process: u32) -> Result<Vec<Sample>, String> {
    let repetitions = usize::try_from(ITERATIONS).unwrap_or(0);
    let input = std::fs::File::open(&launcher.input)
        .map_err(|error| format!("{}: {error}", launcher.name))?;
    let output = Command::new(&launcher.executable)
        .arg(&launcher.metadata)
        .arg(ITERATIONS.to_string())
        .env_clear()
        .stdin(Stdio::from(input))
        .output()
        .map_err(|error| format!("{}: {error}", launcher.name))?;
    let stdout = String::from_utf8_lossy(&output.stdout);
    if !output.status.success() || stdout != launcher.expected.repeat(repetitions) {
        return Err(format!(
            "{} failed verification: {}",
            launcher.name,
            String::from_utf8_lossy(&output.stderr)
        ));
    }
    parse(
        &launcher.name,
        process,
        &String::from_utf8_lossy(&output.stderr),
    )
}

pub fn parse(workload: &str, process: u32, text: &str) -> Result<Vec<Sample>, String> {
    let samples: Vec<Sample> = text
        .lines()
        .map(|line| {
            let nanoseconds: u64 = line
                .trim()
                .parse()
                .map_err(|_| format!("Invalid sample {line:?}"))?;
            Ok(Sample {
                workload: workload.to_owned(),
                process,
                nanoseconds: super::statistics::count_to_float(
                    usize::try_from(nanoseconds).unwrap_or(usize::MAX),
                ),
            })
        })
        .collect::<Result<_, String>>()?;
    if samples.len() == usize::try_from(ITERATIONS).unwrap_or(0) {
        Ok(samples)
    } else {
        Err(format!(
            "{workload}: expected {ITERATIONS} samples, got {}",
            samples.len()
        ))
    }
}
