use pseudolearn_api::NativeRunReport;
use std::io::{Result, Write};
use std::path::Path;
use std::process::{Command, Stdio};

const EFFECTS_IN_FILE: &str = "effects_in.json";
const EFFECTS_OUT_FILE: &str = "effects_out.json";

#[derive(Clone, Debug, Default)]
pub struct NativeLaunch {
    pub seed: i64,
    pub program_arguments: Vec<String>,
    pub program_directory: Option<std::path::PathBuf>,
}

pub fn run_executable(
    executable: &Path,
    working_directory: &Path,
    (inputs, effect_input): (&[String], &[u8]),
    launch: &NativeLaunch,
) -> Result<NativeRunReport> {
    let effects_in = working_directory.join(EFFECTS_IN_FILE);
    let effects_out = working_directory.join(EFFECTS_OUT_FILE);
    std::fs::write(&effects_in, effect_input)?;
    let _stale = std::fs::remove_file(&effects_out);
    let mut command = Command::new(executable);
    match &launch.program_directory {
        Some(directory) => command.current_dir(directory),
        None => command.current_dir(working_directory).env_clear(),
    };
    let mut child = command
        .arg("--effects-in")
        .arg(&effects_in)
        .arg("--effects-out")
        .arg(&effects_out)
        .arg("--semilla")
        .arg(launch.seed.to_string())
        .arg("--")
        .args(&launch.program_arguments)
        .stdin(Stdio::piped())
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()?;
    if let Some(mut pipe) = child.stdin.take() {
        let text = inputs.iter().fold(String::new(), |mut accumulated, line| {
            accumulated.push_str(line);
            accumulated.push('\n');
            accumulated
        });
        let _written = pipe.write_all(text.as_bytes());
    }
    let output = child.wait_with_output()?;
    let effects = std::fs::read(&effects_out).ok();
    let _removed_input = std::fs::remove_file(&effects_in);
    let _removed_output = std::fs::remove_file(&effects_out);
    Ok(NativeRunReport {
        exit_code: output.status.code(),
        output: String::from_utf8_lossy(&output.stdout).into_owned(),
        errors: String::from_utf8_lossy(&output.stderr).into_owned(),
        effects,
    })
}
